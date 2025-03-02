       DEF  cnc_quarter_text
       DEF  clc_quarter_text
*
       REF  VDPREG,VDPADR,VDPWRT            Ref from VDP
       REF  font_addresses                  Ref from FONTS
       REF  update_key_buffer               Ref from KEY
       REF  init_key_buffer                 "
       REF  get_key_from_buffer             "
       REF  block_vdp_interrupt             Ref from PIXELROW
       REF  calc_init_timer_loop            "
       REF  coinc_init_timer_loop           "
       REF  restart_timer_loop              "
       REF  set_timer                       "
       REF  get_timer_value                 "
       REF  timer_isr                       "

*
* Addresses
*
       COPY '..\EQUCPUADR.asm'
       COPY '..\EQUVAR.asm'
       COPY 'EQUDEMO.asm'

SCRN8                 EQU  >2000
char_draw_per_frame   EQU  20
cursor_code           EQU  6*40

pixel_row_interrupts        DATA 6*8,pattern1_isr
                            DATA 12*8,pattern2_isr
                            DATA 18*8,pattern3_isr
pixel_row_interrupts_end
forty                       DATA 40
* Tells us if the cursor should flash or not
bits_indicating_flash       DATA >1F00
* Tells us if the cursor should flash on or off
bits_indicating_cursor      DATA >2000

cursor_char                 DATA >6060,>6060,>6060,>6000
cursor_char_end

cnc_quarter_text
       LWPI WS
       LI   R9,coinc_init_timer_loop
       JMP  quarter_text
clc_quarter_text
       LWPI WS
       LI   R9,calc_init_timer_loop
quarter_text
       LI   R10,STACK
       LIMI 0
* Specify the location of the table of timer ISRs
       LI   R0,pixel_row_interrupts
       LI   R1,pixel_row_interrupts_end
       LI   R2,pattern0_isr
       BL   *R9
*
       BL   @init_vdp_ram
       BL   @init_screen_image_table
*
       BL   @copy_init_text
       LI   R0,document_text
       MOV  R0,@doc_cursor_position
       CLR  @doc_display_index
       CLR  @screen_draw_position
       CLR  @cursor_screen_location
       CLR  @line_break_index
       SETO @word_wrap_needed
       BL   @init_key_buffer
       BL   @get_font_from_position       
*
game_loop
* Disable interrupts
       LIMI 0
*
       BL   @flash_cursor
* Block thread until then end of a frame
* Fool TI-99/4a into thinking that later interrupts are VDP interrupts.
       BLWP @block_vdp_interrupt
* Tell timer_isr to look at the begging of the table again
       BL   @restart_timer_loop
       DEC  @dropped_frames
* Display some of the text
       BL   @display_text
* Enable interrupts
       LIMI 2
* Process keys
       BL   @handle_keys
* If word_wrap_needed = -1, wrap text
       BL   @word_wrap
* Don't end game loop until all timer-interrupts have been triggered
while_waiting_for_interrupt
       MOV  @all_lines_scanned,R0
       JEQ  while_waiting_for_interrupt
*
       JMP  game_loop

init_vdp_ram
       DECT R10
       MOV  R11,*R10
* Write cursor pattern
       LI   R3,cursor_code*8
cursor_loop
       MOV  R3,R0
       BL   @VDPADR
       LI   R0,cursor_char
       LI   R1,cursor_char_end-cursor_char
       BL   @VDPWRT
       AI   R3,256*8
       CI   R3,>2000
       JL   cursor_loop
* Enable text mode
       LI   R0,>01F0
       BL   @VDPREG
* Enable white text / blue background
       LI   R0,>07F4
       BL   @VDPREG
*
       MOV  *R10+,R11
       RT

pattern0_isr
       INC  @dropped_frames
*
       LI   R0,>0400
       JMP  any_pattern

pattern1_isr
       DECT R10
       MOV  R11,*R10
*
       LI   R0,>0401
       BL   @VDPREG
*
       BL   @update_key_buffer
*
       MOV  *R10+,R11
       RT

pattern2_isr
       LI   R0,>0402
       JMP  any_pattern

pattern3_isr
       LI   R0,>0403
       JMP  any_pattern

