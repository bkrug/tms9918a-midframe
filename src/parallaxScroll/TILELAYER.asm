       DEF  smooth_scroll_one_pixel
       DEF  request_upper_redraw
       DEF  draw_single_upper_row
       DEF  init_tile_layer
*
       REF  VDPADR,VDPREG
*
       REF  transition_chars
       REF  unscrolled_patterns
       REF  upper_tile_map
       REF  lower_tile_map
       REF  color_groups

       COPY '.\EQUGAME.asm'
       COPY '..\EQUVAR.asm'
       COPY '..\EQUCPUADR.asm'

tile_code_offset   EQU  >60
pattern_offset     EQU  8*tile_code_offset

speed_1      DATA 1
speed_2      DATA 4
speed_3      DATA 8
speed_4      DATA 16

*
* Scroll the screen such that the lowest portion moves by 1 pixel
*
smooth_scroll_one_pixel
* Increase scroll amount
       A    @speed_4,@x_pos_4
       A    @speed_3,@x_pos_3
       A    @speed_2,@x_pos_2
       A    @speed_1,@x_pos_1
* Calculate pattern table register values
       MOV  @x_pos_1,R0
       ANDI R0,>0070
       SRL  R0,4
       AI   R0,>0400
       MOV  R0,@next_pattern_1
*
       MOV  @x_pos_2,R0
       ANDI R0,>0070
       SRL  R0,4
       AI   R0,>0400
       MOV  R0,@next_pattern_2
*
       MOV  @x_pos_3,R0
       ANDI R0,>0070
       SRL  R0,4
       AI   R0,>0400
       MOV  R0,@next_pattern_3
*
       MOV  @x_pos_4,R0
       ANDI R0,>0070
       SRL  R0,4
       AI   R0,>0400
       MOV  R0,@next_pattern_4
* Calculate lower screen image table register value
       MOV  @x_pos_4,R0
       ANDI R0,>0180
       SRL  R0,3+4-1
       AI   R0,>0208
       MOV  R0,@next_lower_screen
* Calculate upper screen image table register value.
* Base it on scroll region 3, because it is the fastest moving in the upper screen.
       MOV  @x_pos_3,R0
       SRL  R0,4+3
       ANDI R0,>0003
       SLA  R0,1
       AI   R0,>0208
       MOV  R0,@next_upper_screen
*
dont_change_upper_screen
       RT

*
* Request that the upcoming screen image table be redrawn
* This method should be called on the first frame
* after changing the screen image table for the upper screen.
*
request_upper_redraw
* Let @address_of_draw_request = beginning of a screen image table
* Given the current screen image table,
* get the address of the screen image table that has an address >800 bytes higher
       MOV  @current_upper_screen,R0
       ANDI R0,>000F
       AI   R0,vdp_address_for_next_screen-8
       MOV  *R0,@address_of_draw_request
* Calculate the expected x-position of each scroll region,
* for the next time that we change the screen image table of the upper screen.
       MOV  @x_pos_1,@expected_1
       MOV  @x_pos_2,@expected_2
       MOV  @x_pos_3,@expected_3
       MOV  @x_pos_4,@expected_4
*
       MOV  @speed_1,R0
       SLA  R0,4
       A    R0,@expected_1
       MOV  @speed_2,R0
       SLA  R0,4
       A    R0,@expected_2
       MOV  @speed_3,R0
       SLA  R0,4
       A    R0,@expected_3
       MOV  @speed_4,R0
       SLA  R0,4
       A    R0,@expected_4
*
       RT

*
* If the upper screen image table is defined by VDP Reg 4 = >08,
* then the VDP address of the current table is at >2000.
* We don't use the screen image table at >2400 because it overlaps tile patterns.
* So the next screen image table is at >2800.
* The same pattern is repeated 3 more times.
*
vdp_address_for_next_screen
       DATA >2800,>3000,>3800,>2000

*
* Draw one row in the upcoming screen image table
*
draw_single_upper_row
* If the requested VDP address is <= 0, then there is no re-draw request.
* If there is no request for a screen redraw, then return.
       MOV  @address_of_draw_request,R0
       JGT  !
       RT
