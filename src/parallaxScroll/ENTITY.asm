       DEF  ent_init
       DEF  ent_handle

       COPY './EQUGAME.asm'

*
* Hardware-sprite-horizontal-offset-from-entity, Sprite-char, Sprit-color
*
pig_char_1    BYTE >44,>0F
              BYTE >40,>09
              BYTE frame_end
pig_char_2    BYTE >48,>0F
              BYTE >40,>09
              BYTE frame_end
apple_char    BYTE >4C,>08
              BYTE frame_end
turtle_char_1 BYTE >54,>0F
              BYTE >50,>03
              BYTE frame_end
turtle_char_2 BYTE >50,>03
              BYTE frame_end
turtle_char_3 BYTE >54,>09
              BYTE >50,>03
              BYTE frame_end
turtle_char_4 BYTE >50,>03
              BYTE frame_end
rabbit_char_1 BYTE >58,>0A
              BYTE frame_end
rabbit_char_2 BYTE >5C,>0A
              BYTE frame_end

ent_init
* Initialize entity timers
       LI   R0,16*pixel_size
       MOV  R0,@location_of_next_entity
       LI   R0,(256+64)*pixel_size
       MOV  R0,@distance_between_entities
* Initialize entity list with entirely empty entries.
       LI   R0,entity_list
!      CLR  *R0+
       CI   R0,entity_list_end
       JL   -!
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

*
* Insert new entity, if the map has reached the proper location
*
ent_insert
       MOV  @location_of_next_entity,R0
       S    @x_pos_4,R0
       JGT  ent_insert_return
* Find empty entity location
       LI   R0,entity_list
!      MOVB *R0,*R0
       JEQ  found_empty_entry
       AI   R0,entity_length
       CI   R0,entity_list_end
       JL   -!
* All entries in the entity_list are full
       JMP  ent_insert_return
found_empty_entry
* Let R1 = index within possible_entites
       LI   R1,1
* Let R1 = source of starting data for the chosen entity
* Let R2 = end of starting data
       SLA  R1,1
       MOV  @possible_entites(R1),R1
       MOV  R1,R2
       AI   R2,entity_length
* Insert entity data at the found location
!      MOV  *R1+,*R0+
       C    R1,R2
       JL   -!
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

possible_entites     DATA starting_pig,starting_turtle

starting_pig  BYTE e_type_pig         * entity-type
              BYTE 0                  * unused
              DATA 0                  * entity-status
              DATA >0200              * entity's initial y-position
              DATA 0                  * entity's x-position. this will be overwritten at initialization
              DATA pig_char_1         * entity's initial animation frame
              DATA 0,0,0              * unused data
starting_turtle      BYTE e_type_turtle
                     BYTE 0
                     DATA 0
                     DATA >0600              * entity's initial y-position
                     DATA 0                  * entity's x-position. this will be overwritten at initialization
                     DATA turtle_char_1
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
* Let R2 = distance from left side of screen
* And from the player, sort-of.
       MOV  R0,R1
       MOV  @entity_x_pos(R1),R2
       S    @x_pos_4,R2
* Is the pig to the left of the screen?
       C    R2,@left_of_screen
       JLT  delete_entity
* Pick the next entity list entry
skip_empty_entry
       AI   R0,entity_length
*
       CI   R0,entity_list_end
       JL   ent_move_loop
*
       MOV  *R10+,R11
       RT

type_moves    DATA 0,move_pig,move_turtle

* Pig has moved far enough to the left that we can remove it from RAM
delete_entity
       CLR  *R0
       JMP  skip_empty_entry

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

pig_char_list        DATA pig_char_1,pig_char_2
pig_drop_speed       DATA 3*pixel_power/2
pig_close_to_player  DATA 96*pixel_size
pig_x_speed          DATA pixel_size

left_of_screen       DATA -32*pixel_size

*
* Move turtle
*
* Input:
*   R0 - Address of current entity
move_turtle
* Let R1 = address of turtle
       MOV  R0,R1
* Advance turtle position
       S    @pig_x_speed,@entity_x_pos(R1)
* Advance turtle status
       INC  @entity_status(R1)
* Pick turtle animation frame
       LI   R2,turtle_char_list
       MOV  @entity_status(R1),R3
       ANDI R3,>0060
       SRL  R3,4
       A    R3,R2
       MOV  *R2,@entity_char_and_color(R1)
*
       RT

turtle_char_list     DATA turtle_char_1,turtle_char_2,turtle_char_3,turtle_char_4