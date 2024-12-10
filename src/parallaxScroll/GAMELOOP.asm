       DEF  parallax_demo
*
       REF  VDPADR,VDPREG
       REF  transition_chars
       REF  unscrolled_patterns
       REF  upper_tile_map
       REF  lower_tile_map
       REF  color_groups

       COPY '..\EQUVAR.asm'
       COPY '..\EQUCPUADR.asm'

parallax_demo
       LWPI WS
       LI   R10,STACK
* Pattern table
       LI   R0,>0401
       BL   @VDPREG
* Screen Image table
       LI   R0,>0209
       BL   @VDPREG
* Color table
       LI   R0,>0310
       BL   @VDPREG
*
       BL   @write_patterns_to_vdp
       BL   @write_colors
       BL   @write_part_of_screen
*
END    JMP  END

*
* Shift patterns and copy them to VDP RAM
*
write_patterns_to_vdp
       DECT R0
       MOV  R11,*R10
* Let R4 = address of current pattern table
       CLR  R4
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
       LI   R0,>0400
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
       LI   R0,>2400
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
* Write bytes to VDP RAM
row_of_tiles_loop
       MOVB *R2+,@VDPWD
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