       DEF  init_sprite_layer
*
       REF  VDPADR
*
       REF  spr_definitions

       COPY '..\EQUCPUADR.asm'

init_sprite_layer
       DECT R10
       MOV  R11,*R10
*
       LI   R0,>1000
       BL   @VDPADR
*
       LI   R0,spr_definitions
       MOV  R0,R1
       AI   R1,16*16
sprite_pattern_loop
       MOVB *R0+,@VDPWD
       C    R0,R1
       JL   sprite_pattern_loop
*
       MOV  *R10+,R11
       RT