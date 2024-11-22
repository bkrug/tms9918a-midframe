       DEF  tiles
*
       REF  VDPREG,VDPADR,VDPWRT            Ref from VDP
       REF  STACK                           Ref from VAR

*
* Addresses
*
       COPY 'EQUCPUADR.asm'
       COPY 'EQU.asm'

char_pattern
       DATA >0000,>00C0,>0000,>00CC
coinc_sprite_pattern
       DATA >0800,>0000,>0000,>0000
color  BYTE >10
       EVEN
scan_line_interrupts
*       DATA -8,red_color_isr
       DATA 9*8+0,yellow_color_isr
       DATA 17*8+4,blue_color_isr
       DATA vdp_mock,purple_color_isr

tiles
       LI   R10,STACK
* Sprites should be 8x8, and VDP interrupts are enabled
       LI   R0,>01E0
       BL   @VDPREG
* Screen Image table
       LI   R0,>0200
       BL   @VDPREG
* Color table
       LI   R0,>030E
       BL   @VDPREG
* Tile pattern table
       LI   R0,>0401
       BL   @VDPREG
* Sprite attribute list
       LI   R0,>0506
       BL   @VDPREG
* Sprite pattern table (occupies same space as tile pattern table)
       LI   R0,>0601
       BL   @VDPREG
* Write patterns
* >00 = tile pattern forming dotted lines
* >01 = our sprite
       LI   R0,>800
       BL   @VDPADR
       LI   R0,char_pattern
       LI   R1,2*8
       BL   @VDPWRT
* Write color code
       LI   R0,>380
       BL   @VDPADR
       MOVB @COLOR,@VDPWD
* Write tiles
       CLR  R0
       BL   @VDPADR
       LI   R0,24*32
       CLR  R1
while_tiles_to_write
       MOVB R1,@VDPWD
       DEC  R0
       JNE  while_tiles_to_write
*
       LI   R0,>0706
       BL   @VDPREG
*
JMP    JMP  JMP

*red_color_isr

yellow_color_isr

blue_color_isr

purple_color_isr