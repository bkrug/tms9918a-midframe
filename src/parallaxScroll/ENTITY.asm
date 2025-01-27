       DEF  ent_init
       DEF  ent_move

       COPY './EQUGAME.asm'

*
*
test_settings DATA e_type_pig,0,>0200,>1200,pig_char_1
              DATA 0,0,0

e_type_empty  EQU  0
e_type_pig    EQU  2

*
* Hardware-sprite-horizontal-offset-from-entity, Sprite-char, Sprit-color
*
pig_char_1    BYTE 0,>44,>0F
              BYTE 0,>40,>09
              BYTE 0
pig_char_2    BYTE 0,>48,>0F
              BYTE 0,>40,>09
              BYTE 0
apple_char    BYTE 0,>4C,>08
              BYTE 0
turtle_char_1 BYTE 0,>54,>0F
              BYTE 0,>50,>03
              BYTE 0
turtle_char_2 BYTE 1,>54,>0F
              BYTE 0,>50,>03
              BYTE 0
turtle_char_3 BYTE 2,>54,>0F
              BYTE 0,>50,>03
              BYTE 0
rabbit_char_1 BYTE 0,>58,>0A
              BYTE 0
rabbit_char_2 BYTE 0,>5C,>0A
              BYTE 0

ent_init
       LI   R0,entity_list
       LI   R1,test_settings
write_loop
       MOV  *R1+,*R0+
       CI   R1,test_settings+entity_length
       JL   write_loop
*
       RT

*
* Move entities
*
ent_move
* Pick pig position
       LI   R1,entity_list
       INC  *R1
       S    @pig_x_speed,@entity_x_pos(R1)
* Pick pig animation frame
       LI   R2,pig_char_list
       MOV  *R1,R3
       ANDI R3,>0020
       SRL  R3,4
       A    R3,R2
       MOV  *R2,@entity_char_and_color(R1)
* Is pig close enough to player to drop down?
       MOV  @entity_x_pos(R1),R2
       S    @x_pos_4,R2
       JLT  pig_return
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