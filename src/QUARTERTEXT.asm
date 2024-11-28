       DEF  quarter_text
*
       REF  VDPREG,VDPADR,VDPWRT            Ref from VDP
       REF  font_addresses                  Ref from FONTS
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
       COPY 'EQUCPUADR.asm'
       COPY 'EQU.asm'
       COPY 'EQUVAR.asm'

SCRN8                 EQU  >2000
char_draw_per_frame   EQU  20


pixel_row_interrupts
       DATA 6*8-1,pattern1_isr
       DATA 12*8-1,pattern2_isr
       DATA 18*8-1,pattern3_isr
pixel_row_interrupts_end

char_pattern
* Patterns used to demonstrate degree of accuracy in the results
       DATA >F000,>0000,>C000,>0000
       DATA >F000,>0000,>C000,>0001
* Pattern used for COINIC detection
       DATA >8080,>8080,>8080,>8080
end_of_char_patterns

quarter_text
       LWPI WS
       LI   R10,STACK
       LIMI 0
* Write patterns
       LI   R0,>800
       BL   @VDPADR
       LI   R0,char_pattern
       LI   R1,end_of_char_patterns-char_pattern
       BL   @VDPWRT
       LI   R0,>0601
       BL   @VDPREG
* Specify the location of the table of timer ISRs
       LI   R0,pixel_row_interrupts
       LI   R1,pixel_row_interrupts_end
       LI   R2,pattern0_isr
       BL   @coinc_init_timer_loop
* Enable text mode
       LI   R0,>01F0
       BL   @VDPREG
* Enable white text / blue background
       LI   R0,>07F4
       BL   @VDPREG
*
       BL   @copy_init_text
       BL   @init_screen_image_table
       CLR  @doc_display_index
*
game_loop
* Disable interrupts
       LIMI 0
* Block thread until then end of a frame
* Fool TI-99/4a into thinking that later interrupts are VDP interrupts.
       BLWP @block_vdp_interrupt
* Tell timer_isr to look at the begging of the table again
       BL   @restart_timer_loop
* Display some of the text
       BL   @display_text
* Enable interrupts
       LIMI 2
* Don't end game loop until all timer-interrupts have been triggered
while_waiting_for_interrupt
       MOV  @all_lines_scanned,R0
       JEQ  while_waiting_for_interrupt
*
       JMP  game_loop

pattern0_isr
       LI   R0,>0400
       JMP  any_pattern

pattern1_isr
       LI   R0,>0401
       JMP  any_pattern

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
* Copy text to RAM
       LI   R0,initial_text
       LI   R1,document_text
copy_text_loop
       MOVB *R0+,*R1+
       CI   R0,initial_text_end
       JL   copy_text_loop
* Write spaces
       LI   R0,>2000
write_spaces_loop
       MOVB R0,*R1+
       CI   R1,document_text+>800
       JL   write_spaces_loop
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
       TEXT 'Quarter Text Mode. '
       TEXT 'This is a toy text editor that can '
       TEXT 'display normal, bold, italic, or '
       TEXT 'bold italic text. '
       TEXT 'Use CTRL+B to enable or disable '
       TEXT 'bold text. Use CTRL+I to enable or disable '
       TEXT 'italic text. '
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
initial_fonts
       TEXT 'bbbbbbbbbbbbbbbbbb '
       TEXT '          iii                      '
       TEXT '                bbbbb iiiiiii    '
       TEXT 'mmmmmmmmmmm       '
       TEXT '    bbbbbb    iiiiii    iiiiiii '
       TEXT '               mmmmmm    bbbbbb    bbbbbbb '
       TEXT 'iiiiii       '
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
       TEXT ' ibm'
       EVEN

display_text
       DECT R10
       MOV  R11,*R10
* Let R2 = document index
* Let R3 = stopping point
       MOV  @doc_display_index,R2
       MOV  R2,R3
       AI   R3,char_draw_per_frame
* Let R0 = tile position
       MOV  R2,R0
* if R0 >= 18*40, then R0 += 16*3
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
* Let R0 = pattern table position
       SLA  R0,3
* Set VDP ram position
       BL   @VDPADR
char_loop
* Let R1 (high byte) = desired char
       MOV  R2,R1
       AI   R1,document_text
       MOVB *R1,R1
* Let R1 = offset within some pattern table (CPU RAM)
       SRL  R1,8
       AI   R1,-32
       SLA  R1,3
* Let R0 (high byte) = font key
       MOV  R2,R0
       AI   R0,document_font
       MOVB *R0,R0
* Let R0 = address of this font's pattern table (CPU RAM)
       SRL  R0,8
       SLA  R0,1
       AI   R0,font_addresses
       MOV  *R0,R0
* Let R0 = address of character's pattern
       A    R1,R0
* Write char
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
* Next char
       INC  R2
       C    R2,R3
       JL   char_loop
* Finished?
       CI   R2,24*40
       JL   update_index
* Yes, Finished
       CLR  R2
update_index
       MOV  R2,@doc_display_index
*
       MOV  *R10+,R11
       RT