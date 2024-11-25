       DEF  tiles
*
       REF  VDPREG,VDPADR,VDPWRT            Ref from VDP
       REF  STACK                           Ref from VAR
       REF  WS
       REF  all_lines_scanned
       REF  isr_table_address
       REF  isr_element_address
       REF  isr_end_address
       REF  timer_interrupts

*
* Addresses
*
       COPY 'EQUCPUADR.asm'
       COPY 'EQU.asm'

char_pattern
       DATA >F000,>0000,>C000,>0000
       DATA >F000,>0000,>C000,>0001
coinc_sprite_pattern
       DATA >8080,>8080,>8080,>8080
color  BYTE >10
ONE    BYTE >1
* except for the Y-position, these are the sprite-attributes for the COINC sprits
sprite_attributes
       BYTE >FF,>01,>06
       EVEN
scan_line_interrupts
*       DATA -8,red_color_isr
       DATA 0,blue_color_isr
       DATA 4*8+0,yellow_color_isr
       DATA 8*8+0,blue_color_isr
       DATA 12*8+0,yellow_color_isr
       DATA 16*8+0,blue_color_isr
       DATA 20*8+0,yellow_color_isr
       DATA 23*8+0,blue_color_isr
scan_line_interrups_end
       DATA vdp_mock,purple_color_isr
* timer of first scan line
top_scan_time           DATA 186
cru_scan_ratio_top      DATA 95
cru_scan_ratio_bottom   DATA 32

tiles
       LWPI WS
       LI   R10,STACK
       LIMI 0
* Initialize graphics
       BL   @init_graphics
* Specify the location of the table of timer ISRs
       LI   R0,scan_line_interrupts
       LI   R1,scan_line_interrups_end
       BL   @init_timer_loop
*
game_loop
* Disable interrupts
       LIMI 0
* Block thread until then end of a frame
* Fool TI-99/4a into thinking that later interrupts are VDP interrupts.
       BL   @block_vdp_interrupt
* Tell timer_isr to look at the begging of the table again
       BL   @restart_timer_loop
* Enable interrupts
       LIMI 2
* Don't end game loop until all timer-interrupts have been triggered
*
while_waiting_for_interrupt
       MOV  @all_lines_scanned,R0
       JEQ  while_waiting_for_interrupt
*
       JMP  game_loop

*
* Initialize the timer loop.
* Transform data from the scan-line-ISR-table to the timer-ISR-table
*
* Input:
*   R0 - address of scan-line-ISR-table
*   R1 - end of scan-line-ISR-table
init_timer_loop
       DECT R10
       MOV  R11,*R10
* Let R8 = table start address
* Let R9 = table end address
       MOV  R0,R8
       MOV  R1,R9
* Let R7 = destination address
       LI   R7,timer_interrupts
while_isr_records_remain
* Let R2 = desired pixel row
       MOV  *R8+,R1
       MPY  @cru_scan_ratio_top,R1
       DIV  @cru_scan_ratio_bottom,R1
       A    @top_scan_time,R1
* Update destination table
       MOV  R1,*R7+
       MOV  *R8+,*R7+
* Did we reach the end of the source table?
       C    R8,R9
       JL   while_isr_records_remain
* Yes, set start/end addresses
       LI   R0,timer_interrupts
       MOV  R0,@isr_table_address
       MOV  R7,@isr_end_address
* The "timer interrupts" table now contains values
* that measure time between the end of a frame and a desired pixel row.
* Those values need to be replaced with the time between
* one pixel row and the next pixel row.
*
timer_difference_loop
       AI   R7,-4
       C    R7,R0
       JLE  timer_difference_end
       S    @-4(R7),*R7
       JMP  timer_difference_loop
timer_difference_end
* Specify parent ISR address, which will call the child ISRs.
       LI   R1,timer_isr
       MOV  R1,@USRISR
*
       MOV  *R10+,R11
       RT

*
* Initialize the timer loop.
* Transform data from the scan-line-ISR-table to the timer-ISR-table
* This doesn't work in Classic 99, but check on real hardware
*
* Input:
*   R0 - address of scan-line-ISR-table
*   R1 - number of elements
init_timer_from_coinc
       DECT R10
       MOV  R11,*R10
* Let R8 = table start address
* Let R9 = table end address
       MOV  R0,R8
       SLA  R1,2
       A    R1,R0
       MOV  R0,R9
* Let R7 = destination address
       LI   R7,timer_interrupts
while_isr_records_remain_coinc
* Let R1 = Y-Position minus 1 (for TMS9918a reasons)
       MOV  *R8+,R1
       DEC  R1
       SLA  R1,8
* Draw one sprite which does not overlap another
       LI   R3,1
       BL   @write_test_sprites
* Clear COINC flag, and wait till end of video frame
       BL   @unblock_vdp_interrupt
       LIMI 2
clear_vdp_status
       MOVB @VDPSTA,R2
       ANDI R2,>2000
       JNE  clear_vdp_status
       LIMI 0
* Draw two overlapping sprites
       LI   R3,2
       BL   @write_test_sprites
* Clear COINC flag, and wait till end of video frame
       BL   @block_vdp_interrupt
* Reset timer
       LI   R1,>3FFF
       BL   @set_timer
* Wait for COINC
while_coinc_not_triggered
       MOVB @VDPSTA,R1
       ANDI R1,>2000
       JEQ  while_coinc_not_triggered
* Let R2 = new timer value
       BL   @get_timer_value
* Let R2 = time that passed
       NEG  R2
       AI   R2,>3FFF
