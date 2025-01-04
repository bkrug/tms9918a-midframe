       DEF  ent_init

       COPY './EQUGAME.asm'

*
*
test_settings DATA 0,>0400,>0C00,pig_char_1

pig_char_1    BYTE >44,>0F,0
              BYTE >40,>09,0
              BYTE 0
pig_char_2    BYTE >48,>0F,0
              BYTE >40,>09,0
              BYTE 0
apple_char    BYTE >4C,>08,0
              BYTE 0
turtle_char_1 BYTE >54,>0F,0
              BYTE >50,>03,0
              BYTE 0
turtle_char_2 BYTE >54,>0F,1
              BYTE >50,>03,0
              BYTE 0
turtle_char_3 BYTE >54,>0F,2
              BYTE >50,>03,0
              BYTE 0
rabbit_char_1 BYTE >58,>0A,0
              BYTE 0
rabbit_char_2 BYTE >5C,>0A,0
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