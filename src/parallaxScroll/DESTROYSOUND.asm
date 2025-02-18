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
* Duration ratio in 60hz environment
       DATA 5,4
* Duration ratio in 50hz environment
       DATA 1,1

rept3
       DATA dest3a,dest3
       DATA REPEAT,STOP

* Generator 1
* Measure 1
dest3
       BYTE C4,N4
       BYTE D4,N4
       BYTE C4,N4
dest3a