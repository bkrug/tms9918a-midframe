       DEF  tiles
*
       REF  VDPREG,VDPADR,VDPWRT            Ref from VDP
       REF  block_vdp_interrupt             Ref from PIXELROW
       REF  calc_init_timer_loop            "
       REF  coinc_init_timer_loop           "
       REF  restart_timer_loop              "
       REF  set_timer                       "
       REF  get_timer_value                 "
       REF  timer_isr                       "

*
* Addresses
*
       COPY 'EQUCPUADR.asm'
       COPY 'EQU.asm'
       COPY 'EQUVAR.asm'

* TODO: PIXELROW.asm needs a sprite to be defined,
* and it neeeds to know which sprite to use.
* But we have the sprite pattern defined here.
* That might be bad.
char_pattern
* Patterns used to demonstrate degree of accuracy in the results
       DATA >F000,>0000,>C000,>0000
       DATA >F000,>0000,>C000,>0001
* Pattern used for COINIC detection
       DATA >8080,>8080,>8080,>8080
end_of_char_patterns
color  BYTE >10
       EVEN

* For the default demonstration, we will only Configure
* 4 pixel-row interrupts.
* As we increase the number of interrupts-per-frame,
* the system becomes less tolerant of dropped frames.
* To experiment, uncomment "BL   @delay_and_drop_a_frame"
* and move "scan_line_interrups_end"
scan_line_interrupts
       DATA 0,yellow_color_isr
       DATA 4*8+0,blue_color_isr
       DATA 8*8+0,yellow_color_isr
       DATA 12*8+0,blue_color_isr
       DATA 16*8+0,yellow_color_isr
       DATA 20*8+0,blue_color_isr
scan_line_interrups_end
       DATA 23*8+0,yellow_color_isr

tiles  
       LWPI WS
       LI   R10,STACK
       LIMI 0
* Initialize graphics
       BL   @init_graphics
* Specify the location of the table of timer ISRs
       LI   R0,scan_line_interrupts
       LI   R1,scan_line_interrups_end
       LI   R2,red_color_isr
       BL   @coinc_init_timer_loop
*
game_loop
* Disable interrupts
       LIMI 0
* Block thread until then end of a frame
* Fool TI-99/4a into thinking that later interrupts are VDP interrupts.
       BLWP @block_vdp_interrupt
* Tell timer_isr to look at the begging of the table again
       BL   @restart_timer_loop
* Enable interrupts
       LIMI 2
* Uncomment this line to delay game_loop long enough to drop a frame
*       BL   @delay_and_drop_a_frame
* Don't end game loop until all timer-interrupts have been triggered
while_waiting_for_interrupt
       MOV  @all_lines_scanned,R0
       JEQ  while_waiting_for_interrupt
*
       JMP  game_loop

*
*
*
delay_and_drop_a_frame
       LI   R0,1500
delay_loop
       DEC  R0
       JNE  delay_loop
*
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
       LI   R0,>800
       BL   @VDPADR
       LI   R0,char_pattern
       LI   R1,end_of_char_patterns-char_pattern
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