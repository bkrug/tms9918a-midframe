       DEF  block_vdp_interrupt             *BLWP
       DEF  unblock_vdp_interrupt           *BLWP
* All other routines are BL:
       DEF  calc_init_timer_loop
       DEF  coinc_init_timer_loop
       DEF  restart_timer_loop
       DEF  set_timer
       DEF  get_timer_value
       DEF  handle_quit_button
       DEF  SETHRZ
* These routines are only made public so that PIXELROWCOINC can use them
       DEF  generic_timer_init
       DEF  measure_length_of_frame
*
       REF  VDPADR,VDPREG,VDPWRT            Ref from VDP

*
* All of these routines require R10 to be a stack pointer
*

*
* Addresses
*
       COPY 'EQUCPUADR.asm'
       COPY 'EQUVAR.asm'

top_scan_time_60hz          DATA 199
cru_scan_ratio_top_60hz     DATA 2985
cru_scan_ratio_bottom_60hz  DATA 1000
*
top_scan_time_50hz          DATA 240
cru_scan_ratio_top_50hz     DATA 3630
cru_scan_ratio_bottom_50hz  DATA 1000
*
quit_key_bits               DATA >1100

* adjustments that need to be made because
* the act of measuring time takes time
ticks_extra_frame       EQU  5
ticks_initializing_loop EQU  14
ticks_after_interrupt   EQU  12

*
* BLWP:
* Wait for the VDP interrupt, but don't clear it.
* Any future interrupts will be interpreted by ROMs as VDP interrupts.
* We can no longer listen for VDP interrupts,
* but we can listen for timer interrupts.
*
block_vdp_interrupt
       DATA >83C0,block_vdp_interrupt+4
* Munge the INTWS.
       SETO R1                * Disable all VDP interrupt processing.
       SETO R11               * Disable screen timeouts.
       CLR  R12               * Set to 9901 CRU base.
* Munge the GPLWS.
       LWPI >83E0
       CLR  R14               * Disable cassette interrupt and protect >8379.
       LI   R15,>877B         * Disable VDPST reading and protect >837B.   (>FC00 + >877B = >837B, so this results in moving >837B to itself)
* Wait for one frame to finish
       LWPI >83C0
       SBO  2
       MOVB @VDPSTA,R8
*
* Synchronize with the next VDP interrupt.
SYNC   TB   2                 * Check for VDP interrupt.
       JEQ  SYNC
* Configure the 9901 for interrupts.
       SBZ  1                 * Disable external interrupt prioritization.
       SBZ  2                 * Disable VDP interrupt prioritization.
* Done
       RTWP

*
* BLWP:
* Unblock VDP interrupts
*
unblock_vdp_interrupt
       DATA >83C0,unblock_vdp_interrupt+4
* Munge the INTWS.
       CLR  R1                * Enable all VDP interrupt processing.
       CLR  R11               * Enable screen timeouts.
       LI   R12,>70           * Set to 9901 CRU base.
* Munge the GPLWS.
       LWPI >83E0
       LI   R14,>0108         * Enbale cassette interrupt.
       LI   R15,>8C02         * Enable VDPST (>FC00 + >83C0 = >8802)
* Done
       LWPI >83C0
       RTWP

*
* Initialize the timer loop.
* Transform data from the scan-line-ISR-table to the timer-ISR-table
*
* Input:
*   R0 - address of scan-line-ISR-table
*   R1 - end of scan-line-ISR-table
*   R2 - end-of-frame interrupt routine
*      - set to 0, if there is no end-of-frame ISR
calc_init_timer_loop
       DECT R10
       MOV  R11,*R10
*
       LI   R6,calculate_time_to_reach_pixel_row
       JMP  generic_timer_init

*
* Private:
* Initialize the timer loop.
* Given a table of pixel-row indexes followed by ISR addresses,
* generates a table of corresponding timer-values followed with the same ISR addresses.
* The results are stored at @timer_interrupts.
*
* IMPORTANT: the calling code is required to push
* a return address to the stack before calling this routine.
* This routine will pop, but not push, a return address from the stack.
*
* Input:
*   R0 - address of scan-line-ISR-table
*   R1 - end of scan-line-ISR-table
*   R2 - end-of-frame interrupt routine
*      - set to 0, if there is no end-of-frame ISR
*   R6 - routine for converting a pixel-row to a timer value
generic_timer_init
* Let R8 = table start address
* Let R9 = table end address
       MOV  R0,R8
       MOV  R1,R9
* See restart_timer_loop, where it branch-links to the method in @frame_isr
* If we put a null-check there AND a frame is dropped, stuff breaks.
* I haven't figured out why,
* so instead we'll guarantee that @frame_isr always points to some sort of method.
       MOV  R2,R2
       JNE  set_frame_isr
       LI   R2,just_return
set_frame_isr
       MOV  R2,@frame_isr
