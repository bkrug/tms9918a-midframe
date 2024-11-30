       DEF  KEYINT
*
       REF  SCAN

       COPY 'EQUVAR.asm'
       COPY 'EQUCPUADR.asm'

* Key pressed
KEYPRS EQU  >8375

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
       CB   @KEYPRS,@NOKEY
       JNE  KEYDWN
       MOVB @KEYPRS,@PREVKY
       RT
* A key has been pressed.
KEYDWN CB   @KEYPRS,@PREVKY
       JNE  KEYNEW
       DEC  @key_timer
       JH   KEYRTN
* The Key is being repeated
KEYAGN MOV  @WAIT2,@key_timer
       JMP  KEYCPY
* The Key is new
KEYNEW MOV  @WAIT1,@key_timer
       MOVB @KEYPRS,@PREVKY
* Copy the key to the key buffer
* Auto increment the buffer position
KEYCPY MOV  @KEYWRT,R0
       MOVB @KEYPRS,*R0+
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
* The console scan doesn't seem to work now.
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
       MOV  R0,R0
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
       MOVB @NOKEY,@KEYPRS
       RT
key_press_found
* A key press has been detected.
* Get the key code from GROM.
*
* Set GROM address
       LI   R3,>1700
       A    R4,R3
       MOVB R3,@GRMWA
       SWPB R3
       MOVB R3,@GRMWA
* Record the key code
       MOVB @GRMRD,@KEYPRS
*
       RT