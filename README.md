# tms9918a-midframe
Attempt to change some VDP registers strategically mid-frame

## Timer-interrupts

Some 8-bit and 16-bit era systems offered raster-interrupts, allowing a program to trigger a small subroutine when a particular row of pixels was about to be drawn.
The TI-99/4a's video chip only supplies one type of interrupt,
an end-of-frame interrupt, usually reffered to as the VDP interrupt.

In 2006 or 2008, Thierry Nouspikel and Jeff Brown told us that it is also possible to configure CRU-timer interrupts so long as you are willing to loose the ability to trigger VDP end-of-frame interrupts.
(http://www.unige.ch/medecine/nouspikel/ti99/tms9901.htm)
I never understood how to use their code until recently.
The CRU timer ticks more regullarly than the end of a video frame.
In a 60hz environment there are, in fact, about 782 ticks per frame.
This is precise enough so that we can set a CRU timer to trigger on the exact same pixel row for each frame.

One might initially be concerned about the loss of the VDP end-of-frame interrupts.
In most games and a few other programs, knowing when a frame completes is actually more important than knowing when a pixel row is reached.
And since the number of CRU timer ticks per frame is a non-interger,
it is also important to syncronize the timer with the VDP end-of-frame event on a regular basis.
But the loss of end-of-frame interrupts isn't really a problem.
Jeff Brown's same approach of enabling CRU timer interrupts, also involves waiting for an end-of-frame interrupt, so that the TI can be hacked to ignore them.

In game loops that I've programmed, I normally want to block the thread at the end of the loop anyway.
There is usually something in the timing of the game that makes it important to only run one iterration of the loop per video frame.
If our program includes a routine that uses Jeff Brown's approach to enable CRU timers,
then as soon as the program returns from that routine,
we as programmers can be certain that an end-of-frame event has just recently occurred.
If we call this hypothetical routine at either the beginning or the end of the game loop,
then the loop can be syncronized with the video frames, just the same as if we were using the standard VDP interrupts.

This means that at the beginning of each video frame,
we can set a timer interrupt and use it for exactly what the word "interrupt" suggests.
An iterration of a game loop can be interrupted at exactly the right time,
without having to constantly poll to see if the scan beam has reached the disired portion of the screen.

## Scan-line interrupts

I'm hoping to use the COINC flag to measure the number CRU ticks between the end of a frame and the drawing of a particular scan line.
If these measurements are made at an application startup,
then the application won't need to worry about if it is running in a 50hz or 60hz environment.
In code, we can specify which scan-lines should trigger an interrupt,
and one of our routines will calculate the corresponding timer-value which actually triggers the interrupt.

## Possible applications

+ Psuedo-parallax scrolling. Choose different pattern tables at different scan lines, to create the appearance of scrolling by different amounts.
+ If the picture on screen displays sky and ground, then the background border can match the sky color and ground color at different parts of the screen.
+ Give a text-mode screen a header section and body section that are of different colors.
+ Turn text-mode into a bitmap mode by giving each quarter of the screen its own pattern table, perhaps for WYSIWYG text.
+ Exceed 32 sprite limitation.
+ One sprite with more than one color.