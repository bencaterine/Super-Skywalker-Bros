; #########################################################################
;
;   lines.asm - Assembly file for CompEng205 Assignment 2
;   Ben Caterine - brc5967
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc

.DATA

	;; If you need to, you can place global variables here
	
.CODE
	

;; Don't forget to add the USES the directive here
;;   Place any registers that you modify (either explicitly or implicitly)
;;   into the USES list so that caller's values can be preserved
	
;;   For example, if your procedure uses only the eax and ebx registers
;;      DrawLine PROC USES eax ebx x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
DrawLine PROC USES eax ebx x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
	;; Feel free to use local variables...declare them here
	;; For example:
	;; 	LOCAL foo:DWORD, bar:DWORD
	LOCAL delta_x:DWORD, delta_y:DWORD, inc_x:DWORD, inc_y:DWORD, error:DWORD, curr_x:DWORD, curr_y:DWORD, prev_error:DWORD
	;; Place your code here
	
	mov eax, x1
	mov ebx, x0
	sub eax, ebx
	mov delta_x, eax
	cmp delta_x, 0
	jge xabs
	neg delta_x				; delta_x = abs(x1-x0)
xabs:
	mov eax, y1
	mov ebx, y0
	sub eax, ebx
	mov delta_y, eax
	cmp delta_y, 0
	jge yabs
	neg delta_y				; delta_y = abs(y1-y0)
yabs:
	mov inc_x, 1				; if (x0 < x1): inc_x = 1
	mov eax, x1
	cmp x0, eax
	jl xdone
	neg inc_x				; else: inc_x = -1
xdone:
	mov inc_y, 1				; if (y0 < y1): inc_y = 1
	mov eax, y1
	cmp y0, eax
	jl ydone
	neg inc_y				; else: inc_y = -1
ydone:
	mov eax, delta_y
	cmp delta_x, eax
	jle els
	mov eax, delta_x
	mov error, eax
	shr error, 1				; if (delta_x > delta_y): error = delta_x / 2
	jmp next
els:
	mov error, eax
	shr error, 1
	neg error				; else: error = -delta_y / 2
next:
	mov eax, x0
	mov curr_x, eax				; curr_x = x0
	mov eax, y0
	mov curr_y, eax				; curr_y = y0
	invoke DrawPixel, curr_x, curr_y, color	; DrawPixel(curr_x, curr_y, color)
	
	jmp eval				; WHILE LOOP
do:
	invoke DrawPixel, curr_x, curr_y, color	; DrawPixel(curr_x, curr_y, color)
	mov eax, error
	mov prev_error, eax			; prev_error = error
	
	mov eax, delta_x
	neg eax
	cmp prev_error, eax			; if (prev_error > - delta_x):
	jle skip
	mov eax, delta_y
	sub error, eax				;	error -= delta_y
	mov eax, inc_x
	add curr_x, eax				;	curr_x += inc_x
skip:
	mov eax, delta_y
	cmp prev_error, eax			; if (prev_error < delta_y):
	jge eval
	mov eax, delta_x
	add error, eax				;	error += delta_x
	mov eax, inc_y
	add curr_y, eax				;	curr_y += inc_y
eval:
	mov eax, x1
	cmp curr_x, eax				; while (curr_x != x1 OR curr_y != y1)
	jne do
	mov eax, y1
	cmp curr_y, eax
	jne do

	ret        	;;  Don't delete this line...you need it
DrawLine ENDP

END
