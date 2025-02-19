*
* Sound when player destroys an enemy
*
       DEF  destroy_sound

       COPY 'NOTEVAL.asm'
       COPY 'CONST.asm'

*
* Song Header
*
destroy_sound
       DATA 0,0,dest3
* Data structures dealing with repeated music
       DATA 0,0,rept3

rept3
       DATA dest3a,dest3
       DATA REPEAT,STOP

* Generator 1
* Measure 1
dest3
       BYTE A3,N16DOT
       BYTE B3,N16DOT
       BYTE A3,N16DOT
dest3a