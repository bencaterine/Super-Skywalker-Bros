; #########################################################################
;
;   stars.asm - Assembly file for CompEng205 Assignment 1
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive


include stars.inc

.DATA

	;; If you need to, you can place global variables here

.CODE

DrawStarField proc
	
	;; BEN CATERINE

	invoke DrawStar, 30, 30		;; draw left goalpost
	invoke DrawStar, 30, 100
	invoke DrawStar, 30, 170
	invoke DrawStar, 30, 240

	invoke DrawStar, 310, 30	;; draw right goalpost
	invoke DrawStar, 310, 100
	invoke DrawStar, 310, 170
	invoke DrawStar, 310, 240
	
	invoke DrawStar, 100, 240	;; draw crossbar
	invoke DrawStar, 170, 240
	invoke DrawStar, 240, 240
	
	invoke DrawStar, 170, 310	;; draw support post
	invoke DrawStar, 170, 380
	invoke DrawStar, 170, 430
	
	invoke DrawStar, 170, 100	;; draw ball
	
	invoke DrawStar, 310, 430	;; draw kicker

	ret  			; Careful! Don't remove this line
DrawStarField endp



END
