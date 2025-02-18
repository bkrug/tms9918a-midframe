       DEF  PLYINT,PLYMSC
       DEF  gen3_init
*
       REF  TTBL                              Ref from TONETABLE

*
* Constants
*
       COPY 'NOTEVAL.asm'
       COPY 'EQUGAME.asm'
       COPY '..\EQUCPUADR.asm'
       COPY '..\EQUVAR.asm'
* Offsets within sound structure
SNDRPT EQU  2
SNDELP EQU  4
SNDTIM EQU  6
SNDVOL EQU  8
SNDMOD EQU  9
SNDRMN EQU  10
* Current ADSR Modes
MDATCK EQU  0
MDDECY EQU  1
MDSSTN EQU  2
MDRELS EQU  3
* Codes for different tone generators
TGN1   EQU  >8000
TGN2   EQU  >A000
TGN3   EQU  >C000
NOIZGN EQU  >E000
*
SETVOL BYTE >10
NOVOL  BYTE >0F
LOWVOL BYTE >0C
MIDVOL BYTE >04
       EVEN

*
* Public Method:
* Initialize
*
PLYINT
       DECT R10
       MOV  R11,*R10
* Let R3 = address of song header
       MOV  @SONGHD,R3
* Set NOTERT to address of note ratio
* Address depends on 50hz or 60hz electricity
       MOV  R3,R2
       AI   R2,HDR60
       MOVB @HERTZ,R0
       JEQ  INT1
       AI   R2,4
INT1   MOV  R2,@NOTERT
* Start Music
       LI   R0,TGN1
       MOV  @HDRRPT(R3),R2
       MOV  *R3+,R1
       BL   @STRTPL
*
       LI   R0,TGN2
       MOV  @HDRRPT(R3),R2
       MOV  *R3+,R1
       BL   @STRTPL
*
       MOV  *R10+,R11
       RT

*
* Public Method:
* Initialize sound generator 3
* to notifly player of some sort of hit.
*
* Let R0 = address of sound header
*
gen3_init
       DECT R10
       MOV  R11,*R10
*
       MOV  R0,R3
       AI   R3,2*2
* Start Music
       LI   R0,TGN3
       MOV  @HDRRPT(R3),R2
       MOV  *R3,R1
       BL   @STRTPL
*
       MOV  *R10+,R11
       RT

*
* Public Method:
* Continue playing music.
* Check if it is time to switch notes.
*
PLYMSC DECT R10
       MOV  R11,*R10
* Play from Tone Generator 1
       LI   R0,TGN1
       LI   R1,SND1AD
       BL   @PLYONE
* Play from Tone Generator 2
       LI   R0,TGN2
       LI   R1,SND2AD
       BL   @PLYONE
* Play from Tone Generator 3
       LI   R0,TGN3
       LI   R1,SND3AD
       BL   @PLYONE
*
PLYMRT MOV  *R10+,R11
       RT

NTPAUS DATA 2                       pause between notes (not same as a rest)
STOPVL DATA STOP
REPTVL DATA REPEAT
RESTVL BYTE REST                    if this is in place of a tone, then do a rest
       EVEN

*
* Initialize stream of music for one tone generator
*
* R0 - specifies the sound generator
* R1 - address of music for specified sound generator
* R2 - address of repeat structure for specified sound generator
STRTPL
       DECT R10
       MOV  R11,*R10
       DECT R10
       MOV  R3,*R10
* Let R5 = address of Sound structure for current sound generator
       MOV  R0,R5
       AI   R5,-TGN1
       SRL  R5,12
       AI   R5,SNDSTR
       MOV  *R5,R5
* Move specified music to sound structure
       MOV  R1,*R5
       JNE  STRT1
* There is no data for this sonund generator
* Let R1 = Addres of sound structure
       MOV  R5,R1
       JMP  STOPMS
STRT1
* Populate address within Repeat Structure
       MOV  R2,@SNDRPT(R5)
* Clear note-duration ratio remainder
       CLR  @SNDRMN(R5)
* Let R1 = Addres of sound structure
* Let R2 = address of current note
       MOV  R5,R1
       MOV  *R5,R2
*
       JMP  PLY3

