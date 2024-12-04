*
* Variables as >8300
*
WS                        EQU  >8300
STACK                     EQU  >8320+>10
OLDR12                    EQU  >8330

* MAIN.asm
COUNT                     EQU  >8332
swappable_colors          EQU  >8334
isr_hit_count             EQU  >8336

* PIXELROW.asm
* >40 bytes - the timer-ISR-table
* This table has space for >10 entries
* Each entry contains the following two words:
*   - the number of CRU ticks between the previous interrupt and the next one
*   - the address of a routine to trigger when the event goes off
timer_interrupts          EQU  >A000
* We never want to fill the last 4 bytes with a user-defined ISR.
* The last 4 bytes in the timer-ISR-table should always
* point to the end-of-frame interrupt that replaces the VDP interrupt.
limit_timer_interrupts    EQU  >A03C
*
isr_table_address         EQU  >A040
isr_element_address       EQU  >A042
isr_end_address           EQU  >A044
frame_isr                 EQU  >A046
all_lines_scanned         EQU  >A048

* KEY.asm
key_timer     EQU  >A400
KEYWRT        EQU  >A402      * Address where the next keypress 
*                             * should be stored.
KEYRD         EQU  >A404      * Next address to read a keypress from.
*                             * If the value here is equal to the
*                             * value in KEYWRT, then there are no
*                             * new characters to write.===
KEYSTR        EQU  >A406      * First address of key buffer
KEYBUF        EQU  >A406      * Buffer to store keypresses (>10 bytes)
KEYEND        EQU  >A416      * First address after key buffer
PREVKY        EQU  >A416      * The previously detected key press.
*                             * Wait a while before letting this key
*                             * repeat.  (1 byte)

* FOURPARTTEXT.asm
document_text       EQU  >B000
document_text_end   EQU  document_text+>400
document_font       EQU  >B400
document_font_end   EQU  document_font+>400
doc_display_index:
       EQU  >B800
screen_draw_position:
       EQU  >B802
line_break_index:
       EQU  >B804
word_wrap_needed:
       EQU  >B806
doc_cursor_position:
       EQU  >B808
dropped_frames:
       EQU  >B80A
line_breaks:
       EQU  >B810      * 24 words (>18 words)
request_cursor_display:
       EQU  >B840
cursor_screen_location:
       EQU  >B842
current_font:
       EQU  >B844      * 1 byte

* VDP.asm
screen_copy:
       EQU  >C000      * >300 bytes



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