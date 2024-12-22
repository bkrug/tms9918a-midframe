       DEF  process_input
       DEF  player_init
       DEF  request_upper_redraw

       COPY '.\EQUGAME.asm'
       COPY '..\EQUCPUADR.asm'

walking_player
       DATA walking_player_chars_1
       DATA standing_player_chars
       DATA walking_player_chars_2
walking_player_chars_1
       BYTE >20,>30,>00,>10
standing_player_chars
       BYTE >24,>34,>04,>14
walking_player_chars_2
       BYTE >28,>38,>08,>18
jumping_player_chars
       BYTE >2C,>3C,>0C,>1C
*
sword_player
       DATA normal_player_offsets
       DATA sword_player_offsets_1
       DATA sword_player_offsets_2
normal_player_offsets
       DATA >0000
       DATA >2000
       DATA >0000
       DATA >2000
sword_player_offsets_1
       DATA >0006
       DATA >2002
       DATA >0002
       DATA >2002
sword_player_offsets_2
       DATA >0008
       DATA >2000
       DATA >0002
       DATA >2000
jump_sword_player_offsets
       DATA >0004
       DATA >2000
       DATA >0000
       DATA >2000

cycles_per_sprite_frame     DATA 9
* There are only 3 sprite frames, but this is used as an offset among 16-bit addresses
player_sprite_frames        DATA 3*2

sword_button_down           BYTE sword_flag,0
jump_button_down            BYTE jump_flag,0
right_button_down           BYTE right_flag,0

player_max_y                DATA >70*pixel_size

player_init
       MOV  @player_max_y,@player_y_pos
       RT

*
*
*
process_input
       DECT R10
       MOV  R11,*R10
*
       BL   @set_player_animation_frames
       BL   @set_player_sprite_chars
       BL   @set_player_offsets
       BL   @select_sprite_pattern_table
       BL   @update_player_y_pos
*
       MOVB @KEYCOD,R0
       COC  @right_button_down,R0
       JNE  !
       BL   @smooth_scroll_one_pixel
!
*
       MOV  *R10+,R11
       RT

*
*
*
set_player_animation_frames
* Is right-key being pressed?
       MOVB @KEYCOD,R0
       ANDI R0,(right_flag+sword_flag)*>100
       JEQ  animation_return
* Set animation frame for either walking or sword swinging
       LI   R1,sprite_frame_delay
       INC  *R1
       C    *R1,@cycles_per_sprite_frame
       JL   !
       CLR  *R1
*
       LI   R2,sprite_frame
       INCT *R2
       C    *R2,@player_sprite_frames
       JL   !
       CLR  *R2
!
animation_return
       RT

*
* Select correct list of sprite chars for animation
*
set_player_sprite_chars
       MOVB @KEYCOD,R0
* Is jump-key being pressed?
       COC  @jump_button_down,R0
       JEQ  set_jump_frame
* Is right-key being pressed?
       COC  @right_button_down,R0
       JEQ  set_walk_frame
* Is sword key being pressed?
       COC  @sword_button_down,R0
       JEQ  set_walk_frame
* No, set standing frame
       LI   R2,standing_player_chars
       MOV  R2,@player_char_address
*
       RT

set_walk_frame
* Let player_char_address = address chars for this frame of animatioon
       MOV  @sprite_frame,R2
       AI   R2,walking_player
       MOV  *R2,@player_char_address
*
       RT

set_jump_frame
       LI   R2,jumping_player_chars
       MOV  R2,@player_char_address
*
       RT

*
* Select correct list of relative x/y positions for the animation frame
*
set_player_offsets
*
       LI   R2,normal_player_offsets
       MOV  R2,@player_offset_address
*
       MOVB @KEYCOD,R0
* Is sword key being pressed?
       COC  @sword_button_down,R0
       JNE  offsets_return
* Yes, set offsets based on animation frame
       MOV  @sprite_frame,R2
       AI   R2,sword_player
       MOV  *R2,@player_offset_address
* Is jump-key being pressed?
       COC  @jump_button_down,R0
       JNE  offsets_return
* Yes, set offsets based on animation frame
       LI   R2,jump_sword_player_offsets
       MOV  R2,@player_offset_address
*
offsets_return
       RT

