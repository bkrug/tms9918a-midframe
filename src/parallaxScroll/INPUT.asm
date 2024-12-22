       DEF  process_input

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