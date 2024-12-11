****************************************
* Original Character Patterns           
****************************************
PAT0   DATA >FF80,>8080,>FF08,>0808    ; #00
PAT1   DATA >FF80,>8080,>FF08,>1C3C    ; #01
PAT2   DATA >00FF,>FBFF,>BFFF,>FDFF    ; #02 (08)
PAT3   DATA >FFEF,>FFFD,>FFFF,>BFFF    ; #03 (09)
PAT4   DATA >FEFE,>FEFE,>FDFD,>FDFD    ; #04 (10)
PAT5   DATA >FBFB,>FBFB,>F7F7,>F7F7    ; #05 (11)
PAT6   DATA >FFFF,>FFFF,>FFFF,>FFFF    ; #06 (13)
PAT7   DATA >0000,>0000,>0000,>0000    ; #07 (18)
PAT8   DATA >007F,>4040,>4040,>4448    ; #08 (19)
PAT9   DATA >4040,>4040,>FFFF,>0000    ; #09 (1A)
PAT10  DATA >00FE,>0202,>0202,>0202    ; #0A (1B)
PAT11  DATA >1222,>0202,>FFFF,>0000    ; #0B (1C)
PAT12  DATA >FCFC,>FCFC,>FCFC,>FCFC    ; #0C (1E)
PAT13  DATA >FCFC,>FCDC,>8CDC,>FCFC    ; #0D (1F)
PAT14  DATA >0000,>0000,>0000,>0000    ; #0E (20)
PAT15  DATA >FFFF,>FFFF,>FFFF,>FFFF    ; #0F (21)
PAT16  DATA >0103,>070F,>1F3F,>7FFF    ; #10 (22)
PAT17  DATA >80C0,>E0F0,>F8FC,>FEFF    ; #11 (23)
PAT18  DATA >0001,>0307,>0F1F,>3F7F    ; #12 (24)
PAT19  DATA >0001,>0103,>0307,>1F3F    ; #13 (25)
PAT20  DATA >0001,>0303,>0707,>0F3F    ; #14 (26)
PAT21  DATA >0000,>0000,>0001,>073F    ; #15 (28)
PAT22  DATA >081C,>3E7F,>FFFF,>FFFF    ; #16 (29)
PAT23  DATA >0000,>0000,>80E0,>F8FF    ; #17 (2A)
PAT24  DATA >0000,>0003,>070F,>1F7F    ; #18 (2B)
PAT25  DATA >0000,>0080,>C0F0,>F8FC    ; #19 (2C)
PAT26  DATA >0000,>1010,>387C,>7EFF    ; #1A (2D)
PAT27  DATA >0000,>0000,>0010,>38FE    ; #1B (2E)
PAT28  DATA >80C0,>E0F0,>F8FC,>FCFE    ; #1C (30)
PAT29  DATA >0000,>80C0,>C0F0,>FCFF    ; #1D (31)
PAT30  DATA >0001,>0103,>0F1F,>7FFF    ; #1E (32)
PAT31  DATA >0000,>80C0,>F0F8,>FEFF    ; #1F (33)
PAT32  DATA >0107,>1F7F,>FFFF,>FFFF    ; #20 (34)
PAT33  DATA >0000,>0000,>0003,>0F3F    ; #21 (35)
PAT34  DATA >80E0,>F8FE,>FFFF,>FFFF    ; #22 (36)
PAT35  DATA >0000,>0000,>00C0,>F0FC    ; #23 (37)
PAT36  DATA >0000,>0000,>103B,>7FFF    ; #24 (38)
PAT37  DATA >0000,>0000,>069F,>FFFF    ; #25 (39)
PAT38  DATA >0000,>0000,>0020,>F8FF    ; #26 (3A)
PAT39  DATA >F3E1,>C0B0,>8888,>0000    ; #27 (40)
PAT40  DATA >FFFF,>3F0E,>0400,>1C22    ; #28 (41)
PAT41  DATA >FFFF,>8713,>2945,>0000    ; #29 (42)
PAT42  DATA >0000,>0000,>0000,>0000    ; #2A (43)
PAT43  DATA >1F07,>0303,>0F01,>0000    ; #2B (44)
PAT44  DATA >FCF0,>C0E0,>C0F0,>C000    ; #2C (45)
PAT45  DATA >FFFF,>FFFF,>FFCB,>8901    ; #2D (46)
PAT46  DATA >FFFF,>FFFF,>AFDF,>BD85    ; #2E (47)
PAT47  DATA >8080,>C0C0,>E0E0,>F0F0    ; #2F (48)
PAT48  DATA >F8F8,>DCFC,>EEFE,>FFFF    ; #30 (49)
PAT49  DATA >FFFF,>DDFF,>EEFF,>FFFF    ; #31 (4A)
PAT50  DATA >7F7F,>FFFF,>FFFF,>FFFF    ; #32 (4B)
PAT51  DATA >0F0F,>1D1F,>3E3F,>3F7F    ; #33 (4C)
PAT52  DATA >0000,>0000,>0001,>0101    ; #34 (4D)
PAT53  DATA >FFFF,>FFFF,>FFFF,>FFFF    ; #35 (4E)
PAT54  DATA >0000,>0000,>0000,>0000    ; #36 (50)
PAT55  DATA >007F,>4040,>4040,>4448    ; #37 (51)
PAT56  DATA >4040,>4040,>FFFF,>0000    ; #38 (52)
PAT57  DATA >00FE,>0202,>0202,>0202    ; #39 (53)
PAT58  DATA >1222,>0202,>FFFF,>0000    ; #3A (54)
PAT59  DATA >FCFC,>FCFC,>FCFC,>FCFC    ; #3B (56)
PAT60  DATA >FCFC,>FCDC,>8CDC,>FCFC    ; #3C (57)
PAT61  DATA >00FF,>0000,>0008,>1000    ; #3D (78)
PAT62  DATA >0000,>0000,>FFFF,>0000    ; #3E (79)
PAT63  DATA >1C22,>4141,>4122,>1C00    ; #3F (7A)
PAT64  DATA >0101,>0101,>0101,>0101    ; #40 (7B)
PAT65  DATA >0101,>0101,>0101,>0101    ; #41 (80)
PAT66  DATA >8080,>C0C0,>E0E1,>F1F1    ; #42 (88)
****************************************
* Colorset Definitions                  
****************************************
CLRNUM DATA 22                         ;
CLRSET BYTE >14,>14,>14,>16            ;
       BYTE >1B,>1B,>1C,>1C            ;
       BYTE >4C,>BC,>C4,>CB            ;
       BYTE >CE,>D5,>D5,>D5            ;
       BYTE >D5,>DC,>DC,>EC            ;
       BYTE >F5,>F5                    ;
