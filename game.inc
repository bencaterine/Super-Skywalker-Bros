; #########################################################################
;
;   game.inc - Includes for CompEng205 Assignment 4/5
;
;
; #########################################################################

;; Library Definitions
MouseInfo STRUCT
 horiz DWORD ?
 vert  DWORD ?
 buttons DWORD ?
MouseInfo ENDS

MK_CONTROL  = 0008h  ;; The CTRL key is down.
MK_LBUTTON  = 0001h  ;; The left mouse button is down.
MK_MBUTTON  = 0010h  ;; The middle mouse button is down.
MK_RBUTTON  = 0002h  ;; The right mouse button is down.
MK_SHIFT    = 0004h  ;; The SHIFT key is down.
MK_XBUTTON1 = 0020h  ;; The first X button is down.
MK_XBUTTON2 = 0040h  ;; The second X button is down.

;; Library Functions
BlackStarField	PROTO
DrawStr PROTO myStr:PTR BYTE, x:DWORD, y:DWORD, color:DWORD

;; Library Data
EXTERNDEF StarBitmap:EECS205BITMAP
EXTERNDEF MouseStatus:MouseInfo
EXTERNDEF KeyUp:DWORD
EXTERNDEF KeyDown:DWORD
EXTERNDEF KeyPress:DWORD
EXTERNDEF asteroid:EECS205BITMAP
EXTERNDEF tatooine:EECS205BITMAP
EXTERNDEF movplat:EECS205BITMAP
EXTERNDEF jawal:EECS205BITMAP
EXTERNDEF jawar:EECS205BITMAP
EXTERNDEF map:EECS205BITMAP
EXTERNDEF p0:EECS205BITMAP
EXTERNDEF p1:EECS205BITMAP
EXTERNDEF p2:EECS205BITMAP
EXTERNDEF p3:EECS205BITMAP
EXTERNDEF p4:EECS205BITMAP
EXTERNDEF p5:EECS205BITMAP
EXTERNDEF p6:EECS205BITMAP
EXTERNDEF p7:EECS205BITMAP
EXTERNDEF p8:EECS205BITMAP
EXTERNDEF p9:EECS205BITMAP
EXTERNDEF p10:EECS205BITMAP

;; User Defined Functions
MovJawa PROTO jptr:PTR JAWA
CheckJawa PROTO sprp:PTR SPRITE
DrawSprite PROTO sprp:PTR SPRITE
Jumping PROTO
MovPl PROTO sprp:PTR SPRITE
GameOver PROTO
GameInit PROTO
GamePlay PROTO
CheckIntersect PROTO oneX:DWORD, oneY:DWORD, oneBitmap:PTR EECS205BITMAP, twoX:DWORD, twoY:DWORD, twoBitmap:PTR EECS205BITMAP 