* Let R7 = address of destination table
       LI   R7,timer_interrupts
while_isr_records_remain_coinc
* Let R1 (16-bits) = index of a pixel row
       MOV  *R8+,R1
* Let R2 = number of CRU ticks between VDP interrupt and a pixel-row
       BL   *R6
* Update destination table
       MOV  R2,*R7+
       MOV  *R8+,*R7+
* Have we run out of space in the destination table?
       CI   R7,limit_timer_interrupts
       JHE  assign_timer_table_addresses
* No, did we reach the end of the source table?
       C    R8,R9
       JL   while_isr_records_remain_coinc
* Yes, set start/end addresses
assign_timer_table_addresses
       LI   R0,timer_interrupts
       MOV  R0,@isr_table_address
       MOV  R7,@isr_end_address
* Let R2 = length of a video frame
       BL   @measure_length_of_frame
* Add an entry to the timer-ISR-table
* that will only get triggered if the game loop drops a frame.
       MOV  R2,*R7+
       LI   R8,restart_loop_after_dropping_frame
       MOV  R8,*R7+
* Add another entry with no ISR,
* but with a timer value identical to the first entry in the table.
* Again, it only matters if a frame is dropped.
       MOV  @isr_table_address,R0
       MOV  *R0,*R7
*
* The "timer interrupts" table now contains values
* that measure time between the end of a frame and a desired pixel row.
* But as each interrupt triggers within a given frame,
* the main ISR will need to set a timer for the next interrupt.
* So the existing timer values need to be replaced with
* the time between one pixel row and the next pixel row.
*
timer_difference_loop
       AI   R7,-4
       CI   R7,timer_interrupts
       JLE  timer_difference_end
       S    @-4(R7),*R7
       JMP  timer_difference_loop
timer_difference_end
* Specify parent ISR address, which will call the child ISRs.
       LI   R1,timer_isr
       MOV  R1,@USRISR
*
       MOV  *R10+,R11
just_return       
       RT

*
* Measure the CRU ticks between the beginning and end of a frame
*
* Output:
*   R2
measure_length_of_frame
       DECT R10
       MOV  R11,*R10
* Skip the current frame
       LIMI 2
       MOVB @VINTTM,R0
skip_first_frame
       CB   @VINTTM,R0
       JEQ  skip_first_frame
* Set timer for the next frame
       LI   R1,>3FFF
       BL   @set_timer
* Wait for end of second frame
       MOVB @VINTTM,R0
while_second_frame_continues
       CB   @VINTTM,R0
       JEQ  while_second_frame_continues
* Let R2 = new timer value
       BL   @get_timer_value
       NEG  R2
       AI   R2,>3FFF
* Account for the ticks that were missed branching to/from the timer routines
       AI   R2,ticks_extra_frame
*
       LIMI 0
*
       MOV  *R10+,R11
       RT

*
* Calculatre the time it takes to get from
* the end of one frame to a particular pixel-row
* in a 60hz environment
*
* Input:
*   R1: index of pixel row
* Output:
*   R2: number of CRU ticks
calculate_time_to_reach_pixel_row
       DECT R10
       MOV  R11,*R10
* 50 hz or 60 hz?
       DECT R10
       MOV  R0,*R10
       DECT R10
       MOV  R1,*R10
       DECT R10
       MOV  R2,*R10
       DECT R10
       MOV  R9,*R10
       BL   @SETHRZ
       MOV  *R10+,R9
       MOV  *R10+,R2
       MOV  *R10+,R1
       MOV  *R10+,R0
       MOVB @HERTZ,R3
       JEQ  calc_60hz
* 50 hz
calc_50hz
       MPY  @cru_scan_ratio_top_50hz,R1
       DIV  @cru_scan_ratio_bottom_50hz,R1
       A    @top_scan_time_50hz,R1
       MOV  R1,R2
*
       MOV  *R10+,R11
       RT
* 60 hz
calc_60hz
       MPY  @cru_scan_ratio_top_60hz,R1
       DIV  @cru_scan_ratio_bottom_60hz,R1
       A    @top_scan_time_60hz,R1
       MOV  R1,R2
*
       MOV  *R10+,R11
       RT

*
* Point back to the initial isr_element
*
restart_timer_loop
       DECT R10
       MOV  R11,*R10
* Reset timer
* Initialize "isr_element_address"
       MOV  @isr_table_address,R0
       MOV  *R0+,R1
       MOV  R0,@isr_element_address
       AI   R1,-ticks_initializing_loop
       BL   @set_timer
* Call an ISR that was set up for the end-of-frame event,
* to replace the regular VDP interrupt.
continue_restarting
       MOV  @frame_isr,R1
       BL   *R1
* Do stuff that would normally be triggered by VDP interrupts
       AB   @ONE,@VINTTM
* If the quit key was pressed, restart the computer
       BL   @handle_quit_button