****************************************
* Transition Character Pairs (from, to) 
****************************************
TCHNUM DATA 175                        ;
TCHARS BYTE >40,>36                    ; #00 color 1/4
       BYTE >36,>36                    ; #01 color 1/4
       BYTE >36,>37                    ; #02 color 1/4
       BYTE >37,>39                    ; #03 color 1/4
       BYTE >39,>36                    ; #04 color 1/4
       BYTE >36,>35                    ; #05 color 1/4
       BYTE >35,>3B                    ; #06 color 1/4
       BYTE >3B,>36                    ; #07 color 1/4
       BYTE >37,>3D                    ; #08 color 1/4
       BYTE >3D,>3D                    ; #09 color 1/4
       BYTE >3D,>39                    ; #0A color 1/4
       BYTE >3B,>3F                    ; #0B color 1/4
       BYTE >3F,>36                    ; #0C color 1/4
       BYTE >36,>38                    ; #0D color 1/4
       BYTE >38,>3A                    ; #0E color 1/4
       BYTE >3A,>36                    ; #0F color 1/4
       BYTE >35,>3C                    ; #10 color 1/4
       BYTE >3C,>36                    ; #11 color 1/4
       BYTE >38,>3E                    ; #12 color 1/4
       BYTE >3E,>3E                    ; #13 color 1/4
       BYTE >3E,>3A                    ; #14 color 1/4
       BYTE >FF,>FF                    ; #15 unused
       BYTE >FF,>FF                    ; #16 unused
       BYTE >FF,>FF                    ; #17 unused
       BYTE >00,>00                    ; #18 color 1/6
       BYTE >00,>01                    ; #19 color 1/6
       BYTE >01,>00                    ; #1A color 1/6
       BYTE >FF,>FF                    ; #1B unused
       BYTE >FF,>FF                    ; #1C unused
       BYTE >FF,>FF                    ; #1D unused
       BYTE >FF,>FF                    ; #1E unused
       BYTE >FF,>FF                    ; #1F unused
       BYTE >41,>07                    ; #20 color 1/B
       BYTE >07,>07                    ; #21 color 1/B
       BYTE >07,>08                    ; #22 color 1/B
       BYTE >08,>0A                    ; #23 color 1/B
       BYTE >0A,>07                    ; #24 color 1/B
       BYTE >07,>35                    ; #25 color 1/B
       BYTE >35,>0C                    ; #26 color 1/B
       BYTE >0C,>07                    ; #27 color 1/B
       BYTE >0C,>08                    ; #28 color 1/B
       BYTE >07,>09                    ; #29 color 1/B
       BYTE >09,>0B                    ; #2A color 1/B
       BYTE >0B,>07                    ; #2B color 1/B
       BYTE >35,>0D                    ; #2C color 1/B
       BYTE >0D,>07                    ; #2D color 1/B
       BYTE >0D,>09                    ; #2E color 1/B
       BYTE >FF,>FF                    ; #2F unused
       BYTE >2A,>33                    ; #30 color 1/C
       BYTE >33,>31                    ; #31 color 1/C
       BYTE >31,>31                    ; #32 color 1/C
       BYTE >31,>30                    ; #33 color 1/C
       BYTE >30,>2A                    ; #34 color 1/C
       BYTE >34,>32                    ; #35 color 1/C
       BYTE >32,>31                    ; #36 color 1/C
       BYTE >31,>42                    ; #37 color 1/C
       BYTE >42,>32                    ; #38 color 1/C
       BYTE >31,>2F                    ; #39 color 1/C
       BYTE >2F,>2A                    ; #3A color 1/C
       BYTE >2A,>34                    ; #3B color 1/C
       BYTE >2F,>34                    ; #3C color 1/C
       BYTE >FF,>FF                    ; #3D unused
       BYTE >FF,>FF                    ; #3E unused
       BYTE >FF,>FF                    ; #3F unused
       BYTE >2A,>40                    ; #40 color 4/C ERROR
       BYTE >FF,>FF                    ; #41 unused
       BYTE >FF,>FF                    ; #42 unused
       BYTE >FF,>FF                    ; #43 unused
       BYTE >FF,>FF                    ; #44 unused
       BYTE >FF,>FF                    ; #45 unused
       BYTE >FF,>FF                    ; #46 unused
       BYTE >FF,>FF                    ; #47 unused
       BYTE >2A,>41                    ; #48 color B/C ERROR
       BYTE >FF,>FF                    ; #49 unused
       BYTE >FF,>FF                    ; #4A unused
       BYTE >FF,>FF                    ; #4B unused
       BYTE >FF,>FF                    ; #4C unused
       BYTE >FF,>FF                    ; #4D unused
       BYTE >FF,>FF                    ; #4E unused
       BYTE >FF,>FF                    ; #4F unused
       BYTE >36,>2A                    ; #50 color C/4 invert
       BYTE >FF,>FF                    ; #51 unused
       BYTE >FF,>FF                    ; #52 unused
       BYTE >FF,>FF                    ; #53 unused
       BYTE >FF,>FF                    ; #54 unused
       BYTE >FF,>FF                    ; #55 unused
       BYTE >FF,>FF                    ; #56 unused
       BYTE >FF,>FF                    ; #57 unused
       BYTE >07,>2A                    ; #58 color C/B invert
       BYTE >FF,>FF                    ; #59 unused
       BYTE >FF,>FF                    ; #5A unused
       BYTE >FF,>FF                    ; #5B unused
       BYTE >FF,>FF                    ; #5C unused
       BYTE >FF,>FF                    ; #5D unused
       BYTE >FF,>FF                    ; #5E unused
       BYTE >FF,>FF                    ; #5F unused
       BYTE >02,>02                    ; #60 color C/E
       BYTE >03,>03                    ; #61 color C/E
       BYTE >FF,>FF                    ; #62 unused
       BYTE >FF,>FF                    ; #63 unused
       BYTE >FF,>FF                    ; #64 unused
       BYTE >FF,>FF                    ; #65 unused
       BYTE >FF,>FF                    ; #66 unused
       BYTE >FF,>FF                    ; #67 unused
       BYTE >0E,>0E                    ; #68 color D/5
       BYTE >0E,>12                    ; #69 color D/5
       BYTE >12,>0F                    ; #6A color D/5
       BYTE >0F,>0F                    ; #6B color D/5
       BYTE >0F,>1C                    ; #6C color D/5
       BYTE >1C,>0E                    ; #6D color D/5
       BYTE >0F,>11                    ; #6E color D/5
       BYTE >11,>0E                    ; #6F color D/5
       BYTE >0E,>10                    ; #70 color D/5
       BYTE >10,>0F                    ; #71 color D/5
       BYTE >0E,>1E                    ; #72 color D/5
       BYTE >1E,>1F                    ; #73 color D/5
       BYTE >1F,>0E                    ; #74 color D/5
       BYTE >0E,>13                    ; #75 color D/5
       BYTE >13,>0F                    ; #76 color D/5
       BYTE >0F,>1D                    ; #77 color D/5
       BYTE >1D,>0E                    ; #78 color D/5
       BYTE >0E,>14                    ; #79 color D/5
       BYTE >14,>0F                    ; #7A color D/5
       BYTE >0E,>21                    ; #7B color D/5
       BYTE >21,>20                    ; #7C color D/5
       BYTE >20,>0F                    ; #7D color D/5
       BYTE >0F,>22                    ; #7E color D/5
       BYTE >22,>20                    ; #7F color D/5
       BYTE >11,>10                    ; #80 color D/5
       BYTE >22,>23                    ; #81 color D/5
       BYTE >23,>0E                    ; #82 color D/5
       BYTE >FF,>FF                    ; #83 unused
       BYTE >FF,>FF                    ; #84 unused
       BYTE >FF,>FF                    ; #85 unused
       BYTE >FF,>FF                    ; #86 unused
       BYTE >FF,>FF                    ; #87 unused
       BYTE >27,>28                    ; #88 color D/C
       BYTE >28,>29                    ; #89 color D/C
       BYTE >29,>0F                    ; #8A color D/C
       BYTE >0F,>27                    ; #8B color D/C
       BYTE >29,>2D                    ; #8C color D/C
       BYTE >2D,>27                    ; #8D color D/C
       BYTE >2A,>2A                    ; #8E color D/C
       BYTE >2A,>2B                    ; #8F color D/C
       BYTE >2B,>2D                    ; #90 color D/C
       BYTE >2D,>2E                    ; #91 color D/C
       BYTE >2E,>2D                    ; #92 color D/C
       BYTE >2D,>2C                    ; #93 color D/C
       BYTE >2C,>2A                    ; #94 color D/C
       BYTE >2B,>2A                    ; #95 color D/C
       BYTE >FF,>FF                    ; #96 unused
       BYTE >FF,>FF                    ; #97 unused
       BYTE >04,>06                    ; #98 color E/C
       BYTE >06,>06                    ; #99 color E/C
       BYTE >06,>04                    ; #9A color E/C
       BYTE >05,>06                    ; #9B color E/C
       BYTE >06,>05                    ; #9C color E/C
       BYTE >FF,>FF                    ; #9D unused
       BYTE >FF,>FF                    ; #9E unused
       BYTE >FF,>FF                    ; #9F unused
       BYTE >0E,>15                    ; #A0 color F/5
       BYTE >15,>16                    ; #A1 color F/5
       BYTE >16,>17                    ; #A2 color F/5
       BYTE >17,>0E                    ; #A3 color F/5
       BYTE >0E,>18                    ; #A4 color F/5
       BYTE >18,>19                    ; #A5 color F/5
       BYTE >19,>0E                    ; #A6 color F/5
       BYTE >0E,>24                    ; #A7 color F/5
       BYTE >24,>25                    ; #A8 color F/5
       BYTE >25,>26                    ; #A9 color F/5
       BYTE >26,>0E                    ; #AA color F/5
       BYTE >0E,>1A                    ; #AB color F/5
       BYTE >1A,>0E                    ; #AC color F/5
       BYTE >0E,>1B                    ; #AD color F/5
       BYTE >1B,>0E                    ; #AE color F/5
