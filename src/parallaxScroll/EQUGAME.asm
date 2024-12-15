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
* Selected pattern table for different portions of screen
*
current_pattern_1        EQU  >B008
current_pattern_2        EQU  current_pattern_1+2
current_pattern_3        EQU  current_pattern_1+4
current_pattern_4        EQU  current_pattern_1+6
*
next_pattern_1           EQU  >B010
next_pattern_2           EQU  next_pattern_1+2
next_pattern_3           EQU  next_pattern_1+4
next_pattern_4           EQU  next_pattern_1+6
*
* Screen image table
* >08,>0A,>0C, or >0E
*
current_upper_screen     EQU  >B018
next_upper_screen        EQU  current_upper_screen+2
current_lower_screen     EQU  current_upper_screen+4
next_lower_screen        EQU  current_upper_screen+6
*
* Redrawing the next frame
*
address_of_draw_request   EQU  >B020    * VDP address at which to draw one row of upper screen
address_of_tile_data      EQU  >B022    * Cartridge address from which to get next row to draw