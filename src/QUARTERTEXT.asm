       DEF  quarter_text
*
       REF  VDPREG,VDPADR,VDPWRT            Ref from VDP
       REF  font_addresses                  Ref from FONTS
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

SCRN8  EQU  >2000

pixel_row_interrupts
       DATA 6*8-2,pattern1_isr
       DATA 12*8-2,pattern2_isr
       DATA 18*8-2,pattern3_isr
pixel_row_interrupts_end

char_pattern
* Patterns used to demonstrate degree of accuracy in the results
       DATA >F000,>0000,>C000,>0000
       DATA >F000,>0000,>C000,>0001
* Pattern used for COINIC detection
       DATA >8080,>8080,>8080,>8080
end_of_char_patterns

quarter_text
       LWPI WS
       LI   R10,STACK
       LIMI 0
* Write patterns
       LI   R0,>800
       BL   @VDPADR
       LI   R0,char_pattern
       LI   R1,end_of_char_patterns-char_pattern
       BL   @VDPWRT
       LI   R0,>0601
       BL   @VDPREG
* Specify the location of the table of timer ISRs
       LI   R0,pixel_row_interrupts
       LI   R1,pixel_row_interrupts_end
       LI   R2,pattern0_isr
       BL   @coinc_init_timer_loop
* Enable text mode
       LI   R0,>01F0
       BL   @VDPREG
* Enable white text / blue background
       LI   R0,>07F4
       BL   @VDPREG
*
       BL   @init_screen_image_table
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
* Don't end game loop until all timer-interrupts have been triggered
while_waiting_for_interrupt
       MOV  @all_lines_scanned,R0
       JEQ  while_waiting_for_interrupt
*
       JMP  game_loop

init_screen_image_table
       DECT R10
       MOV  R11,*R10
* Choose the screen image table
       LI   R0,>0208
       BL   @VDPREG
       LI   R0,SCRN8
       BL   @VDPADR
* Let R1 = number of quarter-screens remaining to initialize
       LI   R1,4
four_quarters_of_screen
* Let R0 = tile-code to write
       CLR  R0
one_quarter_of_screen
       MOV  R0,@VDPWD
       AB   @ONE,R0
       CI   R0,6*40*>100
       JL   one_quarter_of_screen
*
       DEC  R1
       JNE  four_quarters_of_screen
*
       MOV  *R10+,R11
       RT

pattern0_isr
       LI   R0,>0400
       JMP  any_pattern

pattern1_isr
       LI   R0,>0401
       JMP  any_pattern

pattern2_isr
       LI   R0,>0402
       JMP  any_pattern

pattern3_isr
       LI   R0,>0403
       JMP  any_pattern

* 
* Input:
*   R0: VDP register and value
any_pattern
       DECT R10
       MOV  R11,*R10
* Set background color
       BL   @VDPREG
*
       MOV  *R10+,R11
       RT