*************************************************
* Transition chars with inverted 'to' characters 
*************************************************
ICHARS BYTE >00                        ; #00
       BYTE >00                        ; #01
       BYTE >00                        ; #02
       BYTE >00                        ; #03
       BYTE >00                        ; #04
       BYTE >00                        ; #05
       BYTE >00                        ; #06
       BYTE >00                        ; #07
       BYTE >00                        ; #08
       BYTE >00                        ; #09
       BYTE >00                        ; #0A
       BYTE >00                        ; #0B
       BYTE >00                        ; #0C
       BYTE >00                        ; #0D
       BYTE >00                        ; #0E
       BYTE >00                        ; #0F
       BYTE >00                        ; #10
       BYTE >00                        ; #11
       BYTE >00                        ; #12
       BYTE >00                        ; #13
       BYTE >00                        ; #14
       BYTE >00                        ; #15 unused
       BYTE >00                        ; #16 unused
       BYTE >00                        ; #17 unused
       BYTE >00                        ; #18
       BYTE >00                        ; #19
       BYTE >00                        ; #1A
       BYTE >00                        ; #1B unused
       BYTE >00                        ; #1C unused
       BYTE >00                        ; #1D unused
       BYTE >00                        ; #1E unused
       BYTE >00                        ; #1F unused
       BYTE >00                        ; #20
       BYTE >00                        ; #21
       BYTE >00                        ; #22
       BYTE >00                        ; #23
       BYTE >00                        ; #24
       BYTE >00                        ; #25
       BYTE >00                        ; #26
       BYTE >00                        ; #27
       BYTE >00                        ; #28
       BYTE >00                        ; #29
       BYTE >00                        ; #2A
       BYTE >00                        ; #2B
       BYTE >00                        ; #2C
       BYTE >00                        ; #2D
       BYTE >00                        ; #2E
       BYTE >00                        ; #2F unused
       BYTE >00                        ; #30
       BYTE >00                        ; #31
       BYTE >00                        ; #32
       BYTE >00                        ; #33
       BYTE >00                        ; #34
       BYTE >00                        ; #35
       BYTE >00                        ; #36
       BYTE >00                        ; #37
       BYTE >00                        ; #38
       BYTE >00                        ; #39
       BYTE >00                        ; #3A
       BYTE >00                        ; #3B
       BYTE >00                        ; #3C
       BYTE >00                        ; #3D unused
       BYTE >00                        ; #3E unused
       BYTE >00                        ; #3F unused
       BYTE >00                        ; #40
       BYTE >00                        ; #41 unused
       BYTE >00                        ; #42 unused
       BYTE >00                        ; #43 unused
       BYTE >00                        ; #44 unused
       BYTE >00                        ; #45 unused
       BYTE >00                        ; #46 unused
       BYTE >00                        ; #47 unused
       BYTE >00                        ; #48
       BYTE >00                        ; #49 unused
       BYTE >00                        ; #4A unused
       BYTE >00                        ; #4B unused
       BYTE >00                        ; #4C unused
       BYTE >00                        ; #4D unused
       BYTE >00                        ; #4E unused
       BYTE >00                        ; #4F unused
       BYTE >FF                        ; #50
       BYTE >00                        ; #51 unused
       BYTE >00                        ; #52 unused
       BYTE >00                        ; #53 unused
       BYTE >00                        ; #54 unused
       BYTE >00                        ; #55 unused
       BYTE >00                        ; #56 unused
       BYTE >00                        ; #57 unused
       BYTE >FF                        ; #58
       BYTE >00                        ; #59 unused
       BYTE >00                        ; #5A unused
       BYTE >00                        ; #5B unused
       BYTE >00                        ; #5C unused
       BYTE >00                        ; #5D unused
       BYTE >00                        ; #5E unused
       BYTE >00                        ; #5F unused
       BYTE >00                        ; #60
       BYTE >00                        ; #61
       BYTE >00                        ; #62 unused
       BYTE >00                        ; #63 unused
       BYTE >00                        ; #64 unused
       BYTE >00                        ; #65 unused
       BYTE >00                        ; #66 unused
       BYTE >00                        ; #67 unused
       BYTE >00                        ; #68
       BYTE >00                        ; #69
       BYTE >00                        ; #6A
       BYTE >00                        ; #6B
       BYTE >00                        ; #6C
       BYTE >00                        ; #6D
       BYTE >00                        ; #6E
       BYTE >00                        ; #6F
       BYTE >00                        ; #70
       BYTE >00                        ; #71
       BYTE >00                        ; #72
       BYTE >00                        ; #73
       BYTE >00                        ; #74
       BYTE >00                        ; #75
       BYTE >00                        ; #76
       BYTE >00                        ; #77
       BYTE >00                        ; #78
       BYTE >00                        ; #79
       BYTE >00                        ; #7A
       BYTE >00                        ; #7B
       BYTE >00                        ; #7C
       BYTE >00                        ; #7D
       BYTE >00                        ; #7E
       BYTE >00                        ; #7F
       BYTE >00                        ; #80
       BYTE >00                        ; #81
       BYTE >00                        ; #82
       BYTE >00                        ; #83 unused
       BYTE >00                        ; #84 unused
       BYTE >00                        ; #85 unused
       BYTE >00                        ; #86 unused
       BYTE >00                        ; #87 unused
       BYTE >00                        ; #88
       BYTE >00                        ; #89
       BYTE >00                        ; #8A
       BYTE >00                        ; #8B
       BYTE >00                        ; #8C
       BYTE >00                        ; #8D
       BYTE >00                        ; #8E
       BYTE >00                        ; #8F
       BYTE >00                        ; #90
       BYTE >00                        ; #91
       BYTE >00                        ; #92
       BYTE >00                        ; #93
       BYTE >00                        ; #94
       BYTE >00                        ; #95
       BYTE >00                        ; #96 unused
       BYTE >00                        ; #97 unused
       BYTE >00                        ; #98
       BYTE >00                        ; #99
       BYTE >00                        ; #9A
       BYTE >00                        ; #9B
       BYTE >00                        ; #9C
       BYTE >00                        ; #9D unused
       BYTE >00                        ; #9E unused
       BYTE >00                        ; #9F unused
       BYTE >00                        ; #A0
       BYTE >00                        ; #A1
       BYTE >00                        ; #A2
       BYTE >00                        ; #A3
       BYTE >00                        ; #A4
       BYTE >00                        ; #A5
       BYTE >00                        ; #A6
       BYTE >00                        ; #A7
       BYTE >00                        ; #A8
       BYTE >00                        ; #A9
       BYTE >00                        ; #AA
       BYTE >00                        ; #AB
       BYTE >00                        ; #AC
       BYTE >00                        ; #AD
       BYTE >00                        ; #AE
