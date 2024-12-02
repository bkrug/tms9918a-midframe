       DEF  block_vdp_interrupt             *BLWP
       DEF  unblock_vdp_interrupt           *BLWP
       DEF  calc_init_timer_loop            *This and other routines are BL
       DEF  coinc_init_timer_loop
       DEF  restart_timer_loop
       DEF  set_timer
       DEF  get_timer_value
       DEF  handle_quit_button
*
       REF  VDPADR                          Ref from VDP

*
* All of these routines require R10 to be a stack pointer
*
* TODO:
* the COINC operation is making assumptions about:
*    the location of the sprite pattern table
*    the location of the sprite attribute list
*    the correct sprite-code to use
*    8x8 vs 16x16 sprites
* Make this not rely on assumptions in the future.
*

*
* Addresses
*
       COPY 'EQUCPUADR.asm'
       COPY 'EQU.asm'
       COPY 'EQUVAR.asm'

* except for the Y-position, these are the sprite-attributes for the COINC sprites
sprite_attributes
       BYTE >FF,>02,>00
       EVEN

top_scan_time           DATA 186
cru_scan_ratio_top      DATA 95
cru_scan_ratio_bottom   DATA 32
quit_key_bits           DATA >1100

* adjustments that need to be made because
* the act of measuring time takes time
post_coinc_adjustment   EQU  3
isr_trigger_adjustment  EQU  -11

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
       LI   R6,calculate_time_to_reach_pixel_row
       JMP  generic_timer_init

*
* Initialize the timer loop.
* Given a table of pixel-row indexes followed by ISR addresses,
* generates a table of corresponding timer-values followed with the same ISR addresses.
* The results are stored at @timer_interrupts.
*
* Input:
*   R0 - address of scan-line-ISR-table
*   R1 - end of scan-line-ISR-table
*   R2 - end-of-frame interrupt routine
*      - set to 0, if there is no end-of-frame ISR
coinc_init_timer_loop
       LI   R6,measure_time_to_reach_pixel_row
       JMP  generic_timer_init

*
* Initialize the timer loop.
* Given a table of pixel-row indexes followed by ISR addresses,
* generates a table of corresponding timer-values followed with the same ISR addresses.
* The results are stored at @timer_interrupts.
*
* Input:
*   R0 - address of scan-line-ISR-table
*   R1 - end of scan-line-ISR-table
*   R2 - end-of-frame interrupt routine
*      - set to 0, if there is no end-of-frame ISR
*   R6 - routine for converting a pixel-row to a timer value
generic_timer_init
       DECT R10
       MOV  R11,*R10
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
* Now adjust the value of R2 because of what we've seen in real life experiments
       MOV  @isr_end_address,R0
       S    @isr_table_address,R0
       SRL  R0,2
       LI   R3,2
       MPY  R3,R0
       S    R1,R2
* Add an entry to the timer-ISR-table
* that will only get triggered if the game loop drops a frame.
       MOV  R2,*R7+
       LI   R8,restart_timer_loop
       MOV  R8,*R7+
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
       JLE  timer_difference_end_coinic
       S    @-4(R7),*R7
       JMP  timer_difference_loop
timer_difference_end_coinic
* Draw zero sprites
       CLR  R2
       BL   @write_test_sprites
* Specify parent ISR address, which will call the child ISRs.
       LI   R1,timer_isr
       MOV  R1,@USRISR
*
       MOV  *R10+,R11
just_return       
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
       MPY  @cru_scan_ratio_top,R1
       DIV  @cru_scan_ratio_bottom,R1
       A    @top_scan_time,R1
       MOV  R1,R2
*
       RT

*
* Measure the time it takes to get from
* the end of one frame to a particular pixel-row
*
* Input:
*   R1: index of pixel row
* Output:
*   R2: number of CRU ticks
measure_time_to_reach_pixel_row
       DECT R10
       MOV  R11,*R10
* Let R1 = Y-Position minus 1 (for TMS9918a reasons)
       DEC  R1
       SLA  R1,8
* Draw zero sprites
       CLR  R2
       BL   @write_test_sprites
* Clear COINC flag, and wait for two video frames
       MOVB @VDPSTA,R2
       LIMI 2
       MOVB @VINTTM,R0
       AI   R0,>0200
clear_coinc
       CB   @VINTTM,R0
       JNE  clear_coinc
       LIMI 0
* Draw two overlapping sprites at the pixel-index specified by R1
       LI   R2,2
       BL   @write_test_sprites
* Reset timer
       LI   R1,>3FFF
       BL   @set_timer
* Wait util COINC flag is "true"
while_coinc_not_triggered
       MOVB @VDPSTA,R1
       ANDI R1,>2000
       JEQ  while_coinc_not_triggered
* Let R2 = new timer value
       BL   @get_timer_value
* Need to increase the result in R2 a little bit,
* because we did not record the time when we were
* writing overlapping sprites to the VDP RAM.
* SUSPECT: But something is off.
* I would have thought that the process of writing test sprites would take at least 9 CRU ticks.
* I would have thought that inbetween the end of one frame
* and setting the timer for the first interrupt, there would be a delay of ~3 CRU ticks.
* So why are we adding 3 ticks, instead of (9-3=6) 6 ticks or more?
       NEG  R2
       AI   R2,>3FFF+post_coinc_adjustment
*
       MOV  *R10+,R11
       RT

*
* Write sprite attibute list
*
* Input:
*   R1(high-byte) - pixel-index at which to draw top of sprite
*   R2 - number of sprites to draw
* Changed:
*   R0,R3
write_test_sprites
       DECT R10
       MOV  R11,*R10
* Set VDP address to sprite attribute list
       LI   R0,>300
       BL   @VDPADR
* If R2 = 0, just write the end-of-sprite-attribute-list symbol
       MOV  R2,R2
       JEQ  end_sprite_list
write_one_sprite
* Set Y-Position
       MOVB R1,@VDPWD
* Set X-Position, char, and color
       LI   R0,sprite_attributes
       LI   R3,VDPWD
       MOVB *R0+,*R3
       MOVB *R0+,*R3
       MOVB *R0+,*R3
*
       DEC  R2
       JNE  write_one_sprite
* End sprite list
end_sprite_list
       LI   R3,>D000
       MOVB R3,@VDPWD
*
       MOV  *R10+,R11
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
       LIMI 0
* Let R2 = new timer value
       BL   @get_timer_value
       NEG  R2
       AI   R2,>3FFF
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
       BL   @set_timer
* Call an ISR that was set up for the end-of-frame event,
* to replace the regular VDP interrupt.
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
* Subtract 12 CRU ticks from timer value.
* There is a delay between triggering the ISR, and resetting the timer
       AI   R1,isr_trigger_adjustment
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
*
       LWPI >0
       BLWP @0