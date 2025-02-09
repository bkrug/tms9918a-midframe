       DEF  enm_init
       DEF  enm_handle

       COPY './EQUGAME.asm'
       COPY '../EQUCPUADR.asm'

*
* Hardware-sprite-horizontal-offset-from-entity, Sprite-char, Sprit-color
*
pig_char_1    BYTE >44,>0F
              BYTE >40,>09
              BYTE frame_end
pig_char_2    BYTE >48,>0F
              BYTE >40,>09
              BYTE frame_end
turtle_char_1 BYTE >50,>0F
              BYTE >4C,>03
              BYTE frame_end
turtle_char_2 BYTE >4C,>03
              BYTE frame_end
turtle_char_3 BYTE >50,>09
              BYTE >4C,>03
              BYTE frame_end
rabbit_char_1 BYTE >54,>0A
              BYTE frame_end
rabbit_char_2 BYTE >58,>0A
              BYTE frame_end

enm_init
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
enm_handle
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
       DECT R10
       MOV  R11,*R10
* Has the map scrolled enough to add another entity?
       MOV  @location_of_next_entity,R0
       S    @x_pos_4,R0
       JGT  ent_insert_return
* Yes, is the random seed initialized?
       MOV  @seed,R0
       JNE  already_initialized
* No, initalize it
       LI   R0,49281
       MOV  R0,@seed
       AB   @VINTTM,@(seed+1)
already_initialized
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
* Let R2 = index within possible_entites
* Select a random number of 0, 2, or 4
       BL   @get_random
       MOV  R7,R2
       CLR  R1
       DIV  @three,R1
       SLA  R2,1
* Let R1 = source of starting data for the chosen entity
* Let R2 = end of starting data
* Let R3 = copy of address of entity_list entry
       MOV  @possible_entites(R2),R1
       MOV  R1,R2
       AI   R2,entity_length
       MOV  R0,R3
* Insert entity data at the found location
!      MOV  *R1+,*R0+
       C    R1,R2
       JL   -!
* Replace x-position
       MOV  @location_of_next_entity,R2
       AI   R2,256*pixel_size
       MOV  R2,@entity_x_pos(R3)
* Decrease distance for next entity
       LI   R0,>8*pixel_size
       S    R0,@distance_between_entities
* Don't let distance decrease too much
       C    @distance_between_entities,@min_entity_distance
       JHE  !
       MOV  @min_entity_distance,@distance_between_entities
!
* Prepare for next insert
       A    @distance_between_entities,@location_of_next_entity
ent_insert_return
       MOV  *R10+,R11
       RT

min_entity_distance  DATA >30*pixel_size
three                DATA 3
possible_entites     DATA starting_pig,starting_turtle,starting_rabbit

starting_pig         BYTE e_type_pig         * entity-type
                     BYTE pig_fall_speed     * entity-status
                     DATA >0200              * entity's initial y-position
                     DATA 0                  * entity's x-position. this will be overwritten at initialization
                     DATA pig_char_1         * entity's initial animation frame
starting_turtle      BYTE e_type_turtle
                     BYTE 0
                     DATA >0600              * entity's initial y-position
                     DATA 0                  * entity's x-position. this will be overwritten at initialization
                     DATA turtle_char_1
starting_rabbit      BYTE e_type_rabbit
                     BYTE -rabbit_jump_speed
                     DATA rabbit_max_y       * entity's initial y-position
                     DATA 0                  * entity's x-position. this will be overwritten at initialization
                     DATA rabbit_char_1

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

type_moves    DATA 0,move_pig,move_turtle,move_rabbit

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
* Advance pig position
       S    @pig_x_speed,@entity_x_pos(R1)
* Pick pig animation frame
       MOVB @VINTTM,R3
       ANDI R3,>2000
       SRL  R3,8+4
       MOV  @pig_char_list(R3),@entity_char_and_color(R1)
* Let R2 = distance from left side of screen
* And from the player, sort-of.
       MOV  @entity_x_pos(R1),R2
       S    @x_pos_4,R2
* Is pig close enough to player/screen-edge to drop down?
       C    R2,@pig_close_to_player
       JGT  pig_return
* Yes, is the pig vertical speed still greater than zero?
       MOVB @entity_status(R1),R2
       JLT  pig_return
* Yes, drop pig
       SRA  R2,8
       A    R2,@entity_y_pos(R1)
* Decelerate pig
       SB   @pig_deceleration,@entity_status(R1)
*
pig_return
       RT

pig_fall_speed       EQU  3*pixel_size
pig_deceleration     BYTE 2
                     EVEN
pig_char_list        DATA pig_char_1,pig_char_2
pig_close_to_player  DATA 92*pixel_size
pig_x_speed          DATA 2*pixel_size

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
       S    @turtle_x_speed,@entity_x_pos(R1)
* Pick turtle animation frame
       MOVB @VINTTM,R3
       ANDI R3,>6000
       SRL  R3,8+4
       MOV  @turtle_char_list(R3),@entity_char_and_color(R1)
*
       RT

turtle_x_speed       DATA pixel_size
turtle_char_list     DATA turtle_char_1,turtle_char_2,turtle_char_3,turtle_char_2

*
* Move rabbit
*
* Input:
*   R0 - Address of current entity
move_rabbit
* Let R1 = address of rabbit entry
       MOV  R0,R1
* Advance rabbit x position
       S    @rabbit_x_speed,@entity_x_pos(R1)
* Change rabbit's vertical speed
       AB   @rabbit_deceleration,@entity_status(R1)
* Change rabbit's veritcal position
       MOVB @entity_status(R1),R2
       SRA  R2,8
       A    R2,@entity_y_pos(R1)
* Did the rabbit drop too low?
       LI   R2,rabbit_max_y
       C    @entity_y_pos(R1),R2
       JLE  rabbit_frame
* Yes, re-initialize speed & position
       MOV  R2,@entity_y_pos(R1)
       MOVB @rabbit_jump_byte,@entity_status(R1)
* Pick rabbit animation frame
rabbit_frame
       LI   R3,rabbit_char_2
       MOVB @entity_status(R1),R2
       JLT  !
       LI   R3,rabbit_char_1
!      MOV  R3,@entity_char_and_color(R1)
* Return
       RT

rabbit_jump_speed    EQU  -3*pixel_size-8
rabbit_max_y         EQU  >80*pixel_size
rabbit_x_speed       DATA 3*pixel_size/2
rabbit_deceleration  BYTE 3
rabbit_jump_byte     BYTE rabbit_jump_speed
                     EVEN

*
* Private: get_random
*
* Output:
*  R6 = changes
*  R7 = random value
RNDMOD DATA 7717
get_random
       LI   R6,28645
       MPY  @seed,R6
       AI   R7,31417
       MOV  R7,@seed
       CLR  R6
       SWPB R7
       DIV  @RNDMOD,R6
       RT