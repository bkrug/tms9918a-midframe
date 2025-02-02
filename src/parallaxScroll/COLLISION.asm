       DEF  col_detect

       COPY '.\EQUGAME.asm'
       COPY '..\EQUVAR.asm'
       COPY '..\EQUCPUADR.asm'

col_detect
       DECT R10
       MOV  R11,*R10
*
       BL   @calc_player_box
       BL   @collision_with_player
*
       MOV  *R10+,R11
       RT

player_top_offset       DATA 3*pixel_size
player_left_offset      DATA 0
player_bottom_offset    DATA 32*pixel_size
player_right_offset     DATA 7*pixel_size

calc_player_box
* Let R1 = memory address within collision box structure
* Let R2 = x-position of player sprite
       LI   R1,player_box
       LI   R2,player_from_screen_edge
       A    @x_pos_4,R2
* Calculate player's collision box
       MOV  @player_y_pos,*R1
       A    @player_top_offset,*R1+
*
       MOV  R2,*R1
       A    @player_left_offset,*R1+
*
       MOV  @player_y_pos,*R1
       A    @player_bottom_offset,*R1+
*
       MOV  R2,*R1
       A    @player_right_offset,*R1+
*
       RT

enemy_box_power      EQU  3
enemy_boxes
              BSS  8
* pig_box
              DATA 5*pixel_size,0
              DATA 16*pixel_size,16*pixel_size
* turtle_box
              DATA 0,0
              DATA 7*pixel_size,15*pixel_size
* rabbit_box
              DATA 0,0
              DATA 15*pixel_size,13*pixel_size
*
box_top              EQU  0
box_left             EQU  2
box_bottom           EQU  4
box_right            EQU  6

collision_with_player
* Let R1 = entry within entity_list
* Let R2 = player_box
       LI   R1,entity_list
       LI   R2,player_box
collision_with_player_loop
* Is entry empty?
       MOVB *R1,R3
       JEQ  skip_entity
* No, let R3 = address of enemy's collision box
* When shifting left, realize that call entity types are even numbers
       SRL  R3,8
       SLA  R3,enemy_box_power-1
       AI   R3,enemy_boxes
* Is enemy's left to left of player's right?
       MOV  @entity_x_pos(R1),R4
       A    @box_left(R3),R4
       C    R4,@box_right(R2)
       JH   skip_entity
* No, is enemy's right to right of player's left?
       MOV  @entity_x_pos(R1),R4
       A    @box_right(R3),R4
       C    R4,@box_left(R2)
       JL   skip_entity
* No, is enemy's top above player's bottom?
       MOV  @entity_y_pos(R1),R4
       A    *R3,R4
       C    R4,@box_bottom(R2)
       JH   skip_entity
* No, is enemy's bottom below player's top?
       MOV  @entity_y_pos(R1),R4
       A    @box_bottom(R3),R4
       C    R4,*R2
       JL   skip_entity
* Remove enemy from entity_list
       SB   *R1,*R1
*
skip_entity
       AI   R1,entity_length
       CI   R1,entity_list_end
       JL   collision_with_player_loop
*
       RT