!
* There is a redraw request
       DECT R10
       MOV  R11,*R10
* Let R1 = copy of R0
       MOV  R0,R1
* R0 already contains VDP address for writing.
* Set VDP write address.
       BL   @VDPADR
* Set VDP address for next game loop iteration.
       MOV  R1,R0
       AI   R0,32
       MOV  R0,@address_of_draw_request
* Let R0 = screen position relative to top-left of screen
       MOV  R1,R0
       ANDI R0,>03FF
* If we finished drawing the top 16 rows,
* then remove the draw request for next game loop iteration.
       CI   R0,16*32
       JL   !
       SETO @address_of_draw_request
!
* Let R0 = current row
       SRL  R0,5
* Let R1 = address within x_pos_by_row
       MOV  R0,R1
       SLA  R1,1
       AI   R1,x_pos_by_row
* Let R1 = address of either x_pos_1 or x_pos_2 or x_pos_3
       MOV  *R1,R1
* Let R1 = current x-position of this scroll region
       MOV  *R1,R1
* Let R1 = left-most column from map displayed on screen
       SRL  R1,4+3
       ANDI R1,>003F
* Let R0 = current row * 64 (map width = 64)
       SLA  R0,6
* Let R2 = address in tile map to read from
       LI   R2,upper_tile_map
       AI   R2,6
       A    R0,R2
       A    R1,R2
* Let R3 = address past edge of the map
       LI   R3,upper_tile_map
       A    R0,R3
       AI   R3,6+64
* Let R4 = number of tiles left to write
       LI   R4,32
*
row_within_next_screen_loop
       MOVB *R2+,R5
       AI   R5,tile_code_offset*>100
       MOVB R5,@VDPWD
* Map is round.
* If we reached the right edge, next tile is on left edge.
       C    R2,R3
       JL   !
       AI   R2,-64
!
* If we have not drawn 32 tiles, continue with next tile.
       DEC  R4
       JNE  row_within_next_screen_loop
*
       MOV  *R10+,R11
       RT

*
* For each row in the upper screen,
* A different x position can be used to determine
* the left most column
*
x_pos_by_row
       DATA expected_1
       DATA expected_1
       DATA expected_1
       DATA expected_1
       DATA expected_1
       DATA expected_1
       DATA expected_1
       DATA expected_1
*
       DATA expected_2
       DATA expected_2
       DATA expected_2
       DATA expected_3
       DATA expected_3
       DATA expected_3
       DATA expected_3
       DATA expected_3

*
* Initialize tile layer
*
init_tile_layer
       DECT R10
       MOV  R11,*R10
* Screen Image table
       LI   R0,>0208
       BL   @VDPREG
* Color table
       LI   R0,>0302
       BL   @VDPREG
* Pattern table
       LI   R0,>0401
       BL   @VDPREG
* Background color
       LI   R0,>0715
       BL   @VDPREG
*
       BL   @write_patterns_to_vdp
       BL   @write_colors
       BL   @write_part_of_screen
       BL   @write_lower_screen
*
       MOV  *R10+,R11
       RT

*
* Shift patterns and copy them to VDP RAM
*
write_patterns_to_vdp
       DECT R10
       MOV  R11,*R10
* Let R4 = address of current pattern table
       LI   R4,pattern_offset
pattern_table_loop:
* Set VDP write address
       MOV  R4,R0
       BL   @VDPADR
* Let R2 = position within transition_chars
* Let R3 = end of transition_chars
       LI   R2,transition_chars
       MOV  @-2(R2),R3
       SLA  R3,1
       A    R2,R3
* Let R0 = shift amount
* Determine this by dividing the pattern table's address by >800
       MOV  R4,R0
       SRL  R0,11
transition_pair_loop:
* Let R5 = address of left char
* Let R6 = address of right char
       MOVB *R2+,R5
       MOVB *R2+,R6
       SRL  R5,8
       SRL  R6,8
       SLA  R5,3
       SLA  R6,3
       AI   R5,unscrolled_patterns
       AI   R6,unscrolled_patterns
* Let R7 = end of pattern
       MOV  R5,R7
       AI   R7,8
