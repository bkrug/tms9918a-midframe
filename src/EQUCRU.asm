*
* Values to adjust the accuracy of timer values
* These are values we calculated from CPU documentation
*

* number of CRU ticks missed getting ready to measure the frame length
frame_length_pre_measure       EQU  0
* number of extra CRU ticks trying to get the measured time
frame_length_post_measure      EQU  0
* number of CRU ticks missed getting ready to measure the frame length
pixel_row_pre_measure          EQU  0
* number of extra CRU ticks trying to get the measured time
pixel_row_post_measure         EQU  0
* number of CRU ticks occurring @ block_vdp_interrupt's end & restart_timer_loop's start
skipped_ticks_restarting       EQU  0
* number of CRU ticks occurring between triggering timer_isr & starting next timer
skipped_timer_isr_ticks        EQU  0
* number of CRU ticks occurring between triggering timer_isr at end of video frame & starting the timer in restart_timer_loop
skipped_new_frame_ticks        EQU  0