#include "moteRadio.h"

configuration SenseAppC 
{ 
} 
implementation {
  components SenseC;
  components MainC;
  components LedsC;
  components new TimerMilliC();
  components new DemoSensorC() as Sensor;

  SenseC.Boot -> MainC;
  SenseC.Leds -> LedsC;
  SenseC.Timer -> TimerMilliC;
  SenseC.Read -> Sensor;
  
  components ActiveMessageC;
  components new AMSenderC(AM_MOTERADIOMSG);
  
  	SenseC.Packet -> AMSenderC;
	SenseC.AMPacket -> AMSenderC;
	SenseC.AMSend -> AMSenderC;
	SenseC.AMControl -> ActiveMessageC;
}
