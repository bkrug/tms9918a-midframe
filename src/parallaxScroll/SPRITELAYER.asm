       DEF  init_sprite_layer
       DEF  display_sprites
*
       REF  VDPADR,VDPREG
*
       REF  spr_definitions

       COPY '..\EQUCPUADR.asm'

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
       LI   R0,test_sprite
       LI   R1,5*4+test_sprite
sprite_attribute_loop
       MOVB *R0+,@VDPWD
       C    R0,R1
       JL   sprite_attribute_loop
*
       MOV  *R10+,R11
       RT

test_sprite
       DATA >7010,>2009
       DATA >9010,>3009
       DATA >7010,>0007
       DATA >9010,>1007
       DATA >D000,0