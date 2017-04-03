#include "moteRadio.h"

module moteRadioC {
	uses {
		interface Boot;
		interface Leds;
		interface Timer<TMilli> as Timer0;
	}
	
	uses {
		// Provide commands for clearing a message's contents, getting its payload length, and getting a pointer to its payload area.
		interface Packet;
		// Provide commands for getting a node's AM address, an AM packet's destination, and an AM packet's type.
		interface AMPacket;
		// Provide commands for sending a message and canceling a pending message send. Also provides an event to indicate whether a message was sent successfully or not.
		interface AMSend;
		// Provide commands for controlling the ActiveMessageC component.
		interface SplitControl as AMControl;
	}
}

implementation {
	uint16_t counter = 0;
	message_t radioPacket;
	bool radioBusy = FALSE;

	event void Boot.booted() {
		/*
		 * Enable radio when the system is booted.
		 * Postpone starting the timer until after the radio has completed starting.
		 */
		call AMControl.start();
	}
	
	event void Timer0.fired() {
		counter++;
		/*
		 * Check if a message transmission is not in progress.
		 * Then transmit the node's id and counter value.
		 */
		if (!radioBusy) {
			// Get the packet's payload (data) and cast it to a pointer.
			MoteRadioMsg* radioPayload = (MoteRadioMsg*)(call Packet.getPayload(&radioPacket, sizeof(MoteRadioMsg)));
			// Exit if the packet's payload is not Initialized.
			if (radioPayload == NULL) {
				return;
			}
			
			// Initialize the packet's fields.
			radioPayload -> nodeID = "TOS_NODE_ID";
			radioPayload -> data = counter;
			
			// Send the packet to all nodes in radio range by specyfying the destination address to "AM_BROADCAST_ADDR".
			if (call AMSend.send(AM_MOTERADIOMSG, &radioPacket, sizeof(MoteRadioMsg)) == SUCCESS) {
				radioBusy = TRUE;
			}
		}
	}
	
	/*
	 * This event is signaled after a message transmission attempt.
	 * Check to ensure the message buffer that was signaled is the same as the local message buffer.
	 */
	event void AMSend.sendDone(message_t *msg, error_t error) {
		if (&radioPacket == msg) {
			radioBusy = FALSE;
		}
	}
	
	// Notify caller that the component has been started and is ready to start the timer.
	event void AMControl.startDone(error_t error) {
		if (error == SUCCESS) {
			call Leds.led0On();
			call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
		} else {
			call AMControl.start();
		}
	}
	
	event void AMControl.stopDone(error_t error) {
		// Do nothing.
	}
}