****************************************
* Transition Map Data                   
****************************************
* == Map #0 ==                          
MC0    DATA 0                          ;
MS0    DATA >0040,>0010,>0400          ; Width, Height, Size
* -- Map Row 0 --                       
MD0    DATA >6868,>6868,>6868,>6868    ;
       DATA >6868,>6868,>6868,>6868    ;
       DATA >6868,>6868,>6868,>6868    ;
       DATA >6868,>6868,>6868,>6868    ;
       DATA >6868,>6868,>6868,>6868    ;
       DATA >6868,>6868,>6868,>6868    ;
       DATA >6868,>6868,>6868,>6868    ;
       DATA >6868,>6868,>6868,>6868    ;
* -- Map Row 1 --                       
       DATA >6868,>6868,>6868,>6868    ;
       DATA >6868,>6868,>6868,>6868    ;
       DATA >6868,>6868,>6868,>6868    ;
       DATA >6868,>6868,>6868,>6868    ;
       DATA >6868,>6868,>6868,>6868    ;
       DATA >6868,>6868,>6868,>6868    ;
       DATA >6868,>6868,>6868,>6868    ;
       DATA >6868,>6868,>6868,>6868    ;
* -- Map Row 2 --                       
       DATA >6868,>6868,>6868,>68A0    ;
       DATA >A1A2,>A368,>6868,>6868    ;
       DATA >A4A5,>A668,>68A7,>A8A9    ;
       DATA >AA68,>6868,>6868,>6868    ;
       DATA >6868,>6868,>ABAC,>6868    ;
       DATA >6868,>6868,>6868,>6868    ;
       DATA >A4A5,>A668,>6868,>6868    ;
       DATA >6868,>68A7,>A8A9,>AA68    ;
