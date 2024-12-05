       DEF  BEGIN
*
       REF  DSPINT,NUMASC                   Ref from DISPLAY
       REF  VDPREG,VDPADR,VDPWRT            Ref from VDP
       REF  block_vdp_interrupt             Ref from PIXELROW
       REF  set_timer                       "

*
* Addresses
*
       COPY 'EQUCPUADR.asm'
       COPY 'EQUVAR.asm'

frame_wait EQU  375     * about 8 milliseconds / about half of a video interrupt

*
* Runable code
*
BEGIN
*
       LWPI WS
       LI   R10,STACK
*
       LIMI 0    
* Skip first VDP interrupt; it's too late to measure the full time.
       LIMI 2
       MOVB @VINTTM,R0
FRSTLP CB   @VINTTM,R0
       JEQ  FRSTLP
       LIMI 0
* Set pattern that can flash.
       LI   R0,>0900
       BL   @VDPADR
       LI   R1,>5522
       MOVB R1,@VDPWD
       SWPB R1
       MOVB R1,@VDPWD
       SWPB R1
       MOVB R1,@VDPWD
       SWPB R1
       MOVB R1,@VDPWD
       SWPB R1
       MOVB R1,@VDPWD
       SWPB R1
       MOVB R1,@VDPWD
       SWPB R1
       MOVB R1,@VDPWD
       SWPB R1
       MOVB R1,@VDPWD
*
       LI   R0,60
       MOV  R0,@COUNT
       LI   R0,>1771
       MOV  R0,@swappable_colors
*
* Game Loop
*
game_loop:
* Disable interrupts
       LIMI 0
* Block thread until then end of a frame
* Fool TI-99/4a into thinking that later interrupts are VDP interrupts.
       BLWP @block_vdp_interrupt
* Start clock for timer interrupt
       LI   R1,frame_wait
       BL   @set_timer
* Set background color at top of screen
       LI   R0,>07FD
       BL   @VDPREG
* Set timer-interrupt routine
       LI   R1,OURISR
       MOV  R1,@USRISR
       CLR  @isr_hit_count
* Enable Timer interrupt prioritization
       CLR  R12
       SBO  3
* Swap colors every second
       DEC  @COUNT
       JNE  flash
       LI   R0,>0384
       BL   @VDPADR
       SWPB @swappable_colors
       MOVB @swappable_colors,@VDPWD
       LI   R0,60
       MOV  R0,@COUNT
flash
* Enable interrupts
       LIMI 2
* Don't end game loop until the timer-interrupt has triggered
while_waiting_for_interrupt:
       MOV  @isr_hit_count,R0
       JEQ  while_waiting_for_interrupt
       JMP  game_loop

*
* This is a traditional User-Defined interrupt.
* It would be triggered by the VDP interrupt,
* if we had not blocked those.
*
OURISR
       LIMI 0
* Turn off timer-interrupt
       CLR  R12
       SBZ  3
* For some reason we need to re-confirm that we don't want VDP interrupts
       SBZ  2
* Let main code know if the interrupt was hit or not
       INC  @isr_hit_count
* Get stack pointer
       LI   R10,WS
       AI   R10,2*10
       MOV  *R10,R10
* Save Return address
       DECT R10
       MOV  R11,*R10
* Set background color at bottom of screen
       LI   R0,>07F4
       BL   @VDPREG
*
       LIMI 2
*
       MOV  *R10+,R11
       RT