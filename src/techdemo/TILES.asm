       DEF  clc_tiles
       DEF  cnc_tiles
*
       REF  VDPREG,VDPADR,VDPWRT            Ref from VDP
       REF  write_string                    "
       REF  block_vdp_interrupt             Ref from PIXELROW
       REF  calc_init_timer_loop            "
       REF  coinc_init_timer_loop           "
       REF  restart_timer_loop              "
       REF  set_timer                       "
       REF  get_timer_value                 "
       REF  timer_isr                       "
       REF  GROMCR                          Ref from GROM.asm

*
* Addresses
*
       COPY '..\EQUCPUADR.asm'
       COPY '..\EQUVAR.asm'
       COPY 'EQUDEMO.asm'       

* TODO: PIXELROW.asm needs a sprite to be defined,
* and it neeeds to know which sprite to use.
* But we have the sprite pattern defined here.
* That might be bad.
char_pattern
* Patterns used to demonstrate degree of accuracy in the results
       DATA >F000,>0000,>C000,>0000
       DATA >F000,>0000,>C000,>0001
end_of_char_patterns
color  BYTE >10
ZERO   TEXT '0'
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

clc_tiles
       LWPI WS
       LI   R10,STACK
       LI   R9,calc_init_timer_loop
       JMP  tiles

cnc_tiles  
       LWPI WS
       LI   R10,STACK
       LI   R9,coinc_init_timer_loop
tiles  LIMI 0
* Specify the location of the table of timer ISRs
       LI   R0,scan_line_interrupts
       LI   R1,scan_line_interrups_end
       LI   R2,red_color_isr
       BL   *R9
* Disable interrupts, again
       LIMI 0
* Initialize graphics
       BL   @init_graphics
       BL   @GROMCR
       BL   @display_CRU_times
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
* Write patterns
       LI   R0,>800
       BL   @VDPADR
       LI   R0,char_pattern
       LI   R1,end_of_char_patterns-char_pattern
       BL   @VDPWRT
* Write color code
       LI   R0,>380
       BL   @VDPADR
       LI   R0,32
!      MOVB @COLOR,@VDPWD
       DEC  R0
       JNE  -!
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

*
*
*
display_CRU_times
       DECT R10
       MOV  R11,*R10
*
       LI   R4,timer_interrupts
       LI   R5,25
!      MOV  *R4,R0
       BL   @convert_to_ascii
       MOV  R5,R0
       BL   @VDPADR
       LI   R0,ascii_number_string
       BL   @write_string
       AI   R5,32
       C    *R4+,*R4+
       CI   R4,limit_timer_interrupts+8
       JL   -!
*
       MOV  *R10+,R11
       RT


*
* Unsigned Word to ASCII
* ----------------------
* Input:
*   R0: Word to convert
* Output:
*   6 bytes at ascii_number_string
convert_to_ascii
* Let R3 = location of char to convert. Start from string's end.
       LI   R2,10
       LI   R3,ascii_number_string+5
* Null-terminate the string
       SB   *R3,*R3
* Is the original number zero?
       MOV  R0,R0
       JNE  conversion_loop
* Yes, display zero in just the one's player_char_address
       DEC  R3
       MOVB @ZERO,*R3
       JMP  pad_leading_spaces
* Divide by 10 until the number reaches zero
conversion_loop
       MOV  R0,R1
       JEQ  pad_leading_spaces
       CLR  R0
       DIV  R2,R0
       SLA  R1,8
       AB   @ZERO,R1
       DEC  R3
       MOVB R1,*R3
       JMP  conversion_loop
* Pad leading spaces at the front of the number string
pad_leading_spaces
       CI   R3,ascii_number_string
       JEQ  string_complete
       DEC  R3
       MOVB @SPACE,*R3
       JMP  pad_leading_spaces
string_complete
* return
       RT