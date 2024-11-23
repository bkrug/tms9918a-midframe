       DEF  BEGIN
*
       REF  STACK,WS                        Ref from VAR
       REF  OLDR12,COUNT,COLOR,RETPT
       REF  isr_count
       REF  GROMCR                          Ref from GROM
       REF  DSPINT,NUMASC                   Ref from DISPLAY
       REF  VDPREG,VDPADR,VDPWRT            Ref from VDP

*
* Addresses
*
       COPY 'EQUCPUADR.asm'
       COPY 'EQU.asm'

*
* Runable code
*
BEGIN
*
       LWPI WS
       LI   R10,STACK
*
       LIMI 0    
*
       BL   @GROMCR              Copy pattern definitions from GROM to VRAM
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
       MOV  R0,@COLOR
*
* Game Loop
*
game_loop:
* Block thread until then end of a frame
* Fool TI-99/4a into thinking that later interrupts are VDP interrupts.
       BL   @block_vdp_interrupt
* Start clock for timer interrupt
       LI   R1,frame_wait
       BL   @set_timer
* Set background color at top of screen
       LI   R0,>07FD
       BL   @VDPREG
* Set timer-interrupt routine
       LI   R1,OURISR
       MOV  R1,@USRISR
       CLR  @isr_count
* Enable Timer interrupt prioritization
       CLR  R12
       SBO  3
* Swap colors every second
       DEC  @COUNT
       JNE  flash
       LI   R0,>0384
       BL   @VDPADR
       SWPB @COLOR
       MOVB @COLOR,@VDPWD
       LI   R0,60
       MOV  R0,@COUNT
flash
* Enable interrupts
       LIMI 2
* Don't end game loop until the timer-interrupt has triggered
while_waiting_for_interrupt:
       MOV  @isr_count,R0
       JEQ  while_waiting_for_interrupt
       JMP  game_loop

*
* Private Method:
* Initialize Timer
*
* Input
*   R1 - time before trigger (least significant 14-bits)
set_timer:
       CLR  R12         CRU base of the TMS9901 
       SBO  0           Enter timer mode
       INCT R12         Address of bit 1 
       LDCR R1,14       Load value 
       DECT R12         There is a faster way (see http://www.nouspikel.com/ti99/titechpages.htm) 
       SBZ  0           Exit clock mode, start decrementer 
       RT

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
       INC  @isr_count
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

*
* Wait for the VDP interrupt, but don't clear it.
* Any future interrupts will be interpreted by ROMs as VDP interrupts.
* We can no longer listen for VDP interrupts,
* but we can listen for timer interrupts.
*
* TODO: These should be BLWP methods
block_vdp_interrupt:
       LIMI 0
* Munge the GPLWS.
       LWPI >83E0
       CLR  R14               * Disable cassette interrupt and protect >8379.
       LI   R15,>877B         * Disable VDPST reading and protect >837B.   (>FC00 + >877B = >837B, so this results in moving >837B to itself)
* Munge the INTWS.
       LWPI >83C0
       SETO R1                * Disable all VDP interrupt processing.
       SETO R11               * Disable screen timeouts.
       CLR  R12               * Set to 9901 CRU base.
* Wait for one frame to finish
       SBO  2
       MOVB @>8802,R8
*
* Synchronize with the next VDP interrupt.
SYNC   TB   2                 * Check for VDP interrupt.
       JEQ  SYNC
* Configure the 9901 for interrupts.
       SBZ  1                 * Disable external interrupt prioritization.
       SBZ  2                 * Disable VDP interrupt prioritization.
* Done
       LWPI WS
       RT