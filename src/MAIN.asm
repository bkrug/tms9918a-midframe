       DEF  BEGIN
*
       REF  STACK,WS                        Ref from VAR
       REF  DECNUM,PRVTIM,DSPPOS,CURINT     "
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
*
* Game Loop
*
GAMELP
* Initialize Timer
       BL   @INTTIM 
* Set background color at top of screen
       LI   R0,>07FD
       BL   @VDPREG
* Wait for midscreen timer
MIDLP  BL   @GETTIM
       CI   R2,-frame_wait
       JGT  MIDLP
* Set background color at bottom of screen
       LI   R0,>07F4
       BL   @VDPREG
* Turn on VDP interrupts
       LIMI 2
* Wait for VDP interrupt
       MOVB @VINTTM,R0
TOPLP  CB   @VINTTM,R0
       JEQ  TOPLP
* Turn off interrupts so we can write to VDP
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