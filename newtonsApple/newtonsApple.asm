
	processor 6502
        include "vcs.h"
        include "macro.h"
        include "xmacro.h"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Variables segment

  seg.u Variables
	org $80

P0Height	byte	; player sprite height
PlayerYPos	byte	; player sprite y coord

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Code segment

	seg Code
        org $f000

Reset
	CLEAN_START
        
        ldx #$00	; Black background color
        stx COLUBK

;; Initialize variables
	      lda #180
        sta PlayerYPos	; player y pose = 180
        
        lda #9
        sta P0Height	; player 0 height = 9
        
;; Start a new frame by configuring vblank and vsync
StartFrame:
	      lda #2
        sta VBLANK
        sta VSYNC
        
;; 3 LINES OF VSYNC
	REPEAT 3
		    sta WSYNC
        REPEND
        lda #0
        sta VSYNC	;turn off vsync
        
; 37 lines of vblank
	REPEAT 37
        	sta WSYNC
	REPEND
        
        lda #0
        sta VBLANK	; turn off vblank
        
        
;; Draw 192 visible scanlines

	      ldx #192	; X counter contains the remaining scanlines

Scanline:
	      txa		; transfer x to a
        sec		; make sure carry flag is set for subtraciton
        sbc PlayerYPos	; subtract sprite Y coord
        cmp P0Height	; are we inside the sprite height bounds?
        bcc LoadBitmap	; if result > SpriteHeight, call subroutine
        lda #0		; Else, set index to 0
        
LoadBitmap:
	      tay
        lda P0Bitmap,Y	; load player bitmap slice of data
        
        sta WSYNC	; wait for next scanline
        
        sta GRP0	; set graphics for player 0 slice
        
        lda P0Color,Y	; load player color from lookup table
        
        sta COLUP0	;set color for player 0 slice
        
        dex
        bne Scanline	; repeat next scanline until finished (x == 0)
        




;Overscan:
	      lda #2
        sta VBLANK
        REPEAT 30
        	sta WSYNC
        REPEND

;; Decrement y coor in each frame for falling animation
	dec PlayerYPos


;; Loop to next frame
        jmp StartFrame


;; Lookup tabled for player graphics bitmap

P0Bitmap:
	      byte #%00000000
        byte #%00101000
        byte #%01110100
        byte #%11111010
        byte #%11111010
        byte #%11111010
        byte #%11111110
        byte #%01101100
        byte #%00110000
        
        
        
;; Lookup table for player colors        
        
P0Color:
	byte #$00
        byte #$40
        byte #$40
        byte #$40
        byte #$40
        byte #$42
        byte #$42
        byte #$44
        byte #$D2






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Epilogue

	org $fffc
        .word Reset	; reset vector
        .word Reset	; BRK vector
