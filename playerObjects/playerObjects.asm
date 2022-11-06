;; First attempt at player and scoreboard objects using 2 bitmaps. One for the scoreboard char "2" and one for player sprites


        processor 6502
        include "vcs.h"
        include "macro.h"




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Code segment

        seg Code
        org $f000               ; Begging of cartridge ROM

Reset
        CLEAN_START            ; Clear zero page memory

        ldx #$80               ; blue background color
        stx COLUBK
        
        lda #%1111 ; white playfield color
        sta COLUPF
        
        lda #$48      ; player 0 light red
        sta COLUP0
        
        lda #$c6       ; player 1 light green
        sta COLUP1
        
        ldy #%00000010       ; CTRLPF D1 set to 1 means score so scoreboard is same color as associated player
        sty CTRLPF
        
StartFrame:
        lda #2
        sta VBLANK ; turn on vsync and vblank
        sta VSYNC
        
        REPEAT 3
               sta WSYNC          ; first 3 vsync scanlies
        REPEND
        
        lda #0                           ; turn vsync off
        sta VSYNC
        
        
        REPEAT 37
               sta WSYNC          ; 37 vblank scanlines
        REPEND
        
        lda #0                    ; turn vblank off
        sta VBLANK
        
        
VisibleScanlines:
                ; Draw the 192 visible scanlines
        REPEAT 10
               sta WSYNC          ; Displays 10 lines for the scoreboard number
        REPEND                    ; pulls data from NumberBitmap
        

                ldy #0
ScoreboardLoop:
        lda NumberBitmap,Y      ; Draw scoreboard from numberbitmap
        sta PF1
        sta WSYNC
        iny
        cpy #10
        bne ScoreboardLoop
        
        lda #0
        sta PF1                         ; Disable playfield
        
        ; Draw 50 empty lines between scoreboard and players
        REPEAT 50
               sta WSYNC
        REPEND                
                
        ; Display 10 lines for player 0 graphics
        ; pulls data from playerbitmap
        ldy #0
Player0Loop:
        lda PlayerBitmap,Y
        sta GRP0
        sta WSYNC
        iny
        cpy #10
        bne Player0Loop
        
        lda #0
        sta GRP0
        
        
        ; Display 10 lines for player 1 graphics
        ; pulls from playerbitmap
        
        
        
        ldy #0
Player1Loop:
        lda PlayerBitmap,Y
        sta GRP1
        sta WSYNC
        iny
        cpy #10
        bne Player1Loop
        
        lda #0  
        sta GRP1     ; DISABLE player 1 graphics
        
        ; Draw remaing 102 scanlines since we already used 80 lines
       
        REPEAT 102
               sta WSYNC
        REPEND
        
        REPEAT 30
               sta WSYNC
        REPEND        
        
        jmp StartFrame
        
 
                org $FFE8               ; Store bitmap close to the end of the cartridge ROM
PlayerBitmap:                           ; Smiley face player bitmap
        .byte #%01111110   ;  ######
        .byte #%11111111   ; ########
        .byte #%10011001   ; #  ##  #
        .byte #%11111111   ; ########
        .byte #%11111111   ; ########
        .byte #%11111111   ; ########
        .byte #%10111101   ; # #### #
        .byte #%11000011   ; ##    ##
        .byte #%11111111   ; ########
        .byte #%01111110   ;  ###### 


                org $FFF2               ; store this bitmap in the last bit of space before end of cartridge ROM
NumberBitmap:                           ; Number '2' bitmap
        .byte #%00001110   ; ###
        .byte #%00001110   ; ###
        .byte #%00000010   ;   #
        .byte #%00000010   ;   #
        .byte #%00001110   ; ###
        .byte #%00001110   ; ###
        .byte #%00001000   ; #
        .byte #%00001000   ; #
        .byte #%00001110   ; ###
        .byte #%00001110   ; ###



        ; Complete ROM size
        org $FFFC
        .word Reset
        .word Reset