*
* Tell game loop that it
* shouldn't turn off interrupts and wait for Video frame yet.
       CLR  @all_lines_scanned
* Enable Timer interrupt prioritization
       CLR  R12
       SBO  3
*
       MOV  *R10+,R11
       RT

*
* In situations where a frame was dropped,
* restart the timer loop.
* But don't restart the timer from here.
* It was already restarted by timer_isr.
*
restart_loop_after_dropping_frame
       DECT R10
       MOV  R11,*R10
* Reset timer
* Initialize "isr_element_address"
       MOV  @isr_table_address,R0
       MOV  *R0+,R1
       MOV  R0,@isr_element_address
*
       JMP  continue_restarting

*
* Private Method:
* Initialize Timer
*
* Input
*   R1 - time before trigger (least significant 14-bits)
set_timer
       CLR  R12         CRU base of the TMS9901 
       SBO  0           Enter timer mode
       INCT R12         Address of bit 1 
       LDCR R1,14       Load value 
       DECT R12         There is a faster way (see http://www.nouspikel.com/ti99/titechpages.htm) 
       SBZ  0           Exit clock mode, start decrementer 
       RT

*
* Private Method:
* Get Time from CRU
* Output: R2
*   - Status bits compared to 0
*
get_timer_value:
       CLR  R12 
       SBO  0           Enter timer mode 
       STCR R2,15       Read current value (plus mode bit)
       SBZ  0
* Ignore left-most and right-most bits, while maintaining sign
       SLA  R2,1
       SRL  R2,2
       RT

*
* Parent ISR
* keeps track of the next child isr
*
timer_isr
       LIMI 0
* Get stack pointer
       LI   R10,WS
       AI   R10,2*10
       MOV  *R10,R10
* Save Return address
       DECT R10
       MOV  R11,*R10
* Let R9 = address of child interrupt
* Let R1 = next timer value
* Update interrupt element address
       MOV  @isr_element_address,R0
       MOV  *R0+,R9
       MOV  *R0+,R1
       MOV  R0,@isr_element_address
* Subtract a few CRU ticks from timer value.
* There is a delay between triggering the ISR, and resetting the timer
       AI   R1,-ticks_after_interrupt
* Configure next interrupt's timer
       BL   @set_timer
* Clear timer-interrupt
       CLR  R12
       SBO  3
* For some reason we need to re-confirm that we don't want VDP interrupts
       SBZ  2
* Run child interrupt
       BL   *R9
* did we run out of ISR elements?
       C    @isr_element_address,@isr_end_address
       JL   timer_isr_return
* Yes, let main code know that it can proceed with the next game loop
* and thus can test for the next end-of-frame
       SETO @all_lines_scanned
*
timer_isr_return
       LIMI 2
*
       MOV  *R10+,R11
       RT

*
* Check if the user is pressing the quit key,
* And if so, restart the TI.
*
handle_quit_button
* Get key presses from CRU
       CLR  R1                  Test column 0
       LI   R12,>0024           Address for column selection
       LDCR R1,3                Select column
       LI   R12,>0006           Address to read rows
       STCR R1,8
* Is the user pressing the FCTN and = keys?
       CZC  @quit_key_bits,R1
       JEQ  restart_ti99
* No, return
       RT

*
*
*
restart_ti99
* Disable timer interrupts,
* or restart routine will get stuck in infinite loop
       CLR  R12
       SBZ  3
* Call computer-boot-up routine
       LWPI >0
       BLWP @0

*
* Public Method:
* Set HERTZ
*    0 = 60hz
*    -1 = 50hz
*
SETHRZ
       DECT R10
       MOV  R11,*R10
*
       LI   R1,>3FFF
       BL   @set_timer
* Turn on VDP interrupts
       LIMI 2
* Skip first VDP interrupt; it's too late to measure the full time.
       MOVB @VINTTM,R0
FRSTLP CB   @VINTTM,R0
       JEQ  FRSTLP
* Let R9 = recorded time at begging of interrupt
       BL   @get_timer_value
       MOV  R2,R9
VDPLP
* Let R0 = most recently read VDP time
       MOVB @VINTTM,R0
* Wait for VDP interrupt
WAITLP CB   @VINTTM,R0
       JEQ  WAITLP
* Let R2 = newly recorded time
       BL   @get_timer_value
* Let R9 = quantity of time between interrupts
       S    R2,R9
* Turn off interrupts so we can write to VDP
       LIMI 0
*
* In a 50hz environment R3 should contain about 938.
* We'll accept 888 - 988 in case an emulator is not accurate.
* Any other value implies 60hz or an emulator that doesn't implement the CRU timer.
*
       CLR  R4
       CI   R9,988
       JH   HRZ1
       CI   R9,888
       JL   HRZ1
       DEC  R4
HRZ1   MOVB R4,@HERTZ
*
       MOV  *R10+,R11
       RT