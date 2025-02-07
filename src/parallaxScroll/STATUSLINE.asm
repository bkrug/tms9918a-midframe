       DEF  status_print
       DEF  game_over_print
*
       REF  VDPADR
       REF  write_string

       COPY '.\EQUGAME.asm'
       COPY '..\EQUCPUADR.asm'

status_message
       TEXT 'HP:.....   THINGS KILLED:'
       BYTE 0
       EVEN
game_over_message
       TEXT 'GAME OVER!'
       BYTE 0
ZERO   BYTE '0'
       EVEN

status_print
       DECT R10
       MOV  R11,*R10
*
       LI   R0,screen_image_table_i+(22*32)+1
       BL   @VDPADR
*
       LI   R0,status_message
       BL   @write_string
* Display player health
       MOV  @player_health_points,R0
       BL   @convert_to_ascii
*
       LI   R0,screen_image_table_i+(22*32)+4
       BL   @VDPADR
       LI   R0,ascii_number
       BL   @write_string
* Display number of enemies killed
       MOV  @enemies_killed,R0
       BL   @convert_to_ascii
*
       LI   R0,screen_image_table_i+(22*32)+26
       BL   @VDPADR
       LI   R0,ascii_number
       BL   @write_string
*
       MOV  *R10+,R11
       RT

*
* Unsigned Word to ASCII
* ----------------------
* Input:
*   R0: Word to convert
* Output:
*   6 bytes at ascii_number
convert_to_ascii
* Let R3 = location of char to convert
       LI   R2,10
       LI   R3,ascii_number+5
* Null-terminate the string
       SB   *R3,*R3
* Divide by 10 until the number reaches zero
conversion_loop
       MOV  R0,R1
       JEQ  conversion_complete
       CLR  R0
       DIV  R2,R0
       SLA  R1,8
       AB   @ZERO,R1
       DEC  R3
       MOVB R1,*R3
       JMP  conversion_loop
* Put spaces at the front of the number string
conversion_complete
       CI   R3,ascii_number
       JEQ  string_complete
       DEC  R3
       MOVB @SPACE,*R3
       JMP  conversion_complete
string_complete
* return
       RT

*
*
*
game_over_print
       DECT R10
       MOV  R11,*R10
*
       LI   R0,screen_image_table_i+(22*32)+1
       BL   @VDPADR
*
       LI   R0,game_over_message
       BL   @write_string
*
       MOV  *R10+,R11
       RT