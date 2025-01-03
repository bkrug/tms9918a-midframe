       DEF  init_sprite_layer
       DEF  display_sprites
*
       REF  VDPADR,VDPREG
*
       REF  normal_player_patterns
       REF  sword_player_patterns
       REF  entity_sprite_patterns

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
       LI   R0,vdp_reg_6_sprite_i
       MOV  R0,@sprite_pattern_vdp_reg
       BL   @VDPREG
* Write empty sprite atrribute list
       CLR  R0
       BL   @VDPADR
       LI   R0,>D000
       MOVB R0,@VDPWD
*
       LI   R0,sprite_pattern_table_i
       BL   @VDPADR
*
       LI   R0,normal_player_patterns
       BL   @write_player_patterns
*
       LI   R0,sprite_pattern_table_ii
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
       LI   R2,VDPWD
sprite_pattern_loop
       MOVB *R0+,*R2
       C    R0,R1
       JL   sprite_pattern_loop
*
       LI   R0,entity_sprite_patterns
       AI   R1,8*32
entity_pattern_loop
       MOVB *R0+,*R2
       C    R0,R1
       JL   entity_pattern_loop
*
       RT

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
* Let R4 = VDPWD
       MOV  @player_offset_address,R1
       MOV  @player_char_address,R2
       LI   R3,player_colors
       LI   R4,VDPWD
* Write sprites for player character
sprite_attribute_loop
       MOV  @player_y_pos,R0
       SLA  R0,8-pixel_power
       AB   *R1+,R0
       MOVB R0,*R4
       LI   R0,>1000
       AB   *R1+,R0
       MOVB R0,*R4
       MOVB *R2+,*R4
       MOVB *R3+,*R4
       CI   R3,player_colors+4
       JL   sprite_attribute_loop
* End the sprite list
       LI   R0,>D000
       MOVB R0,*R4
*
       MOV  @sprite_pattern_vdp_reg,R0
       BL   @VDPREG
*
       MOV  *R10+,R11
       RT

player_colors
       BYTE >0E,>05,>09,>09