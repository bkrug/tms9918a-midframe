*
* Values representing the scroll position of different portions of screen
* Measured to the nearest 16th of a pixel.
* Any non-scrolling portions are omitted.
*
x_pos_1                  EQU  >B000
x_pos_2                  EQU  >B002
x_pos_3                  EQU  >B004
x_pos_4                  EQU  >B006
*
* Selected pattern table for different portions of screen
*
patt_1                   EQU  >B008
patt_2                   EQU  >B009
patt_3                   EQU  >B00A
patt_4                   EQU  >B00B
*
* Next screen image table
* >08,>0A,>0C, or >0E
*
next_screen_image_table  EQU  >B00C