* MAIN.asm
COUNT                     EQU  >8332
swappable_colors          EQU  >8334
isr_hit_count             EQU  >8336

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

