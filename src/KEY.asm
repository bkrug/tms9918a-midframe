       DEF  KEYINT
*
       REF  SCAN

       COPY 'EQUVAR.asm'
       COPY 'EQUCPUADR.asm'

* The delay before initial repeat
WAIT1  DATA >18
* The delay before additional repeats
WAIT2  DATA >4
NOKEY  EQU  NEGONE
       EVEN

* Use an interupt to record key presses
* so that if the computer is working on
* a long process the keys will still be
* recorded.
KEYINT
*
       DECT R10
       MOV  R11,*R10
* Call our Key Scan routine
       BL   @replacement_scan
* restore R11
       MOV  *R10+,R11
       RT
*
       CB   @KEYCOD,@NOKEY
       JNE  KEYDWN
       MOVB @KEYCOD,@PREVKY
       RT
* A key has been pressed.
KEYDWN CB   @KEYCOD,@PREVKY
       JNE  KEYNEW
       DEC  @key_timer
       JH   KEYRTN
* The Key is being repeated
KEYAGN MOV  @WAIT2,@key_timer
       JMP  KEYCPY
* The Key is new
KEYNEW MOV  @WAIT1,@key_timer
       MOVB @KEYCOD,@PREVKY
* Copy the key to the key buffer
* Auto increment the buffer position
KEYCPY MOV  @KEYWRT,R0
       MOVB @KEYCOD,*R0+
* If the next position is past the
* buffer end, move to the buffer start
       CI   R0,KEYEND
       JL   KEY1
       LI   R0,KEYSTR
* Update KEYWRT with the new buffer
* position, unless this would cause
* KEYWRT to equal KEYRD
KEY1   C    R0,@KEYRD
       JEQ  KEYRTN
       MOV  R0,@KEYWRT
*
KEYRTN RT

*
* The console scan doesn't seem to work after we mangled the GPL WS.
* So there!
*
replacement_scan
* Let R1 = column to scan
* Let R4 = index in key code table
       CLR  R1
       CLR  R4
* Select column to scan
scan_loop
       LI   R12,>0024
       LDCR R1,3
* Put results in R2
       LI   R12,>0006
       STCR R2,8
* If this is column 0, store CTRL, SHIFT, FCTN in R3
       MOV  R1,R1
       JNE  not_col_0
       MOV  R2,R3
* For column 0, set modifier keys to unpressed.
       LI   R0,>F800
       SOC  R0,R2
not_col_0
* find a pressed key
       LI   R5,8
unpressed_loop
       SLA  R2,1
       JNC  key_press_found
       INC  R4
       DEC  R5
       JNE  unpressed_loop
* select next column
       AB   @ONE,R1
       CI   R1,>0800
       JL   scan_loop
* Record NOKEY and return
       MOVB @NOKEY,@KEYCOD
       RT
key_press_found
* A key press has been detected.
* Get the key code from GROM.
*
* Let R5 = GROM address of key code without modifier keys
       LI   R5,>1700
       A    R4,R5
* Let R3 = address in modifier_key_offsets
       ANDI R3,>7000
       MOVB R3,@>A416
       SRL  R3,11
       AI   R3,modifier_key_offsets
* Increase GROM address by a multiple of >30
       A    *R3,R5
* Set GROM address
       MOVB R5,@GRMWA
       SWPB R5
       MOVB R5,@GRMWA
* Record the key code
       MOVB @GRMRD,@KEYCOD
*
       RT

* Three bits are used to tell us if modifier keys are pressed.
* Whichever bit is set to 0, is being pressed.
* The keys by bit position are CTRL, SHIFT, FCTN
modifier_key_offsets
       DATA >30       * All modifiers pressed
       DATA >90       * CTRL & SHIFT pressed
       DATA >60       * CTRL & FCTN pressed
       DATA >90       * Only CTRL pressed
       DATA >60       * SHIFT & FCTN pressed
       DATA >30       * Only SHIFT pressed
       DATA >60       * Only FCTN pressed
       DATA 0         * No modifiers pressed