* 
* Input:
*   R0: VDP register and value
any_pattern
       DECT R10
       MOV  R11,*R10
* Set background color
       BL   @VDPREG
*
       MOV  *R10+,R11
       RT

init_screen_image_table
       DECT R10
       MOV  R11,*R10
* Choose the screen image table
       LI   R0,>0208
       BL   @VDPREG
       LI   R0,SCRN8
       BL   @VDPADR
* Let R1 = number of quarter-screens remaining to initialize
       LI   R1,4
four_quarters_of_screen
* Let R0 = tile-code to write
       CLR  R0
one_quarter_of_screen
       MOV  R0,@VDPWD
       AB   @ONE,R0
       CI   R0,6*40*>100
       JL   one_quarter_of_screen
*
       DEC  R1
       JNE  four_quarters_of_screen
*
       MOV  *R10+,R11
       RT

*
*
*
copy_init_text
*
* Copy text from Cartridge ROM to a RAM position where it can be edited.
*
       LI   R0,initial_text
       LI   R1,document_text
copy_text_loop
       MOVB *R0+,*R1+
       CI   R0,initial_text_end
       JL   copy_text_loop
* Write spaces
write_spaces_loop
       MOVB @SPACE,*R1+
       CI   R1,document_text_end
       JL   write_spaces_loop
*
* Convert space, "b", "i", or "m" to an index (0-3).
* This will allow later code to find an address within "font_addresses".
* And thereafter to find a pattern for one charater within a font.
*       
* Copy font data to RAM
       LI   R0,initial_fonts
       LI   R1,document_font
copy_fonts_loop
* Let R2 = font key
       LI   R3,font_keys
       MOV  R3,R2
key_search_loop
       CB   *R0,*R2
       JEQ  found_font_key
       INC  R2
       JMP  key_search_loop
found_font_key
       S    R3,R2
* Copy font key to RAM
       INC  R0
       MOVB @LBR2,*R1+
       CI   R0,initial_fonts_end
       JL   copy_fonts_loop
*
       RT

initial_text
       TEXT '========== Quarter Text Mode ========== '
       TEXT 'CTRL+B to turn bold on/off ............ '
       TEXT 'CTRL+I to turn italic on/off .......... '
       TEXT 'If you move the cursor, the bold & italic '
       TEXT 'settings will change to match the character '
       TEXT 'under the cursor. '
       TEXT 'This is a toy text editor that can '
       TEXT 'display normal, bold, italic, or '
       TEXT 'bold italic text. '
       TEXT 'This display is in 40-column text mode. '
       TEXT 'In order to make this possible, '
       TEXT 'the screen is divided to into four quarters. '
       TEXT 'Each quarter has it"s own pattern table. '
       TEXT 'So each quarter has 256 unique tiles and '
       TEXT 'only 240 tile positions that need to be filled. '
       TEXT 'This would not be possible in the barley '
       TEXT 'documented text-bitmap mode. '
       TEXT 'That mode divides the screen into thirds, '
       TEXT 'and each third has 320 tile positions to fill. '
       TEXT 'This would be possible in regular bitmap mode, '
       TEXT 'but would require a lot of bitshift operations '
       TEXT 'in order to achieve 40-columns. '
initial_text_end

* Space implies basic text.
* "m" implies both bold and italic.
initial_fonts
       TEXT '           bbbbbbbbbbbbbbbbb            '
       TEXT '               bbbb                     '
       TEXT '               iiiiii                   '
       TEXT '                            mmmmmmmmmmmmm '
       TEXT '                                            '
       TEXT '                  '
       TEXT '          iii                      '
       TEXT '                bbbbb iiiiiii    '
       TEXT 'mmmmmmmmmmm       '
       TEXT '                                        '
       TEXT '                                '
       TEXT '                              iiiiiiiiiiiiii '
       TEXT '                                         '
       TEXT '                        iiiiii           '
       TEXT '              bbbbbbbbb                 mmmmmmm '
       TEXT '                                         '
       TEXT '           mmmmmmmmmmm       '
       TEXT '                                  iiiiiii '
       TEXT '                                               '
       TEXT '                                  bbbbbbbbbbbb '
       TEXT '                           iiiiiiii            '
       TEXT '                                '
