#include "Timer.h"

module BlinkC @safe() {
	uses interface Timer<TMilli> as Timer0;
	uses interface Timer<TMilli> as Timer1;
	uses interface Timer<TMilli> as Timer2;
	uses interface Leds;
 	uses interface Boot;
}

implementation {
	event void Boot.booted() {
		call Timer0.startPeriodic( 250 );
		call Timer1.startPeriodic( 500 );
		call Timer2.startPeriodic( 1000 );
	}
	
	/**
	 * Question 3.
	 * If a component needs to post task several times, then the end of the task logic can repost itself as need be.
	 * This code breaks the task into a couple of smaller tasks.
	 * Each task runs through 100,000 iterations of the loop. 
	 * If it hasn't completed all 1,000,000 iterations, it reposts itself.
	 **/	
	task void performTask2() {
		static uint32_t i;
		uint32_t j;
		for (j = i; i < j + 100000 && i < 1000000; i++) {}
		if (i >= 1000000) {
			i = 0;
		} else {
			post performTask2();
		}
	}
	 
	 /**
	 * Question 2.
	 * Tasks can safely both call commands and signal events.
	 * The post operation returns SUCCESS or FAIL.
	 **/
	 task void performTask1() {
	 	uint32_t i;
	 	for (i = 0; i < 1000000; i++) {}
	 }

	/**
	 * Question 1.
	 * This will cause the timer to toggle 1,000,000 times, rather than once.
	 * We observe that Led0 introduces so much latency in the Led1 and Led2 toggles that you never see a situation where only one is on.
	 * The problem is that this computation is interfering with the timer's operation.
	 **/
	event void Timer0.fired() {
		uint32_t i;
		dbg("BlinkC", "Timer 0 fired @ %s.\n", sim_time_string());
		for (i = 0; i < 1000000; i++) {
			call Leds.led0Toggle();
		}
		
		//post performTask1();
	}
	
	event void Timer1.fired() {
		dbg("BlinkC", "Timer 1 fired @ %s \n", sim_time_string());
		call Leds.led1Toggle();
	}
	
	event void Timer2.fired() {
		dbg("BlinkC", "Timer 2 fired @ %s.\n", sim_time_string());
		call Leds.led2Toggle();
	}
}