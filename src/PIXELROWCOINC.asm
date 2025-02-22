       DEF  coinc_init_timer_loop
*
       REF  block_vdp_interrupt             *BLWP
       REF  unblock_vdp_interrupt           *BLWP
       REF  calc_init_timer_loop
       REF  restart_timer_loop
       REF  set_timer
       REF  get_timer_value
       REF  calc_hertz
       REF  generic_timer_init
       REF  measure_length_of_frame
*
       REF  VDPADR,VDPREG,VDPWRT            Ref from VDP

*
* All of these routines require R10 to be a stack pointer
*

*
* Addresses
*
       COPY 'EQUCPUADR.asm'
       COPY 'EQUVAR.asm'

* TODO: duplicate of value in PIXELROW.asm
* See if we can move this to some area filed with EQU consts.
ticks_calling_timer     EQU  2

*
* Initialize the timer loop.
* Given a table of pixel-row indexes followed by ISR addresses,
* generates a table of corresponding timer-values followed with the same ISR addresses.
* The results are stored at @timer_interrupts.
*
* IMPORTANT: This routine writes to the VDP RAM
* and changes VDP registers without your permission.
* The calling routine should not do its own
* VDP initialization until after calling this method.
*
* Input:
*   R0 - address of scan-line-ISR-table
*   R1 - end of scan-line-ISR-table
*   R2 - end-of-frame interrupt routine
*      - set to 0, if there is no end-of-frame ISR
coinc_init_timer_loop
       DECT R10
       MOV  R11,*R10
*
       BL   @setup_vdp_for_coinc
*
       LI   R6,measure_time_to_reach_pixel_row
       B    @generic_timer_init
* TODO: can we change the above to a BL and then call the following code?
* Clear sprite attribute table
*       CLR  R2
*       BL   @write_test_sprites


char_pattern
* Pattern used for COINIC detection
       DATA >8080,>8080,>8080,>8080
end_of_char_patterns

* These are some of the sprite-attributes for the COINC sprites.
* The Y-position is only know at runtime.
* The X-position is intentinally at the far right side of the screen.
* The sprite code is >00.
* The color is transparent.
sprite_attributes
       BYTE >80,>00,>00
       EVEN

*
* In order to detect overlapping sprites,
* the VDP RAM needs a sprite pattern somewhere.
*
setup_vdp_for_coinc
       DECT R10
       MOV  R11,*R10
       DECT R10
       MOV  R1,*R10
       DECT R10
       MOV  R0,*R10
* Write char & sprite patterns
       LI   R0,>800
       BL   @VDPADR
       LI   R0,char_pattern
       LI   R1,end_of_char_patterns-char_pattern
       BL   @VDPWRT
* Specify address of sprite pattern table
       LI   R0,>0601
       BL   @VDPREG
* Specify address of sprite attirbute list
       LI   R0,>0506
       BL   @VDPREG
*
       MOV  *R10+,R0
       MOV  *R10+,R1
       MOV  *R10+,R11
       RT

*
* Measure the time it takes to get from
* the end of one frame to a particular pixel-row
*
* Input:
*   R1: index of pixel row
* Output:
*   R2: number of CRU ticks
measure_time_to_reach_pixel_row
       DECT R10
       MOV  R11,*R10
* Let R1 = Y-Position minus 1 (for TMS9918a reasons)
       DEC  R1
       SLA  R1,8
*
       DECT R10
       MOV  R1,*R10
* Clear sprite attribute table
       CLR  R2
       BL   @write_test_sprites
* Clear COINC flag, and wait for two video frames
       MOVB @VDPSTA,R2
       LIMI 2
       MOVB @VINTTM,R0
       AI   R0,>0200
clear_coinc
       CB   @VINTTM,R0
       JNE  clear_coinc
* Reset timer
       LI   R1,>3FFF
       BL   @set_timer
*
       LIMI 0
* Draw two overlapping sprites at the pixel-index specified by R1
       MOV  *R10+,R1
       LI   R2,2
       BL   @write_test_sprites
* Wait util COINC flag is "true"
while_coinc_not_triggered
       MOVB @VDPSTA,R1
       ANDI R1,>2000
       JEQ  while_coinc_not_triggered
* Let R2 = new timer value
       BL   @get_timer_value
       NEG  R2
       AI   R2,>3FFF
* Account for missed ticks branching to/from timer routines
       AI   R2,ticks_calling_timer
*
       MOV  *R10+,R11
       RT

*
* Write sprite attibute list
*
* Input:
*   R1(high-byte) - pixel-index at which to draw top of sprite
*   R2 - number of sprites to draw
* Changed:
*   R0,R3
write_test_sprites
       DECT R10
       MOV  R11,*R10
* Set VDP address to sprite attribute list
       LI   R0,>300
       BL   @VDPADR
* If R2 = 0, just write the end-of-sprite-attribute-list symbol
       MOV  R2,R2
       JEQ  end_sprite_list
write_one_sprite
* Set Y-Position
       MOVB R1,@VDPWD
* Set X-Position, char, and color
       LI   R0,sprite_attributes
       LI   R3,VDPWD
       MOVB *R0+,*R3
       MOVB *R0+,*R3
       MOVB *R0+,*R3
*
       DEC  R2
       JNE  write_one_sprite
* End sprite list
end_sprite_list
       LI   R3,>D000
       MOVB R3,@VDPWD
*
       MOV  *R10+,R11
       RT