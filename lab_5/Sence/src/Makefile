COMPONENT=SenseAppC

BUILD_EXTRA_DEPS=MoteRadioMsg.class

MoteRadioMsg.class: MoteRadioMsg.java
	javac MoteRadioMsg.java
	
MoteRadioMsg.java:
	mig java -target=null -java-classname=MoteRadioMsg moteRadio.h MoteRadioMsg -o $@

include $(MAKERULES)
