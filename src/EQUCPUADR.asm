FAC    EQU  >834A        GPL parameter (word)
STATUS EQU  >837C        GPL status (byte)
VINTTM EQU  >8379        VDP Interrupt timer (byte)
VSAVER EQU  >83D6        Screen Saver timer address (word)
*
KEYARG EQU  >8374        contains the keyboard argument.
KEYCOD EQU  >8375        returns the key code, or >FF if no key was pressed.
JOYX   EQU  >8376        returns the X-value for a joystick (0,4, or >FC).
JOYY   EQU  >8377        returns the X-value for a joystick.
KEYSTS EQU  >837C        bit 2 (value >20) is set if a key was pressed. 
*
USRISR EQU  >83C4        Address defining address of user-defined service routine
*
SGADR  EQU  >8400        Address for accessing sound generators
*
VDPSTA EQU  >8802        VDP RAM status
VDPRD  EQU  >8800        VDP RAM read data
VDPWD  EQU  >8C00        VDP RAM write data
VDPWA  EQU  >8C02        VDP RAM write address
*
GRMWA  EQU  >9C02
GRMRD  EQU  >9800