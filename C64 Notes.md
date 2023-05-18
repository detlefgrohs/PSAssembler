Codebase: https://codebase64.org/doku.php?id=start

https://www.c64-wiki.com/wiki/raster_time#:~:text=Raster%20time%20for%20one%20horizontal%20line%20of%20graphic,complete%20screen%20update%2Fframe%2C%20which%20equals%2019656%20CPU%20cycles.

Raster time equals the duration it takes the VIC-II to put a byte of graphic data (=8 pixels/bits) onto the screen and is measured in horizontal lines or CPU cycles.

Raster time for one horizontal line of graphic (504 pixels including border) equals 63 CPU cycles. The whole graphic screen consists of 312 horizontal lines including the border. In total there are 63 * 312 CPU cycles for one complete screen update/frame, which equals 19656 CPU cycles. Given the C64 CPU clock with 985248 Hertz divided by the 19656 CPU cycles, the result is ~50Hz (the PAL screen standard), not considering the time for screen blanking.

That is the math for the screen output side, but an assembler programmer also has to consider special VIC-II timing aspects.

All C64 internal circuits share the same data bus. For preventing conflicts, the CPU access the data bus whilst phi2 is high, the low phase of the oscillation cycle lets the VIC-II use the bus. The graphic screen needs colour too, so data needs to be fetched from colour ram.

As there are no cycles left for this during the phi2 low phase, the VIC-II takes over the phi2 high phase/data bus and locks out the CPU temporarily via the AEC line. Then during 40 cycles the colour values are transferred into a VIC-II internal buffer.

This colour value fetching happens every eight rasterlines, resulting in the infamous badline, where there are only 23 CPU cycles of raster time left for computing. The VIC-II can be programmed to fetch colour values every rasterline, so every rasterline becomes a badline, resulting in even less rastertime left, but more colourful graphics. The FLI graphic mode uses this technique.

So generally, C64 assembler programmers speak of rastertime because all these factors have to be considered. SID music/sound effect player routines ideally have to use very few raster time, so there are enough CPU cycles left for the main program. Also the screen timing has to be considered to reduce flickering.

Many digi sample playing routines that use no graphics tend to turn off the VIC-II, to have all the rastertime available for a faster D/A conversion.

