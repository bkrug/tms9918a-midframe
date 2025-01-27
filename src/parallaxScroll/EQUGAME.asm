*
* Constants
*

*
* Keys
*
right_flag               EQU  >04
jump_flag                EQU  >02
sword_flag               EQU  >10
*
* Player positions are measured to the nearest 16th of a pixel.
* 16 = 2^4
*
pixel_size               EQU  16
pixel_power              EQU  4
tile_power               EQU  3
*
* VDP Addresses
*
color_table_address      EQU  >0080
sprite_pattern_table_i   EQU  >1000
sprite_pattern_table_ii  EQU  >1800
screen_image_table_i     EQU  >2000
screen_image_table_ii    EQU  >2800
screen_image_table_iii   EQU  >3000
screen_image_table_iv    EQU  >3800
*
* VDP Reg values
*
vdp_reg_2_screen_i       EQU  >0200+(screen_image_table_i/>400)
vdp_reg_2_screen_ii      EQU  >0200+(screen_image_table_ii/>400)
vdp_reg_2_screen_iii     EQU  >0200+(screen_image_table_iii/>400)
vdp_reg_2_screen_iv      EQU  >0200+(screen_image_table_iv/>400)
vdp_reg_3_color_table    EQU  >0300+(color_table_address/>40)
vdp_reg_4_text_patterns  EQU  >0401
vdp_reg_6_sprite_i       EQU  >0600+(sprite_pattern_table_i/>800)
vdp_reg_6_sprite_ii      EQU  >0600+(sprite_pattern_table_ii/>800)
*
* Screen sizes
*
upper_screen_rows        EQU  14
lower_screen_rows        EQU  8
*
* Entities offsets
*
entity_type              EQU  0  (byte)
entity_movement          EQU  2  (word)
entity_y_pos             EQU  4  (word)
entity_x_pos             EQU  6  (word)
entity_char_and_color    EQU  8  (word)
* Size of an entity entry measured as 2^x power
entity_length            EQU  16
entity_power             EQU  4

* =========================================================================================

*
* CPU RAM addresses
*

*
* Values representing the scroll position of different portions of screen
* Measured to the nearest 16th of a pixel.
* Any non-scrolling portions are omitted.
*
x_pos_1                  EQU  >B000
x_pos_2                  EQU  x_pos_1+2
x_pos_3                  EQU  x_pos_1+4
x_pos_4                  EQU  x_pos_1+6
*
* Expected Scroll Position
*
expected_1               EQU  >B008
expected_2               EQU  expected_1+2
expected_3               EQU  expected_1+4
expected_4               EQU  expected_1+6
*
* Selected pattern table for different portions of screen
*
current_pattern_1        EQU  >B010
current_pattern_2        EQU  current_pattern_1+2
current_pattern_3        EQU  current_pattern_1+4
current_pattern_4        EQU  current_pattern_1+6
*
next_pattern_1           EQU  >B018
next_pattern_2           EQU  next_pattern_1+2
next_pattern_3           EQU  next_pattern_1+4
next_pattern_4           EQU  next_pattern_1+6
*
* Screen image table
* >08,>0A,>0C, or >0E
*
current_upper_screen     EQU  >B020
next_upper_screen        EQU  current_upper_screen+2
current_lower_screen     EQU  current_upper_screen+4
next_lower_screen        EQU  current_upper_screen+6
*
* Sprite Pattern VDP Reg value
*
sprite_pattern_vdp_reg   EQU  >B028
*
* Redrawing the next frame
*
address_of_draw_request  EQU  >B02A    * VDP address at which to draw one row of upper screen
*
* Player position
*
player_y_pos             EQU  >B02C
player_y_speed           EQU  player_y_pos+2
*
* Sprite frame
*
sprite_frame_delay       EQU  >B030
sprite_frame             EQU  sprite_frame_delay+2
player_char_address      EQU  sprite_frame_delay+4       * Address of four sprite codes for the current player sprite animation frame
player_offset_address    EQU  sprite_frame_delay+6       * Address of eight values for the player sprite's x/y positions
*
* Entities
*
entity_list              EQU  >B038
entity_list_end          EQU  entity_list+(8*entity_length)

* =========================================================================================
