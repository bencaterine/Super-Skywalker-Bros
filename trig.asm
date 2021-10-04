; #########################################################################
;
;   trig.asm - Assembly file for CompEng205 Assignment 3
;	Ben Caterine - brc5967
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include trig.inc

.DATA

;;  These are some useful constants (fixed point values that correspond to important angles)
PI_HALF = 102943           	;;  PI / 2
PI =  205887	                ;;  PI 
TWO_PI	= 411774                ;;  2 * PI 
PI_INC_RECIP =  5340353        	;;  Use reciprocal to find the table entry for a given angle
	                        ;;              (It is easier to use than divison would be)


	;; If you need to, you can place global variables here
	
.CODE

FixedMul PROC USES edx a:FXPT, b:FXPT
	mov eax, a
	imul b
	shl edx, 16
	shr eax, 16
	or eax, edx
	ret
FixedMul ENDP

FixedSin PROC USES edi esi angle:FXPT
	mov eax, angle
	jmp neg_check		; while(angle < 0)
neg_do:
	add eax, TWO_PI			; angle += 2pi
neg_check:
	cmp eax, 0
	jl neg_do

	mov esi, 0			; negate = 0
	jmp pi2_eval		; while(angle > pi/2)
pi_check:
	cmp eax, PI
	jnl two_pi_check		; if(angle < pi)
	neg eax
	add eax, PI					; angle = pi - angle
	jmp pi2_eval
two_pi_check:
	cmp eax, TWO_PI
	jnl other				; else if (angle < 2pi)
	sub eax, PI					; angle -= pi
	add esi, 1					; negate = 1
	jmp pi2_eval
other:						; else
	sub eax, TWO_PI				; angle -= 2pi
pi2_eval:
	cmp eax, PI_HALF
	jg pi_check
	jl next

	mov eax, 10000h			; if(angle == 2pi)
	jmp negate_check			; result = 1
	
next:
	INVOKE FixedMul, eax, PI_INC_RECIP
	mov edi, 0			; i = 0
	jmp sin_eval		; while(angle >= i*pi/256)
sin_do:
	add edi, 10000h			; i++
sin_eval:
	cmp eax, edi
	jge sin_do
	
	sub edi, 10000h		; i--
	shr edi, 16
	mov eax, 0
	mov ax, WORD PTR [SINTAB + 2*edi]	; result = SINTAB[i]

negate_check:	
	cmp esi, 1			; if(negate)
	jne skip
	neg eax					; result = -result
skip:
	ret					; return result
FixedSin ENDP
	
FixedCos PROC angle:FXPT
	mov eax, angle
	add eax, PI_HALF
	INVOKE FixedSin, eax	; result = sin(angle + pi/2)
	ret						; return result
FixedCos ENDP	
END