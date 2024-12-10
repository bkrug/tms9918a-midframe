       DEF  parallax_demo
*
       REF  VDPADR
       REF  transition_chars
       REF  unscrolled_patterns

       COPY '..\EQUVAR.asm'
       COPY '..\EQUCPUADR.asm'

parallax_demo
       LWPI WS
       LI   R10,STACK
*
       BL   @write_patterns_to_vdp
*
JMP    JMP  JMP

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
       SLA  R8,0
* Write to VDP RAM
       MOVB R8,@VDPWD
* Is this the end of one pattern?
       C    R5,R7
       JL   bit_shift_loop
* Yes, advance to next transition pairs
       INCT R2
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