* -- Map Row 3 --                       
       DATA >6868,>6868,>6868,>696A    ;
       DATA >6B6B,>6C6D,>6868,>6869    ;
       DATA >6A6B,>6E6F,>6868,>6868    ;
       DATA >6868,>6870,>716B,>6E6F    ;
       DATA >6868,>6870,>716E,>6F68    ;
       DATA >6868,>6868,>6868,>6870    ;
       DATA >716B,>6E6F,>6868,>6868    ;
       DATA >6868,>6868,>6868,>6868    ;
* -- Map Row 4 --                       
       DATA >6868,>7273,>7475,>766B    ;
       DATA >6B6B,>6B77,>7868,>797A    ;
       DATA >6B6B,>6B6E,>6F68,>6868    ;
       DATA >687B,>7C7D,>6B6B,>6B6E    ;
       DATA >6F68,>7071,>6B6B,>6E6F    ;
       DATA >6868,>6868,>6868,>7071    ;
       DATA >6B6B,>6B6E,>6F68,>6868    ;
       DATA >ABAC,>68AD,>AE68,>6868    ;
* -- Map Row 5 --                       
       DATA >6870,>716B,>6B6B,>6B6B    ;
       DATA >6B6B,>6B6B,>7E7F,>7D6B    ;
       DATA >6B6B,>6B6B,>6E6F,>7B7C    ;
       DATA >7D6B,>6B6B,>6B6B,>6B6B    ;
       DATA >6B6B,>6B6B,>6B6B,>6B6E    ;
       DATA >6F68,>6868,>6870,>716B    ;
       DATA >6B6B,>6B6B,>6E6F,>6870    ;
       DATA >716E,>8071,>6E6F,>6868    ;