initial_fonts_end

font_keys
       TEXT ' bim'
       EVEN

display_text
       DECT R10
       MOV  R11,*R10
* Let R2 = document index
* Let R3 = number of chars to write
       MOV  @doc_display_index,R2
       LI   R3,char_draw_per_frame
* Let R4 = address within line break list
       MOV  @line_break_index,R4
       SLA  R4,1
       AI   R4,line_breaks
* Let R0 = position in VDP RAM to write next pattern
       BL   @get_vdp_ram_pattern_address
* Set VDP ram position
       BL   @VDPADR
char_loop
* Draw pattern of one character
       BL   @draw_one_char
* Advance R2 to the next character within the document,
* unless we've passed then end of the line.
       C    R2,*R4
       JHE  skip_char_advance
       INC  R2
skip_char_advance
* Have we writen the last pattern for this video frame?
* If not, continue in the loop.
       DEC  R3
       JH   char_loop
* Loop complete.
* Let R0 = next screen position
       MOV  @screen_draw_position,R0
       AI   R0,char_draw_per_frame
* Update line_break_index
       CLR  R3
       MOV  R0,R4
       DIV  @forty,R3
       MOV  R3,@line_break_index
* Is this the end of a line?
       MOV  R4,R4
       JNE  last_pattern_check
* Yes, doc_display_index should point to the same place as the old line break
       MOV  R3,R4
       SLA  R4,1
       AI   R4,line_breaks-2
       MOV  *R4,R2
* Have we written the last pattern on screen?
last_pattern_check
       CI   R3,24
       JL   update_index
* Yes, last pattern.
       CLR  R2
       CLR  R0
       CLR  @line_break_index
* Update the indecies so that we know where to continue
* in the next video frame.
update_index
       MOV  R0,@screen_draw_position
       MOV  R2,@doc_display_index
*
       MOV  *R10+,R11
       RT

*
*
* Output: R0
get_vdp_ram_pattern_address
* Let R0 = tile position
       MOV  @screen_draw_position,R0
* Let R0 = tile code within a particular VDP RAM pattern table.
* If R0 >= 18*40, then R0 += 16*3
* else if R0 >= 12*40, then R0 += 16*2
* else if R0 >= 6*40, then R0 += 16
       CI   R0,18*40
       JL   pattern_pick1
       AI   R0,16*3
       JMP  pattern_pick_good
pattern_pick1
       CI   R0,12*40
       JL   pattern_pick2
       AI   R0,16*2
       JMP  pattern_pick_good
pattern_pick2
       CI   R0,6*40
       JL   pattern_pick_good
       AI   R0,16
pattern_pick_good
* Let R0 = address within in VDP RAM pointing to
* the first pattern that we will update in this video-frame.
       SLA  R0,3
*
       RT

*
* Places a single ASCII character on screen.
*
* Input:
*   R2 - document index
*   R4 - address within line break list
draw_one_char
* Have we reached the end of a line?
       C    R2,*R4
       JL   draw_actual_char
* Yes, draw spaces
       MOVB @SPACE,R1
       JMP  ascii_char_selected
* Let R1 (high byte) = desired ASCII code of next char
draw_actual_char
       MOV  R2,R1
       AI   R1,document_text
       MOVB *R1,R1
* Let R1 = offset within some pattern table (Cartridge ROM).
* Spaces are the first character in each table.
ascii_char_selected
       SRL  R1,8
       AI   R1,-32
       SLA  R1,3
* Let R0 (high byte) = font key
       MOV  R2,R0
       AI   R0,document_font
       MOVB *R0,R0
* Let R0 = address of this font's pattern table (Cartridge ROM)
       SRL  R0,8
       SLA  R0,1
       AI   R0,font_addresses
       MOV  *R0,R0
* Let R0 = address of character's pattern
       A    R1,R0
* Write char pattern
       LI   R1,VDPWD
       MOVB *R0+,*R1
       MOVB *R0+,*R1
       MOVB *R0+,*R1
       MOVB *R0+,*R1
*
       MOVB *R0+,*R1
       MOVB *R0+,*R1
       MOVB *R0+,*R1
       MOVB *R0+,*R1
