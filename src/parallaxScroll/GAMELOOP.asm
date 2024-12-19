       DEF  parallax_demo
*
       REF  VDPADR,VDPREG
*
       REF  transition_chars
       REF  unscrolled_patterns
       REF  upper_tile_map
       REF  lower_tile_map
       REF  color_groups
*
       REF  coinc_init_timer_loop
       REF  block_vdp_interrupt
       REF  restart_timer_loop
*
       REF  smooth_scroll_one_pixel
       REF  request_upper_redraw
       REF  draw_single_upper_row
       REF  init_tile_layer

       COPY '.\EQUGAME.asm'
       COPY '..\EQUVAR.asm'
       COPY '..\EQUCPUADR.asm'

tile_code_offset   EQU  >60
pattern_offset     EQU  8*tile_code_offset

scan_line_interrupts
       DATA 60,config_region_2
       DATA 84,config_region_3
       DATA 128,config_region_4
scan_line_interrups_end


parallax_demo
       LWPI WS
       LI   R10,STACK
       LIMI 0
* Set everything to zero
       LI   R0,>A000
!      CLR  *R0+
       MOV  R0,R0
       JNE  -!
* Specify the location of the table of timer ISRs
       LI   R0,scan_line_interrupts
       LI   R1,scan_line_interrups_end
       LI   R2,config_region_1
       BL   @coinc_init_timer_loop
* Pattern table
       LI   R0,>0401
       BL   @VDPREG
* Screen Image table
       LI   R0,>0208
       BL   @VDPREG
* Color table
       LI   R0,>0300
       BL   @VDPREG
* Sprite Attribute Table
       LI   R0,>0501
       BL   @VDPREG
*
       BL   @init_tile_layer
* Write empty sprite atrribute list
       LI   R0,>80
       BL   @VDPADR
       LI   R0,>D000
       MOVB R0,@VDPWD
*
       LI   R0,>0208
       MOV  R0,@current_upper_screen
       MOV  R0,@current_lower_screen
*
       LI   R0,>0400
       MOV  R0,@current_pattern_1
       MOV  R0,@current_pattern_2
       MOV  R0,@current_pattern_3
       MOV  R0,@current_pattern_4
* Request that the second screen image table be drawn to
       BL   @request_upper_redraw
*
game_loop
* Disable interrupts
       LIMI 0
* Block thread until then end of a frame
* Fool TI-99/4a into thinking that later interrupts are VDP interrupts.
       BLWP @block_vdp_interrupt
* Tell timer_isr to look at the begging of the table again
       BL   @restart_timer_loop
* If the upper screen image table wil change in the next video frame,
* then request a redraw of the next screen image table.
       MOV  @x_pos_3,R0
       ANDI R0,>007F
       JNE  !
       BL   @request_upper_redraw
!
* If a re-draw request is incomplete, draw one row of it now
       BL   @draw_single_upper_row
*
       BL   @smooth_scroll_one_pixel
* Enable interrupts
       LIMI 2
* Don't end game loop until all timer-interrupts have been triggered
!      MOV  @all_lines_scanned,R0
       JEQ  -!
* Update VDP register Values
       MOV  @next_upper_screen,@current_upper_screen
       MOV  @next_lower_screen,@current_lower_screen
*
       MOV  @next_pattern_1,@current_pattern_1
       MOV  @next_pattern_2,@current_pattern_2
       MOV  @next_pattern_3,@current_pattern_3
       MOV  @next_pattern_4,@current_pattern_4
*
       JMP  game_loop

*
config_region_1
       DECT R10
       MOV  R11,*R10
* Set Pattern table
       MOV  @current_pattern_1,R0
       BL   @VDPREG
* Set screen image table
       MOV  @current_upper_screen,R0
       BL   @VDPREG
*
       MOV  *R10+,R11
       RT

config_region_2
       DECT R10
       MOV  R11,*R10
*
       LIMI 0
* Set Pattern table
       MOV  @current_pattern_2,R0
       BL   @VDPREG
*
       LIMI 2
*
       MOV  *R10+,R11
       RT

config_region_3
       DECT R10
       MOV  R11,*R10
*
       LIMI 0
* Set Pattern table
       MOV  @current_pattern_3,R0
       BL   @VDPREG
*
       LIMI 2
*
       MOV  *R10+,R11
       RT

config_region_4
       DECT R10
       MOV  R11,*R10
*
       LIMI 0
* Set Pattern table
       MOV  @current_pattern_4,R0
       BL   @VDPREG
* Set screen image table
       MOV  @current_lower_screen,R0
       BL   @VDPREG
*
       LIMI 2
*
       MOV  *R10+,R11
       RT