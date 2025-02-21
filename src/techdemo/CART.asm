       REF  BEGIN
       REF  clc_tiles
       REF  cnc_tiles
       REF  cnc_quarter_text
       REF  clc_quarter_text       

********@*****@*********************@**************************
*--------------------------------------------------------------
* Cartridge header
*--------------------------------------------------------------
* Since this header is not absolutely positioned at >6000,
* it is important to include '-a ">6000"' in the xas99.py
* command when linking files into a cartridge.
       BYTE  >AA,1,1,0,0,0
       DATA  PROG6
       BYTE  0,0,0,0,0,0,0,0
*
PROG6  DATA  PROG5
       DATA  cnc_quarter_text
       BYTE  P6MSGE-P6MSG
P6MSG  TEXT  'TEXT EDITOR COINC'
P6MSGE
*
PROG5  DATA  PROG4
       DATA  clc_quarter_text
       BYTE  P5MSGE-P5MSG
P5MSG  TEXT  'TEXT EDITOR CALC'
P5MSGE
*
PROG4  DATA  PROG3
       DATA  cnc_tiles
       BYTE  P4MSGE-P4MSG
P4MSG  TEXT  'PIXEL-ROW INTS COINC'
P4MSGE
*
PROG3  DATA  PROG2
       DATA  clc_tiles
       BYTE  P3MSGE-P3MSG
P3MSG  TEXT  'PIXEL-ROW INTS CALC'
P3MSGE
*
PROG2  DATA  0
       DATA  BEGIN
       BYTE  P2MSGE-P2MSG
P2MSG  TEXT  'TIMER INTERRUPT'
P2MSGE