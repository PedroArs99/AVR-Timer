; *****************************************************************************
; Author: Pedro Arenas
; Project name: AVR Timer
; *****************************************************************************

; Define I/O Devices Labels
.EQU L1 = 4
.EQU L2 = 2
.EQU BZ = 3
.EQU S  = 6
.EQU BT = 5

; Define Time Constants
.EQU CLK_FREQ_IN_HZ = 16000000
.EQU CLK_IN_LOOP = 12

.DEF COUNTER_0 = r16
.DEF COUNTER_1 = r17
.DEF COUNTER_2 = r18
.DEF COUNTER_3 = r19


.EQU ONE_SECOND = (CLK_FREQ_IN_HZ / CLK_IN_LOOP)
.EQU HALF_SECOND = ONE_SECOND / 2
.EQU ONE_MINUTE = 60 * ONE_SECOND
.EQU TIME_TO_WAIT_IN_MINUTES = 1

.EQU TIME_TO_WAIT_IN_CYCLES = TIME_TO_WAIT_IN_MINUTES * ONE_MINUTE

; *****************************************************************************
; Configure the I/O devices used in the program using the DDRD register
; This sets output devices as 1 on DDRD and input as 0
; 
; @params: none
; 
; *****************************************************************************
CONFIG_IO:
	SBI DDRD, L1
	SBI DDRD, L2
	SBI DDRD, BZ
	CBI DDRD, S
	CBI DDRD, BT

; *****************************************************************************
; Main Program
; *****************************************************************************
MAIN:
	SBIC PIND, S ; If S is set to High run start up
	RJMP START_UP
	RJMP MAIN

; *****************************************************************************
; Turns L1 on and start counting down.
; When the time has run out it will make L2 and BZ blink.
;
; @params: none
;
; *****************************************************************************
START_UP:
	RCALL TURN_L1_ON
	RCALL WAIT_TIME
	RJMP BLINK_L2_BZ

; *****************************************************************************
; Reset Timer when BT is pressed. Makes L1 Blink once and reset the program
;
; @params: none
;
; *****************************************************************************
RESET:
	RCALL TURN_L1_OFF
	RCALL SHORT_WAIT
	RJMP START_UP

; *****************************************************************************
; Turns all the I/O outputs off and returns to program start
;
; @params: none
;
; *****************************************************************************
SHUT_DOWN:
	RCALL TURN_L1_OFF
	RCALL TURN_L2_OFF
	RCALL TURN_BZ_OFF
	RJMP MAIN

; *****************************************************************************
; Turn L1 on by setting the bit on PORTD to 1
;
; @params: none
; 
; *****************************************************************************
TURN_L1_ON:
	SBI PORTD, L1
	RET

; *****************************************************************************
; Turn L1 off by setting the bit on PORTD to 0
;
; @params: none
; 
; *****************************************************************************
TURN_L1_OFF:
	CBI PORTD, L1
	RET

; *****************************************************************************
; Turn L2 on by setting the bit on PORTD to 1
;
; @params: none
; *****************************************************************************
TURN_L2_ON:
	SBI PORTD, L2
	RET

; *****************************************************************************
; Turn L2 off by setting the bit on PORTD to 0
;
; @params: none
; 
; *****************************************************************************
TURN_L2_OFF:
	CBI PORTD, L2
	RET

; *****************************************************************************
; Turn BZ on by setting the bit on PORTD to 1
;
; @params: none
; *****************************************************************************
TURN_BZ_ON:
	SBI PORTD, BZ
	RET

; *****************************************************************************
; Turn L2 off by setting the bit on PORTD to 0
;
; @params: none
; 
; *****************************************************************************
TURN_BZ_OFF:
	CBI PORTD, BZ
	RET

; *****************************************************************************
; Makes L2 And BZ Blink
;
; @params: none
;
; *****************************************************************************
BLINK_L2_BZ:
	RCALL TURN_L2_ON
	RCALL TURN_BZ_ON
	RCALL SHORT_WAIT
	RCALL TURN_L2_OFF
	RCALL TURN_BZ_OFF
	RCALL SHORT_WAIT

	; Check If BT is pressed to shut up the alarm
	SBIC PIND, BT
	RJMP RESET

	; Check if S is swtiched to low to shut down the timer
	SBIS PIND, S
	RJMP SHUT_DOWN

	; Else keep noising
	RJMP BLINK_L2_BZ

; *****************************************************************************
; Wait a time defined on the HALF_SECOND constant
;
; @params:
;  - time to wait: defined on HALF_SECOND constant
; @registers:
;  - COUNTER_0:COUNTER_3: Time counter
;
; *****************************************************************************
SHORT_WAIT:
	; Clear Registers
	CLR COUNTER_0
	CLR COUNTER_1
	CLR COUNTER_2
	CLR COUNTER_3

	; Initialize Counter
	LDI COUNTER_0, LOW(HALF_SECOND)
    LDI COUNTER_1, BYTE2(HALF_SECOND)
    LDI COUNTER_2, BYTE3(HALF_SECOND)
    LDI COUNTER_3, BYTE4(HALF_SECOND)

	RCALL LOOP
	RET

; *****************************************************************************
; Wait a time defined on the TIME_TO_WAIT_IN_CYCLES constant
;
; @params:
;  - time to wait: defined on TIME_TO_WAIT_IN_CYCLES constant
; @registers:
;  - COUNTER_0:COUNTER_3: Time counter
;
; *****************************************************************************
WAIT_TIME:
	; Clear Registers
	CLR COUNTER_0
	CLR COUNTER_1
	CLR COUNTER_2
	CLR COUNTER_3

	; Initialize Counter
	LDI COUNTER_0, LOW(TIME_TO_WAIT_IN_CYCLES)
    LDI COUNTER_1, BYTE2(TIME_TO_WAIT_IN_CYCLES)
    LDI COUNTER_2, BYTE3(TIME_TO_WAIT_IN_CYCLES)
    LDI COUNTER_3, BYTE4(TIME_TO_WAIT_IN_CYCLES)

	RCALL LOOP
	RET

; *****************************************************************************
; Waits a number of cycles in a loop
; 
; @params:
;  - Number of cycles: Passed using COUNTER_0:3
;
; *****************************************************************************
LOOP:
	; If BT is pressed reset the alarm
	SBIC PIND, BT
	RJMP RESET

	; If S is switched to Low shut down the timer
	SBIS PIND, S
	RJMP SHUT_DOWN

	; Else keep counting

	; Set Zero flag
	SEZ
	; Clear Carry
	CLC 

	; Decrease Counter
	SBCI COUNTER_0, 1
	SBCI COUNTER_1, 0 
	SBCI COUNTER_2, 0 
	SBCI COUNTER_3, 0 

	; Compare the counter with 0
	BRNE LOOP
	RET