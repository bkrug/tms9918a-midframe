*
* This file listens for some interrupts
* and writes log messages to the screen based on what it finds
*

       DEF  log_interrupts
*
       REF  GROMCR                          Ref from GROM
       REF  DSPINT,NUMASC                   Ref from DISPLAY
       REF  VDPREG,VDPADR,VDPWRT            Ref from VDP
       REF  set_vdp_read_address            "
       REF  read_multiple_vdp_bytes         "
       REF  write_string                    "
       REF  mult_spaces                     "
       REF  block_vdp_interrupt             Ref from PIXELROW       
       REF  set_timer                       "
       REF  get_timer_value                 "

*
* Addresses
*
       COPY '..\EQUCPUADR.asm'
       COPY '..\EQUVAR.asm'

OLDR12                    EQU  >8330

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
       LIMI 0
       BLWP @block_vdp_interrupt
*
       BL   @check_vdp_interrupt_bit
* Specify user defined interrupt routine
       LI   R0,report_unexpected_vdp
       MOV  R0,@USRISR
* Wait for about 1/3 second
       BL   @set_timer
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
       BL   @set_timer
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

*
* Scroll screen and print up to 32 characters of text.
*
* Input:
* R0 - address of null-terminating string
* Output:
* R0 - changed
* R1 - changed
* R2 - changed
scroll_and_print:
       DECT R10
       MOV  R11,*R10
       DECT R10
       MOV  R0,*R10
* Read current screen to scroll
       LI   R0,>0020
       BL   @set_vdp_read_address
       LI   R0,screen_copy
       LI   R1,23*32
       BL   @read_multiple_vdp_bytes
* Write screen one line higher
       CLR  R0
       BL   @VDPADR
       LI   R0,screen_copy
       LI   R1,23*32
       BL   @VDPWRT
* Write one line
       LI   R0,23*32
       BL   @VDPADR
       MOV  *R10,R0
       BL   @write_string
* Write enough spaces to overwrite old text
       S    *R10+,R0
       NEG  R0
       AI   R0,32+1
       BL   @mult_spaces
*
       MOV  *R10+,R11
       RT

* VDP.asm
screen_copy:
       EQU  >C000      * >300 bytes
