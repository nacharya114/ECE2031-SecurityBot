;Mode0 Code Snippets for Team BuzzBot
	
			ORG 0
	
;Detects the distance to wall prior to running intruder detection 		
DistToWall:		
	LOAD 	Mask6		
	OUT		SONAREN		;Enables Sensor 6 to find the distance to the wall
	IN		DIST6
	STORE	WALLDIST	;Stores the distance to WALLDIST
	LOAD	MAXLEN
	SUB		WALLDIST	
	STORE	MAX1		;Get approximate distance sonar 1 is from the end of the zone

;Resets the Sonar sensor and sets up the bot for detection	
InitDetect:		
	LOAD	ZERO
	OUT 	SONAREN
	
	CALL 	MAKEMASK
	OUT 	SONAREN
	CALL	UpdateDist
	
	
	
;Running loop for intruder detection
DetectIntuder:
	CALL	CmpDist
	JPOS	Alarm
	JUMP	DetectIntruder
	
Alarm:
	LOAD	IBEEP
	OUT		BEEP
	JUMP	DetectIntruder
	
	


	
;Subroutine Puts the mask into the accumulator
MAKEMASK:	
	LOAD	Mask1
	OR		Mask2
	OR		Mask3
	OR		Mask6
	RETURN

;Update distances and compare 
UpdateDist:
	IN 		DIST1
	STORE	DIST1P
	IN		DIST2
	STORE	DIST2P
	IN		DIST3
	STORE	DIST3P
	IN		DIST4
	STORE	DIST4P
	IN		DIST6
	STORE	DIST6P
	RETURN
	
	
;Compare Distances by checking distance between them. Returns 1 if the distance change is significant
CmpDist:
	;For sensor 1, if the distance is anything less than the distance
		;to the end of the zone we calculated, flag the alert in the AC
	IN		DIST1
	SUB		MAX1
	JNEG	Cmp_alert
	
	;For sensors 2,3,4 and 6, we check the distance against the previous recorded distance 	
		;then, it checks if the absolute change is greater than our specified margin of error
	IN		DIST2
	SUB		DIST2P
	CALL	Abs
	SUB		DELTAX
	JPOS	Cmp_alert
	
	IN		DIST3
	SUB		DIST3P
	CALL	Abs
	SUB		DELTAX
	JPOS	Cmp_alert
	
	IN		DIST4
	SUB		DIST4P
	CALL	Abs
	SUB		DELTAX
	JPOS	Cmp_alert
	
	IN		DIST6
	SUB		DIST6P
	CALL	Abs
	SUB		DELTAX
	JPOS	Cmp_alert
	
	LOADI 	0	;Load zero if no significant change detected
	
Cmp_r:
	RETURN

Cmp_alert:
	LOADI	1	;Load 1 if significant change is detected
	JUMP	Cmp_r
		
	

;Constants & Variables

ZERO:		DW	&H0000
MAXLEN:		DW 	7289			;MAX LENGTH of the entire test area

MAX1:		DW	&H0000			;Approximate distance sonar1 is away from the end of the area.

DELTAX:		DW	5				;constant to check margin of error

WALLDIST:	DW 	&H0000			; Distance Sonar 6 is from the wall

;Temporary variables to store the previous Distances from the sonar.
DIST1P:		DW	&H0000
DIST2P:		DW	&H0000
DIST3P:		DW	&H0000
DIST4P:		DW	&H0000
DIST6P:		DW 	&H0000

IBEEP:		DW	&H0811		;Variable for BeepOnIntruder		;fix this later




; CODE FOR MODE SELECT			;
WaitForUser:
	; This loop will wait for the user to press PB3, to ensure that
	; they have a chance to prepare for any movement in the main code.
	IN     TIMER       ; Used to blink the LEDs above PB3
	AND    Mask1
	SHIFT  5           ; Both LEDG6 and LEDG7
	STORE  Temp        ; (overkill, but looks nice)
	SHIFT  1
	OR     Temp
	OUT    XLEDS
	IN     XIO         ; XIO contains KEYs
	AND    Mask2       ; KEY2 IS FOR MODE 0
	JPOS   WaitForUser ; not ready (KEYs are active-low, hence JPOS)
	LOAD   Zero
	OUT    XLEDS       ; clear LEDs once ready to continue
	