; #########################################################################
;
;   game.asm - Assembly file for CompEng205 Assignment 4/5
;	Ben Caterine - brc5967
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include trig.inc
include blit.inc
include game.inc

;; Has keycodes
include keys.inc
	
.DATA

SPRITE STRUCT
	bitp		DWORD	?
	xcen		FXPT	?
	ycen		FXPT	?
	xvel		FXPT	?
	yvel		FXPT	?
	stat		BYTE	?
SPRITE ENDS

JAWA STRUCT
	sptr		DWORD	?
	minx		FXPT	?
	maxx		FXPT	?
JAWA ENDS

mapdraw SPRITE <OFFSET map, 2875*10000h, 240*10000h, 0,0,1>		; level map sprite
platforms SPRITE <OFFSET p0, 316*10000h, 447*10000h, 0,0,1>,	; sprites store platform locations
	<OFFSET p1, 701*10000h, 400*10000h, 0,0,1>,
	<OFFSET p2, 957*10000h, 304*10000h, 0,0,1>,
	<OFFSET p3, 973*10000h, 176*10000h, 0,0,1>,
	<OFFSET p4, 1133*10000h, 400*10000h, 0,0,1>,
	<OFFSET p3, 1261*10000h, 272*10000h, 0,0,1>,
	<OFFSET p5, 1453*10000h, 144*10000h, 0,0,1>,
	<OFFSET p1, 1725*10000h, 432*10000h, 0,0,1>
platforms2 SPRITE <OFFSET p3, 2029*10000h, 432*10000h, 0,0,1>,
	<OFFSET p1, 2045*10000h, 176*10000h, 0,0,1>,
	<OFFSET p3, 2221*10000h, 432*10000h, 0,0,1>,
	<OFFSET p4, 2349*10000h, 304*10000h, 0,0,1>,
	<OFFSET p6, 2589*10000h, 208*10000h, 0,0,1>,
	<OFFSET p1, 3261*10000h, 368*10000h, 0,0,1>,
	<OFFSET p2, 3517*10000h, 240*10000h, 0,0,1>,
	<OFFSET p4, 3725*10000h, 432*10000h, 0,0,1>
platforms3 SPRITE <OFFSET p1, 3837*10000h, 303*10000h, 0,0,1>,
	<OFFSET p1, 4029*10000h, 303*10000h, 0,0,1>,
	<OFFSET p7, 4939*10000h, 447*10000h, 0,0,1>,
	<OFFSET p8, 4509*10000h, 352*10000h, 0,0,1>,
	<OFFSET p9, 4573*10000h, 320*10000h, 0,0,1>,
	<OFFSET p10, 4637*10000h, 288*10000h, 0,0,1>
ast SPRITE <OFFSET asteroid, 175 * 10000h, 390 * 10000h, 0, 0, 1>	; luke sprite
movplats SPRITE <OFFSET movplat, 1869*10000h, 176*10000h, 0,8*10000h,1>,	; moving platforms
	<OFFSET movplat, 2788*10000h, 176*10000h, 0,8*10000h,1>,
	<OFFSET movplat, 2941*10000h, 176*10000h, 0,12*10000h,1>,
	<OFFSET movplat, 3094*10000h, 176*10000h, 0,16*10000h,1>
j1 SPRITE <OFFSET jawal, 973*10000h, 141*10000h, -4*10000h,0,1>		; jawas sprites
j2 SPRITE <OFFSET jawal, 1453*10000h, 109*10000h, -4*10000h,0,1>
j3 SPRITE <OFFSET jawal, 2029*10000h, 397*10000h, -4*10000h,0,1>
j4 SPRITE <OFFSET jawal, 2221*10000h, 397*10000h, -4*10000h,0,1>
j5 SPRITE <OFFSET jawal, 2589*10000h, 173*10000h, -4*10000h,0,1>
j6 SPRITE <OFFSET jawal, 3261*10000h, 333*10000h, -4*10000h,0,1>
j7 SPRITE <OFFSET jawal, 3517*10000h, 205*10000h, -4*10000h,0,1>
j8 SPRITE <OFFSET jawal, 4029*10000h, 268*10000h, -4*10000h,0,1>
jawas JAWA <OFFSET j1, 894*10000h, 1052*10000h>,
	<OFFSET j2, 1342*10000h, 1564*10000h>,
	<OFFSET j3, 1950*10000h, 2108*10000h>,
	<OFFSET j4, 2142*10000h, 2300*10000h>,
	<OFFSET j5, 2494*10000h, 2684*10000h>,
	<OFFSET j6, 3198*10000h, 3324*10000h>,
	<OFFSET j7, 3390*10000h, 3644*10000h>,
	<OFFSET j8, 3966*10000h, 4092*10000h>
