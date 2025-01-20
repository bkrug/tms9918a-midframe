       DEF  ent_init

       COPY './EQUGAME.asm'

*
*
test_settings DATA 0,>0400,>0C00,pig_char_1

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