*
       RT

*
* Word wraps the document.
* For now we assume the whole document is just one big paragraph.
* The document can be 2KB long, but we only wrap the first 24 lines.
*
word_wrap
       MOV  @word_wrap_needed,R0
       JNE  word_wrap_start
       RT
word_wrap_start
* Let R0 = start of the current line
* Let R1 = current location in line break list
       LI   R2,document_text
       LI   R1,line_breaks
word_wrap_loop
       MOV  R2,R0
* Let R2 = position at which we look for a space
       AI   R2,40
find_space
       CB   *R2,@SPACE
       JEQ  space_found
       DEC  R2
       C    R2,R0
       JH   find_space
* Word is too long to break
       AI   R2,39
space_found
* Let R2 = address after the found space
       INC  R2
* Store line break address
       MOV  R2,R3
       AI   R3,-document_text
       MOV  R3,*R1+
* Was that the 24th line?
       CI   R1,line_breaks+(24*2)
       JL   word_wrap_loop
* Yes
       CLR  @word_wrap_needed
       RT

key_routines
       DATA >0300,delete_char
       DATA >0800,move_left
       DATA >0900,move_right
       DATA >0A00,move_down
       DATA >0B00,move_up
       DATA >8200,toggle_bold
       DATA >8900,toggle_italic
key_routines_end

*
* 
*
handle_keys
       DECT R10
       MOV  R11,*R10
* Let R0 (high byte) = key press
       BL   @get_key_from_buffer
* Was this a visible key press?
       CB   R0,@SPACE
       JL   fctn_ctrl_key
       CB   R0,@highest_ascii
       JH   fctn_ctrl_key
* Yes, insert it into the document
       BL   @insert_visible_text
       JMP  handle_keys_done
* No, the user pressed a FCTN or CTRL key
fctn_ctrl_key
* Let R1 = position in dictionary of routines for each key press
       LI   R1,key_routines
* Does this entry match the key that was pressed?
find_key_routine_loop
       CB   *R1,R0
       JEQ  found_routine
* No, move to next entry.
       C    *R1+,*R1+
* Did we run out of table entries?
       CI   R1,key_routines_end
       JL   find_key_routine_loop
* Yes
       JMP  handle_keys_done
* Run the routine for this key
found_routine
       INCT R1
       MOV  *R1,R1
       BL   *R1
*
handle_keys_done
       MOV  *R10+,R11
       RT

*
*
*
insert_visible_text
       DECT R10
       MOV  R11,*R10
* Make space for extra character in document
       MOV  @doc_cursor_position,R1
       LI   R2,document_text_end
       BL   @insert_one_byte
* Make space for extra font detail
       MOV  @doc_cursor_position,R1
       AI   R1,document_font-document_text
       MOV  R1,R5
       LI   R2,document_font_end
       BL   @insert_one_byte
* Copy character to document
       MOV  @doc_cursor_position,R1
       MOVB R0,*R1+
       MOV  R1,@doc_cursor_position
* Place user-specified font in place
       MOVB @current_font,*R5
* Word wrap the document
       SETO @word_wrap_needed
* Request that the cursor be displayed, because it moved
       SETO @request_cursor_display
*
       MOV  *R10+,R11
       RT

move_left
       DECT R10
       MOV  *R10,R11
*
       LI   R1,document_text
       C    @doc_cursor_position,R1
       JEQ  not_doc_beggining
       DEC  @doc_cursor_position
not_doc_beggining
*
       BL   @get_font_from_position
* Request that the cursor be displayed, because it moved
       SETO @request_cursor_display
*
       MOV  *R10+,R11
       RT

move_right
       DECT R10
       MOV  *R10,R11
*
       LI   R1,document_text+(24*40)-2
       C    @doc_cursor_position,R1
       JHE  not_screen_end
       INC  @doc_cursor_position
not_screen_end
*
       BL   @get_font_from_position
* Request that the cursor be displayed, because it moved
       SETO @request_cursor_display
*
       MOV  *R10+,R11
       RT

move_down
       DECT R10
       MOV  *R10,R11
* Let R2 = ddress within line_breaks pointing to start of the next line
* Let R3 = index of character within document
       BL   @get_line_break_address
