       DEF  disable_vdp
*
       REF  STACK,WS                        Ref from VAR
       REF  OLDR12,COUNT,COLOR,RETPT
       REF  GROMCR                          Ref from GROM
       REF  DSPINT,NUMASC                   Ref from DISPLAY
       REF  VDPREG,VDPADR,VDPWRT            Ref from VDP
       REF  scroll_and_print                "

*
* Addresses
*
       COPY 'EQUCPUADR.asm'
       COPY 'EQU.asm'

waiting_for_vdp:
       TEXT 'Waiting for VDP interrupt.'
       BYTE 0
interrupt_occurred:
       TEXT 'VDP interrupt occurred.'
       BYTE 0
vdp_interrupt_bit_low:
       TEXT 'VDP interrupt bit low.'
       BYTE 0
vdp_interrupt_bit_high:
       TEXT 'VDP interrupt bit high.'
       BYTE 0
no_vdp_interrupt:
       TEXT 'No VDP interrupt for 1/3 sec.'
       BYTE 0

*
* Runable code
*
disable_vdp:
*
       LWPI WS
       LI   R10,STACK
*
       LIMI 0    
*
       BL   @GROMCR              Copy pattern definitions from GROM to VRAM
*
       LI   R0,waiting_for_vdp
       BL   @scroll_and_print
* Skip first VDP interrupt; it's too late to measure the full time.
       LIMI 2
       MOVB @VINTTM,R0
FRSTLP CB   @VINTTM,R0
       JEQ  FRSTLP
       LIMI 0
*
       LI   R0,interrupt_occurred
       BL   @scroll_and_print
*
       BL   @check_vdp_interrupt_bit
*
       BL   @block_vdp_interrupt
*
       BL   @check_vdp_interrupt_bit
* Wait for about 1/3 second
       BL   @init_timer
       MOVB @VINTTM,R9
while_timer_not_elapsed:
       BL   @get_timer_value
       CI   R2,>80
       JHE  while_timer_not_elapsed
* Did a VDP interrupt occur?
       CB   R9,@VINTTM
       JNE  unexpected_vinttm_change
       LI   R0,no_vdp_interrupt
       BL   @scroll_and_print
       JMP  COMPLETE
unexpected_vinttm_change:
       LI   R0,interrupt_occurred
       BL   @scroll_and_print
*
COMPLETE JMP COMPLETE

*
* Check if VDP interrupt bit is high or low
* Log the result
*
check_vdp_interrupt_bit:
       DECT R10
       MOV  R11,*R10
* Is the VDP interrupt high or low?
       CLR  R12
       TB   2
       JNE  bit_low
       LI   R0,vdp_interrupt_bit_high
       BL   @scroll_and_print
       JMP  vdp_check_done
bit_low:
       LI   R0,vdp_interrupt_bit_low
       BL   @scroll_and_print
vdp_check_done:
       MOV  *R10+,R11
       RT

*
* Private Method:
* Initialize Timer
*
init_timer:
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
get_timer_value:
       CLR  R12 
       SBO  0           Enter timer mode 
       STCR R2,15       Read current value (plus mode bit)
       SBZ  0
* Ignore left-most and right-most bits, while maintaining sign
       SLA  R2,1
       SRL  R2,2
       RT

*
* Wait for the VDP interrupt, but don't clear it.
* Or some such giberish.
*
block_vdp_interrupt:
* Munge the GPLWS.
       LWPI >83E0
       CLR  R14               * Disable cassette interrupt and protect >8379.
       LI   R15,>877B         * Disable VDPST reading and protect >837B.   (>FC00 + >877B = >837B, so this results in moving >837B to itself)
* Munge the INTWS.
       LWPI >83C0
       SETO R1                * Disable all VDP interrupt processing.
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