*
* Variables as >8300
*
WS                        EQU  >8300
STACK                     EQU  >8320+>10
OLDR12                    EQU  >8330
COUNT                     EQU  >8332
swappable_colors          EQU  >8334
RETPT                     EQU  >8336
isr_hit_count             EQU  >8338
all_lines_scanned         EQU  >833A
isr_table_address         EQU  >833C
isr_element_address       EQU  >833E
isr_end_address           EQU  >8340
frame_isr                 EQU  >8342

*
* Avoid letting the above grow past >8370 which is reserved for GPL status
*

*
* Variables at >8380
* 

*
* Avoid letting the above grow past >83C4 or so, which is reserved for
* some other routines' workspaces.
*

*
* Scratch PAD usage outside programmer control.
* The below assumes that VDP Interrupts are enabled.
* From E/A manual page 404-406 and some independent research:
*
* >8370->837F GPL status block.
*       >8374       contains the keyboard argument.
*       >8375       returns the key code, or >FF if no key was pressed.
*       >8376       returns the X-value for a joystick (0,4, or >FC).
*       >8377       returns the X-value for a joystick.
*       >8379       (byte) VDP interrupt timer. Incremented every 1/60th second.
*       >837A       (byte) number of sprites allowed in motion
*       >837B       (byte) VDP status byte
*
* >83C0->83DF Interpretter Workspace.
*             A routine at >0900 executes each VDP interrupt and uses this.
*       >83C4       (word) Address of user-defined interrupt
*       >83D6       (word) Screen time-out counter. Decrements every 1/60th second.
*       >83DA       (word) Player number used in some scan routine
*       >83DC       (word) undocumented. Switches between two values.
*       >83DE       (word) undocumented. Out of our control.
*
* >83E0->83FF GPL workspace registers.
*             It's a workspace. All of it is out of our control,
*             but writing to these addresses (words) in particular breaks our program.
*       >83E2
*       >83EA
*       >83F0
*       >83F6
*       >83F8
*       >83FC
*       >83FE

*
* Labels for lower bytes of registers
*
LBR0   EQU  WS+1
LBR1   EQU  WS+3
LBR2   EQU  WS+5
LBR3   EQU  WS+7
LBR4   EQU  WS+9
LBR5   EQU  WS+11
LBR6   EQU  WS+13
LBR7   EQU  WS+15
LBR8   EQU  WS+17
LBR9   EQU  WS+19
LBR10  EQU  WS+21
LBR11  EQU  WS+23
LBR12  EQU  WS+25
LBR13  EQU  WS+27
LBR14  EQU  WS+29
LBR15  EQU  WS+31


screen_copy:
       EQU  >A000      * >300 bytes
timer_interrupts:
       EQU  >A300      * >40 bytes - the timer-ISR-table
limit_timer_interrupts:
       EQU  >A33C      * We never want to fill the last 4 bytes with a user-defined ISR.
*                        The last 4 bytes in the timer-ISR-table should always
*                        point to the end-of-frame interrupt that replaces the VDP interrupt.
document_text:
       EQU  >B000
document_font:
       EQU  >B800