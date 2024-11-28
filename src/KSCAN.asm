       DEF  KSCAN
*
* Our method of enabling timer interrupts,
* seems to also disable the console SCAN routine.
* Sorry.
*
* This routine sets the following bits at >8375
* when one or more keys are detected:
*   >80  X
*   >40  Q
*   >20  S
*   >10  FCTN
*   >08  E
*   >04  D
*   >02  SPACE
*   >01  =
*
*       REF  VDPREG

*
* Constants
*
       COPY 'EQUCPUADR.asm'
       COPY 'EQUVAR.asm'

*
KCOL2  BYTE >02
* Key column, key rows to ignore
SCNCOL BYTE >0,>EC       * Ignore everything except FCTN, Space, and =
       BYTE >1,>5F       * Ignore everything except X & S
       BYTE >5,>BF       * Ignore everything except Q
SCEND
       EVEN

*
* Public Method:
* Scan Keyboard and Joysticks
* Place reslts in BUTTON
*
KSCAN
       DECT R10
       MOV  R11,*R10
* Let R1 = button flags
*
* Scan Key Columns
* First Column 2 (the black sheep with a bit-shift operation)
       LI   R12,>0024
       LDCR @KCOL2,3
* Let R3 = detected keys
       LI   R12,>0006
       STCR R3,8
       INV  R3
* Ignore everything except D & E
       ANDI R3,>6000
* Shift by 3 bits so that D & E flags do not overlap other keys we care about
       SRL  R3,3
* Let R2 = position in SCNCOL
       LI   R2,SCNCOL
KSCAN1
* Select column to scan
       LI   R12,>0024
       LDCR *R2+,3
* Put results in R4
       LI   R12,>0006
       STCR R4,8
       INV  R4
* Ignore some keys
       SZCB *R2+,R4
* logical OR with results in R3
       SOCB R4,R3
* End of list?
       CI   R2,SCEND
       JL   KSCAN1
*
       MOVB R3,@KEYCOD
* Was anything pressed?
*       JEQ  KSCAN8
* Yes, reset screen Saver
*       LI   R1,-15*MINUTE
*       MOV  R1,@VSAVER
* If screen currently off, redisplay it
*       LI   R0,VDP1DF
*       BL   @VDPREG
*
KSCAN8
       MOV  *R10+,R11
       RT