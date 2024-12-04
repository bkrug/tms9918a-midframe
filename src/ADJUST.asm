       DEF  ADJUST
*
       REF  set_timer
       REF  get_timer_value

       COPY 'EQUVAR.asm'
       COPY 'EQUCRU.asm'

ADJUST
       LWPI WS
       LI   R10,STACK
*
       BL   @measure_time_between_timer_calls
       BL   @measure_time_setting_up_coinc
       BL   @measure_time_after_coinc
       BL   @measure_time_restarting_loop
       BL   @measure_time_triggering_isr
*
JMP    JMP  JMP


*
* Calling and returning from set_timer & get_timer_value
* takes time itself.
* Place the number of CRU ticks in "time_to_measure_time".
*
measure_time_between_timer_calls
       DECT R10
       MOV  R11,*R10
*
       LI   R1,>3FFF
       BL   @set_timer
       BL   @get_timer_value
       NEG  R2
       AI   R2,>3FFF
       MOV  R2,@time_to_measure_time
*
       MOV  *R10+,R11
       RT

*
* When using the "sprite coinc" approach,
* there is a period of time inbetween a video frame
* that has no sprites, and a frame that does have sprites.
* Measure the time it takes to get from the end of the
* frame to setting the timer
*
measure_time_setting_up_coinc
       DECT R10
       MOV  R11,*R10
* Set Timer
       LI   R1,>3FFF
       BL   @set_timer
*
* Beginning of mock of code in "measure_time_to_reach_pixel_row"
*
       JMP  out_of_coinc_loop
out_of_coinc_loop
       LIMI 0
* Reset timer
       LI   R1,>3FFF
* Configure next interrupt's timer
       BL   @mock_set_timer_1
*
* This routine should take the same amount of time
* as the real set_timer, without actually changing the timer value.
*
mock_set_timer_1
       CLR  R12         CRU base of the TMS9901 
* Instead of calling SBO, call "LI R0,14" which we think takes the same amount of time
*       SBO  0           Enter timer mode
       LI   R0,14
       INCT R12         Address of bit 1 
* Instead of calling "LDCR R1,14", call "SRL  R12,0" which we think takes the same amount of time when R0 contains 14
*       LDCR R1,14       Load value 
       SRL  R12,0
*
* End of mock routine
*
       BL   @get_timer_value
       NEG  R2
       AI   R2,>3FFF
       S    @time_to_measure_time,R2
       MOV  R2,@pixel_row_pre_measure
* Now we need the real return address
       MOV  *R10+,R11
       RT

*
* After the coinc measurement routine detects
* two overlapping sprites, it reads the timer.
* How long does this take?
measure_time_after_coinc
       DECT R10
       MOV  R11,*R10
* Set Timer
       LI   R1,>3FFF
       BL   @set_timer
*
* Mock of some code in
*
       ANDI R1,>2000
       JNE  mock_coinc_has_been_triggered
mock_coinc_has_been_triggered
* Let R2 = new timer value
       BL   @mock_get_timer_value
mock_get_timer_value
       CLR  R12 
* Instead of calling SBO, call "LI R0,15" which we think takes the same amount of time
*       SBO  0           Enter timer mode
* Instead of calling "STCR R2,15", call "SRL  R12,0" which we think takes the same amount of time when R0 contains 15
*       STCR R2,15       Read current value (plus mode bit)
       LI   R0,15
       SRL  R12,0
*
* End of mock
*
       BL   @get_timer_value
       NEG  R2
       AI   R2,>3FFF
       S    @time_to_measure_time,R2
       MOV  R2,@pixel_row_post_measure
* Now we need the real return address
       MOV  *R10+,R11
       RT

*
* At the beginning of a game loop, we normally call 
* "block_vdp_interrupt" and "restart_timer_loop" consecutively.
* This routine measures how long it should take to get
* from the point in code where an end-of-frame is detected
* to the point where the timer is started for the first time.
*
measure_time_restarting_loop
       DECT R10
       MOV  R11,*R10
