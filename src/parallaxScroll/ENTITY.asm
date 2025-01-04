       DEF  ent_init

       COPY './EQUGAME.asm'

*
*
test_settings DATA 0,>0400,>0C00,pig_char_1

pig_char_1    BYTE >10,>09,0
              BYTE >11,>0F,0
              BYTE 0
pig_char_2    BYTE >10,>09,0
              BYTE >12,>0F,0
              BYTE 0
apple_char    BYTE >13,>08,0
              BYTE 0
turtle_char_1 BYTE >14,>03,0
              BYTE >15,>0F,0
              BYTE 0
turtle_char_2 BYTE >14,>03,0
              BYTE >15,>0F,1
              BYTE 0
turtle_char_3 BYTE >14,>03,0
              BYTE >15,>0F,2
              BYTE 0
rabbit_char_1 BYTE >16,>0A,0
              BYTE 0
rabbit_char_2 BYTE >17,>0A,0
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