jump BYTE 0			; jump status (1=jumping)
victory BYTE 0		; win statsu (1=win)
paus BYTE 0			; pause status (1=paused)
frame DWORD 0		; frame counter for drawing sprites
str1 BYTE "YOU WIN!", 0											; text for pause / end screens
str2 BYTE "We will watch your career with great interest.", 0
str3 BYTE "[SPACE] to Play Again", 0
str4 BYTE "[SPACE] to Resume", 0

.CODE

MovJawa PROC USES eax edi esi jptr:PTR JAWA
	; moves the position of the given jawa, changing direction if necessary
	mov edi, [jptr]
	mov esi, [edi]
	mov eax, [esi+4]		; x
	add eax, [esi+12]		; x+xvel
	cmp eax, [edi+4]		; if (x+xvel) < xmin, change direction
	jle l_to_r
	cmp eax, [edi+8]		; if (x+xvel) > xmax, change direction
	jge r_to_l
	mov [esi+4], eax		; xchg
	jmp done
l_to_r:
	neg DWORD PTR [esi+12]	; change direction (l to r)
	mov [esi], OFFSET jawar
	jmp done
r_to_l:
	neg DWORD PTR [esi+12]	; change direction (r to l)
	mov [esi], OFFSET jawal
done:
	ret
MovJawa ENDP

CheckJawa PROC USES eax ebx ecx edx edi esi sprp:PTR SPRITE
	; checks whether the given jawa intersects luke, determines if luke or the jawa dies
	mov esi, [sprp]
	mov edi, [esi]		; jawa bitmap
	mov ecx, [esi+4]	; jawa.x
	mov edx, [esi+8]	; jawa.y
	mov eax, ast.xcen	; luke.x
	mov ebx, ast.ycen	; luke.y
	sar eax, 16
	sar ebx, 16
	sar ecx, 16
	sar edx, 16
	INVOKE CheckIntersect, eax, ebx, ast.bitp, ecx, edx, edi
	cmp eax, 0
	je done				; if not intersecting, done
	sub edx, 45
	mov ecx, ast.yvel
	sar ecx, 16
	sub ebx, ecx
	cmp ebx, edx
	jg death
	mov BYTE PTR [esi+20], 0	; if luke is above jawa, jawa dies
	jmp done
death:
	mov ast.stat, 0		; if luke is beside jawa, luke dies (game over)
done:
	ret
CheckJawa ENDP

DrawSprite PROC USES eax ebx ecx esi sprp:PTR SPRITE
	; draws the given sprite at (sprite.xcen, sprite.ycen)
	mov esi, [sprp]
	mov ecx, [esi]
	mov eax, 0
	mov al, [esi+20]
	cmp al, 0			; if status == 0: done
	je done
	mov eax, [esi+4]
	mov ebx, [esi+8]
	sar eax, 16
	sar ebx, 16
	add eax, frame
	INVOKE BasicBlit, ecx, eax, ebx		; draw sprite
done:
	ret
DrawSprite ENDP

Jumping PROC USES eax ebx ecx edx
	; handles all luke jump functionality and all platform interaction
	; specifically, checks whether luke intersects all platforms and checks whether he's jumping
	mov ecx, ast.xcen
	mov ebx, ast.ycen
	add ecx, ast.xvel
	sar ecx, 16
	add ebx, ast.yvel
	sar ebx, 16
	
	; check whether luke intersects platforms in platforms array
	mov edi, 0
