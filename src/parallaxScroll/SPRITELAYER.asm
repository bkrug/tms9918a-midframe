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
       BL   @write_one_pattern_table
*
       LI   R0,sprite_pattern_table_ii
       BL   @VDPADR
*
       LI   R0,sword_player_patterns
       BL   @write_one_pattern_table
*
       BL   @display_sprites
*
       MOV  *R10+,R11
       RT

*
*
*
write_one_pattern_table
       MOV  R0,R1
       AI   R1,16*32
       LI   R2,VDPWD
sprite_pattern_loop
       MOVB *R0+,*R2
       C    R0,R1
       JL   sprite_pattern_loop
*
       LI   R0,entity_sprite_patterns
       MOV  R0,R1
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
* Display first of the entities
       BL   @display_entity
* End the sprite list
       LI   R0,>D000
       MOVB R0,*R4
*
       MOV  @sprite_pattern_vdp_reg,R0
       BL   @VDPREG
*
       MOV  *R10+,R11
       RT

*
* Display one multisprite entity
*
display_entity
       DECT R10
       MOV  R11,*R10
* Let R0 = address within the first item in the entity list
*          (the y-pos rather than beginning of the item)
       LI   R0,entity_list+entity_y_pos
* Let R1 = y-position rounded to a pixel
       MOV  *R0+,R1
       SRL  R1,pixel_power
       SLA  R1,8
* Let R2 = x-position to nearest sub-pixel
       MOV  *R0+,R2
       S    @x_pos_4,R2
* Is entity's x-position on-screen?
       CI   R2,-32*pixel_size
       JLT  display_entity_return
       CI   R2,256*pixel_size
       JGT  display_entity_return
* Let R5 = early clock
* If early clock is turned on, increase x-position
       CLR  R5
       MOV  R2,R2
       JGT  !
       JEQ  !
       LI   R5,>F000
       AI   R2,32*pixel_size
!
* Let R2 = x-position rounded to a pixel
       SRL  R2,pixel_power
       SLA  R2,8
* Yes, Let R0 = address in char/color list
       MOV  *R0,R0
* Draw each hardware sprite in multi-sprite entity
       BL   @draw_entity_hardware_sprite
       BL   @draw_entity_hardware_sprite
*
display_entity_return
*
       MOV  *R10+,R11
       RT

*
* Draw a hardware sprite within the larger multi-sprite entity
*
* Input:
*  R0, R1, R2
*  R4 - VDPWD
*  R5 - early clock value
* Output:
*  R0 - next entry in char-code/color list
* Changed:
*  R3
draw_entity_hardware_sprite
* y-pos
       MOVB R1,*R4
* x-pos
       MOVB R2,R3
       AB   *R0+,R3
       MOVB R3,*R4
* sprite-char
       MOVB *R0+,*R4
* sprite-color and early-clock
       MOVB *R0+,R3
       AB   R5,R3
       MOVB R3,*R4
*
       RT

player_colors
       BYTE >0E,>05,>09,>09