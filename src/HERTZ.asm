       DEF  SETHRZ
*
       REF  set_timer,get_timer_value

*
* Addresses
*
       COPY 'EQUCPUADR.asm'
       COPY 'EQUVAR.asm'

*
* Public Method:
* Set HERTZ
*    0 = 60hz
*    -1 = 50hz
*
SETHRZ
       DECT R10
       MOV  R11,*R10
*
       LI   R1,>3FFF
       BL   @set_timer
* Turn on VDP interrupts
       LIMI 2
* Skip first VDP interrupt; it's too late to measure the full time.
       MOVB @VINTTM,R0
FRSTLP CB   @VINTTM,R0
       JEQ  FRSTLP
* Let R9 = recorded time at begging of interrupt
       BL   @get_timer_value
       MOV  R2,R9
VDPLP
* Let R0 = most recently read VDP time
       MOVB @VINTTM,R0
* Wait for VDP interrupt
WAITLP CB   @VINTTM,R0
       JEQ  WAITLP
* Let R2 = newly recorded time
       BL   @get_timer_value
* Let R9 = quantity of time between interrupts
       S    R2,R9
* Turn off interrupts so we can write to VDP
       LIMI 0
*
* In a 50hz environment R3 should contain about 938.
* We'll accept 888 - 988 in case an emulator is not accurate.
* Any other value implies 60hz or an emulator that doesn't implement the CRU timer.
*
       CLR  R4
       CI   R9,988
       JH   HRZ1
       CI   R9,888
       JL   HRZ1
       DEC  R4
HRZ1   MOVB R4,@HERTZ
*
       MOV  *R10+,R11
       RT