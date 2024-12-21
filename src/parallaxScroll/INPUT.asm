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

cycles_per_sprite_frame     DATA 9
* There are only 3 sprite frames, but this is used as an offset among 16-bit addresses
player_sprite_frames        DATA 3*2

*
*
*
process_input
* Is right-key being pressed?
       MOVB @KEYCOD,R0
       LI   R4,right_flag*>100
       COC  R4,R0
       JEQ  set_walk_frame
* Is jump-key being pressed?
       LI   R4,jump_flag*>100
       COC  R4,R0
       JEQ  set_jump_frame
* No, set standing frame
       LI   R2,standing_player_chars
       MOV  R2,@player_char_address
*
       RT

set_walk_frame
* Animate the player walking
       INC  @sprite_frame_delay
       C    @sprite_frame_delay,@cycles_per_sprite_frame
       JL   !
       CLR  @sprite_frame_delay
       INCT @sprite_frame
       C    @sprite_frame,@player_sprite_frames
       JL   !
       CLR  @sprite_frame
!
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