       DEF  log_interrupts
*
       REF  GROMCR                          Ref from GROM
       REF  DSPINT,NUMASC                   Ref from DISPLAY
       REF  VDPREG,VDPADR,VDPWRT            Ref from VDP
       REF  scroll_and_print                "

*
* STATUS:
* Currently we have an interrupt that can maintain the return address.
* And the interrupt is only triggered 3 times per second, when the timer hits zero.
*

*
* Addresses
*
       COPY 'EQUCPUADR.asm'
       COPY 'EQUVAR.asm'
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
user_isr_reached:
       TEXT 'User Defined ISR reached'
       BYTE 0
cassette_isr_reached:
       TEXT 'Timer/Cassette ISR reached'
       BYTE 0
*
       EVEN

*
* Runable code
*
log_interrupts:
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
*
timer_interrupt_test:
* Configure traditional timer/cassette interrupt
*       LI   R0,>3FFF
*       LI   R1,report_cassette_isr_hit
*       BL   @set_timer_interrupt
*
* Specify user defined interrupt routine
       LI   R0,report_user_isr_hit
       MOV  R0,@USRISR
* Enable timer interrupts
       CLR  R12                CRU base address >0000 
       SBO  3                  Enable timer interrupts
       BL   @init_timer
* Demonstrate that interrupts are not seeing a left-over return address
       CLR  R11
       CLR  R14
* Increment R5 regularly so that we can see in the debugger
* that work is happening in between interrupts.
       CLR  R5
increment_loop:
       LIMI 2
       INC  R5
       JMP  increment_loop
*

*
* This ISR is configured to be called
* after VDP interrupts were already supposed to be disabled
*
report_unexpected_vdp:
       LIMI 0
*
       LI   R10,WS
       AI   R10,2*10
       MOV  *R10,R10
*
       DECT *R10
       MOV  R11,*R10
*
       LI   R0,isr_unexpectedly_reached
       BL   @scroll_and_print
*
       LIMI 2
*
       MOV  *R10+,R11
       RT

*
* This is a traditional User-Defined interrupt.
* It would be triggered by the VDP interrupt,
* if we had not blocked those.
*
report_user_isr_hit:
       LIMI 0
* Clear timer interrupt
       CLR  R12
       SBO  3
* For some reason we need to re-confirm that we don't want VDP interrupts
       SBZ  2
* Get stack pointer
       LI   R10,WS
       AI   R10,2*10
       MOV  *R10,R10
* Save Return address
       DECT R10
       MOV  R11,*R10
* Log message that the routine was triggered
       LI   R0,user_isr_reached
       BL   @scroll_and_print
*
       LIMI 2
*
       MOV  *R10+,R11
       RT

*
* This interrupt routine is meant to be called by "set_timer_interrupt"
*
report_cassette_isr_hit:
       DECT R10
       MOV  R11,*R10
*
       LIMI 0
* Clear timer interrupt
       CLR  R12
       SBO  3
       SBZ  2
*
       LI   R0,cassette_isr_reached
       BL   @scroll_and_print
*
       LIMI 2
*
       MOV  *R10+,R11
       RT

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
* Any future interrupts will be interpreted by ROMs as VDP interrupts.
* We can no longer listen for VDP interrupts,
* but we can listen for timer interrupts.
*
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
*
* Synchronize with the next VDP interrupt.
SYNC   TB   2                 * Check for VDP interrupt.
       JEQ  SYNC
* Configure the 9901 for interrupts.
       SBZ  1                 * Disable external interrupt prioritization.
       SBZ  2                 * Disable VDP interrupt prioritization.
       SBZ  3                 * Disable Timer interrupt prioritization.
* Done
       LWPI WS
       RT


*
* This is the non-hacky way to set a timer-interrupt.
* Copied directly from: http://www.unige.ch/medecine/nouspikel/ti99/tms9901.htm
* Thierry Nouspikel explains that the problem with this approach
* is that we loose the return address.
*
* Input:
*   R0 - delay
*   R1 - a branch vector in R1 (or >0000 to use a forever loop)
set_timer_interrupt:
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