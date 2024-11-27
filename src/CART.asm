       REF  BEGIN,log_interrupts,tiles

********@*****@*********************@**************************
*--------------------------------------------------------------
* Cartridge header
*--------------------------------------------------------------
* Since this header is not absolutely positioned at >6000,
* it is important to include '-a ">6000"' in the xas99.py
* command when linking files into a cartridge.
       BYTE  >AA,1,1,0,0,0
       DATA  PROG3
       BYTE  0,0,0,0,0,0,0,0
*
PROG3  DATA  PROG2
       DATA  tiles
       BYTE  P3MSGE-P3MSG
P3MSG  TEXT  'TILES'
P3MSGE
*
PROG2  DATA  PROG1
       DATA  log_interrupts
       BYTE  P2MSGE-P2MSG
P2MSG  TEXT  'TIMER INTERRUPT'
P2MSGE
*
PROG1  DATA  0
       DATA  BEGIN
       BYTE  P1MSGE-P1MSG
P1MSG  TEXT  'MID-FRAME'
P1MSGE