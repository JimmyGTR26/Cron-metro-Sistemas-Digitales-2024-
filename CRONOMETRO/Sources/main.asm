;*******************************************************************
;* This stationery serves as the framework for a user application. *
;* For a more comprehensive program that demonstrates the more     *
;* advanced functionality of this processor, please see the        *
;* demonstration applications, located in the examples             *
;* subdirectory of the "Freescale CodeWarrior for HC08" program    *
;* directory.                                                      *
;*******************************************************************

; Include derivative-specific definitions
            INCLUDE 'derivative.inc'

; export symbols
            XDEF _Startup, main
            ; we export both '_Startup' and 'main' as symbols. Either can
            ; be referenced in the linker .prm file or from C/C++ later on

            XREF __SEG_END_SSTACK   ; symbol defined by the linker for the end of the stack


; variable/data section
MY_ZEROPAGE: SECTION  SHORT         ; Insert here your data definition

; code section
MyCode:     SECTION
main:
_Startup:
            LDHX   #__SEG_END_SSTACK ; initialize the stack pointer
            TXS
            CLI                     ; enable interrupts
            LDA #$FF
            STA PTBDD
            STA PTADD
   	 		STA PTCD
            LDA #$00
            STA PTCDD
         	CLR $00A0		
			CLR $00A1
			CLR $00A2
			CLR $00A3
   			LDA #00
   	 		STA $006E


mainLoop:

; BOTON Y SENSADO DEL MISMO

			LDA PTCD
			BRCLR 2,PTCD,SI_ON 		; ME FIJO SI APRETARON SW1 PTC2
			BRCLR 3,PTCD,STOP_ON		; ME FIJO SI APRETAROB SW1 PTC3
			JMP SIG_1

SI_ON
			BRCLR 3,PTCD,RESET_ON
			LDA #%10011111		; CARGA RTC PARA QUE CUENTE 1s
			STA $006C
			BRA SIG_1
STOP_ON
			BRCLR 2,PTCD,RESET_ON
			LDA #%10001111		; APAGO EL ENABLE DEL RTC (CREO)
			STA $006C
			BRA SIG_1
RESET_ON
         	CLR $00A0		
			CLR $00A1
			CLR $00A2
			CLR $00A3					

SIG_1


		
;SUBRUTINA REFRESCO
	

			LDA $00A0
			JSR SUB_7
			
			feed_watchdog
	
			LDA #%00000000
			STA PTAD
			LDA #10	
			LDX #10	
R_1MS		DBNZX R_1MS	
			DBNZA R_1MS

			LDA $00A1
			JSR SUB_7

			feed_watchdog
			LDA #%00000001
			STA PTAD
			LDA #10	
			LDX #10	
R_2MS		DBNZX R_2MS	
			DBNZA R_2MS
		

			LDA $00A2
			JSR SUB_7	
			
			feed_watchdog	
			
			LDA #%00000010
			STA PTAD
			LDA #10	
			LDX #10	
R_3MS		DBNZX R_3MS	
			DBNZA R_3MS

		
			LDA $00A3
			JSR SUB_7	
			
			feed_watchdog
			
			LDA #%00000011
			STA PTAD
			LDA #10
			LDX #10	
R_4MS		DBNZX R_4MS	
			DBNZA R_4MS	
	
	
			LDA #%00000001
			STA PTBD		
			
			feed_watchdog
			
			LDA #%00000010
			STA PTAD
			LDA #10
			LDX #10
R_5MS		DBNZX R_5MS	
			DBNZA R_5MS	
	
		
			JMP mainLoop
		


;********************************************************************
;subrutina display traduccion

SUB_7

			CMP #$00
			BNE NO_0
			LDA #%10111110
			STA PTBD
			CLRA
	
NO_0
			CMP #$01
			BNE NO_1
			LDA #%00000110
			STA PTBD
			CLRA
	
NO_1
			CMP #$02
			BNE NO_2
			LDA #%11011010
			STA PTBD
			CLRA
	
NO_2
			CMP #$03
			BNE NO_3
			LDA #%11001110
			STA PTBD	
			CLRA
	
NO_3
			CMP #$04
			BNE NO_4
			LDA #%01100110
			STA PTBD
			CLRA
	
NO_4
			CMP #$05
			BNE NO_5
			LDA #%11101100
			STA PTBD
			CLRA
	
NO_5
			CMP #$06
			BNE NO_6
			LDA #%11111100
			STA PTBD	
			CLRA
	
NO_6
			CMP #$07
			BNE NO_7
			LDA #%10000110
			STA PTBD	
			CLRA
	
NO_7
			CMP #$08
			BNE NO_8
			LDA #%11111110
			STA PTBD
			CLRA
	
NO_8
			CMP #$09
			BNE NO_9
			LDA #%11101110
			STA PTBD	
			CLRA
	
NO_9	
			RTS
;********************************************************************
	
;Codigo sergio interrupcion		


rtcISR


			bset 7,$006C

U_SEG
			LDA #10
			INC $00A0
			CMP $00A0
			BEQ D_SEG
			BRA FIN
	

D_SEG
			CLR $00A0
			LDA #6
			INC $00A1
			CMP $00A1
			BEQ U_MIN
			BRA FIN

U_MIN 
	
			CLR $00A1
			LDA #10	
			INC $00A2
			CMP $00A2
			BEQ D_MIN
			BRA FIN

D_MIN
			CLR $00A2
			LDA #6
 			INC $00A3
			CMP $00A3
	
	
FIN
			RTI	
		
		
			org $ffcc
			fdb rtcISR
			