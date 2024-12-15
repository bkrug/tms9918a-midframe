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
patt_1                   EQU  >B008
patt_2                   EQU  patt_1+2
patt_3                   EQU  patt_1+4
patt_4                   EQU  patt_1+6
*
* Screen image table
* >08,>0A,>0C, or >0E
*
current_upper_screen  EQU  >B010
next_upper_screen     EQU  current_upper_screen+2
current_lower_screen  EQU  current_upper_screen+4
next_lower_screen     EQU  current_upper_screen+6