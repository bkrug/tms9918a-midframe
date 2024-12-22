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
* Sprite frame
*
sprite_frame_delay       EQU  >B030
sprite_frame             EQU  sprite_frame_delay+2
player_char_address      EQU  sprite_frame_delay+4       * Address of four sprite codes for the current player sprite animation frame
player_offset_address    EQU  sprite_frame_delay+6       * Address of eight values for the player sprite's x/y positions



*
* Keys
*
right_flag     EQU  >04
jump_flag      EQU  >02
sword_flag     EQU  >10
