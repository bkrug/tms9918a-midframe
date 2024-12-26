       DEF  VDPREG,VDPUPD,VDPADR,VDPWRT
       DEF  write_string
       DEF  set_vdp_read_address
       DEF  read_multiple_vdp_bytes
       DEF  scroll_and_print
       DEF  mult_spaces
*

       COPY 'EQUCPUADR.asm'
       COPY 'EQUVAR.asm'
BIT0   DATA >8000
BIT1   DATA >4000
       EVEN

*
* Write to a VDP register
*
* Input:
* R0
* Output:
* R0
VDPREG
* VDP Reg 1, needs to be set to >F0
*       LI   R0,>01F0
* Specify that we are changing a register
       SOC  @BIT0,R0
       SZC  @BIT1,R0
* Write new value to copy byte
       SWPB R0
* TODO: Should we still copy Reg 1 to this address?
*       MOVB R0,@REG1CP
* Write new value to VDP register
       MOVB R0,@VDPWA
* Specify VDP register to change
       SWPB R0
       MOVB R0,@VDPWA
*
       RT

*
* Set VDP write address 
*
* Input:
* R0 - VDP address
* Output:
* R0 - bits 0 and 1 changed
VDPADR
* Set most signficant two bits for writing
       SZC  @BIT0,R0
       SOC  @BIT1,R0
* Write address to system
VDPAD1 SWPB R0
       MOVB R0,@VDPWA
       SWPB R0
       MOVB R0,@VDPWA
*
       RT

*
* Write multiple bytes to VDP
*
* Input:
* R0 - Address of text to copy
* R1 - Number of bytes
* Output:
* R0 - original value + R1's value
* R1 - 0
VDPWRT
* Don't write if R1 = 0
       MOV  R1,R1
       JEQ  VWRT2
* Write as many bytes as R1 specifies
VWRT1  MOVB *R0+,@VDPWD
       DEC  R1
       JNE  VWRT1
*
VWRT2  RT

*
* Write null-terminating string to VDP
*
* Input:
* R0 - Address of string
* Output:
* R0 - address following null value
* R1 - 0
write_string:
       MOVB *R0+,R1
       JEQ  found_string_end
write_string_loop:
       MOVB R1,@VDPWD
       MOVB *R0+,R1
       JNE  write_string_loop
found_string_end:
       RT

*
* Write empty spaces
*
* Input:
* R0 - number of spaces to write
* Output:
* R0 - 0
mult_spaces:
       CI   R0,1
       JLT  write_space_end
write_space_loop:
       MOVB @SPACE,@VDPWD
       DEC  R0
       JNE  write_space_loop
write_space_end:
       RT

*
* Set VDP read address 
*
* Input:
* R0 - VDP address
* Output:
* R0 - bits 0 and 1 changed
set_vdp_read_address:
* Set most signfication two bits for 
* reading
       SZC  @BIT0,R0
       SZC  @BIT1,R0
* Write address to system
       JMP  VDPAD1

*
* Read multiple bytes from VDP
*
* Input:
* R0 - Address to copy text to
* R1 - Number of bytes
* Output:
* R0 - original value + R1's value
* R1 - 0
read_multiple_vdp_bytes:
* Don't read if R1 = 0
       MOV  R1,R1
       JEQ  VRD2
* Read as many bytes as R1 specifies
VRD1   MOVB @VDPRD,*R0+
       DEC  R1
       JNE  VRD1
*
VRD2   RT

*
* Scroll screen and print up to 32 characters of text.
*
* Input:
* R0 - address of null-terminating string
* Output:
* R0 - changed
* R1 - changed
* R2 - changed
scroll_and_print:
       DECT R10
       MOV  R11,*R10
       DECT R10
       MOV  R0,*R10
* Read current screen to scroll
       LI   R0,>0020
       BL   @set_vdp_read_address
       LI   R0,screen_copy
       LI   R1,23*32
       BL   @read_multiple_vdp_bytes
* Write screen one line higher
       CLR  R0
       BL   @VDPADR
       LI   R0,screen_copy
       LI   R1,23*32
       BL   @VDPWRT
* Write one line
       LI   R0,23*32
       BL   @VDPADR
       MOV  *R10,R0
       BL   @write_string
* Write enough spaces to overwrite old text
       S    *R10+,R0
       NEG  R0
       AI   R0,32+1
       BL   @mult_spaces
*
       MOV  *R10+,R11
       RT