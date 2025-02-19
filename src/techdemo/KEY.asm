       DEF  init_key_buffer
       DEF  get_key_from_buffer
       DEF  update_key_buffer
*
       REF  SCAN

       COPY '../EQUVAR.asm'
       COPY '../EQUCPUADR.asm'
       COPY 'EQUDEMO.asm'

* The delay before initial repeat
WAIT1  DATA >18
* The delay before additional repeats
WAIT2  DATA >4
* Bits that correspond to the modifier keys in key-column 0
MODKEY BYTE >F8
lower_a TEXT 'a'
lower_z TEXT 'z'
NOKEY  EQU  NEGONE
       EVEN

init_key_buffer
       LI   R0,KEYSTR
       MOV  R0,@KEYWRT
       MOV  R0,@KEYRD
       RT

*
* Get the next key from the key buffer
*
* Output:
*   R0 (high byte)
* Changed:
*   R1
get_key_from_buffer
* Set R0 to default value.
       MOVB @NOKEY,R0
* Is there anything in the key buffer?
       C    @KEYRD,@KEYWRT
       JEQ  get_key_done
* Yes, copy one byte to R0
       MOV  @KEYRD,R1
       MOVB *R1+,R0
       MOV  R1,@KEYRD
* Has the read position reached the end of the buffer?
       CI   R1,KEYEND
       JL   get_key_done
* Yes, point it to the start of the buffer
       LI   R1,KEYSTR
       MOV  R1,@KEYRD
get_key_done
       RT

* In order to avoid dropped keys,
* record key presses in a buffer.
update_key_buffer
*
       DECT R10
       MOV  R11,*R10
* Call our Key Scan routine
       BL   @kscan_mode_0
* restore R11
       MOV  *R10+,R11
* Was a key pressed?
       CB   @KEYCOD,@NOKEY
       JNE  KEYDWN
* No
       MOVB @KEYCOD,@PREVKY
       RT
* A key has been pressed.
* If the user holding a key down?
KEYDWN CB   @KEYCOD,@PREVKY
       JNE  KEYNEW
* Yes, has enough time passed to register it a second time?
       DEC  @key_timer
       JH   KEYRTN
* Yes, reset the timer, then register the repeated key.
       MOV  @WAIT2,@key_timer
       JMP  KEYCPY
* The Key is new, reset the timer.
KEYNEW CB   @PREVKY,@NOKEY
       MOV  @WAIT1,@key_timer
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
* I can't think of a solution other than to reimplement it.
*
kscan_mode_0
* Let R6 = >00 if caps lock is down, >01 if caps lock is up.
       LI   R12,>002A
       CLR  R1
       LDCR R1,1
       LI   R12,>000E
       STCR R6,1
* Let R1 = column to scan, with caps-lock ignored
*      bit of weight >0800 turns off caps-lock scanning
*      bits of weight >0100 to >0400 select the column
* Let R4 = index in key code table
       LI   R1,>0800
       CLR  R4
* Select column to scan
scan_loop
       LI   R12,>0024
       LDCR R1,4
* Put results in R2
       LI   R12,>0006
       STCR R2,8
* If this is column 0, store CTRL, SHIFT, FCTN in R3
       CI   R1,>0800
       JNE  not_col_0
       MOV  R2,R3
* For column 0, set modifier keys to unpressed.
       SOCB @MODKEY,R2
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
       CI   R1,>1000
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
       SRL  R3,11
       AI   R3,modifier_key_offsets
* Increase GROM address by a multiple of >30
       A    *R3,R5
* Set GROM address
       MOVB R5,@GRMWA
       SWPB R5
       MOVB R5,@GRMWA
* Let R0 = key code
       MOVB @GRMRD,R0
* Is caps lock down?
       MOVB R6,R6
       JNE  dont_capitalize
* Yes, is the key code a lower case letter?
       CB   R0,@lower_a
       JL   dont_capitalize
       CB   R0,@lower_z
       JH   dont_capitalize
* Yes, make it upper case
       AI   R0,>E000
dont_capitalize
* Record the key code
       MOVB R0,@KEYCOD
*
       RT

* Three bits are used to tell us if modifier keys are pressed.
* Whichever bit is set to 0, is being pressed.
* The keys by bit position are CTRL, SHIFT, FCTN
modifier_key_offsets
       DATA >30       * All modifiers pressed, select SHIFT key codes
       DATA >90       * CTRL & SHIFT pressed, select SHIFT key codes
       DATA >60       * CTRL & FCTN pressed, select FCTN key codes
       DATA >90       * Only CTRL pressed
       DATA >60       * SHIFT & FCTN pressed, select FCTN key codes
       DATA >30       * Only SHIFT pressed
       DATA >60       * Only FCTN pressed
       DATA 0         * No modifiers pressed