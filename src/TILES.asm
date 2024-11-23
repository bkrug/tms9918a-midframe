       DEF  tiles
*
       REF  VDPREG,VDPADR,VDPWRT            Ref from VDP
       REF  STACK                           Ref from VAR
       REF  WS
       REF  all_lines_scanned
       REF  isr_table_address
       REF  isr_element_address
       REF  isr_end_address

*
* Addresses
*
       COPY 'EQUCPUADR.asm'
       COPY 'EQU.asm'

char_pattern
       DATA >0000,>00C0,>0000,>00CC
coinc_sprite_pattern
       DATA >0800,>0000,>0000,>0000
color  BYTE >10
       EVEN
timer_interrupts
*       DATA 275,red_color_isr
       DATA 275,yellow_color_isr
       DATA 175,blue_color_isr
*       DATA vdp_mock,purple_color_isr
       DATA >3F00,0
scan_line_interrupts
*       DATA -8,red_color_isr
       DATA 9*8+0,yellow_color_isr
       DATA 17*8+4,blue_color_isr
       DATA vdp_mock,purple_color_isr

tiles
       LWPI WS
       LI   R10,STACK
       LIMI 0
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
       LI   R1,2*8
       BL   @VDPWRT
* Write color code
       LI   R0,>380
       BL   @VDPADR
       MOVB @COLOR,@VDPWD
* Write tiles
       CLR  R0
       BL   @VDPADR
       LI   R0,24*32
       CLR  R1
while_tiles_to_write
       MOVB R1,@VDPWD
       DEC  R0
       JNE  while_tiles_to_write
*
       LI   R1,timer_isr
       MOV  R1,@USRISR
*
game_loop
       BL   @block_vdp_interrupt
* Set timer-interrupt routine
       BL   @restart_timer_loop
* Set background color
       LI   R0,>0706
       BL   @VDPREG
* Don't end game loop until the timer-interrupt has triggered
while_waiting_for_interrupt
       MOV  @all_lines_scanned,R0
       JEQ  while_waiting_for_interrupt
*
       JMP  game_loop

*
* Point back to the initial isr_element
*
restart_timer_loop
       DECT R10
       MOV  R11,*R10
* Reset timer
* Initialize "isr_element_address"
       LI   R0,timer_interrupts
       MOV  *R0+,R1
       MOV  R0,@isr_element_address
       BL   @set_timer
*
       LI   R0,timer_interrupts+(2*4)
       MOV  R0,@isr_end_address
*
       CLR  @all_lines_scanned
* Enable Timer interrupt prioritization
       CLR  R12
       SBO  3
* Enable interrupts
       LIMI 2
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

*red_color_isr

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
       LIMI 0
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