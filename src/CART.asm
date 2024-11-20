       REF  BEGIN,disable_vdp

********@*****@*********************@**************************
*--------------------------------------------------------------
* Cartridge header
*--------------------------------------------------------------
* Since this header is not absolutely positioned at >6000,
* it is important to include '-a ">6000"' in the xas99.py
* command when linking files into a cartridge.
       BYTE  >AA,1,1,0,0,0
       DATA  PROG2
       BYTE  0,0,0,0,0,0,0,0
*
PROG2  DATA  PROG1
       DATA  disable_vdp
       BYTE  P2MSGE-P2MSG
P2MSG  TEXT  'DISABLE VDP'
P2MSGE
*
PROG1  DATA  0
       DATA  BEGIN
       BYTE  P1MSGE-P1MSG
P1MSG  TEXT  'MID-FRAME'
P1MSGE