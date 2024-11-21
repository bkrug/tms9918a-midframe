       DEF  disable_vdp
*
       REF  STACK,WS                        Ref from VAR
       REF  OLDR12,COUNT,COLOR,RETPT
       REF  GPLRT
       REF  GROMCR                          Ref from GROM
       REF  DSPINT,NUMASC                   Ref from DISPLAY
       REF  VDPREG,VDPADR,VDPWRT            Ref from VDP
       REF  scroll_and_print                "

*
* Addresses
*
       COPY 'EQUCPUADR.asm'
       COPY 'EQU.asm'

H20    BYTE >20

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
isr_unexpectedly_reached:
       TEXT 'ISR reached unexpectedly.'
       BYTE 0
timer_isr_1_reached:
       TEXT 'Timer ISR routine 1 reached'
       BYTE 0
timer_isr_2_reached:
       TEXT 'Timer ISR routine 2 reached'
       BYTE 0
timer_isr_3_reached:
       TEXT 'Timer ISR routine 3 reached'
       BYTE 0
*
       EVEN

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
* Specify user defined interrupt routine
       LI   R0,report_unexpected_vdp
       MOV  R0,@USRISR
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
       JMP  timer_interrupt_test
unexpected_vinttm_change:
       LI   R0,interrupt_occurred
       BL   @scroll_and_print
* Specify user defined interrupt routine
timer_interrupt_test:
       LI   R0,report_timer_isr_1_hit
       MOV  R0,@USRISR
*       LI   R0,report_timer_isr_2_hit
*       BL   @set_timer_interrupt
       LI   R0,>3FFF
       LI   R1,report_timer_isr_3_hit
       BL   @set_2nd_timer_interrupt
*
       BL   @init_timer
*
       CLR  R5
increment_loop:
       LIMI 2
       INC  R5
       JMP  increment_loop
*

*
*
*
report_unexpected_vdp:
       LIMI 0
       MOV  R11,@GPLRT
       LI   R10,WS
       AI   R10,2*10
       MOV  *R10,R10
*
       LI   R0,isr_unexpectedly_reached
       BL   @scroll_and_print
*
       LIMI 2
       MOV  @GPLRT,R11
       RT

*
*
*
report_timer_isr_1_hit:
       LIMI 0
       MOV  R11,@GPLRT
       LI   R10,WS
       AI   R10,2*10
       MOV  *R10,R10
*
       LI   R0,timer_isr_1_reached
       BL   @scroll_and_print
*
       LIMI 2
       MOV  @GPLRT,R11
       RT

*
*
*
report_timer_isr_2_hit:
       LIMI 0
       LWPI WS
*
       LI   R0,timer_isr_2_reached
       BL   @scroll_and_print
*
       LIMI 2
       JMP  increment_loop

*
*
*
report_timer_isr_3_hit:
       DECT R10
       MOV  R11,*R10
*
       LIMI 0
*
       LI   R0,timer_isr_3_reached
       BL   @scroll_and_print
*
       MOV  *R10+,R11
       LIMI 2
       RT
isr3_end JMP isr3_end

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
       SBZ  1                 * Enable external interrupt prioritization.
       SBZ  2                 * Disable VDP interrupt prioritization.
       SBZ  3                 * Disable Timer interrupt prioritization.
* Done
       LWPI WS
       RT

*
* Set timer interrupt
*
* Input:
*   R0 - address of routine
set_timer_interrupt:
       LWPI >83C0
       MOV  @WS,R2         * Set our interrupt vector.
* Turn on timer interrupt
       LWPI WS
       CLR  R12
       SBO  3
       SBZ  0
       RT

*
* Set timer interrupt
*
* Input:
*   R0 - delay
*   R1 - a branch vector in R1 (or >0000 to use a forever loop)
set_2nd_timer_interrupt:
       SOCB @H20,@>83FD        Set timer interrupt flag bit
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