check:
	mov eax, (SPRITE PTR [platforms + edi]).xcen
	mov edx, (SPRITE PTR [platforms + edi]).ycen
	mov esi, (SPRITE PTR [platforms + edi]).bitp
	sar eax, 16
	sar edx, 16
	INVOKE CheckIntersect, ecx, ebx, ast.bitp, eax, edx, esi
	cmp eax, 1
	je above_or_below
	add edi, TYPE SPRITE
	cmp edi, SIZEOF platforms
	jl check

	; check whether luke intersects platforms in platforms2 array
	mov edi, 0
check2:
	mov eax, (SPRITE PTR [platforms2 + edi]).xcen
	mov edx, (SPRITE PTR [platforms2 + edi]).ycen
	mov esi, (SPRITE PTR [platforms2 + edi]).bitp
	sar eax, 16
	sar edx, 16
	INVOKE CheckIntersect, ecx, ebx, ast.bitp, eax, edx, esi
	cmp eax, 1
	je above_or_below
	add edi, TYPE SPRITE
	cmp edi, SIZEOF platforms2
	jl check2
	
	; check whether luke intersects platforms in platforms3 array
	mov edi, 0
check3:
	mov eax, (SPRITE PTR [platforms3 + edi]).xcen
	mov edx, (SPRITE PTR [platforms3 + edi]).ycen
	mov esi, (SPRITE PTR [platforms3 + edi]).bitp
	sar eax, 16
	sar edx, 16
	INVOKE CheckIntersect, ecx, ebx, ast.bitp, eax, edx, esi
	cmp eax, 1
	je above_or_below
	add edi, TYPE SPRITE
	cmp edi, SIZEOF platforms3
	jl check3
	
	; check whether luke intersects moving platforms
	mov edi, 0
check_movs:
	mov eax, (SPRITE PTR [movplats + edi]).xcen
	mov edx, (SPRITE PTR [movplats + edi]).ycen
	mov esi, (SPRITE PTR [movplats + edi]).bitp
	sar eax, 16
	sar edx, 16
	INVOKE CheckIntersect, ecx, ebx, ast.bitp, eax, edx, esi
	cmp eax, 1
	je aob_movs
	add edi, TYPE SPRITE
	cmp edi, SIZEOF movplats
	jl check_movs
	jmp finished
aob_movs:
	mov ast.yvel, 0
	sal edx, 16
	cmp ast.ycen, edx
	jg below
	mov jump, 0			; if luke is intersecting/above moving platform, he lands on it
	mov ecx, [esi+4]
	sal ecx, 15
	mov ebx, [ast.bitp]
	mov edi, [ebx+4]
	sal edi, 15
	add ecx, edi
	sub edx, ecx
	add edx, 100000h
	mov ast.ycen, edx
	jmp next
finished:
	mov jump, 1
	jmp next
above_or_below:
	mov ast.yvel, 0		; check whether luke is above or below the intersecting platform
	sal edx, 16
	cmp ast.ycen, edx
	jle above
below:
	mov ast.yvel, 0		; if luke is below platform, his head bounces off it and he descends
	mov ecx, [esi+4]
	sal ecx, 15
	mov ebx, [ast.bitp]
	mov edi, [ebx+4]
	sal edi, 15
	add ecx, edi
	add edx, ecx
	mov ast.ycen, edx
	jmp next
above:
	mov jump, 0			; if luke is above platform, he lands on it
	mov ecx, [esi+4]
	sal ecx, 15
	mov ebx, [ast.bitp]
	mov edi, [ebx+4]
	sal edi, 15
	add ecx, edi
	sub edx, ecx
	add edx, 10000h
	mov ast.ycen, edx
next:
	cmp jump, 0			; if luke is jumping, add 8 to his velocity (accel. due to gravity)
	je check_key
	add ast.yvel, 80000h
	jmp done
check_key:
	cmp KeyPress, VK_UP	; if luke is not jumping and UP key is pressed, he starts jumping (w/ inital velo.)
	jne done
	mov eax, -48
	shl eax, 16
	mov ast.yvel, eax
	mov jump, 1
