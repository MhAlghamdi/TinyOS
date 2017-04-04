#ifndef MOTE_RADIO_H
#define MOTE_RADIO_H

typedef nx_struct MoteRadioMsg {
	nx_uint16_t nodeID;
	nx_uint16_t data;
} MoteRadioMsg;

enum {
	AM_MOTERADIOMSG = 6,
	TIMER_PERIOD_MILLI = 100,
};

#endif /* MOTE_RADIO_H */
