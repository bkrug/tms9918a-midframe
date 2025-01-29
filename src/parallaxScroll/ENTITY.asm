       DEF  ent_init
       DEF  ent_handle

       COPY './EQUGAME.asm'

*
* Hardware-sprite-horizontal-offset-from-entity, Sprite-char, Sprit-color
*
pig_char_1    BYTE 0,>44,>0F
              BYTE 0,>40,>09
              BYTE frame_end
pig_char_2    BYTE 0,>48,>0F
              BYTE 0,>40,>09
              BYTE frame_end
apple_char    BYTE 0,>4C,>08
              BYTE frame_end
turtle_char_1 BYTE 0,>54,>0F
              BYTE 0,>50,>03
              BYTE frame_end
turtle_char_2 BYTE 1,>54,>0F
              BYTE 0,>50,>03
              BYTE frame_end
turtle_char_3 BYTE 2,>54,>0F
              BYTE 0,>50,>03
              BYTE frame_end
rabbit_char_1 BYTE 0,>58,>0A
              BYTE frame_end
rabbit_char_2 BYTE 0,>5C,>0A
              BYTE frame_end

ent_init
* Initialize entity timers
       LI   R0,16*pixel_size
       MOV  R0,@location_of_next_entity
       LI   R0,(256+64)*pixel_size
       MOV  R0,@distance_between_entities
*
       LI   R0,entity_list
*
       CLR  R1
init_as_empty_loop
       MOV  R1,*R0+
       CI   R0,entity_list_end
       JL   init_as_empty_loop
*
       RT

*
* Handle entities
*
ent_handle
       DECT R10
       MOV  R11,*R10
*
       BL   @ent_insert
       BL   @ent_move
*
       MOV  *R10+,R11
       RT

ent_insert
       MOV  @location_of_next_entity,R0
       S    @x_pos_4,R0
       JGT  ent_insert_return
*
* Insert new entity
*
* Find empty entity location
       LI   R0,entity_list
* Insert pig data at the found location
       LI   R1,starting_pig
write_loop
       MOV  *R1+,*R0+
       CI   R1,starting_pig+entity_length
       JL   write_loop
* Replace x-position
       MOV  @location_of_next_entity,R2
       AI   R2,256*pixel_size
       MOV  R2,@(entity_list+entity_x_pos)
* Decrease distance for next entity
       LI   R0,2*pixel_size
       S    R0,@distance_between_entities
* Prepare for next insert
       A    @distance_between_entities,@location_of_next_entity
ent_insert_return
       RT

starting_pig  BYTE e_type_pig
              BYTE 0
              DATA 0,>0200,>1200,pig_char_1
              DATA 0,0,0

*
* Move entities
* Select each entity in memory and run it's movement algorithm
*
ent_move
       DECT R10
       MOV  R11,*R10
* Let R0 = position within entity list
       LI   R0,entity_list
ent_move_loop
* Let R1 = the entity type
       MOVB *R0,R1
* Is list entry empty?
       JEQ  skip_empty_entry
* No, push R0 to stack
       DECT R10
       MOV  R0,*R10
* Branch link to  the entity's movement algorithm
       SRL  R1,8
       MOV  @type_moves(R1),R1
       BL   *R1
* Pop R0 from stack
       MOV  *R10+,R0
* Pick the next entity list entry
skip_empty_entry
       AI   R0,entity_length
*
       CI   R0,entity_list_end
       JL   ent_move_loop
*
       MOV  *R10+,R11
       RT

type_moves    DATA 0,move_pig

*
* Move pig
*
* Input:
*   R0 - Address of current entity
move_pig
* Let R1 = address of pig
       MOV  R0,R1
* Advance pig status
       INC  @entity_status(R1)
* Advance pig position
       S    @pig_x_speed,@entity_x_pos(R1)
* Pick pig animation frame
       LI   R2,pig_char_list
       MOV  @entity_status(R1),R3
       ANDI R3,>0020
       SRL  R3,4
       A    R3,R2
       MOV  *R2,@entity_char_and_color(R1)
* Let R2 = distance from left side of screen
* And from the player, sort-of.
       MOV  @entity_x_pos(R1),R2
       S    @x_pos_4,R2
* Is the pig to the left of the screen?
       C    R2,@left_of_screen
       JLT  delete_pig
* Is pig close enough to player to drop down?
       C    R2,@pig_close_to_player
       JGT  pig_return
* Yes, has the pig dropped too low?
       C    @entity_y_pos(R1),@player_y_pos
       JGT  pig_return
* No, drop more
       A    @pig_drop_speed,@entity_y_pos(R1)
*
pig_return
       RT

* Pig has moved far enough to the left that we can remove it from RAM
delete_pig
       CLR  *R0
       JMP  pig_return

pig_char_list        DATA pig_char_1,pig_char_2
pig_drop_speed       DATA 3*pixel_power/2
pig_close_to_player  DATA 96*pixel_size
pig_x_speed          DATA pixel_size

left_of_screen       DATA -32*pixel_size
