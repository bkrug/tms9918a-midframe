*
* Values to adjust the accuracy of timer values
* These are values we calculated from CPU documentation
*

* number of CRU ticks missed getting ready to measure the frame length
frame_length_pre_measure       EQU  >A080
* number of extra CRU ticks trying to get the measured time
frame_length_post_measure      EQU  >A082
* number of CRU ticks missed getting ready to measure the frame length
pixel_row_pre_measure          EQU  >A084
* number of extra CRU ticks trying to get the measured time
pixel_row_post_measure         EQU  >A086
* number of CRU ticks occurring @ block_vdp_interrupt's end & restart_timer_loop's start
skipped_ticks_restarting       EQU  >A088
* number of CRU ticks occurring between triggering timer_isr & starting next timer
skipped_timer_isr_ticks        EQU  >A08A
* number of CRU ticks occurring between triggering timer_isr at end of video frame & starting the timer in restart_timer_loop
skipped_new_frame_ticks        EQU  >A08C
* time that passes when calling set_timer and get_timer_value consequtively
time_to_measure_time           EQU  >A08E


* This is what I think "pixel_row_pre_measure" - "pixel_row_post_measure" will equal
pixel_row_measure_shortage     EQU  27
