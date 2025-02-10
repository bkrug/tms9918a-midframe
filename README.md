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
Jeff Brown's same approach of enabling CRU timer interrupts, also involves polling for an end-of-frame interrupt, so that the TI can be hacked to ignore them.

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
In MAME and Classic 99, the timer triggers _within_ the specified pixel row.
On real hardware, the timer triggers can trigger 1 to 2 pixel rows early.
In order to really hide flicker from the widest audience, it is ideal two have three pixel rows that are a solid color.

The text editor demo seems to get away with only having one row of solid pixels.
But even in the text editor you should be able to notice a small amount of flicker on real hardware.
It depends on the particular text being displayed.

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
This doesn't seem to cause flicker.

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

* PIXELROW.asm
* HERTZ.asm
* VDP.asm
* EQUVAR.asm
* EQUCPUADR.asm

If you don't wish to use coinc_init_timer_loop, then don't copy VDP.asm and delete these methods from PIXELROW.asm:
*    coinc_init_timer_loop
*    measure_time_to_reach_pixel_row
*    write_test_sprites
*    measure_length_of_frame