done:
	cmp jump, 0
	je finish
	mov ast.xvel, 8*10000h	; if luke is jumping, his x position moves forward at a constant rate
finish:
	mov eax, ast.xvel	; luke.x += luke.xvel
	add ast.xcen, eax
	mov ebx, ast.yvel	; luke.y += luke.yvel
	add ast.ycen, ebx
	ret
Jumping ENDP

MovPl PROC uses eax ebx esi sprp:PTR SPRITE
	; moves the moving platforms, flipping their direction if necessary
	mov esi, [sprp]
	mov eax, [esi+16]
	add DWORD PTR [esi+8], eax	; movplat.y += movplat.yvel
	mov ebx, [esi+8]
	cmp eax, 0
	jl upper
	cmp ebx, 424*10000h		; if movplat.y > 432, set it there and reverse direction
	jl upper
	mov DWORD PTR [esi+8], 432*10000h
	neg DWORD PTR [esi+16]
	jmp done
upper:
	cmp eax, 0
	jg done
	cmp ebx, 168*10000h		; if movplat.y < 168, set it there and reverse direction
	jg done
	mov DWORD PTR [esi+8], 176*10000h
	neg DWORD PTR [esi+16]
done:
	ret
MovPl ENDP

GameOver PROC
	; resets all sprites and restarts the game when luke dies
	mov ast.xcen, 175*10000h	; reset luke position
	mov ast.ycen, 390*10000h
	mov ast.stat, 1
	mov frame, 0
	mov edi, OFFSET jawas
jawa_reset:
	mov esi, [edi]
	mov BYTE PTR [esi+20], 1	; activate all jawas
	add edi, TYPE jawas
	cmp edi, OFFSET jawas + SIZEOF jawas
	jl jawa_reset
	ret
GameOver ENDP

GameInit PROC
	cld
	mov ecx, 307200
	mov esi, tatooine.lpBytes
	mov edi, ScreenBitsPtr
	rep movsb							; draw background
	INVOKE DrawSprite, OFFSET mapdraw	; draw initial map
	INVOKE DrawSprite, OFFSET ast		; draw initial luke
	
	mov edi, OFFSET jawas
jawa_draw:								; draw initial jawas
	mov esi, [edi]
	INVOKE DrawSprite, esi
	add edi, TYPE jawas
	cmp edi, OFFSET jawas + SIZEOF jawas
	jl jawa_draw

	mov edi, OFFSET movplats
moving_draw:							; draw initial moving platforms
	INVOKE DrawSprite, edi
	add edi, TYPE movplats
	cmp edi, OFFSET movplats + SIZEOF movplats
	jl moving_draw
	ret
GameInit ENDP

GamePlay PROC
	cld
	mov ecx, 307200
	mov esi, tatooine.lpBytes
	mov edi, ScreenBitsPtr
	rep movsb							; draw background
over_checks:
	cmp victory, 0						; if the player won, draw the end screen & text
	je resume
	INVOKE DrawStr, OFFSET str1, 285, 140, 0ffh
	INVOKE DrawStr, OFFSET str2, 140, 170, 0ffh
	INVOKE DrawStr, OFFSET str3, 235, 410, 0ffh
	INVOKE BasicBlit, OFFSET asteroid, 319, 360
	cmp KeyPress, VK_SPACE				; if the player wants to play again, call GameOver to reset
	jne donee
	mov victory, 0
	INVOKE GameOver
	jmp donee
resume:
	cmp ast.ycen, 500*10000h			; if luke fell off the screen, call GameOver
	jg g_o
	cmp ast.stat, 1
	je winner
g_o:
	INVOKE GameOver
	jmp donee
winner:
	cmp ast.xcen, 4939*10000h			; if luke reached the end, set the victory flag
	jl maybe_pause
	mov victory, 1
	jmp donee
maybe_pause:
	cmp KeyPress, VK_SHIFT				; if player presses shift, don't increment frame to pause all sprites
	jne pause_check
	mov paus, 1
