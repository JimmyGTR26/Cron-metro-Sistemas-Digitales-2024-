*************************************************************************** 
* IDE para 68HC908JK1 parcialmente adaptado para simular micro 6800  
*************************************************************************** 
*                              RESTRICCIONES
* NO EXISTE EL ACUMULADOR B
* ldaa    se reemplaza por lda
* staa    se reemplaza por sta
* suba    se reemplaza por  sub
* ldx     se reemplaza por ldhx
* inx     se reemplaxapor aix #1
***************************************************************************
*                    Declaracion de constantes
 
RAMStart        equ $0080   ; Comienzo de RAM (finaliza en $00FF)
ROMStart        equ $F600   ; Comienzo de EPROM (1536 bytes disponibles)

VectorStart     equ $FFF8   ; Comienzo de Zona de vectores 
Config1         equ $001F   ; registro especial del microcontrolador
                            ; require inicializacion
************************************************************************** 
 
              org RAMStart  ;($0080)
 
 
************************************************************************** 
               org ROMStart            ;($F600)Flash ROM: Zona de Programa
Inicio
             
			 lda  #$11
             sta  Config1
             
otra_vez     nop
			
			 jsr  delay_10m     ; esta instruccion consume 5 ciclos de reloj
			 	
			 nop
			 
			 bra otra_vez	
			 

;***********************************************************************************************
; entre parentesis (cantidad de ciclos de reloj que insume la ejecucion de la instruccion)

delay_10m       
                                       ; [5] viene del llamado a jsr 
									   
		pshh                   ; (2) el H al stack
                clrh         	       ; (1) limpio el H   
                
		lda #!26               ; (2)  se escrbe el A
                ldx #!235              ; (2)  se escribe el X
leep            DBNZX leep             ; (3)
                DBNZA leep             ; (3)
				
                pulh			       ; (2)recupero el H
                rts				       ; [4]
		 
;;;;;;;;;;;;;;;;;;;;;;;;;;;; COMENTARIOS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				 			 

; SUBRUTINA: delay_10m    ; demora de 10 milisegundos para una especifica frecuencia de trabajo
	
******************************************************************************************************
; tiempo de retardo (delay) = N_Ciclos_reloj(NC) que insume la subrutina x periodo del ciclo de reloj
******************************************************************************************************

;**** ecuacion para implementar un determinado numero de ciclos (NC) *****

; El codigo de: delay_10m cumple con la siguiente ecuacion para el calculo de NC 
; Desde el llamado a subrutina que son [5] ciclos de reloj,hasta el rts que son [4] ciclos de reloj
; la ecuacion es:
; N_Ciclos_reloj(NC)=[5]+ 2+1+2+2 + CT2*3 + 3 +(CT1-1)*([3*256]+3)] + 2 +[4] ;;;

;;;;;;; bucles producidos con primer DBNZX: CT2*3=78, +3 (DBNZA siguiente) --> vuelve a DBNZX --> el registro X se decrementa pero con
overflow, leido como 255 por el uP (eso produce la cantidad de 256 comandos DBNZX hasta que el registro llega a X=0 (3*256)-->
--> el +3 siguiente corresponde al DBNZA de cada ciclo --> todo multiplicado por CT1-1 (ya que el primer DBNZA de todos me decremento
en 1 el registro A por primera vez ;;;;;;;

;A = #CT1
;X = #CT2
; Dado el tiempo que se quiere implementar y conociendo la frecuencia de reloj, despejando NC  >>
; NC = tiempo (delay) / periodo reloj =  delay x fXtal 
; Para delay = 0.010 segundos (10 miliseg) y frecuencia Xtal 2000000 (2MHz)
; Resulta un NC = 20000
; Adoptamos el valor de una constante y aproximamos el otro, por ejemplo: 
; Si CT1 =!26 ; y  CT2 =!235
; entonces:  NC = 12 + 235*3 + 3 + 25 * 771 + 6 
; NC = 12 + 705 + 3 + 19275 + 6 = 20001
; Se podria reducir el valor de CT2 y luego insertar tantos nop (1 ciclo)
; despues del pulh para que NC de exacto 20000.
             
****************************************************************************** 
*   Atencion de Interrupciones  
  
Vacio            
                 rti                     ;retorna sin hacer nada
 
******************************************************************************* 
                 org  VectorStart  ; a partir de $FFF8
 
        dw   Vacio                      ;FFF8+FFF9, no usado
        dw   Vacio                      ;FFFA+FFFB, (direccion atencion interrupcion por IRQ)
        dw   Vacio                      ;FFFC+FFFD, (direccion atencion interrupcion por SWI)
        dw   Inicio                     ;FFFE+FFFF, (direccion comienzo del programa)
*******************************************************************************