InitFakeCGA:
        movem.l d2-d6/a2, -(sp)

        ;; Prep pointers
        movea.l #$C00000, a0
        move.l  a0, a1
        addq.l  #4, a1

        ;; Set 64x64 scroll size and word increments.
        move.l  #$90118f02, (a1)

        ;; Load palette
        move.l  #$c0000000, (a1)
        movea.l #@CGAPal, a2
        moveq   #7, d0
@lp:    move.l  (a2)+, (a0)
        dbra    d0, @lp

        ;; Create characters
        move.l  #$40000000, (a1)
        move.w  #$1111, d0      ; half-row increment
        moveq   #15, d1         ; outer loop counter
        moveq   #$0, d3         ; left half
        moveq   #$0, d6         ; We'll need a zero
@lp2:   moveq   #15, d2         ; inner loop counter
        moveq   #$0, d4         ; right half
@lp3:   moveq   #3,  d5         ; innermost loop counter
@lp4:   move.w  d3, (a0)
        move.w  d4, (a0)
        dbra    d5, @lp4
        move.l  d6, (a0)
        move.l  d6, (a0)
        move.l  d6, (a0)
        move.l  d6, (a0)
        add.w   d0, d4
        dbra    d2, @lp3
        add.w   d0, d3
        dbra    d1, @lp2

        movem.l (sp)+, d2-d6/a2
        rts

@CGAPal:
        dc.w    $0000,$0A00,$00A0,$0AA0,$000A,$0A0A,$004A,$0AAA
        dc.w    $0666,$0E66,$06E6,$0EE6,$066E,$0E6E,$06EE,$0EEE

CGATestPattern:
        ;; Prep pointers
        movem.l d2-d3, -(sp)
        movea.l #$C00000, a0
        move.l  a0, a1
        addq.l  #4, a1

        ;; Start writing to C000 in VRAM
        move.l  #$40000003, (a1)

        ;; Fill Scroll A
        moveq   #$01, d0
        moveq   #63, d1         ; Row count
@lp1:   moveq   #63, d2         ; Column count
@lp2:   move.w  d0, (a0)
        bsr.s   @nextbyte
        dbra    d2, @lp2
        bsr.s   @nextbyte       ; Skip an extra unit for the missed row
        dbra    d1, @lp1

        ;; Fill Scroll B
        move.w  #$1012, d0
        moveq   #63, d1         ; Row count
@lp3:   moveq   #63, d2         ; Column count
@lp4:   move.w  d0, (a0)
        bsr.s   @nextbyte
        dbra    d2, @lp4
        bsr.s   @nextbyte       ; Skip an extra unit for the missed row
        dbra    d1, @lp3

        movem.l (sp)+, d2-d3
        rts
        ;; This miniroutine is part of CGATestPattern and trashes d3. Don't
        ;; tell any other routines about this, it's a secret to everyone
@nextbyte:
        move.b  d0, d3
        addq    #2, d3
        and.b   #$F0, d0
        and.b   #$0F, d3
        or.b    d3, d0
        add.b   #$20, d0
        rts