* Set R13 & R14 so that RTWP won't actually change anything
       LI   R13,WS
       LI   R14,mock_return_from_RTWP
* Set Timer
       LI   R1,>3FFF
       BL   @set_timer
*
* This code is as close to the end of "block_vdp_interrupt"
* and the beginning of "restart_timer_loop" as is possible.
*
mock_end_of_block_vdp_interrupt
       JMP  out_of_sync_loop
out_of_sync_loop
* Configure the 9901 for interrupts.
       SBZ  1                 * Disable external interrupt prioritization.
       SBZ  2                 * Disable VDP interrupt prioritization.
* Done
       RTWP
mock_return_from_RTWP
*
       BL   @mock_restart_timer_loop
mock_restart_timer_loop
*
       DECT R10
       MOV  R11,*R10
* Reset timer
* Initialize "isr_element_address"
       MOV  @isr_table_address,R0
       MOV  *R0+,R1
       MOV  R0,@isr_element_address
       BL   @mock_set_timer_2
*
* This routine should take the same amount of time
* as the real set_timer, without actually changing the timer value.
*
mock_set_timer_2
       CLR  R12         CRU base of the TMS9901 
* Instead of calling SBO, call "LI R0,14" which we think takes the same amount of time
*       SBO  0           Enter timer mode
       LI   R0,14
       INCT R12         Address of bit 1 
* Instead of calling "LDCR R1,14", call "SRL  R12,0" which we think takes the same amount of time when R0 contains 14
*       LDCR R1,14       Load value 
       SRL  R12,0
*
* End of mock routine
*
       BL   @get_timer_value
       NEG  R2
       AI   R2,>3FFF
       S    @time_to_measure_time,R2
       MOV  R2,@skipped_starting_new_frame
* Undo any damage we did to the CRU
       CLR  R12
       SBO  1
       SBO  2
* Pop something off of the stack that we won't use
       INCT R10
* Now we need the real return address
       MOV  *R10+,R11
       RT

*
*
*
measure_time_triggering_isr
       LWPI >83C0
*
       DECT R10
       MOV  R11,*R10
*
* This is a mock of the code in timer_isr
*
       LIMI 0
* Get stack pointer
       LI   R10,WS
       AI   R10,2*10
       MOV  *R10,R10
* Save Return address
       DECT R10
       MOV  R11,*R10
* Let R9 = address of child interrupt
* Let R1 = next timer value
* Update interrupt element address
       MOV  @isr_element_address,R0
       MOV  *R0+,R9
       MOV  *R0+,R1
       MOV  R0,@isr_element_address
* Subtract 12 CRU ticks from timer value.
* There is a delay between triggering the ISR, and resetting the timer
       AI   R1,isr_trigger_adjustment
* Configure next interrupt's timer
       BL   @mock_set_timer_3
*
* This routine should take the same amount of time
* as the real set_timer, without actually changing the timer value.
*
mock_set_timer_3
       CLR  R12         CRU base of the TMS9901 
* Instead of calling SBO, call "LI R0,14" which we think takes the same amount of time
*       SBO  0           Enter timer mode
       LI   R0,14
       INCT R12         Address of bit 1 
* Instead of calling "LDCR R1,14", call "SRL  R12,0" which we think takes the same amount of time when R0 contains 14
*       LDCR R1,14       Load value 
       SRL  R12,0
*
* End of mock routine
*
       BL   @get_timer_value
       NEG  R2
       AI   R2,>3FFF
       S    @time_to_measure_time,R2
       MOV  R2,@skipped_timer_isr_ticks
* Pop something off of the stack that we won't use
       INCT R10
* Now we need the real return address
       MOV  *R10+,R11
*
       LWPI WS
       RT

isr_trigger_adjustment    EQU  11