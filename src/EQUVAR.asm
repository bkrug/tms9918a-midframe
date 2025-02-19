*
* Variables as >8300
*
WS                        EQU  >8300
STACK                     EQU  >8320+>10

* PIXELROW.asm
* >40 bytes - the timer-ISR-table
* This table has space for >10 entries
* Each entry contains the following two words:
*   - the number of CRU ticks between the previous interrupt and the next one
*   - the address of a routine to trigger when the event goes off
timer_interrupts          EQU  >A000
* We never want to fill the last 8 bytes with a user-defined ISR.
* The second from last entry in the timer-ISR-table should always
* point to the end-of-frame interrupt that replaces the VDP interrupt.
* The last entry should have a time identical to the first.
limit_timer_interrupts    EQU  >A038
*
isr_table_address         EQU  >A040
isr_element_address       EQU  >A042
isr_end_address           EQU  >A044
frame_isr                 EQU  >A046
all_lines_scanned         EQU  >A048
HERTZ                     EQU  >A04A    * 50 hz vs. 60 hz

*
* Labels for lower bytes of registers
*
LBR0   EQU  WS+1
LBR1   EQU  WS+3
LBR2   EQU  WS+5
LBR3   EQU  WS+7
LBR4   EQU  WS+9
LBR5   EQU  WS+11
LBR6   EQU  WS+13
LBR7   EQU  WS+15
LBR8   EQU  WS+17
LBR9   EQU  WS+19
LBR10  EQU  WS+21
LBR11  EQU  WS+23
LBR12  EQU  WS+25
LBR13  EQU  WS+27
LBR14  EQU  WS+29
LBR15  EQU  WS+31