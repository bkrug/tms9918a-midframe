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
* Duration ratio in 60hz environment
       DATA 5,4
* Duration ratio in 50hz environment
       DATA 1,1

rept3
       DATA harm3a,harm3
       DATA REPEAT,STOP

* Generator 1
* Measure 1
harm3
       BYTE C1,N16DOT
       BYTE B0,N16DOT
       BYTE A0,N16DOT
harm3a