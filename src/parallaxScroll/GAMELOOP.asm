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
       REF  request_upper_redraw
       REF  draw_single_upper_row
       REF  init_tile_layer
*
       REF  init_sprite_layer
       REF  display_sprites
*
       REF  BSCAN
*
       REF  player_init
       REF  process_input
*
       REF  status_print
       REF  game_over_print
*
       REF  ent_init
       REF  ent_handle
*
       REF  col_init
       REF  col_detect

       COPY '.\EQUGAME.asm'
       COPY '..\EQUVAR.asm'
       COPY '..\EQUCPUADR.asm'

tile_code_offset   EQU  >60
pattern_offset     EQU  8*tile_code_offset

scan_line_interrupts
       DATA 5*8+4,config_region_2
       DATA 8*8+4,config_region_3
       DATA upper_screen_rows*8+0,config_region_4
       DATA (upper_screen_rows+lower_screen_rows)*8-1,config_region_5
scan_line_interrups_end


parallax_demo
       LWPI WS
       LI   R10,STACK
       LIMI 0
* Set all addresses in upper memory expansion to zero
       LI   R0,>A000
!      CLR  *R0+
       MOV  R0,R0
       JNE  -!
* Specify the location of the table of timer ISRs
       LI   R0,scan_line_interrupts
       LI   R1,scan_line_interrups_end
       LI   R2,config_region_1
       BL   @coinc_init_timer_loop
* Write tiles and colors to VDP RAM.
* Draw first screen image table.
       BL   @init_tile_layer
* Write sprite patterns
       BL   @init_sprite_layer
*
       BL   @player_init
       BL   @ent_init
       BL   @col_init
*
       LI   R0,vdp_reg_2_screen_i
       MOV  R0,@current_upper_screen
       MOV  R0,@current_lower_screen
*
       LI   R0,>0400
       MOV  R0,@current_pattern_1
       MOV  R0,@current_pattern_2
       MOV  R0,@current_pattern_3
       MOV  R0,@current_pattern_4
* Request that the second screen image table be drawn to
       MOV  @current_upper_screen,@next_upper_screen
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
* If the player is out of health, skip most of the loop
       MOV  @player_health_points,R0
       JGT  !
       BL   @game_over_routine
       LIMI 2
       JMP  end_of_iteration
!
* If a re-draw request is incomplete, draw one row of it now
       BL   @draw_single_upper_row
*
       BL   @display_sprites
*
       BL   @status_print
* Enable interrupts
       LIMI 2
* Load KEYCOD with value
       BL   @BSCAN
*
       BL   @process_input
       BL   @ent_handle
       BL   @col_detect
* Don't end game loop until all timer-interrupts have been triggered
end_of_iteration
       MOV  @all_lines_scanned,R0
       JEQ  end_of_iteration
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
config_region_5
       DECT R10
       MOV  R11,*R10
*
       LIMI 0
* Set screen image table
       LI   R0,vdp_reg_2_screen_i
       BL   @VDPREG
* Select Pattern table that contains ASCII patterns
       LI   R0,vdp_reg_4_text_patterns
       BL   @VDPREG
*
       LIMI 2
*
       MOV  *R10+,R11
       RT

*
config_region_1
       DECT R10
       MOV  R11,*R10
* Set screen image table
       MOV  @current_upper_screen,R0
       BL   @VDPREG
* Set Pattern table
       MOV  @current_pattern_1,R0
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
* Set screen image table
       MOV  @current_lower_screen,R0
       BL   @VDPREG
* Set Pattern table
       MOV  @current_pattern_4,R0
       BL   @VDPREG
*
       LIMI 2
*
       MOV  *R10+,R11
       RT

game_over_routine
       DECT R10
       MOV  R11,*R10
*
       BL   @game_over_print
*
       MOV  *R10+,R11
       RT