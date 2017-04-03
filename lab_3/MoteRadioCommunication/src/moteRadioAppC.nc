#include "moteRadio.h"

configuration moteRadioAppC {
}

implementation {
	components MainC;
	components LedsC;
	components moteRadioC as App;
	components new TimerMilliC() as Timer0;
	App.Boot -> MainC;
	App.Leds -> LedsC;
	App.Timer0 -> Timer0;
	
	components ActiveMessageC;
	components new AMSenderC(AM_MOTERADIOMSG);
	
	App.Packet -> AMSenderC;
	App.AMPacket -> AMSenderC;
	App.AMSend -> AMSenderC;
	App.AMControl -> ActiveMessageC;	
}