pause_check:
	cmp paus, 0
	je frames
	cmp KeyPress, VK_SPACE
	jne skip
	mov paus, 0
	jmp skip
frames:
	cmp ast.xvel, 0
	je skip
	sub frame, 8						; increment frame to move the screen / sprites
skip:
	INVOKE DrawSprite, OFFSET mapdraw	; draw map
	INVOKE DrawSprite, OFFSET ast		; draw luke
	
	mov edi, OFFSET jawas
jawa_draw:
	mov esi, [edi]
	cmp BYTE PTR [esi+20], 0
	je dontjmove
	INVOKE CheckJawa, esi				; check jawa intersections
	INVOKE DrawSprite, esi				; draw jawas
	cmp paus, 1
	je dontjmove
	INVOKE MovJawa, edi					; move jawas
dontjmove:
	add edi, TYPE jawas
	cmp edi, OFFSET jawas + SIZEOF jawas
	jl jawa_draw

	mov edi, OFFSET movplats
moving_draw:
	INVOKE DrawSprite, edi				; draw moving platforms
	cmp paus, 1
	je dont_move
	INVOKE MovPl, edi					; move platforms
dont_move:
	add edi, TYPE movplats
	cmp edi, OFFSET movplats + SIZEOF movplats
	jl moving_draw

	cmp paus, 0
	je rest_of_draw
	INVOKE DrawStr, OFFSET str4, 240, 170, 0ffh		; if pause, draw pause text
	jmp donee

rest_of_draw:
	INVOKE Jumping						; call Jumping to handle luke jumping / intersections

	cmp KeyPress, VK_RIGHT
	jne done
	mov ast.xvel, 8*10000h				; if player pressing right, move luke to the right
	jmp donee
done:
	cmp jump, 1
	je donee
	mov ast.xvel, 0						; if not jump or pressing right, luke.xvel = 0
donee:
	ret
GamePlay ENDP

CheckIntersect PROC USES edi esi oneX:DWORD, oneY:DWORD, oneBitmap:PTR EECS205BITMAP, twoX:DWORD, twoY:DWORD, twoBitmap:PTR EECS205BITMAP
	LOCAL oneLeft:DWORD, oneRight:DWORD, oneTop:DWORD, oneBottom:DWORD, twoLeft:DWORD, twoRight:DWORD, twoTop:DWORD, twoBottom:DWORD
	
	mov esi, oneBitmap
	
	mov edi, [esi]
	shr edi, 1
	mov eax, oneX
	mov oneLeft, eax
	sub oneLeft, edi	; oneLeft = one.x - one.width/2
	mov oneRight, eax
	add oneRight, edi	; oneRight = one.x + one.width/2
	
	mov edi, [esi+4]
	shr edi, 1
	mov eax, oneY
	mov oneTop, eax
	sub oneTop, edi		; oneTop = one.y - one.height/2
	mov oneBottom, eax
	add oneBottom, edi	; oneBottom = one.y + one.height/2

	mov esi, twoBitmap
	
	mov edi, [esi]
	shr edi, 1
	mov eax, twoX
	mov twoLeft, eax
	sub twoLeft, edi	; twoLeft = two.x - two.width/2
	mov twoRight, eax
	add twoRight, edi	; twoRight = two.x + two.width/2
	
	mov edi, [esi+4]
	shr edi, 1
	mov eax, twoY
	mov twoTop, eax
	sub twoTop, edi		; twoTop = two.y - two.height/2
	mov twoBottom, eax
	add twoBottom, edi	; twoBottom = two.y + two.height/2

	mov eax, oneRight
	cmp eax, twoLeft	; if (oneRight < twoLeft ||
	jl done
	mov eax, twoRight
	cmp eax, oneLeft		; twoRight < oneLeft ||
	jl done
	mov eax, oneBottom
	cmp eax, twoTop			; oneBottom < twoTop ||
	jl done
	mov eax, twoBottom
	cmp eax, oneTop			; twoBottom < oneTop)
	jl done						; return 0
	mov eax, 1			; else
	ret							; return 1
done:
	mov eax, 0
	ret
CheckIntersect ENDP

END
