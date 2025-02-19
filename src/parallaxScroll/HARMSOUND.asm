       DEF  harm_sound

       COPY 'NOTEVAL.asm'
       COPY 'CONST.asm'

*
* Song Header
*
harm_sound
       DATA 0,0,harm3
* Data structures dealing with repeated music
       DATA 0,0,rept3

rept3
       DATA harm3a,harm3
       DATA REPEAT,STOP

* Generator 1
* Measure 1
harm3
       BYTE G3,N16DOT
       BYTE F3,N16DOT
       BYTE E3,N4
harm3a