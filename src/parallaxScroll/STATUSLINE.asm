       DEF  status_print
*
       REF  VDPADR
       REF  write_string

status_message
       TEXT 'HP:        THINGS KILLED:'
       BYTE 0
       EVEN

status_print
       DECT R10
       MOV  R11,*R10
*
       LI   R0,>2000+(22*32)+1
       BL   @VDPADR
*
       LI   R0,status_message
       BL   @write_string
*
       MOV  *R10+,R11
       RT
