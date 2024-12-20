       DEF  init_sprite_layer
       DEF  display_sprites
*
       REF  VDPADR,VDPREG
*
       REF  spr_definitions

       COPY '..\EQUCPUADR.asm'
       COPY '.\EQUGAME.asm'

init_sprite_layer
       DECT R10
       MOV  R11,*R10
* Sprites should be 16x16, magnified sprites, and VDP interrupts are enabled
       LI   R0,>01E3
       BL   @VDPREG
* Sprite Attribute Table
       LI   R0,>0500
       BL   @VDPREG
* Sprite Pattern Definition Table
       LI   R0,>0602
       BL   @VDPREG
* Write empty sprite atrribute list
       CLR  R0
       BL   @VDPADR
       LI   R0,>D000
       MOVB R0,@VDPWD
*
       LI   R0,>1000
       BL   @VDPADR
*
       LI   R0,spr_definitions
       MOV  R0,R1
       AI   R1,16*32
sprite_pattern_loop
       MOVB *R0+,@VDPWD
       C    R0,R1
       JL   sprite_pattern_loop
*
       BL   @display_sprites
*
       MOV  *R10+,R11
       RT

cycles_per_sprite_frame     DATA 9

* There are only 3 sprite frames, but this is used as an offset among 16-bit addresses
player_sprite_frames        DATA 3*2

display_sprites
       DECT R10
       MOV  R11,*R10
*
       CLR  R0
       BL   @VDPADR
* Is right-key being pressed?
       MOVB @KEYCOD,R0
       LI   R1,right_flag*>100
       COC  R1,R0
       JEQ  display_walking_player
* Display standing player sprite
       LI   R0,standing_player
       JMP  display_any_player_sprites
*
display_walking_player
       INC  @sprite_frame_delay
       C    @sprite_frame_delay,@cycles_per_sprite_frame
       JL   !
       CLR  @sprite_frame_delay
       INCT @sprite_frame
       C    @sprite_frame,@player_sprite_frames
       JL   !
       CLR  @sprite_frame
!
*
       MOV  @sprite_frame,R0
       AI   R0,walking_player
       MOV  *R0,R0
*
display_any_player_sprites
       MOV  R0,R1
       AI   R1,4*4+1
sprite_attribute_loop
       MOVB *R0+,@VDPWD
       C    R0,R1
       JL   sprite_attribute_loop
*
       MOV  *R10+,R11
       RT

walking_player
       DATA walking_player_1,standing_player,walking_player_2

walking_player_1
       DATA >7010,>2009
       DATA >9010,>3009
       DATA >7010,>0007
       DATA >9010,>1007
       DATA >D000,0
standing_player
       DATA >7010,>2409
       DATA >9010,>3409
       DATA >7010,>0407
       DATA >9010,>1407
       DATA >D000,0
walking_player_2
       DATA >7010,>2809
       DATA >9010,>3809
       DATA >7010,>0807
       DATA >9010,>1807
       DATA >D000,0