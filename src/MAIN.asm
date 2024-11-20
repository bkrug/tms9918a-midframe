       DEF  BEGIN
*
       REF  STACK,WS                        Ref from VAR
       REF  OLDR12,COUNT,COLOR,RETPT
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
GAMELP
* Initialize Timer
       LI   R0,frame_wait      Middle of screen
       LI   R1,OURISR          That's our hook
       BL   @TIMEON            Start the timer
* Set background color at top of screen
       LI   R0,>07FD
       BL   @VDPREG
* Initialize midframe interrupt
       LI   R11,IRET           Desired ISR return point
       MOV  R11,@RETPT         From now on, timer interrupts will return at IRET
* Wait for midframe interrupt
       LIMI 2                  Enable interrupts
MIDLP  JMP  MIDLP
* Interrupt happened. Screen color was changed by OURISR
IRET   LIMI 0                  Disable interrupts (Our ISR returns here)
       BL   @TIMOFF            Stops the timer. Restores VDP interrupt.
* Swap colors every second
       DEC  @COUNT
       JNE  CURSOR
       LI   R0,>0384
       BL   @VDPADR
       SWPB @COLOR
       MOVB @COLOR,@VDPWD
       LI   R0,60
       MOV  R0,@COUNT
CURSOR
* Wait for VDP interrupt signalling end of frame
       LIMI 2
       MOVB @VINTTM,R0
TOPLP  CB   @VINTTM,R0
       JEQ  TOPLP
       LIMI 0
* Continue Game Loop
       JMP  GAMELP

*
* Private Method:
* Initialize Timer
*
INTTIM 
       CLR  R12         CRU base of the TMS9901 
       SBO  0           Enter timer mode
       LI   R1,>3FFF    Maximum value
       INCT R12         Address of bit 1 
       LDCR R1,14       Load value 
       DECT R12         There is a faster way (see http://www.nouspikel.com/ti99/titechpages.htm) 
       SBZ  0           Exit clock mode, start decrementer 
       RT

*
* Private Method:
* Get Time from CRU
* Output: R2
*   - Status bits compared to 0
*
GETTIM CLR  R12 
       SBO  0           Enter timer mode 
       STCR R2,15       Read current value (plus mode bit)
       SBZ  0
* Ignore left-most and right-most bits, while maintaining sign
       SLA  R2,1
       SRA  R2,2
       RT

* This routine hooks the timer interrupts
* It expects a delay value in R0
* and a branch vector in R1 (or >0000 to use a forever loop)
TIMEON SOCB @H20,@>83FD        Set timer interrupt flag bit
       MOV  R12,@OLDR12        Preserve caller's R12 
       CLR  R12                CRU base address >0000 
       SBZ  1                  Disable peripheral interrupts 
       SBZ  2                  Disable VDP interrupts 
       SBO  3                  Enable timer interrupts
       MOV  R1,@>83E2          Zero if we want to wait in a forever loop 
       JEQ  EVERLP      
       SETO @>83E2             Flad: we intend to branch elsewhere 
       MOV  R1,@>83EC          Set address where to go
EVERLP SLA  R0,1               Make room for clock bit
       INC  R0                 Set the clock bit to put TMS9901 in clock mode 
       LDCR R0,15              Load the clock bit + the delay 
       SBZ  0                  Back to normal mode: start timer
       MOV  @OLDR12,R12        Restore caller's R12
       B    *R11

* This routines "unhooks" the timer interrupt
TIMOFF SZCB @H20,@>83FD        Clear timer interrupt flag bit 
       MOV  R12,@OLDR12        Preserve caller's R12    
       CLR  R12                CRU base address >0000 
       SBO  1                  Enables peripheral interrupts 
       SBO  2                  Enables VDP interrupts 
       SBZ  3                  Disables timer interrupts
       MOV  @OLDR12,R12        Restore caller's R12
       B    *R11

H20    BYTE >20
       EVEN

* This is our ISR. All it does is to count the number of times it is called.
OURISR
* Set background color at bottom of screen
       LI   R0,>07F4
       BL   @VDPREG
*
       LWPI >83C0              Back to interrupt workspace (R13, R15 unchanged) 
       MOV  @RETPT,R14         Get the return point (as R14 contains OURISR) 
       RTWP                    Return to IRET

*
* Wait for the VDP interrupt, but don't clear it.
* Or some such giberish.
*
config_interrupt:
* Munge the GPLWS.
       LWPI >83E0
       CLR  R14               * Disable cassette interrupt and protect >8379.
       LI   R15,>877B         * Disable VDPST reading and protect >837B.   (>FC00 + >877B = >837B, so this results in moving >837B to itself)
* Munge the INTWS.
       LWPI >83C0
       SETO R1                * Disable all VDP interrupt processing.
       LI   R2,OURISR         * Set our interrupt vector.
       SETO R11               * Disable screen timeouts.
       CLR  R12               * Set to 9901 CRU base.
*
* Synchronize with the next VDP interrupt.
SYNC   TB   2                 * Check for VDP interrupt.
       JEQ  SYNC
* Configure the 9901 for interrupts.
       SBO  1                 * Enable external interrupt prioritization.
       SBZ  2                 * Disable VDP interrupt prioritization.
       SBZ  3                 * Disable Timer interrupt prioritization.
* Done
       LWPI WS
       RT