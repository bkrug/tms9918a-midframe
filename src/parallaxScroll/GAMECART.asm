       REF  parallax_demo

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
PROG2  DATA  0
       DATA  parallax_demo
       BYTE  P2MSGE-P2MSG
P2MSG  TEXT  'PARALLAX SCROLLING'
P2MSGE
       EVEN