*
* Let sprite_pattern_vdp_reg = sword is extended ? >0603 : >0602
*
select_sprite_pattern_table
       LI   R1,>0602
       MOVB @KEYCOD,R0
       COC  @sword_button_down,R0
       JNE  !
       INC  R1
!      MOV  R1,@sprite_pattern_vdp_reg
*
       RT

*
*
*
update_player_y_pos
       RT

speed_1      DATA 1
speed_2      DATA 4
speed_3      DATA 8
speed_4      DATA 16

*
* Scroll the screen such that the lowest portion moves by 1 pixel
*
smooth_scroll_one_pixel
       DECT R10
       MOV  R11,*R10
* Increase scroll amount
       A    @speed_4,@x_pos_4
       A    @speed_3,@x_pos_3
       A    @speed_2,@x_pos_2
       A    @speed_1,@x_pos_1
* Calculate pattern table register values.
* High byte specifies that this will be recorded in VDP register 4.
* Low byte specifies the particular pattern table.
       MOV  @x_pos_1,R0
       ANDI R0,>0070
       SRL  R0,4
       AI   R0,>0400
       MOV  R0,@next_pattern_1
*
       MOV  @x_pos_2,R0
       ANDI R0,>0070
       SRL  R0,4
       AI   R0,>0400
       MOV  R0,@next_pattern_2
*
       MOV  @x_pos_3,R0
       ANDI R0,>0070
       SRL  R0,4
       AI   R0,>0400
       MOV  R0,@next_pattern_3
*
       MOV  @x_pos_4,R0
       ANDI R0,>0070
       SRL  R0,4
       AI   R0,>0400
       MOV  R0,@next_pattern_4
* Calculate lower screen image table register value
* High byte specifies that this will be recorded in VDP register 2.
* Low byte specifies a screen image table that is an even number no less than 8.
       MOV  @x_pos_4,R0
       SRL  R0,tile_power+pixel_power-1
       ANDI R0,>0006
       AI   R0,>0208
       MOV  R0,@next_lower_screen
* Calculate upper screen image table register value.
* Base it on scroll region 3, because it is the fastest moving in the upper screen.
* High byte specifies that this will be recorded in VDP register 2.
* Low byte specifies a screen image table that is an even number no less than 8.
       MOV  @x_pos_3,R0
       SRL  R0,tile_power+pixel_power-1
       ANDI R0,>0006
       AI   R0,>0208
       MOV  R0,@next_upper_screen
*
       C    @next_upper_screen,@current_upper_screen
       JEQ  !
       BL   @request_upper_redraw
!
*
       MOV  *R10+,R11
       RT

*
* Request that the upcoming screen image table be redrawn
* This method should be called on the first frame
* after changing the screen image table for the upper screen.
*
request_upper_redraw
* Let @address_of_draw_request = beginning of a screen image table
* Given the current screen image table,
* get the address of the screen image table that has an address >800 bytes higher
       MOV  @next_upper_screen,R0
       ANDI R0,>000F
       AI   R0,vdp_address_for_next_screen-8
       MOV  *R0,@address_of_draw_request
* Calculate the expected x-position of each scroll region,
* for the next time that we change the screen image table of the upper screen.
       MOV  @x_pos_1,@expected_1
       MOV  @x_pos_2,@expected_2
       MOV  @x_pos_3,@expected_3
       MOV  @x_pos_4,@expected_4
* Assuming that "smooth_scroll_one_pixel" is called 16 times total,
* calculate what the scroll positions _will_ be.
       MOV  @speed_1,R0
       SLA  R0,4
       A    R0,@expected_1
       MOV  @speed_2,R0
       SLA  R0,4
       A    R0,@expected_2
       MOV  @speed_3,R0
       SLA  R0,4
       A    R0,@expected_3
       MOV  @speed_4,R0
       SLA  R0,4
       A    R0,@expected_4
*
       RT

*
* If the upper screen image table is defined by VDP Reg 4 = >08,
* then the VDP address of the current table is at >2000.
* We don't use the screen image table at >2400 because it overlaps tile patterns.
* So the next screen image table is at >2800.
* The same pattern is repeated 3 more times.
*
vdp_address_for_next_screen
       DATA >2800,>3000,>3800,>2000