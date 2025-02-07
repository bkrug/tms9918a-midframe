       DEF  col_init
       DEF  col_detect

       COPY '.\EQUGAME.asm'
       COPY '..\EQUVAR.asm'
       COPY '..\EQUCPUADR.asm'

col_init
       LI   R0,32
       MOV  R0,@player_health_points

sword_button_down           BYTE sword_flag,0
                            EVEN

col_detect
       DECT R10
       MOV  R11,*R10
* Is sword key being pressed?
       MOVB @KEYCOD,R0
       COC  @sword_button_down,R0
       JNE  !
* Yes, detect collision with sword
       BL   @calc_sword_box
       BL   @collision_with_sword
* Detect collision with player
!      BL   @calc_player_box
       BL   @collision_with_player
*
       MOV  *R10+,R11
       RT

player_top_offset       DATA 1*magnified_pixel
player_left_offset      DATA 3*magnified_pixel
player_bottom_offset    DATA 32*magnified_pixel
player_right_offset     DATA 10*magnified_pixel

* SUGGESTION: Give the player a different collision box when jumping from standing or walking
*
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

sword_top_offset       DATA 7*magnified_pixel
sword_left_offset      DATA 10*magnified_pixel
sword_bottom_offset    DATA 16*magnified_pixel
sword_right_offset     DATA 16*magnified_pixel

calc_sword_box
* Let R1 = memory address within collision box structure
* Let R2 = x-position of sword within player sprite
       LI   R1,sword_box
       LI   R2,player_from_screen_edge
       A    @x_pos_4,R2
* Calculate sword's collision box
       MOV  @player_y_pos,*R1
       A    @sword_top_offset,*R1+
*
       MOV  R2,*R1
       A    @sword_left_offset,*R1+
*
       MOV  @player_y_pos,*R1
       A    @sword_bottom_offset,*R1+
*
       MOV  R2,*R1
       A    @sword_right_offset,*R1+
*
       RT

enemy_box_power      EQU  3
enemy_boxes
              BSS  8
* pig_box
              DATA 5*magnified_pixel,5*magnified_pixel
              DATA 16*magnified_pixel,13*magnified_pixel
* turtle_box
              DATA 0,0
              DATA 7*magnified_pixel,15*magnified_pixel
* rabbit_box
              DATA 4*magnified_pixel,1*magnified_pixel
              DATA 15*magnified_pixel,13*magnified_pixel
*
box_top              EQU  0
box_left             EQU  2
box_bottom           EQU  4
box_right            EQU  6
enemy_damage         DATA 4

*
*
*
collision_with_player
       DECT R10
       MOV  R11,*R10
*
       LI   R2,player_box
       BL   @collision_with_thing
       JNE  !
* Collision detected
* Decrease hero health
       S    @enemy_damage,@player_health_points
* Return
!      MOV  *R10+,R11
       RT

*
*
*
collision_with_sword
       DECT R10
       MOV  R11,*R10
*
       LI   R2,sword_box
       BL   @collision_with_thing
       JNE  !
* Collision detected
* Increment things killed
* Return
!      MOV  *R10+,R11
       RT

*
* Input:
*   R2: address of the collision box for the thing enemies collied with
* Output:
*   if EQ status bit set, collision detected
*
collision_with_thing
* If R9 == 0, collision detected.
* If R9 == -1, no collision.
       SETO R9
* Let R1 = entry within entity_list
       LI   R1,entity_list
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
* Collision detected
       CLR  R9
* Remove enemy from entity_list
       SB   *R1,*R1
*
skip_entity
       AI   R1,entity_length
       CI   R1,entity_list_end
       JL   collision_with_player_loop
* Set EQ status bit according to whether or not collision happened
       MOV  R9,R9
*
       RT