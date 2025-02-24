# tms9918a-midframe
Attempt to change some VDP registers strategically mid-frame

## Timer-interrupts

Some 8-bit and 16-bit era systems offered raster-interrupts, allowing a program to trigger a small subroutine when a particular row of pixels was about to be drawn.
However, the TI-99/4a's video chip only supplies one type of interrupt,
an end-of-frame interrupt, usually referred to as the VDP interrupt.

In 2006, Jeff Brown and Thierry Nouspikel told us that it is also possible to configure CRU-timer interrupts so long as you are willing to loose the ability to trigger VDP end-of-frame interrupts.
(http://www.unige.ch/medecine/nouspikel/ti99/tms9901.htm)
I never understood how to use their code until recently.
The CRU timer ticks more often than the end of a video frame.
In a 60hz environment there are, in fact, about 782 ticks per frame.
This is precise enough so that we can set a CRU timer to trigger on the exact same pixel row for each frame.

One might initially be concerned about the loss of the VDP end-of-frame interrupts.
In most games and a few other programs, knowing when a frame completes is actually more important than knowing when a pixel row is reached.
And since the number of CRU timer ticks per frame is a non-integer,
it is also important to synchronize the timer with the VDP end-of-frame event on a regular basis.
But the loss of end-of-frame interrupts isn't really a problem.
Jeff Brown's same approach of enabling CRU timer interrupts, also involves polling for an end-of-frame event, so that the TI can be hacked to ignore them.

In game loops that I've programmed, I normally want to block the thread at the end of the loop anyway.
There is usually something in the timing of the game that makes it important to only run one iteration of the loop per video frame.
If our program includes a routine that uses Jeff Brown's approach to enable CRU timers,
then as soon as the program returns from that routine,
we as programmers can be certain that an end-of-frame event has just recently occurred.
If we call this hypothetical routine at either the beginning or the end of the game loop,
then the loop can be synchronized with the video frames, just the same as if we were using the standard VDP interrupts.

This means that at the beginning of each video frame,
we can set a timer interrupt and use it for exactly what the word "interrupt" suggests.
An iteration of a game loop can be interrupted at exactly the right time,
without having to constantly poll to see if the scan beam has reached the desired portion of the screen.

Note that we can have multiple timer interrupts per frame.
When the first interrupt triggers, a program can set the timer again.
The time just needs to be less than what remains for the current video frame.

## Tech Demos in this Repository

Assembling the code in this repository will result in two ROM cartridge images.
They contain the following demos:

1. A program that changes the background color mid-screen, and changes it back at the end of the frame.
This program doesn't try to time the interrupt to any particular pixel row.
1. A program that changes the background color on multiple pixel rows.
This program makes use of additional routines to calculate the correct timer value for a particular pixel row.
1. A 40-column WYSIWYG text editor.
The text editor supports regular, bold, italic, and bold-italic text.
This requires more than 256 unique character patterns.
This demo switches between four different Pattern Definition tables over the course of a frame.
Every six tile-rows on screen have a different pattern table,
So each quarter of the screen has 256 unique patterns, and only 240 tile positions that need to be filled.
Note that in the "undocumented" text-bitmap mode, the screen is only divided into three regions.
So in text-bitmap mode, each third of the screen has more than 256 tile positions to fill.
1. A simple hack-and-slash game with pseudo-parallax scrolling in the background.
Granted, the TI port of Moon Patrol already had pseudo-parallax scrolling.
This isn't the first TI program to achieve that effect.
The point of this repo is to demonstrate achieving said effect through timer-interrupts instead of some other means.
Like many other homebrew games,
this demo achieves smooth horizontal scrolling by configuring eight different pattern tables to have very similar patterns.
That is, VDP register 4 becomes a scroll register instead of a pattern table register.
And the parallax scrolling is achieved by scrolling by different amounts at different places on the screen.

## Flicker

In the two programs that change the background color,
a user will notice some obvious flicker at the point where the color changes.
As noted above, the number of CRU ticks per frame is a non-integer.
There are almost-but-not-quite three ticks per pixel-row.
So the color always changes in the same 1/3 of a pixel-row, but not on the exact same pixel.

The text-editor and the scrolling-game make attempts to hide that flicker.
In the text editor, all text patterns have a blank line on the top pixel row,
and the timer-interrupt triggers in the consistently blank rows.
The game configures the timer interrupts to trigger at places on the screen where the pixel row is a single solid color.

## Emulators vs. real hardware

The demos in this repo specify particular pixel rows where interrupts should occur as a number in the range 0 to 191.
On real hardware, the timer triggers _within_ the specified pixel row.
In MAME and Classic 99, the timer triggers can trigger 1 pixel row early.
In order to really hide flicker from the widest audience, it is ideal to have two pixel rows that are a solid color.

The text editor demo tries to get away with only having one row of solid pixels.
When text is mostly lower case, then two pixel-rows are made up of mostly a single color.

Not all emulators seem to implement the CRU timer.
If they don't, these demos will not work.

## Dropped frames

Our program needs to set the first timer at the very beginning of each video frame,
in order to ensure that interrupt occurs at a consistent place on the screen for each frame.
One might assume that this would make a program intolerant of dropped frames,
but it doesn't.
In the same sense that we can set more than one timer interrupt per frame,
we can also set an interrupt to trigger at the exact end of a frame.
As previously noted, it is important to synchronize with the real end-of-frame event regularly,
but the CRU timer is still precise enough that dropping three-or-so frames between synchronizations seems to be tolerable.

The previously mentioned text editor drops three frames every time the user inserts a character.
As far as I can tell any "flicker" has more to do with the text editor taking time to respond to key strokes rather than the dropped frames.

## Mapping pixel-rows to the corresponding CRU ticks.

The code in this repo includes two different ways to figure out the correct timer value for a particular pixel-row.
One method multiplies the desired pixel-row by about 3 and adds some more ticks to account for the time between video frames.
(See the routine calc_init_timer_loop in PIXELROW.asm)
The second method places two overlapping sprites on the screen and polls the VDP's COINC flag until it sees that the overlapping sprites have been hit.
(See the routine coinc_init_timer_loop in PIXELROW.asm)

I wanted to experiment with the coinc approach because I was inspired by the sprite 0 approach used in some NES games.
But the calculation approach is probably better.
The coinc approach has the freedom to be ignorant as to whether the program is running in a 60hz or 50hz environment.
It could also theoretically work on an emulator that implements the CRU timer in an incorrect, but consistent way.
But displaying overlapping sprites requires changing the contents of the VDP RAM, which could interfere with other parts of a program.
And the coinc approach doesn't fix the above-mentioned issue of the difference of one pixel-row between real hardware and the most accurate emulators.
And the coinc approach is substantially more code.
Given that it is possible to programmatically determine if a TI-99 is running in a 50hz or 60hz environment,
the calculation approach doesn't really have much of a downside.

## Possible applications

+ Pseudo-parallax scrolling. Choose different pattern tables at different scan lines, to create the appearance of scrolling by different amounts.
+ If the picture on screen displays sky and ground, then the background border can match the sky color and ground color at different parts of the screen.
+ Give a text-mode screen, a header section and body section that are of different colors.
+ Turn text-mode into a bitmap mode by giving each quarter of the screen its own pattern table, perhaps for WYSIWYG text.
+ Exceed 32 sprite limitation (but sadly maintain the 4 sprites per pixel-row limitation).
+ Display 40 columns and 32 columns of text on different tile rows, by changing video modes mid-screen.

I haven't experimented with those last two ideas, yet. Maybe someone else would like to try.

## Copying code to another project

If you wish to use coinc_init_timer_loop then you will need to copy all of the files that are in src, but not a subfolder of src

If you don't wish to use coinc_init_timer_loop, then you only need these files:
* PIXELROW.asm
* EQUCPUADR.asm
* EQUVAR.asm

## How to use the demo text editor

```
Insert mode is always on.
(FCTN+1) Delete a character
All arrow keys are enabled.
(CTRL+B) Enables/Disables bold text
(CTRL+I) Enables/Disables italic text
```

If you move the cursor using arrow keys, the bold/italic settings will change to match whatever character your cursor lands on.
You can change them again using CTRL+B/I, but there is no indication of the change until you start typing.
Sorry, I wanted to keep the copde simple.

## How to play the demo-game

```
(D) Moves the player right
(SPACE) Causes the player to jump
(FCTN) extends the player's sword
```

If you hit a turtle, pig, or rabbit you take damage.
If any of the animals touches your sword, you destroy them without taking damage.

## Shared methods and data blocks

IMPORTANT: All of the routines in this repo assume that a stack pointer is stored in R10.
The stack grows downwards in memory.

IMPORTANT: The interrupts you define use a different workspace from the main program, but they use the same stack.

NOTE: All of these functions are written for a program that has a game loop.
The game loop is expected to run one iteration for each video frame,
but does have tollerance for some dropped frames.

### Pixel-Row Interrupt block

```
pixel_row_interrupts        DATA 6*8,pattern1_isr
                            DATA 12*8,pattern2_isr
                            DATA 18*8,pattern3_isr
pixel_row_interrupts_end
```

This is a data structure made up of several 4-byte long entries.
There can be up to 14 entires in the data block.

In each entry, the first 2-byte word is the pixel row upon which we expect to see the interrupt triggered.
It may be any number from 0 to 191.
The second 2-byte word is the address of the interrupt routine that is to be called when that occurrs.

Your program may also have an end-of-frame routine that would normally be triggered by the standard VDP interrupt.
But do not reference that routine in this block.
See calc_init_timer_loop or coinc_init_timer_loop, instead.

### calc_init_timer_loop

```
BL
calc_init_timer_loop
Input:
   R0 - address of Pixel-Row Interrupt block
   R1 - address of the end of the Pixel-Row Interrupt block
   R2 - address of the end-of-frame interrupt routine
      - set to 0, if there is no end-of-frame routine
```

Scans the Pixel-Row Interrupt block and calculates the correct CRU timer value at which to trigger each routine.
Call this function once when initializing your program, and before entering a game loop.

### coinc_init_timer_loop

```
BL
coinc_init_timer_loop
Input:
   R0 - address of Pixel-Row Interrupt block
   R1 - address of the end of the Pixel-Row Interrupt block
   R2 - address of the end-of-frame interrupt routine
      - set to 0, if there is no end-of-frame routine
```

This is an alternative to calc_init_timer_loop.
calc_init_timer_loop is the recommended method.

This routine scans the Pixel-Row Interrupt block and determines the correct CRU timer value at which to trigger each routine.
Call this function once when initializing your program, and before entering a game loop.

This routine expects to be in the default graphics mode when called.
Your program is not required to remain in graphics mode,
but call this routine before changing the video mode.

This routine alters the contents of your VDP RAM.
Call it before calling anything that would intialize the VDP RAM that your program will use.

### block_vdp_interrupt

```
BLWP
block_vdp_interrupt
Input: none
```

This routine disables interrupts triggered by the VDP, and enables CRU timer interrupts.
Also blocks the CPU until the VDP's end-of-frame event is detected.

Call this routine using BLWP.
(Most other routines in this repo require BL.)

You are encouraged to call this routine once at the very beginning or very end of a game loop.

### unblock_vdp_interrupt

```
BLWP
block_vdp_interrupt
Input: none
```

Re-enables interrupts triggered by the VDP, and disabled CRU timer interrupts.

Call this routine using BLWP.
(Most other routines in this repo require BL.)

### restart_timer_loop

```
BL
restart_timer_loop
Input: none
```

The routines in this repo keep track of which pixel-row interrupt routine needs to be called next.
This routine tells tells the rest of the code that the first entry in your Pixel-Row Interrupt block
is the next interrupt that should be triggered.

It is recommended that your program call this routine directly after "block_vdp_interrupt".

### set_timer

```
BL
set_timer
Input:
   R1 - value to place in CRU timer (only least significant 14-bits are used)
```

Places a value in the timer that will auto-decrement.

Calling set_timer followed by get_timer_value could literally measure time.

If you have called "block_vdp_interrupt" but not called "restart_timer_loop",
then when the timer value reaches zero,
the TI-99's User-defined Interrupt will be triggered.
This is the interrupt whose address is stored at address >83C4,
the same interrupt normally triggered by the VDP interrupt.

If you have called "restart_timer_loop",
then it is not recommended that you call set_timer.

### get_timer_value

```
BL
get_timer_value
Input:
   none
Output:
   R2 - (only least significant 14-bits) the value read from the CRU timer
   CPU's status register holds the timer value compared to 0
```

### calc_hertz

```
BL
calc_hertz
Input:
   none
Output:
   byte at @HERTZ = 0 implies 60hz; -1 implies 50hz
```

Measures the time between video frames,
and sets the value of memory address HERTZ
to specify whether the program is running on a 50hz or 60hz TI-99/4a.

### @all_lines_scanned

@all_lines_scanned is a memory address that indicates if all of the pixel-row interrupts for this frame have been reached or not.
If the address contains zero, then at least one interrupt has yet to trigger.
If the address contains non-zero, then the last interrupt already triggered, and you can start another iteration of your game loop.

### timer_isr (private routine)

The timer_isr is not specified in a DEF statement, and not directly available to your program.
However, this is the routine that gets called whenever the CRU timer reaches zero.
It is responsible for running the routines specified by your programs Pixel-Row Interrupt block,
and for resetting the CRU timer so that the next ISR can be triggered.

### Sample code

This is the structure of a game loop that uses the above mentioned routines.
If you wanted to use coinc_init_timer_loop,
then replace the below use of calc_init_timer_loop.

```
       LIMI 0
* Specify the location of the Pixel-Row Interrupt block
* and the end_of_frame_routine
       LI   R0,pixel_row_interrupts
       LI   R1,pixel_row_interrupts_end
       LI   R2,end_of_frame_routine
       BL   @calc_init_timer_loop
....
* More initialization specific to your program
....
*
game_loop
* Disable interrupts
       LIMI 0
* Block thread until then end of a frame
* Fool TI-99/4a into thinking that CRU timer interrupts are VDP interrupts.
       BLWP @block_vdp_interrupt
* Tell timer_isr to look at the begining of the interrupt table again
       BL   @restart_timer_loop
....
* Execute code that Writes data to the VDP RAM.
* This must finish executing before your first pixel-row interrupt,
* because your interrupt probably changes a VDP write-only register.
....
* Enable interrupts
       LIMI 2
....
* Execute more code that doesn't change VDP RAM contents.
....
* If this iteration of your game loop completed extremely quickly,
* then the program might not have executed all pixel-row interrupts for this frame yet.
* While @all_lines_scanned is equal to zero,
* there are more interrupts to trigger,
* so wait here.
while_waiting_for_interrupt
       MOV  @all_lines_scanned,R0
       JEQ  while_waiting_for_interrupt
*
* All pixel-row interrupts have now triggered.
* The next iterration will call block_vdp_interrupt,
* which will also temporarily disable CRU timer interrupts,
* and wait until the current video frame has completed.
       JMP  game_loop
```