* -- Map Row 6 --                       
       DATA >7C7D,>6B6B,>6B6B,>6B6B    ;
       DATA >6B6B,>6B6B,>6B6B,>6B6B    ;
       DATA >6B6B,>6B6B,>6B6B,>6B6B    ;
       DATA >6B6B,>6B6B,>6B6B,>6B6B    ;
       DATA >6B6B,>6B6B,>6B6B,>6B6B    ;
       DATA >7E81,>827B,>7C7D,>6B6B    ;
       DATA >6B6B,>6B6B,>6B7E,>7F7D    ;
       DATA >6B6B,>6B6B,>6B6E,>6F7B    ;
* -- Map Row 7 --                       
       DATA >6B6B,>6B6B,>6B6B,>6B6B    ;
       DATA >6B6B,>6B6B,>6B6B,>6B6B    ;
       DATA >6B6B,>6B6B,>6B6B,>6B6B    ;
       DATA >6B6B,>6B6B,>6B6B,>6B6B    ;
       DATA >6B6B,>6B6B,>6B6B,>6B6B    ;
       DATA >6B6B,>6B6B,>6B6B,>6B6B    ;
       DATA >6B6B,>6B6B,>6B6B,>6B6B    ;
       DATA >6B6B,>6B6B,>6B6B,>6B6B    ;
