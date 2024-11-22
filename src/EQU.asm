frame_wait EQU 375     * about 8 milliseconds / about half of a video interrupt
vdp_mock   EQU >00BF   * The last scan line, and the place where a VDP interrupt would happen anyway