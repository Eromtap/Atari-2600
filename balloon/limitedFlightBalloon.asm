
	processor 6502
        include "vcs.h"
        include "macro.h"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variables segment
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        seg.u Variables
	org $80

P0XPos	byte	; sprite X coord defined

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Code segment
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	seg Code
        org $f000

Reset:
	CLEAN_START
        
        ldx #$a2	; blueish background
        stx COLUBK
        
;; Initialize variables
	lda #40
        sta P0XPos	; initialize player X coord
        
      
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start a new frame by configuring vblank and vsync        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
StartFrame:
	lda #2
        sta VBLANK	; turn on vblank and vsync
        sta VSYNC
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; display 3 vertical lines of vsync
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	REPEAT 3
        	sta WSYNC
        REPEND
        lda #0
        sta VSYNC	; turn off vsync
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set player horizontal position while we are in vblank
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	lda P0XPos	; load register A with X position
        and #$7F	; same as AND 01111111, forces bit 7 to zero
        		; keeping the value in A always positive (negative flag set to zero)
        
        sta WSYNC	; wait for next scanline
        sta HMCLR	; clear old horizontal position values
        
        sec
DivideLoop:
	sbc #15		; A -= 15
        bcs DivideLoop	; loop while carry flag is still set
        
        eor #7		; adjust the remainder in A between -8 and 7
        asl		; shift left by 4, as HMP0 uses only 4 bits
        asl
        asl
        asl
        sta HMP0	; Set fine position
        sta RESP0	; reset 15-step brute position
        sta WSYNC	; wait for next scanline
        sta HMOVE	; apply the fine position
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; let the TIA output the (37-2) recommended lines of vblank
;; 35 lines of vblank instead of 37 because we used 2 lines in the 
;; setup for the player horizontal position
;; WSYNC lines are the lines used
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
        REPEAT 35
        	sta WSYNC
        REPEND
        
        lda #0
        sta VBLANK	; turn vblank off
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; draw 192 visible scanlines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
        REPEAT 60
        	sta WSYNC
	REPEND
        
        ldy 8		; counter to draw 8 rows of bitmap
DrawBitmap:
	lda P0Bitmap,Y	; load player bitmap slice of data
        sta GRP0
        
        lda P0Color,Y	; load player color from lookup table
        sta COLUP0	; set player 0 slice color
        
        sta WSYNC	; wait for next scanline
        
        dey
        bne DrawBitmap	; repeat next scanline until finished
        
        lda #0
        sta GRP0	; disable P0 bitmap graphics
        
        REPEAT 124
        	sta WSYNC	; wait for remaining 124 empty scanlines
	REPEND                
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; oUTPUT 30 MORE LINES OF VBLANK FOR OVERSCAN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
Overscan:
	lda #2
        sta VBLANK
        REPEAT 30
        	sta WSYNC
	REPEND		                
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; increment X coord before next frame for animation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;         
	inc P0XPos
        lda P0XPos
        cmp #80
        beq Limit
        

	
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Loop to next frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;         
        jmp StartFrame
 
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; limit balloon to 40 - 80 pixel flight
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
Limit:
	lda #40
        sta P0XPos    
        jmp StartFrame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Player graphics bitmap table
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;         
P0Bitmap:
	byte #%00000000
        byte #%00010000
        byte #%00001000
        byte #%00011100
        byte #%00110110
        byte #%00101110
        byte #%00101110
        byte #%00111110
        byte #%00011100
        
        
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; lookup table for player colors
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
P0Color:
	byte #$52
        byte #$52
        byte #$52
        byte #$52
        byte #$52
        byte #$52
        byte #$52
        byte #$52
        

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Epilogue
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	org $fffc
        .word Reset	; reset vector
        .word Reset	; BRK vector