* -- Map Row 8 --                       
       DATA >8889,>8A6B,>6B6B,>6B8B    ;
       DATA >8889,>8A6B,>6B6B,>6B8B    ;
       DATA >8889,>8C8D,>8889,>8A6B    ;
       DATA >6B6B,>6B8B,>8889,>8A6B    ;
       DATA >6B6B,>6B8B,>8889,>8C8D    ;
       DATA >8889,>8A6B,>6B6B,>6B6B    ;
       DATA >6B6B,>6B8B,>8889,>8A6B    ;
       DATA >6B6B,>6B8B,>8889,>8A8B    ;
* -- Map Row 9 --                       
       DATA >8E8E,>8F90,>9192,>9394    ;
       DATA >8E8E,>8F90,>9192,>9394    ;
       DATA >8E8E,>8E8E,>8E8E,>8F90    ;
       DATA >9192,>9394,>8E8E,>8F90    ;
       DATA >9192,>9394,>8E8E,>8E8E    ;
       DATA >8E8E,>8F90,>9192,>9192    ;
       DATA >9192,>9394,>8E8E,>8F90    ;
       DATA >9192,>9394,>8E8E,>8F95    ;
* -- Map Row 10 --                      
       DATA >8E8E,>8E8E,>8E8E,>8E8E    ;
       DATA >8E8E,>8E8E,>8E8E,>8E8E    ;
       DATA >8E8E,>8E8E,>8E8E,>8E8E    ;
       DATA >8E8E,>8E8E,>8E8E,>8E8E    ;
       DATA >8E8E,>8E8E,>8E8E,>8E8E    ;
       DATA >8E8E,>8E8E,>8E8E,>8E8E    ;
       DATA >8E8E,>8E8E,>8E8E,>8E8E    ;
       DATA >8E8E,>8E8E,>8E8E,>8E8E    ;
