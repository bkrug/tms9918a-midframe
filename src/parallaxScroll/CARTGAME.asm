       REF  clc_parallax_demo
       REF  cnc_parallax_demo

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
       DATA  cnc_parallax_demo
       BYTE  P2MSGE-P2MSG
P2MSG  TEXT  'PARALLAX DEMO COINC'
P2MSGE
PROG1  DATA  0
       DATA  clc_parallax_demo
       BYTE  P1MSGE-P1MSG
P1MSG  TEXT  'PARALLAX DEMO CALC'
P1MSGE
       EVEN