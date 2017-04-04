#include "Timer.h"
#include "moteRadio.h"

module SenseC {
    uses {
        interface Boot;
        interface Leds;
        interface Timer<TMilli>;
        interface Read<uint16_t>;
        
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
    // sampling frequency in binary milliseconds
    #define SAMPLING_FREQUENCY 100
    uint16_t counter = 0;
	message_t radioPacket;
	bool radioBusy = FALSE;

    event void Boot.booted() {
    	call AMControl.start();
    }

    event void Timer.fired() {
        call Read.read();
    }

    event void Read.readDone(error_t result, uint16_t data) {
    	if (!radioBusy) {
			MoteRadioMsg* radioPayload = (MoteRadioMsg*)(call Packet.getPayload(&radioPacket, sizeof(MoteRadioMsg)));
			if (radioPayload == NULL) {
				return;
			}

			radioPayload -> nodeID = "TOS_NODE_ID";
			radioPayload -> data = data;
			
			if (call AMSend.send(AM_MOTERADIOMSG, &radioPacket, sizeof(MoteRadioMsg)) == SUCCESS) {
				radioBusy = TRUE;
			}
		}
    }

    event void AMSend.sendDone(message_t *msg, error_t error){
		if (&radioPacket == msg) {
			radioBusy = FALSE;
		}
	}

	event void AMControl.startDone(error_t error) {
		if (error == SUCCESS) {
			call Leds.led0On();
			call Timer.startPeriodic(SAMPLING_FREQUENCY);
		} else {
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t error){
		// TODO Auto-generated method stub
	}
}