bit_shift_loop:
* Let R8 = merged pattern
       MOVB *R6+,R8       
       SRL  R8,8
       MOVB *R5+,R8
* Shift
       MOV  R0,R0
       JEQ  !
       SLA  R8,0
!
* Write to VDP RAM
       MOVB R8,@VDPWD
* Is this the end of one pattern?
       C    R5,R7
       JL   bit_shift_loop
* Was that the last transition pair?
       C    R2,R3
       JL   transition_pair_loop
* Yes, advance to next pattern table
       AI   R4,>800
* Was this the last pattern table?
       CI   R4,>4000
       JL   pattern_table_loop
* Yes, return to caller
       MOV  *R10+,R11
       RT

*
*
*
write_colors
       DECT R10
       MOV  R11,*R10
* Let R1 = address within color table
* Let R2 = end of color table in ROM
       LI   R1,color_groups
       MOV  @-2(R1),R2
       A    R1,R2
* Set VDP address
       LI   R0,tile_code_offset/8+>80
       BL   @VDPADR
*
color_loop
       MOVB *R1+,@VDPWD
       C    R1,R2
       JL   color_loop
*
       MOV  *R10+,R11
       RT

*
*
*
write_part_of_screen
       DECT R10
       MOV  R11,*R10
*
       LI   R0,>2000
       BL   @VDPADR
* Let R1 = address of tile map
       LI   R1,upper_tile_map
* Let R2 = row within tile map
       MOV  R1,R2
       AI   R2,6
upper_screen_loop
* Let R3 = after the point we can fit on screen
       MOV  R2,R3
       AI   R3,32
* Let R5 = a constant
       LI   R5,tile_code_offset*>100
* Write bytes to VDP RAM
row_of_tiles_loop
       MOVB *R2+,R0
       AB   R5,R0
       MOVB R0,@VDPWD
       C    R2,R3
       JL   row_of_tiles_loop
* Advance to next row
       AI   R2,-32
       A    *R1,R2
* Was that the last row?
       MOV  R1,R0
       AI   R0,>40*>10+6
       C    R2,R0
       JL   upper_screen_loop
*
       MOV  *R10+,R11
       RT

*
* Write lower screen
*
write_lower_screen
       DECT R10
       MOV  R11,*R10
* Let R1 = address within VDP RAM
* Let R2 = left-most column of screen
       LI   R1,>2000+(16*32)
       CLR  R2
lower_screen_image_loop
* Set address within screen image table
       MOV  R1,R0
       BL   @VDPADR
* Draw one screen image table
       MOV  R2,R0
       BL   @write_one_screen_table
* Continue with next screen image table
       AI   R1,>800
       INC  R2
       CI   R2,4
       JL   lower_screen_image_loop
*
       MOV  *R10+,R11
       RT

*
* Input:
*   R0 - left-most column
*   VDP RAM address already set
write_one_screen_table
       DECT R10
       MOV  R11,*R10
       DECT R10
       MOV  R2,*R10
       DECT R10
       MOV  R1,*R10
* Let R1 = address of left-most character in the current row
       LI   R1,lower_tile_map
       AI   R1,6
* Let R2 = end of row in map (but the row is supposed to get repeated several times)
       MOV  R1,R2
       AI   R2,4
lower_table_loop
* Let R3 = address of current character in the row
* Let R4 = number of characters to write in this row
       MOV  R1,R3
       A    R0,R3
       LI   R4,32
lower_row_loop
* Write one character
       MOVB *R3+,R5
       AI   R5,tile_code_offset*>100
       MOVB R5,@VDPWD
* Select next character
       C    R3,R2
       JL   !
       MOV  R1,R3
!
* Was this the last character in the row?
       DEC  R4
       JNE  lower_row_loop
* Yes, advance to next row
       MOV  R2,R1
       AI   R2,4
* Was this the last row?
       LI   R5,lower_tile_map
       AI   R5,8*4+6
       C    R1,R5
       JL   lower_table_loop
* Yes, return
       MOV  *R10+,R1
       MOV  *R10+,R2
       MOV  *R10+,R11
       RT