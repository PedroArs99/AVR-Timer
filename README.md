# AVR-Timer
Timer for ATMega328P Microcontroller

* Using a 4 byte counter the program is able to wait for more than one hour
* By default, the program will wait one minute, can be easily changed through an assembler directive
* To start the count down, the switch plugged in D6 has to be set to High
* Switching this element to Low will turn off the timer
* The LED plugged in D4 will indicate if the timer is on/off
* When the time has run out, LED plugged in D2 and Buzzer in D3 will make a signal
* Pressing the Button plugged in D5 will reset the timer anytime.
* To "discard" the alarm it has to be eiter resetted or turned down

![Connections](/Docs/Connections.png)
![Device List](/Docs/Device%20List.png)
![Workflow](/Docs/Workflow.png)


