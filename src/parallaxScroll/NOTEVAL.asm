HDRRPT EQU  6
HDR60  EQU  12
HDR50  EQU  16

*
* 16-bit symbols used to signal something
* besides a note or a rest
*
STOP   EQU  >FFFF       Stop playing a signal/tune at end
REPEAT EQU  >FE00       Play signal/tune as repeated loop

*
* Durantion values
*
* The smallest not should be set to a multiple of 3.
* Otherwise Trippletes will get tone generators out of sync.
N32    EQU  3
N16    EQU  N32*2
N8     EQU  N16*2
N4     EQU  N8*2
N2     EQU  N4*2
N1     EQU  N2*2
NDBL   EQU  N1*2

N64TRP EQU  N32/3
N32TRP EQU  N16/3
N16TRP EQU  N8/3
N8TRP  EQU  N4/3
N4TRP  EQU  N2/3
N2TRP  EQU  N1/3

N16DOT EQU  N16+N32
N8DOT  EQU  N8+N16
N4DOT  EQU  N4+N8
N2DOT  EQU  N2+N4
N1DOT  EQU  N1+N2

*
* Note Codes
*
NOIZ8  EQU  -8
NOIZ7  EQU  -7
NOIZ6  EQU  -6
NOIZ5  EQU  -5
NOIZ4  EQU  -4
NOIZ3  EQU  -3
NOIZ2  EQU  -2
NOIZ1  EQU  -1
A0     EQU  >00
As0    EQU  >01
Bb0    EQU  >01
B0     EQU  >02
C1     EQU  >03
Cs1    EQU  >04
Db1    EQU  >04
D1     EQU  >05
Ds1    EQU  >06
Eb1    EQU  >06
E1     EQU  >07
F1     EQU  >08
Fs1    EQU  >09
Gb1    EQU  >09
G1     EQU  >0A
Gs1    EQU  >0B
Ab1    EQU  >0B
A1     EQU  >0C
As1    EQU  >0D
Bb1    EQU  >0D
B1     EQU  >0E
C2     EQU  >0F
Cs2    EQU  >10
Db2    EQU  >10
D2     EQU  >11
Ds2    EQU  >12
Eb2    EQU  >12
E2     EQU  >13
F2     EQU  >14
Fs2    EQU  >15
Gb2    EQU  >15
G2     EQU  >16
Gs2    EQU  >17
Ab2    EQU  >17
A2     EQU  >18
As2    EQU  >19
Bb2    EQU  >19
B2     EQU  >1A
C3     EQU  >1B
Cs3    EQU  >1C
Db3    EQU  >1C
D3     EQU  >1D
Ds3    EQU  >1E
Eb3    EQU  >1E
E3     EQU  >1F
F3     EQU  >20
Fs3    EQU  >21
Gb3    EQU  >21
G3     EQU  >22
Gs3    EQU  >23
Ab3    EQU  >23
A3     EQU  >24
As3    EQU  >25
Bb3    EQU  >25
B3     EQU  >26
C4     EQU  >27
Cs4    EQU  >28
Db4    EQU  >28
D4     EQU  >29
Ds4    EQU  >2A
Eb4    EQU  >2A
E4     EQU  >2B
F4     EQU  >2C
Fs4    EQU  >2D
Gb4    EQU  >2D
G4     EQU  >2E
Gs4    EQU  >2F
Ab4    EQU  >2F
A4     EQU  >30
As4    EQU  >31
Bb4    EQU  >31
B4     EQU  >32
C5     EQU  >33
Cs5    EQU  >34
Db5    EQU  >34
D5     EQU  >35
Ds5    EQU  >36
Eb5    EQU  >36
E5     EQU  >37
F5     EQU  >38
Fs5    EQU  >39
Gb5    EQU  >39
G5     EQU  >3A
Gs5    EQU  >3B
Ab5    EQU  >3B
A5     EQU  >3C
As5    EQU  >3D
Bb5    EQU  >3D
B5     EQU  >3E
C6     EQU  >3F
Cs6    EQU  >40
Db6    EQU  >40
D6     EQU  >41
Ds6    EQU  >42
Eb6    EQU  >42
E6     EQU  >43
F6     EQU  >44
REST   EQU  >7F