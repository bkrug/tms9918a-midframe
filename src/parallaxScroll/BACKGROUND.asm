       DEF  unscrolled_patterns
       DEF  color_groups
       DEF  transition_chars
       DEF  inverted_chars
       DEF  upper_tile_map
       DEF  lower_tile_map
*
* The file below-mentioned file was
* generated by exporting data from Magellan
*
* To re-create use menu:
*   Export -> Assembly Scroll Data
* Use settings:  
*   Transition Type: Left to Right
*   Wrap Edges: True
*   Current Map Only: False
*   Map Compression: No Compression
*   Generate Scrolled Character Frames: 0
*   Include Character Numbers: False
*   Include Comments: (Optional)
*
       COPY 'BACKGROUNDMAP.asm'

unscrolled_patterns     EQU  PAT0
color_groups            EQU  CLRSET
transition_chars        EQU  TCHARS
inverted_chars          EQU  ICHARS
upper_tile_map          EQU  MS0
lower_tile_map          EQU  MS1