* Update destination table
       MOV  R2,*R7+
       MOV  *R8+,*R7+
* Did we reach the end of the source table?
       C    R8,R9
       JL   while_isr_records_remain_coinc
* Yes, set start/end addresses
       LI   R0,timer_interrupts
       MOV  R0,@isr_table_address
       MOV  R7,@isr_end_address
* Specify parent ISR address, which will call the child ISRs.
       LI   R1,timer_isr
       MOV  R1,@USRISR
*
       MOV  *R10+,R11
       RT

*
* Write sprite attibute list
*
* Input:
*    R1, R3
write_test_sprites
       DECT R10
       MOV  R11,*R10
* Set VDP address to sprite attribute list
       LI   R0,>300
       BL   @VDPADR
write_one_sprite
* Set Y-Position
       MOVB R1,@VDPWD
* Set X-Position
       LI   R2,sprite_attributes
while_more_attr_to_write
       MOVB *R2+,@VDPWD
       CI   R2,sprite_attributes+3
       JL   while_more_attr_to_write
*
       DEC  R3
       JNE  write_one_sprite
* End sprite list
       LI   R2,>D000
       MOVB R2,@VDPWD
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
* TODO: call some interrupt that is meant to match the VDP interrupt
       BL   @red_color_isr
*
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
       AI   R1,-11
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
       JL   not_end_of_isr_list
* Yes, let main code know that it can proceed with the next game loop
* and thus can test for the next end-of-frame
       SETO @all_lines_scanned
not_end_of_isr_list
*
       LIMI 2
*
       MOV  *R10+,R11
       RT

red_color_isr
       DECT R10
       MOV  R11,*R10
* Set background color
       LI   R0,>0706
       BL   @VDPREG
*
       MOV  *R10+,R11
       RT

yellow_color_isr
       DECT R10
       MOV  R11,*R10
* Set background color
       LI   R0,>070A
       BL   @VDPREG
*
       MOV  *R10+,R11
       RT

blue_color_isr
       DECT R10
       MOV  R11,*R10
* Set background color
       LI   R0,>0704
       BL   @VDPREG
*
       MOV  *R10+,R11
       RT

purple_color_isr

*
* Wait for the VDP interrupt, but don't clear it.
* Any future interrupts will be interpreted by ROMs as VDP interrupts.
* We can no longer listen for VDP interrupts,
* but we can listen for timer interrupts.
*
* TODO: These should be BLWP methods
block_vdp_interrupt
* Munge the GPLWS.
       LWPI >83E0
       CLR  R14               * Disable cassette interrupt and protect >8379.
       LI   R15,>877B         * Disable VDPST reading and protect >837B.   (>FC00 + >877B = >837B, so this results in moving >837B to itself)
* Munge the INTWS.
       LWPI >83C0
       SETO R1                * Disable all VDP interrupt processing.
       SETO R11               * Disable screen timeouts.
       CLR  R12               * Set to 9901 CRU base.
* Wait for one frame to finish
       SBO  2
       MOVB @>8802,R8
*
* Synchronize with the next VDP interrupt.
SYNC   TB   2                 * Check for VDP interrupt.
       JEQ  SYNC
* Configure the 9901 for interrupts.
       SBZ  1                 * Disable external interrupt prioritization.
       SBZ  2                 * Disable VDP interrupt prioritization.
* Done
       LWPI WS
       RT

*
* Unblock VDP interrupts
*
unblock_vdp_interrupt
* Munge the GPLWS.
       LWPI >83E0
       LI   R14,>0108         * Enbale cassette interrupt.
       LI   R15,>8C02         * Enable VDPST (>FC00 + >83C0 = >8802)
* Munge the INTWS.
       LWPI >83C0
       CLR  R1                * Enable all VDP interrupt processing.
       CLR  R11               * Enable screen timeouts.
       LI   R12,>70           * Set to 9901 CRU base.
* Done
       LWPI WS
       RT

*
* Set VDP registers.
* Draw a series of dotted lines across the screen.
* Set up sprite character appearance (a single pixel).
*
init_graphics
       DECT R10
       MOV  R11,*R10
* Sprites should be 8x8, and VDP interrupts are enabled
       LI   R0,>01E0
       BL   @VDPREG
* Screen Image table
       LI   R0,>0200
       BL   @VDPREG
* Color table
       LI   R0,>030E
       BL   @VDPREG
* Tile pattern table
       LI   R0,>0401
       BL   @VDPREG
* Sprite attribute list
       LI   R0,>0506
       BL   @VDPREG
* Sprite pattern table (occupies same space as tile pattern table)
       LI   R0,>0601
       BL   @VDPREG
* Write patterns
* >00 = tile pattern forming dotted lines
* >01 = our sprite
       LI   R0,>800
       BL   @VDPADR
       LI   R0,char_pattern
       LI   R1,3*8
       BL   @VDPWRT
* Write color code
       LI   R0,>380
       BL   @VDPADR
       MOVB @COLOR,@VDPWD
* Write all tiles except bottom row
       CLR  R0
       BL   @VDPADR
       LI   R0,23*32
       CLR  R1
while_tiles_to_write
       MOVB R1,@VDPWD
       DEC  R0
       JNE  while_tiles_to_write
* Write bottom row of tiles
       LI   R0,32
       AB   @ONE,R1
while_bottom_tile
       MOVB R1,@VDPWD
       DEC  R0
       JNE  while_bottom_tile
*
       MOV  *R10+,R11
       RT