* -- Map Row 11 --                      
       DATA >3031,>3232,>3232,>3233    ;
       DATA >3430,>3132,>3232,>3232    ;
       DATA >3232,>3233,>348E,>8E8E    ;
       DATA >8E8E,>8E8E,>8E8E,>8E8E    ;
       DATA >8E8E,>8E8E,>8E8E,>3031    ;
       DATA >3232,>3232,>3232,>3232    ;
       DATA >3233,>3430,>3132,>3232    ;
       DATA >3232,>3232,>3233,>348E    ;
* -- Map Row 12 --                      
       DATA >3536,>3232,>3232,>3232    ;
       DATA >3738,>3632,>3232,>3232    ;
       DATA >3232,>3232,>393A,>8E8E    ;
       DATA >8E8E,>8E8E,>8E8E,>8E8E    ;
       DATA >8E8E,>8E8E,>8E3B,>3536    ;
       DATA >3232,>3232,>3232,>3232    ;
       DATA >3232,>3738,>3632,>3232    ;
       DATA >3232,>3232,>3232,>393C    ;
* -- Map Row 13 --                      
       DATA >4820,>2121,>2121,>2121    ;
       DATA >5840,>0001,>0101,>0101    ;
       DATA >0101,>0101,>508E,>8E8E    ;
       DATA >8E8E,>8E8E,>8E8E,>8E8E    ;
       DATA >8E8E,>8E8E,>8E8E,>4820    ;
       DATA >2121,>2121,>2121,>2121    ;
       DATA >2121,>5840,>0001,>0101    ;
       DATA >0101,>0101,>0101,>508E    ;
* -- Map Row 14 --                      
       DATA >4820,>2223,>2425,>2627    ;
       DATA >5840,>0002,>0304,>0506    ;
       DATA >0702,>0304,>508E,>8E8E    ;
       DATA >8E8E,>8E8E,>8E8E,>8E8E    ;
       DATA >8E8E,>8E8E,>8E8E,>4820    ;
       DATA >2526,>2823,>2425,>2628    ;
       DATA >2324,>5840,>0002,>0809    ;
       DATA >0A04,>0506,>0B0C,>508E    ;
* -- Map Row 15 --                      
       DATA >4820,>292A,>2B25,>2C2D    ;
       DATA >5840,>000D,>0E0F,>0510    ;
       DATA >110D,>0E0F,>508E,>8E8E    ;
       DATA >8E8E,>8E8E,>8E8E,>8E8E    ;
       DATA >8E8E,>8E8E,>8E8E,>4820    ;
       DATA >252C,>2E2A,>2B25,>2C2E    ;
       DATA >2A2B,>5840,>000D,>1213    ;
       DATA >140F,>0510,>1101,>508E    ;
* == Map #1 ==                          
MC1    DATA 0                          ;
MS1    DATA >0004,>0008,>0020          ; Width, Height, Size
* -- Map Row 0 --                       
MD1    DATA >1818,>1818                ;
* -- Map Row 1 --                       
       DATA >1818,>1818                ;
* -- Map Row 2 --                       
       DATA >1818,>1818                ;
* -- Map Row 3 --                       
       DATA >1818,>191A                ;
* -- Map Row 4 --                       
       DATA >6060,>6060                ;
* -- Map Row 5 --                       
       DATA >9899,>999A                ;
* -- Map Row 6 --                       
       DATA >9B99,>999C                ;
* -- Map Row 7 --                       
       DATA >6161,>6161                ;