* Is R2 pointing to the last line break (and thus last line on screen?)
       CI   R2,line_breaks+(2*23)
       JEQ  move_down_return
* Let R4 = screen column
       MOV  R3,R4
       CI   R2,line_breaks
       JEQ  screen_col
       S    @-2(R2),R4
screen_col
* Let R1 = index of the end of the line + column index
       MOV  *R2,R1
       A    R4,R1
*
       mov  R1,@>C000
       MOV  R2,@>C002
       MOV  R3,@>C004
       MOV  R4,@>C006
* Is R1 right of the next line's end?
       C    R1,@2(R2)
       JL   found_new_position
* Yes, lower R1
       MOV  @2(R2),R1
       DEC  R1
* Save new position
found_new_position
       AI   R1,document_text
       MOV  R1,@doc_cursor_position
* Request that the cursor be displayed, because it moved
       SETO @request_cursor_display
*
       BL   @get_font_from_position
*
move_down_return
       MOV  *R10+,R11
       RT

move_up
       DECT R10
       MOV  *R10,R11
* Let R2 = ddress within line_breaks pointing to start of the next line
* Let R3 = index of character within document
       BL   @get_line_break_address
* Is R2 pointing to the last line break (and thus last line on screen?)
       CI   R2,line_breaks
       JLE  move_up_return
* Let R4 = screen column
       MOV  R3,R4
       S    @-2(R2),R4
* Let R1 = index of the end of the previous line + column index
       MOV  @-4(R2),R1
       A    R4,R1
* Is R1 right of the previous line's end?
       C    R1,@-2(R2)
       JL   found_new_up_position
* Yes, lower R1
       MOV  @-2(R2),R1
       DEC  R1
* Save new position
found_new_up_position
       AI   R1,document_text
       MOV  R1,@doc_cursor_position
* Request that the cursor be displayed, because it moved
       SETO @request_cursor_display
*
       BL   @get_font_from_position
*
move_up_return
       MOV  *R10+,R11
       RT

*
*
*
delete_char
       DECT R10
       MOV  R11,*R10
* Delete one character
       MOV  @doc_cursor_position,R1
       MOV  R1,R2
       INC  R2
delete_loop
       MOVB *R2+,*R1+
       CI   R2,document_text_end
       JL   delete_loop
* Delete one font byte
       MOV  @doc_cursor_position,R1
       AI   R1,document_font-document_text
       MOV  R1,R2
       INC  R2
delete_font_loop
       MOVB *R2+,*R1+
       CI   R2,document_font_end
       JL   delete_font_loop
*
       SETO @word_wrap_needed
*
       BL   @get_font_from_position
*
       MOV  *R10+,R11
       RT

*
*
*
toggle_bold
       LI   R1,>0100
       JMP  toggle_one_bit

*
*
*
toggle_italic
       LI   R1,>0200
toggle_one_bit
       MOVB @current_font,R2
       COC  R1,R2
       JEQ  turn_bit_off
       SOCB R1,R2
       JMP  save_bit
turn_bit_off
       SZCB R1,R2
save_bit
       MOVB R2,@current_font
       RT

*
* Move block of data forwards by one byte
*
* Input:
*   R1 - insertion point
*   R2 - address following the moveable block
insert_one_byte
* Let R4 = insert point rounded up to the address divislbe by 8
       MOV  R1,R4
       AI   R4,7
       SRL  R4,3
       SLA  R4,3
insert_char_loop
       DECT R2
       MOVB *R2+,*R2
       DECT R2
       MOVB *R2+,*R2
       DECT R2
       MOVB *R2+,*R2
       DECT R2
       MOVB *R2+,*R2
       DECT R2
       MOVB *R2+,*R2
       DECT R2
       MOVB *R2+,*R2
       DECT R2
       MOVB *R2+,*R2
       DECT R2
       MOVB *R2+,*R2
       C    R2,R4
       JH   insert_char_loop
* Let R1 = postion after the desired insertion point
       INC  R1
* Is R2 already pointing to after insertion point?
insert_char_loop_2
       C    R2,R1
       JLE  insert_no_more
* No copy one more byte
       DECT R2
       MOVB *R2+,*R2
       JMP  insert_char_loop_2
