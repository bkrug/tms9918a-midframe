# tms9918a-midframe
Attempt to change some VDP registers strategically mid-frame

## Timer-interrupts

Years ago T.N. and Jeff Brown that it is possible to configure CRU-timer interrupts so long as you are willing to loose the ability to trigger VDP interrupts.
I never understood how to use their code until now.
Loosing VDP interrupts isn't a bit problem, because at the end of a game loop,
I usually need to block the thread until the VDP interrupts occurr anyway.
Use Jeff Brown's method, I can have a loop that keeps checking if a VDP interrupt was just ignored.
Timer-interrupts trigger while my game loop is still doing work, and they are far more important than VDP-interrupts.

## Scan-line interrupts

I'm hoping to use the COINC flag to measure the number CRU ticks between the end of a frame and the drawing of a particular scan line.
If these measurements are made at an application startup,
then the application won't need to worry about if it is running in a 50hz or 60hz environment.
In code, we can specify scan-lines we want to see interrupts on,
and one of our routines will calculate the timer-value for us.

## Possible applications

+ Psuedo-parallax scrolling. Choose different pattern tables at different scan lines, to create the appearance of scrolling by different amounts.
+ If the picture on screen displays sky and ground, then the background border can match the sky color and ground color at different parts of the screen.
+ Give a text-mode screen a header section and body section that are of different colors.
+ Turn text-mode into a bitmap mode by giving each quarter of the screen its own pattern table.
+ Exceed 32 sprite limitation.
+ One sprite with more than one color.