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

display_sprites
       DECT R10
       MOV  R11,*R10
*
       CLR  R0
       BL   @VDPADR
*
       INC  @sprite_frame_delay
       LI   R0,9
       C    @sprite_frame_delay,R0
       JL   !
       CLR  @sprite_frame_delay
       INCT @sprite_frame
       LI   R0,6
       C    @sprite_frame,R0
       JL   !
       CLR  @sprite_frame
!
*
       MOV  @sprite_frame,R0
       AI   R0,test_sprite
       MOV  *R0,R0
*
       MOV  R0,R1
       AI   R1,4*4+1
sprite_attribute_loop
       MOVB *R0+,@VDPWD
       C    R0,R1
       JL   sprite_attribute_loop
*
       MOV  *R10+,R11
       RT

test_sprite
       DATA test_sprite_1,test_sprite_2,test_sprite_3

test_sprite_1
       DATA >7010,>2009
       DATA >9010,>3009
       DATA >7010,>0007
       DATA >9010,>1007
       DATA >D000,0
test_sprite_2
       DATA >7010,>2409
       DATA >9010,>3409
       DATA >7010,>0407
       DATA >9010,>1407
       DATA >D000,0
test_sprite_3
       DATA >7010,>2809
       DATA >9010,>3809
       DATA >7010,>0807
       DATA >9010,>1807
       DATA >D000,0