SNDSTR DATA SND1AD,SND2AD,SND3AD

*
* Check if a note has finished. If yes, then play a new one
*
* R0 - specifies the sound generator
* R1 - address of address of the next piece of data for sound generator
PLYONE DECT R10
       MOV  R11,*R10
       DECT R10
       MOV  R2,*R10
* Let R2 = address of current note
       MOV  *R1,R2
* If R2 = 0, then skip
       JEQ  STOPMS
* Update times
       INC  @SNDELP(R1)
       DEC  @SNDTIM(R1)
* Reached end of note?
       JNE  ENVELP
* Yes, look at next note
       INCT R2
* Have we reached a repeat bar or volta bracket?
       MOV  @SNDRPT(R1),R5
       C    R2,*R5
       JNE  PLY3
* Yes, jump to another part of the music
       INCT R5
       MOV  *R5+,R2
       C    *R5,@REPTVL        * Was that the last bar or bracket?
       JNE  PLY2
       INCT R5                 * Yes, reached end of song.
       C    *R5,@STOPVL        * Stop music or repeat from some point?
       JEQ  STOPMS             * Stop music.
       MOV  *R5,R5             * Repeat from some specified point.
PLY2   MOV  R5,@SNDRPT(R1)
*
* Play tone
*
* Look up tone-code based on note-code.
* Note-codes (see NOTEVAL.asm) are one byte values.
* Tone-codes (see TONETABLE.asm) are 10-bit values understood by the SN76489.
PLY3   MOVB *R2,R5
       CB   R5,@RESTVL
       JEQ  PLY4
       SRL  R5,8
       SLA  R5,1
       AI   R5,TTBL
* Load tone into sound address. Have to select generator, too.
       MOV  *R5,R8
       A    R0,R8
       MOVB R8,@SGADR
       SWPB R8
       MOVB R8,@SGADR
*
* Set note duration
*
* Let R5 = address of note-duration ratio
PLY4   MOV  @NOTERT,R5
* Let R7 = note duration in base speed
       MOVB @1(R2),R7
       SRL  R7,8
* Multiply duration by numerator
* and add remainder from previous operation
       MPY  *R5+,R7
       A    @SNDRMN(R1),R8
* Divide by denominator
       DIV  *R5,R7
* Store converted duration
* And remainder from division
       MOV  R7,@SNDTIM(R1)
       MOV  R8,@SNDRMN(R1)
* Set elapsed time
       CLR  @SNDELP(R1)
*
* Update position within music data
*
       MOV  R2,*R1
*
* Select Envelope
*
ENVELP 
* Let R3 = SNDTIM(R1)
* Let R4 = SNDVOL(R1)
       MOV  R1,R3
       AI   R3,SNDTIM
       MOV  R1,R4
       AI   R4,SNDVOL
* Call envelope to set the cur volume in *R4
       BL   @ENV1
* Set new volume
       AB   @SETVOL,R0
       AB   *R4,R0
       MOVB R0,@SGADR
*
PLY1RT MOV  *R10+,R3
       MOV  *R10+,R11
       RT

*
* Stop non-repeating music
* Then turn-off sound generator
*
STOPMS CLR  *R1
       AI   R0,>1F00
       MOVB R0,@SGADR
*
       JMP  PLY1RT

*
* Loop to beginning of tune for one tone generator
*
REPTMS MOV  @2(R2),*R1
       MOV  *R1,R2
       JMP  PLY3

*
* For each envelope routine the following parameters are already set
*
* R0 = value indicating current sound generator
* R1 = address of sound structure
* R2 = address of current note
* R3 = address of remaining time
* R4 = address of current volume
*

*
* Envelope 1
* Flat max volume with short paus between notes
*
ENV1
* Is this a rest?
       CB   *R2,@RESTVL
       JEQ  ENV1A
* No, are we at end of note?
       C    *R3,@NTPAUS
       JH   ENV1B
* Yes, lower sound
       MOVB @LOWVOL,*R4
       RT
* Yes, turn off sound
ENV1A  MOVB @NOVOL,*R4
       RT
* No, turn volume to top
ENV1B  MOVB @MIDVOL,*R4
       RT