; #########################################################################
;
;   blit.asm - Assembly file for CompEng205 Assignment 3
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


.DATA

	;; If you need to, you can place global variables here
	
.CODE

FixedMul2 PROC USES edx a:FXPT, b:FXPT
	mov eax, a
	imul b
	shl edx, 16
	shr eax, 16
	or eax, edx
	ret
FixedMul2 ENDP

DrawPixel PROC USES eax ebx ecx edx x:DWORD, y:DWORD, color:DWORD
	mov eax, y
	mov ebx, 640
	mul ebx
	add eax, x
	mov ebx, ScreenBitsPtr
	mov ecx, color
	mov BYTE PTR [ebx + eax], cl	; ScreenBits[y*640+x] = color
	ret
DrawPixel ENDP

BasicBlit PROC USES ebx ecx edx edi esi ebp ptrBitmap:PTR EECS205BITMAP , xcenter:DWORD, ycenter:DWORD
	LOCAL wwidth:DWORD, height:DWORD, transp:BYTE, bytes:DWORD, x0:DWORD, y0:DWORD
	
	mov edi, ptrBitmap
	mov eax, DWORD PTR [edi]
	mov wwidth, eax					; wwidth = bitmap.width
	mov eax, DWORD PTR [edi+4]
	mov height, eax					; height = bitmap.height
	mov al, BYTE PTR [edi+8]
	mov transp, al					; transp = bitmap.transparent
	mov eax, DWORD PTR [edi+12]
	mov bytes, eax					; bytes = bitmap.lpbytes
	
	mov eax, wwidth
	shr eax, 1
	mov ebx, xcenter
	mov x0, ebx
	sub x0, eax						; x0 = xcenter - (wwidth / 2)

	mov eax, height
	shr eax, 1
	mov ebx, ycenter
	mov y0, ebx
	sub y0, eax						; y0 = ycenter - (height / 2)
	
	mov eax, wwidth
	mov edi, 0						; for(i = 0; i < height; i++)
	jmp icond
ido:
	mov esi, 0						; for(j = 0; j < wwidth; j++)
	jmp jcond
jdo:
	mov ebx, x0
	add ebx, esi					; x = x0 - j
	mov ecx, y0
	add ecx, edi					; y = y0 - i
	
	cmp ebx, 639					; if(x > 639 ||
	jg skip_draw
	cmp ebx, 0							; x < 0 ||
	jl skip_draw
	cmp ecx, 479						; y > 479 ||
	jg skip_draw
	cmp ecx, 0							; y < 0)
	jl skip_draw							; skip draw
	
	mov eax, wwidth
	mul edi
	add eax, esi
	mov edx, 0
	mov ebx, bytes
	mov dl, BYTE PTR [ebx + eax]	; pixel (x, y)
	mov ebx, x0
	add ebx, esi
	cmp dl, transp					; if(pixel is transparent)
	je skip_draw						; skip draw
	INVOKE DrawPixel, ebx, ecx, edx	; DrawPixel(x, y, pixel)
skip_draw:
	inc esi
jcond:
	cmp esi, wwidth
	jl jdo
	inc edi
icond:
	cmp edi, height
	jl ido
	ret
BasicBlit ENDP


RotateBlit PROC lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:FXPT
	LOCAL sina:DWORD, cosa:DWORD, wwidth:DWORD, height:DWORD, transp:BYTE, bytes:DWORD, shiftX:SDWORD, shiftY:SDWORD, dest:DWORD
	
	INVOKE FixedSin, angle
	mov sina, eax					; sina = FixedSin(angle)
	INVOKE FixedCos, angle
	mov cosa, eax					; cosa = FixedCos(angle)
	mov esi, lpBmp					; esi = lpBitmap

	mov eax, DWORD PTR [esi]
	mov wwidth, eax					; wwidth = bitmap.width
	mov eax, DWORD PTR [esi+4]
	mov height, eax					; height = bitmap.height
	mov al, BYTE PTR [esi+8]
	mov transp, al					; transp = bitmap.transparent
	mov eax, DWORD PTR [esi+12]
	mov bytes, eax					; bytes = bitmap.lpbytes

	mov ebx, wwidth
	shl ebx, 16
	mov ecx, height
	shl ecx, 16
	
	INVOKE FixedMul2, ebx, cosa
	sar eax, 17
	mov shiftX, eax
	INVOKE FixedMul2, ecx, sina
	sar eax, 17
	sub shiftX, eax					; shiftX = wwidth * cosa / 2 - height * sina / 2

	INVOKE FixedMul2, ecx, cosa
	sar eax, 17
	mov shiftY, eax
	INVOKE FixedMul2, ebx, sina
	sar eax, 17
	add shiftY, eax					; shiftY = height * cosa / 2 + wwidth * sina / 2

	mov eax, wwidth
	add eax, height
	mov dest, eax					; dest = wwidth + height (= dstWidth = dstHeight)

	mov edi, dest
	neg edi							; for(dstX = -dest; dstX < wwidth; dstX++)
	jmp xcond
xdo:
	mov esi, dest
	neg esi							; for(dstY = -dest; dstY < height; dstY++)
	jmp ycond
ydo:
	mov ebx, edi
	shl ebx, 16
	INVOKE FixedMul2, ebx, cosa		; dstX*cosa
	mov ecx, eax

	INVOKE FixedMul2, ebx, sina		; dstX*sina
	neg eax
	mov edx, eax

	mov ebx, esi
	shl ebx, 16
	INVOKE FixedMul2, ebx, sina		; dstY*sina
	add ecx, eax
	sar ecx, 16

	INVOKE FixedMul2, ebx, cosa		; dstY*cosa
	add edx, eax
	sar edx, 16

	mov ebx, ecx					; srcX = dstX*cosa + dstY*sina
	mov eax, edx					; srcY = dstY*cosa - dstX*sina

	cmp ebx, 0						; if(!(srcX >= 0 &&
	jnge skipd
	cmp ebx, wwidth						; srcX < wwidth &&
	jnl skipd
	cmp eax, 0							; srcY >= 0 &&
	jnge skipd
	cmp eax, height						; srcY < height))
	jnl skipd								; skip draw

	mul wwidth
	add eax, ebx
	mov edx, 0
	mov ebx, bytes
	mov dl, BYTE PTR [ebx + eax]	; pixel (srcX, srcY)
	cmp dl, transp					; if(pixel is transparent)
	je skipd								; skip draw
	
	mov eax, xcenter
	add eax, edi
	sub eax, shiftX					; eax = xcenter+dstX-shiftX
	mov ebx, ycenter
	add ebx, esi
	sub ebx, shiftY					; ebx = ycenter+dstY-shiftY

	cmp eax, 0						; if(!(eax >= 0 &&
	jnge skipd
	cmp eax, 639						; eax < 639 &&
	jnl skipd
	cmp ebx, 0							; ebx >= 0 &&
	jnge skipd
	cmp ebx, 479						; ebx < 479))
	jnl skipd								; skip draw

	INVOKE DrawPixel, eax, ebx, edx	; DrawPixel(xcenter+dstX-shiftX, ycenter+dstY-shiftY, pixel)

skipd:
	inc esi
ycond:
	cmp esi, dest
	jl ydo
	inc edi
xcond:
	cmp edi, dest
	jl xdo
	ret
RotateBlit ENDP



END
