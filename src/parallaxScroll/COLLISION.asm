       DEF  col_detect

       COPY '.\EQUGAME.asm'
       COPY '..\EQUVAR.asm'
       COPY '..\EQUCPUADR.asm'

pig_box         DATA 5*pixel_size,0
                DATA 16*pixel_size,16*pixel_size
turtle_box      DATA 0,0
                DATA 7*pixel_size,15*pixel_size
rabbit_box      DATA 0,0
                DATA 15*pixel_size,13*pixel_size

player_top_offset       DATA 3*pixel_size
player_left_offset      DATA 0
player_bottom_offset    DATA 32*pixel_size
player_right_offset     DATA 7*pixel_size

col_detect
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