insert_no_more
       RT

*
*
*
flash_cursor
       DECT R10
       MOV  R11,*R10
* Has a different routine requested that the cursor be displayed?
       MOV  @request_cursor_display,R0
       JEQ  base_flash_on_timer
* Yes, the cursor must have moved.
* So hide the old one, and display the new one.
       BL   @hide_cursor
       BL   @show_cursor
       CLR  @request_cursor_display
       JMP  flash_cursor_rt
base_flash_on_timer
* Don't flash if waiting for word wrap
*       MOV  @word_wrap_needed,R0
*       JNE  flash_cursor_rt
* Is this an okay time to flash cursor?
       MOVB @VINTTM,R0
       CZC  @bits_indicating_flash,R0
       JNE  flash_cursor_rt
* Turn cursor on or off?
       MOVB @VINTTM,R0
       COC  @bits_indicating_cursor,R0
       JEQ  display_cursor
* Off, hide cursor
       BL   @hide_cursor
       JMP  flash_cursor_rt
* On, show cursor
display_cursor
       BL   @show_cursor
flash_cursor_rt
       MOV  *R10+,R11
       RT

*
*
*
show_cursor
       DECT R10
       MOV  R11,*R10
* Let R1 = screen position of cursor
       BL   @get_screen_position
       MOV  R1,@cursor_screen_location
* Let R0 = address in screen image table
       MOV  R1,R0
       AI   R0,SCRN8
* Set VDP RAM write address
       BL   @VDPADR
* Write character to screen
       LI   R1,cursor_code*>100
       MOVB R1,@VDPWD
*
       MOV  *R10+,R11
       RT

*
* Display the character that was replaced by the cursor
*
* Input: n/a
* Changed: R1, R2, R3
hide_cursor
       DECT R10
       MOV  R11,*R10
       DECT R10
       MOV  R0,*R10
* Let R1 = screen position of cursor
       MOV  @cursor_screen_location,R1
* Let R0 = address in screen image table
       MOV  R1,R0
       AI   R0,SCRN8
* Set VDP RAM write address
       BL   @VDPADR
* Let R1 = tile code to place in screen image table.
* Except for the cursor, the screen image table holds
* codes 0-239 repeated four times.
find_tile_code
       CI   R1,240
       JL   have_tile_code
       AI   R1,-240
       JMP  find_tile_code
have_tile_code
* Write code to VDP RAM
       MOVB @LBR1,@VDPWD
*
       MOV  *R10+,R0
       MOV  *R10+,R11
       RT

*
*
* Input:
*   @doc_cursor_position
* Output:
*   R1 - screen position
* Changed:
*   R0, R2, R3
get_screen_position
       DECT R10
       MOV  R11,*R10
* Let R2 = ddress within line_breaks pointing to start of the next line
* Let R3 = index of character within document
       BL   @get_line_break_address
* Let R0 = screen row
       MOV  R2,R0
       AI   R0,-line_breaks
       SRL  R0,1
* Let R3 = screen column
       CI   R2,line_breaks  
       JEQ  top_line
       S    @-2(R2),R3
top_line
* Let R1 = screen position
       MPY  @FORTY,R0
       A    R3,R1
* Check for irrational result
       CI   R1,24*40
screen_position_error
       JH   screen_position_error
*
       MOV  *R10+,R11
       RT

*
* Get address within line breaks pointing at current line
*
* Input:
*   @doc_cursor_position
* Output:
*   R2 - address within line_breaks pointing to start of the next line
*   R3 - index of character within document
get_line_break_address
* Let R3 = index within document
       MOV  @doc_cursor_position,R3
       AI   R3,-document_text
* Let R2 = highest address within line_breaks
* where line break within paragraph > doc_cursor_position
       LI   R2,line_breaks
calc_screen_row
       CI   R2,line_breaks+48
       JEQ  calc_done
       C    *R2+,R3
       JLE  calc_screen_row
       DECT R2
calc_done
*
       RT

*
* Look up the current font based on the position in the document.
*
get_font_from_position
      MOV  @doc_cursor_position,R1
      AI   R1,document_font-document_text
      MOVB *R1,@current_font
      RT