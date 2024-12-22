       DEF  init_sprite_layer
       DEF  display_sprites
*
       REF  VDPADR,VDPREG
*
       REF  normal_player_patterns
       REF  sword_player_patterns

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
       MOV  R0,@sprite_pattern_vdp_reg
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
       LI   R0,normal_player_patterns
       BL   @write_player_patterns
*
       LI   R0,>1800
       BL   @VDPADR
*
       LI   R0,sword_player_patterns
       BL   @write_player_patterns
*
       BL   @display_sprites
*
       MOV  *R10+,R11
       RT

*
*
*
write_player_patterns
       MOV  R0,R1
       AI   R1,16*32
sprite_pattern_loop
       MOVB *R0+,@VDPWD
       C    R0,R1
       JL   sprite_pattern_loop

*
*
*
display_sprites
       DECT R10
       MOV  R11,*R10
*
       CLR  R0
       BL   @VDPADR
* Let R1 = address of player normal_player_offsets
* Let R2 = address of player chars
* Let R3 = address of player colors
       MOV  @player_offset_address,R1
       MOV  @player_char_address,R2
       LI   R3,player_colors
* Write sprites for player character
sprite_attribute_loop
       LI   R0,>7000
       AB   *R1+,R0
       MOVB R0,@VDPWD
       LI   R0,>1000
       AB   *R1+,R0
       MOVB R0,@VDPWD
       MOVB *R2+,@VDPWD
       MOVB *R3+,@VDPWD
       CI   R3,player_colors+4
       JL   sprite_attribute_loop
* End the sprite list
       LI   R0,>D000
       MOVB R0,@VDPWD
*
       MOV  @sprite_pattern_vdp_reg,R0
       BL   @VDPREG
*
       MOV  *R10+,R11
       RT

player_colors
       BYTE >09,>09,>07,>07