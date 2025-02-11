* MAIN.asm
COUNT                     EQU  >8332
swappable_colors          EQU  >8334
isr_hit_count             EQU  >8336

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

ascii_number_string   EQU  >A600     * six characters

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

