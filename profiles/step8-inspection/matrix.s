	.build_version macos, 26, 0	sdk_version 26, 4
	.section	__TEXT,__text,regular,pure_instructions
	.globl	__ZN9inference6MatrixC2Emm      ; -- Begin function _ZN9inference6MatrixC2Emm
	.p2align	2
__ZN9inference6MatrixC2Emm:             ; @_ZN9inference6MatrixC2Emm
Lfunc_begin0:
	.cfi_startproc
	.cfi_personality 155, ___gxx_personality_v0
	.cfi_lsda 16, Lexception0
; %bb.0:
	sub	sp, sp, #64
	stp	x22, x21, [sp, #16]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #32]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #48]             ; 16-byte Folded Spill
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	mov	x19, x0
	mov	x20, x0
	stp	xzr, xzr, [x20, #16]!
	str	xzr, [x20, #16]
	cbz	x2, LBB0_2
; %bb.1:
	mov	x8, #4611686018427387903        ; =0x3fffffffffffffff
	udiv	x8, x8, x2
	cmp	x1, x8
	b.hi	LBB0_5
LBB0_2:
	stp	x1, x2, [x19]
	mul	x1, x2, x1
	str	wzr, [sp, #12]
	cbz	x1, LBB0_4
; %bb.3:
Ltmp6:
	add	x2, sp, #12
	mov	x0, x20
	bl	__ZNSt3__16vectorIfNS_9allocatorIfEEE8__appendEmRKf
Ltmp7:
LBB0_4:
	mov	x0, x19
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #32]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #64
	ret
LBB0_5:
	mov	w0, #16                         ; =0x10
	bl	___cxa_allocate_exception
	mov	x22, x0
Ltmp0:
Lloh0:
	adrp	x1, l_.str@PAGE
Lloh1:
	add	x1, x1, l_.str@PAGEOFF
	bl	__ZNSt11logic_errorC2EPKc
Ltmp1:
; %bb.6:
Lloh2:
	adrp	x8, __ZTVSt12length_error@GOTPAGE
Lloh3:
	ldr	x8, [x8, __ZTVSt12length_error@GOTPAGEOFF]
	add	x8, x8, #16
	str	x8, [x22]
Ltmp3:
Lloh4:
	adrp	x1, __ZTISt12length_error@GOTPAGE
Lloh5:
	ldr	x1, [x1, __ZTISt12length_error@GOTPAGEOFF]
Lloh6:
	adrp	x2, __ZNSt12length_errorD1Ev@GOTPAGE
Lloh7:
	ldr	x2, [x2, __ZNSt12length_errorD1Ev@GOTPAGEOFF]
	mov	x0, x22
	bl	___cxa_throw
Ltmp4:
; %bb.7:
	brk	#0x1
LBB0_8:
Ltmp5:
	b	LBB0_11
LBB0_9:
Ltmp2:
	mov	x21, x0
	mov	x0, x22
	bl	___cxa_free_exception
	b	LBB0_12
LBB0_10:
Ltmp8:
LBB0_11:
	mov	x21, x0
LBB0_12:
	ldr	x0, [x20]
	cbz	x0, LBB0_14
; %bb.13:
	str	x0, [x19, #24]
	bl	__ZdlPv
LBB0_14:
	mov	x0, x21
	bl	__Unwind_Resume
	.loh AdrpAdd	Lloh0, Lloh1
	.loh AdrpLdrGot	Lloh6, Lloh7
	.loh AdrpLdrGot	Lloh4, Lloh5
	.loh AdrpLdrGot	Lloh2, Lloh3
Lfunc_end0:
	.cfi_endproc
	.section	__TEXT,__gcc_except_tab
	.p2align	2, 0x0
GCC_except_table0:
Lexception0:
	.byte	255                             ; @LPStart Encoding = omit
	.byte	255                             ; @TType Encoding = omit
	.byte	1                               ; Call site Encoding = uleb128
	.uleb128 Lcst_end0-Lcst_begin0
Lcst_begin0:
	.uleb128 Ltmp6-Lfunc_begin0             ; >> Call Site 1 <<
	.uleb128 Ltmp7-Ltmp6                    ;   Call between Ltmp6 and Ltmp7
	.uleb128 Ltmp8-Lfunc_begin0             ;     jumps to Ltmp8
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp7-Lfunc_begin0             ; >> Call Site 2 <<
	.uleb128 Ltmp0-Ltmp7                    ;   Call between Ltmp7 and Ltmp0
	.byte	0                               ;     has no landing pad
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp0-Lfunc_begin0             ; >> Call Site 3 <<
	.uleb128 Ltmp1-Ltmp0                    ;   Call between Ltmp0 and Ltmp1
	.uleb128 Ltmp2-Lfunc_begin0             ;     jumps to Ltmp2
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp3-Lfunc_begin0             ; >> Call Site 4 <<
	.uleb128 Ltmp4-Ltmp3                    ;   Call between Ltmp3 and Ltmp4
	.uleb128 Ltmp5-Lfunc_begin0             ;     jumps to Ltmp5
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp4-Lfunc_begin0             ; >> Call Site 5 <<
	.uleb128 Lfunc_end0-Ltmp4               ;   Call between Ltmp4 and Lfunc_end0
	.byte	0                               ;     has no landing pad
	.byte	0                               ;   On action: cleanup
Lcst_end0:
	.p2align	2, 0x0
                                        ; -- End function
	.section	__TEXT,__text,regular,pure_instructions
	.private_extern	__ZNSt12length_errorC1B9nqe210106EPKc ; -- Begin function _ZNSt12length_errorC1B9nqe210106EPKc
	.globl	__ZNSt12length_errorC1B9nqe210106EPKc
	.weak_def_can_be_hidden	__ZNSt12length_errorC1B9nqe210106EPKc
	.p2align	2
__ZNSt12length_errorC1B9nqe210106EPKc:  ; @_ZNSt12length_errorC1B9nqe210106EPKc
	.cfi_startproc
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	bl	__ZNSt11logic_errorC2EPKc
Lloh8:
	adrp	x8, __ZTVSt12length_error@GOTPAGE
Lloh9:
	ldr	x8, [x8, __ZTVSt12length_error@GOTPAGEOFF]
	add	x8, x8, #16
	str	x8, [x0]
	ldp	x29, x30, [sp], #16             ; 16-byte Folded Reload
	ret
	.loh AdrpLdrGot	Lloh8, Lloh9
	.cfi_endproc
                                        ; -- End function
	.globl	__ZN9inference6MatrixC1Emm      ; -- Begin function _ZN9inference6MatrixC1Emm
	.p2align	2
__ZN9inference6MatrixC1Emm:             ; @_ZN9inference6MatrixC1Emm
	.cfi_startproc
; %bb.0:
	b	__ZN9inference6MatrixC2Emm
	.cfi_endproc
                                        ; -- End function
	.globl	__ZN9inference6MatrixaSERKS0_   ; -- Begin function _ZN9inference6MatrixaSERKS0_
	.p2align	2
__ZN9inference6MatrixaSERKS0_:          ; @_ZN9inference6MatrixaSERKS0_
	.cfi_startproc
; %bb.0:
	stp	x26, x25, [sp, #-80]!           ; 16-byte Folded Spill
	stp	x24, x23, [sp, #16]             ; 16-byte Folded Spill
	stp	x22, x21, [sp, #32]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #48]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #64]             ; 16-byte Folded Spill
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	mov	x19, x0
	cmp	x0, x1
	b.eq	LBB3_6
; %bb.1:
	ldp	x23, x24, [x1]
	ldp	x21, x8, [x1, #16]
	subs	x22, x8, x21
	b.eq	LBB3_7
; %bb.2:
	tbnz	x22, #63, LBB3_8
; %bb.3:
	mov	x0, x22
	bl	__Znwm
	mov	x20, x0
	add	x25, x0, x22
	mov	x1, x21
	mov	x2, x22
	bl	_memcpy
	stp	x23, x24, [x19]
	mov	x21, x19
	ldr	x0, [x21, #16]!
	cbz	x0, LBB3_5
LBB3_4:
	str	x0, [x19, #24]
	bl	__ZdlPv
	stp	xzr, xzr, [x21]
	str	xzr, [x21, #16]
LBB3_5:
	stp	x20, x25, [x19, #16]
	str	x25, [x19, #32]
LBB3_6:
	mov	x0, x19
	ldp	x29, x30, [sp, #64]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #48]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #32]             ; 16-byte Folded Reload
	ldp	x24, x23, [sp, #16]             ; 16-byte Folded Reload
	ldp	x26, x25, [sp], #80             ; 16-byte Folded Reload
	ret
LBB3_7:
	mov	x20, #0                         ; =0x0
	mov	x25, #0                         ; =0x0
	stp	x23, x24, [x19]
	mov	x21, x19
	ldr	x0, [x21, #16]!
	cbnz	x0, LBB3_4
	b	LBB3_5
LBB3_8:
	bl	__ZNSt3__16vectorIfNS_9allocatorIfEEE20__throw_length_errorB9nqe210106Ev
	.cfi_endproc
                                        ; -- End function
	.globl	__ZN9inference6MatrixaSEOS0_    ; -- Begin function _ZN9inference6MatrixaSEOS0_
	.p2align	2
__ZN9inference6MatrixaSEOS0_:           ; @_ZN9inference6MatrixaSEOS0_
	.cfi_startproc
; %bb.0:
	cmp	x0, x1
	b.eq	LBB4_4
; %bb.1:
	stp	x22, x21, [sp, #-48]!           ; 16-byte Folded Spill
	stp	x20, x19, [sp, #16]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	mov	x19, x1
	ldr	q0, [x1]
	str	q0, [x0]
	mov	x20, x0
	ldr	x8, [x20, #16]!
	cbz	x8, LBB4_3
; %bb.2:
	str	x8, [x0, #24]
	mov	x21, x0
	mov	x0, x8
	bl	__ZdlPv
	mov	x0, x21
	stp	xzr, xzr, [x20]
	str	xzr, [x20, #16]
LBB4_3:
	ldr	q0, [x19, #16]
	str	q0, [x0, #16]
	ldr	x8, [x19, #32]
	str	x8, [x0, #32]
	str	xzr, [x19, #32]
	movi.2d	v0, #0000000000000000
	stp	q0, q0, [x19]
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp], #48             ; 16-byte Folded Reload
LBB4_4:
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	__ZN9inference6MatrixC2EOS0_    ; -- Begin function _ZN9inference6MatrixC2EOS0_
	.p2align	2
__ZN9inference6MatrixC2EOS0_:           ; @_ZN9inference6MatrixC2EOS0_
	.cfi_startproc
; %bb.0:
	ldr	q0, [x1]
	str	q0, [x0]
	stp	xzr, xzr, [x0, #24]
	str	xzr, [x0, #16]
	ldr	q0, [x1, #16]
	str	q0, [x0, #16]
	ldr	x8, [x1, #32]
	str	x8, [x0, #32]
	str	xzr, [x1, #32]
	movi.2d	v0, #0000000000000000
	stp	q0, q0, [x1]
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	__ZN9inference6MatrixC1EOS0_    ; -- Begin function _ZN9inference6MatrixC1EOS0_
	.p2align	2
__ZN9inference6MatrixC1EOS0_:           ; @_ZN9inference6MatrixC1EOS0_
	.cfi_startproc
; %bb.0:
	ldr	q0, [x1]
	str	q0, [x0]
	stp	xzr, xzr, [x0, #24]
	str	xzr, [x0, #16]
	ldr	q0, [x1, #16]
	str	q0, [x0, #16]
	ldr	x8, [x1, #32]
	str	x8, [x0, #32]
	str	xzr, [x1, #32]
	movi.2d	v0, #0000000000000000
	stp	q0, q0, [x1]
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	__ZNK9inference6Matrix4rowsEv   ; -- Begin function _ZNK9inference6Matrix4rowsEv
	.p2align	2
__ZNK9inference6Matrix4rowsEv:          ; @_ZNK9inference6Matrix4rowsEv
	.cfi_startproc
; %bb.0:
	ldr	x0, [x0]
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	__ZNK9inference6Matrix4colsEv   ; -- Begin function _ZNK9inference6Matrix4colsEv
	.p2align	2
__ZNK9inference6Matrix4colsEv:          ; @_ZNK9inference6Matrix4colsEv
	.cfi_startproc
; %bb.0:
	ldr	x0, [x0, #8]
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	__ZN9inference6MatrixclEmm      ; -- Begin function _ZN9inference6MatrixclEmm
	.p2align	2
__ZN9inference6MatrixclEmm:             ; @_ZN9inference6MatrixclEmm
Lfunc_begin1:
	.cfi_startproc
	.cfi_personality 155, ___gxx_personality_v0
	.cfi_lsda 16, Lexception1
; %bb.0:
	stp	x20, x19, [sp, #-32]!           ; 16-byte Folded Spill
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	ldr	x8, [x0]
	cmp	x1, x8
	b.hs	LBB9_3
; %bb.1:
	ldr	x8, [x0, #8]
	cmp	x2, x8
	b.hs	LBB9_3
; %bb.2:
	mul	x8, x8, x1
	ldr	x9, [x0, #16]
	add	x8, x9, x8, lsl #2
	add	x0, x8, x2, lsl #2
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp], #32             ; 16-byte Folded Reload
	ret
LBB9_3:
	mov	w0, #16                         ; =0x10
	bl	___cxa_allocate_exception
	mov	x19, x0
Ltmp9:
Lloh10:
	adrp	x1, l_.str.1@PAGE
Lloh11:
	add	x1, x1, l_.str.1@PAGEOFF
	bl	__ZNSt12out_of_rangeC1B9nqe210106EPKc
Ltmp10:
; %bb.4:
	mov	x0, x19
	bl	__ZN9inference6MatrixclEmm.cold.1
LBB9_5:
Ltmp11:
	mov	x20, x0
	mov	x0, x19
	bl	___cxa_free_exception
	mov	x0, x20
	bl	__Unwind_Resume
	.loh AdrpAdd	Lloh10, Lloh11
Lfunc_end1:
	.cfi_endproc
	.section	__TEXT,__gcc_except_tab
	.p2align	2, 0x0
GCC_except_table9:
Lexception1:
	.byte	255                             ; @LPStart Encoding = omit
	.byte	255                             ; @TType Encoding = omit
	.byte	1                               ; Call site Encoding = uleb128
	.uleb128 Lcst_end1-Lcst_begin1
Lcst_begin1:
	.uleb128 Lfunc_begin1-Lfunc_begin1      ; >> Call Site 1 <<
	.uleb128 Ltmp9-Lfunc_begin1             ;   Call between Lfunc_begin1 and Ltmp9
	.byte	0                               ;     has no landing pad
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp9-Lfunc_begin1             ; >> Call Site 2 <<
	.uleb128 Ltmp10-Ltmp9                   ;   Call between Ltmp9 and Ltmp10
	.uleb128 Ltmp11-Lfunc_begin1            ;     jumps to Ltmp11
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp10-Lfunc_begin1            ; >> Call Site 3 <<
	.uleb128 Lfunc_end1-Ltmp10              ;   Call between Ltmp10 and Lfunc_end1
	.byte	0                               ;     has no landing pad
	.byte	0                               ;   On action: cleanup
Lcst_end1:
	.p2align	2, 0x0
                                        ; -- End function
	.section	__TEXT,__text,regular,pure_instructions
	.private_extern	__ZNSt12out_of_rangeC1B9nqe210106EPKc ; -- Begin function _ZNSt12out_of_rangeC1B9nqe210106EPKc
	.globl	__ZNSt12out_of_rangeC1B9nqe210106EPKc
	.weak_def_can_be_hidden	__ZNSt12out_of_rangeC1B9nqe210106EPKc
	.p2align	2
__ZNSt12out_of_rangeC1B9nqe210106EPKc:  ; @_ZNSt12out_of_rangeC1B9nqe210106EPKc
	.cfi_startproc
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	bl	__ZNSt11logic_errorC2EPKc
Lloh12:
	adrp	x8, __ZTVSt12out_of_range@GOTPAGE
Lloh13:
	ldr	x8, [x8, __ZTVSt12out_of_range@GOTPAGEOFF]
	add	x8, x8, #16
	str	x8, [x0]
	ldp	x29, x30, [sp], #16             ; 16-byte Folded Reload
	ret
	.loh AdrpLdrGot	Lloh12, Lloh13
	.cfi_endproc
                                        ; -- End function
	.globl	__ZNK9inference6MatrixclEmm     ; -- Begin function _ZNK9inference6MatrixclEmm
	.p2align	2
__ZNK9inference6MatrixclEmm:            ; @_ZNK9inference6MatrixclEmm
Lfunc_begin2:
	.cfi_startproc
	.cfi_personality 155, ___gxx_personality_v0
	.cfi_lsda 16, Lexception2
; %bb.0:
	stp	x20, x19, [sp, #-32]!           ; 16-byte Folded Spill
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	ldr	x8, [x0]
	cmp	x1, x8
	b.hs	LBB11_3
; %bb.1:
	ldr	x8, [x0, #8]
	cmp	x2, x8
	b.hs	LBB11_3
; %bb.2:
	mul	x8, x8, x1
	ldr	x9, [x0, #16]
	add	x8, x9, x8, lsl #2
	add	x0, x8, x2, lsl #2
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp], #32             ; 16-byte Folded Reload
	ret
LBB11_3:
	mov	w0, #16                         ; =0x10
	bl	___cxa_allocate_exception
	mov	x19, x0
Ltmp12:
Lloh14:
	adrp	x1, l_.str.1@PAGE
Lloh15:
	add	x1, x1, l_.str.1@PAGEOFF
	bl	__ZNSt12out_of_rangeC1B9nqe210106EPKc
Ltmp13:
; %bb.4:
	mov	x0, x19
	bl	__ZNK9inference6MatrixclEmm.cold.1
LBB11_5:
Ltmp14:
	mov	x20, x0
	mov	x0, x19
	bl	___cxa_free_exception
	mov	x0, x20
	bl	__Unwind_Resume
	.loh AdrpAdd	Lloh14, Lloh15
Lfunc_end2:
	.cfi_endproc
	.section	__TEXT,__gcc_except_tab
	.p2align	2, 0x0
GCC_except_table11:
Lexception2:
	.byte	255                             ; @LPStart Encoding = omit
	.byte	255                             ; @TType Encoding = omit
	.byte	1                               ; Call site Encoding = uleb128
	.uleb128 Lcst_end2-Lcst_begin2
Lcst_begin2:
	.uleb128 Lfunc_begin2-Lfunc_begin2      ; >> Call Site 1 <<
	.uleb128 Ltmp12-Lfunc_begin2            ;   Call between Lfunc_begin2 and Ltmp12
	.byte	0                               ;     has no landing pad
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp12-Lfunc_begin2            ; >> Call Site 2 <<
	.uleb128 Ltmp13-Ltmp12                  ;   Call between Ltmp12 and Ltmp13
	.uleb128 Ltmp14-Lfunc_begin2            ;     jumps to Ltmp14
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp13-Lfunc_begin2            ; >> Call Site 3 <<
	.uleb128 Lfunc_end2-Ltmp13              ;   Call between Ltmp13 and Lfunc_end2
	.byte	0                               ;     has no landing pad
	.byte	0                               ;   On action: cleanup
Lcst_end2:
	.p2align	2, 0x0
                                        ; -- End function
	.section	__TEXT,__text,regular,pure_instructions
	.globl	__ZN9inference6Matrix4dataEv    ; -- Begin function _ZN9inference6Matrix4dataEv
	.p2align	2
__ZN9inference6Matrix4dataEv:           ; @_ZN9inference6Matrix4dataEv
	.cfi_startproc
; %bb.0:
	ldr	x0, [x0, #16]
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	__ZNK9inference6Matrix4dataEv   ; -- Begin function _ZNK9inference6Matrix4dataEv
	.p2align	2
__ZNK9inference6Matrix4dataEv:          ; @_ZNK9inference6Matrix4dataEv
	.cfi_startproc
; %bb.0:
	ldr	x0, [x0, #16]
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	__ZN9inference16matmul_referenceERKNS_6MatrixES2_ ; -- Begin function _ZN9inference16matmul_referenceERKNS_6MatrixES2_
	.p2align	2
__ZN9inference16matmul_referenceERKNS_6MatrixES2_: ; @_ZN9inference16matmul_referenceERKNS_6MatrixES2_
Lfunc_begin3:
	.cfi_startproc
	.cfi_personality 155, ___gxx_personality_v0
	.cfi_lsda 16, Lexception3
; %bb.0:
	stp	x24, x23, [sp, #-64]!           ; 16-byte Folded Spill
	stp	x22, x21, [sp, #16]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #32]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #48]             ; 16-byte Folded Spill
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	mov	x19, x8
	ldr	x8, [x0, #8]
	ldr	x9, [x1]
	cmp	x8, x9
	b.ne	LBB14_43
; %bb.1:
	mov	x20, x1
	mov	x21, x0
	ldr	x1, [x0]
	ldr	x2, [x20, #8]
	mov	x0, x19
	bl	__ZN9inference6MatrixC2Emm
	ldr	x22, [x19]
	cbz	x22, LBB14_17
; %bb.2:
	ldr	x8, [x19, #8]
	cbz	x8, LBB14_17
; %bb.3:
	ldr	x9, [x20]
	cbz	x9, LBB14_15
; %bb.4:
	sub	x10, x9, #1
	cmp	x9, #4
	b.hs	LBB14_18
; %bb.5:
	mov	x11, #0                         ; =0x0
	mov	x12, #0                         ; =0x0
	lsl	x13, x8, #2
	movi.2d	v0, #0000000000000000
	b	LBB14_7
LBB14_6:                                ;   in Loop: Header=BB14_7 Depth=1
	add	x12, x12, #1
	add	x11, x11, x13
	cmp	x12, x22
	b.eq	LBB14_17
LBB14_7:                                ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB14_10 Depth 2
	ldr	x14, [x21]
	cmp	x12, x14
	b.hs	LBB14_39
; %bb.8:                                ;   in Loop: Header=BB14_7 Depth=1
	mov	x14, #0                         ; =0x0
	ldr	x15, [x19, #16]
	add	x15, x15, x11
	b	LBB14_10
LBB14_9:                                ;   in Loop: Header=BB14_10 Depth=2
	str	s1, [x15, x14, lsl #2]
	add	x14, x14, #1
	cmp	x8, x14
	b.eq	LBB14_6
LBB14_10:                               ;   Parent Loop BB14_7 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ldr	x3, [x21, #8]
	ldr	x16, [x20, #8]
	cmp	x14, x16
	b.hs	LBB14_38
; %bb.11:                               ;   in Loop: Header=BB14_10 Depth=2
	cmp	x3, x10
	b.ls	LBB14_39
; %bb.12:                               ;   in Loop: Header=BB14_10 Depth=2
	ldr	x17, [x21, #16]
	mul	x0, x3, x12
	add	x17, x17, x0, lsl #2
	ldr	x0, [x20, #16]
	ldr	s1, [x17]
	ldr	s2, [x0, x14, lsl #2]
	fmadd	s1, s1, s2, s0
	cmp	x9, #1
	b.eq	LBB14_9
; %bb.13:                               ;   in Loop: Header=BB14_10 Depth=2
	ldr	s2, [x17, #4]
	add	x1, x0, x16, lsl #2
	ldr	s3, [x1, x14, lsl #2]
	fmadd	s1, s2, s3, s1
	cmp	x9, #2
	b.eq	LBB14_9
; %bb.14:                               ;   in Loop: Header=BB14_10 Depth=2
	ldr	s2, [x17, #8]
	add	x16, x0, x16, lsl #3
	ldr	s3, [x16, x14, lsl #2]
	fmadd	s1, s2, s3, s1
	b	LBB14_9
LBB14_15:
	mov	x21, #0                         ; =0x0
	lsl	x20, x8, #2
LBB14_16:                               ; =>This Inner Loop Header: Depth=1
	ldr	x8, [x19, #16]
	add	x0, x8, x21
	mov	x1, x20
	bl	_bzero
	add	x21, x21, x20
	subs	x22, x22, #1
	b.ne	LBB14_16
LBB14_17:
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #32]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #16]             ; 16-byte Folded Reload
	ldp	x24, x23, [sp], #64             ; 16-byte Folded Reload
	ret
LBB14_18:
	mov	x11, #0                         ; =0x0
	mov	x12, #0                         ; =0x0
	and	x13, x9, #0xfffffffffffffff0
	and	x14, x9, #0xc
	and	x15, x9, #0xfffffffffffffffc
	neg	x16, x15
	b	LBB14_20
LBB14_19:                               ;   in Loop: Header=BB14_20 Depth=1
	add	x12, x12, #1
	add	x11, x11, #4
	cmp	x12, x22
	b.eq	LBB14_17
LBB14_20:                               ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB14_23 Depth 2
                                        ;       Child Loop BB14_30 Depth 3
                                        ;       Child Loop BB14_34 Depth 3
                                        ;       Child Loop BB14_37 Depth 3
	ldr	x17, [x21]
	cmp	x12, x17
	b.hs	LBB14_39
; %bb.21:                               ;   in Loop: Header=BB14_20 Depth=1
	mov	x17, #0                         ; =0x0
	mov	x0, #0                          ; =0x0
	mul	x1, x8, x12
	ldr	x2, [x19, #16]
	add	x1, x2, x1, lsl #2
	mov	w2, #32                         ; =0x20
	b	LBB14_23
LBB14_22:                               ;   in Loop: Header=BB14_23 Depth=2
	str	s0, [x1, x0, lsl #2]
	add	x0, x0, #1
	add	x2, x2, #4
	add	x17, x17, #4
	cmp	x0, x8
	b.eq	LBB14_19
LBB14_23:                               ;   Parent Loop BB14_20 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB14_30 Depth 3
                                        ;       Child Loop BB14_34 Depth 3
                                        ;       Child Loop BB14_37 Depth 3
	ldr	x3, [x21, #8]
	ldr	x4, [x20, #8]
	cmp	x0, x4
	b.hs	LBB14_38
; %bb.24:                               ;   in Loop: Header=BB14_23 Depth=2
	cmp	x3, x10
	b.ls	LBB14_39
; %bb.25:                               ;   in Loop: Header=BB14_23 Depth=2
	ldr	x5, [x21, #16]
	ldr	x6, [x20, #16]
	cmp	x4, #1
	b.ne	LBB14_28
; %bb.26:                               ;   in Loop: Header=BB14_23 Depth=2
	cmp	x9, #16
	b.hs	LBB14_29
; %bb.27:                               ;   in Loop: Header=BB14_23 Depth=2
	mov	x24, #0                         ; =0x0
	movi.2d	v0, #0000000000000000
	b	LBB14_33
LBB14_28:                               ;   in Loop: Header=BB14_23 Depth=2
	mov	x23, #0                         ; =0x0
	movi.2d	v0, #0000000000000000
	b	LBB14_36
LBB14_29:                               ;   in Loop: Header=BB14_23 Depth=2
	madd	x7, x11, x3, x5
	add	x7, x7, #32
	add	x23, x6, x2
	movi.2d	v0, #0000000000000000
	mov	x24, x13
LBB14_30:                               ;   Parent Loop BB14_20 Depth=1
                                        ;     Parent Loop BB14_23 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	ldp	q1, q2, [x7, #-32]
	ldp	q3, q4, [x7], #64
	ldp	q5, q6, [x23, #-32]
	ldp	q7, q16, [x23], #64
	fmul.4s	v1, v1, v5
	mov	s5, v1[3]
	mov	s17, v1[2]
	mov	s18, v1[1]
	fmul.4s	v2, v2, v6
	mov	s6, v2[3]
	mov	s19, v2[2]
	mov	s20, v2[1]
	fmul.4s	v3, v3, v7
	mov	s7, v3[3]
	mov	s21, v3[2]
	mov	s22, v3[1]
	fmul.4s	v4, v4, v16
	mov	s16, v4[3]
	mov	s23, v4[2]
	mov	s24, v4[1]
	fadd	s0, s0, s1
	fadd	s0, s0, s18
	fadd	s0, s0, s17
	fadd	s0, s0, s5
	fadd	s0, s0, s2
	fadd	s0, s0, s20
	fadd	s0, s0, s19
	fadd	s0, s0, s6
	fadd	s0, s0, s3
	fadd	s0, s0, s22
	fadd	s0, s0, s21
	fadd	s0, s0, s7
	fadd	s0, s0, s4
	fadd	s0, s0, s24
	fadd	s0, s0, s23
	fadd	s0, s0, s16
	subs	x24, x24, #16
	b.ne	LBB14_30
; %bb.31:                               ;   in Loop: Header=BB14_23 Depth=2
	cmp	x9, x13
	b.eq	LBB14_22
; %bb.32:                               ;   in Loop: Header=BB14_23 Depth=2
	mov	x24, x13
	mov	x23, x13
	cbz	x14, LBB14_36
LBB14_33:                               ;   in Loop: Header=BB14_23 Depth=2
	add	x7, x16, x24
	lsl	x24, x24, #2
	add	x23, x17, x24
	add	x23, x6, x23
	madd	x24, x11, x3, x24
	add	x24, x5, x24
LBB14_34:                               ;   Parent Loop BB14_20 Depth=1
                                        ;     Parent Loop BB14_23 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	ldr	q1, [x24], #16
	ldr	q2, [x23], #16
	fmul.4s	v1, v1, v2
	mov	s2, v1[3]
	mov	s3, v1[2]
	mov	s4, v1[1]
	fadd	s0, s0, s1
	fadd	s0, s0, s4
	fadd	s0, s0, s3
	fadd	s0, s0, s2
	adds	x7, x7, #4
	b.ne	LBB14_34
; %bb.35:                               ;   in Loop: Header=BB14_23 Depth=2
	mov	x23, x15
	cmp	x9, x15
	b.eq	LBB14_22
LBB14_36:                               ;   in Loop: Header=BB14_23 Depth=2
	sub	x7, x9, x23
	lsl	x23, x23, #2
	madd	x6, x23, x4, x6
	lsl	x4, x4, #2
	madd	x3, x11, x3, x23
	add	x3, x5, x3
LBB14_37:                               ;   Parent Loop BB14_20 Depth=1
                                        ;     Parent Loop BB14_23 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	ldr	s1, [x3], #4
	ldr	s2, [x6, x17]
	fmadd	s0, s1, s2, s0
	add	x6, x6, x4
	subs	x7, x7, #1
	b.ne	LBB14_37
	b	LBB14_22
LBB14_38:
	cbnz	x3, LBB14_40
LBB14_39:
	mov	w0, #16                         ; =0x10
	bl	___cxa_allocate_exception
	mov	x21, x0
Ltmp21:
Lloh16:
	adrp	x1, l_.str.1@PAGE
Lloh17:
	add	x1, x1, l_.str.1@PAGEOFF
	bl	__ZNSt11logic_errorC2EPKc
Ltmp22:
	b	LBB14_41
LBB14_40:
	mov	w0, #16                         ; =0x10
	bl	___cxa_allocate_exception
	mov	x21, x0
Ltmp18:
Lloh18:
	adrp	x1, l_.str.1@PAGE
Lloh19:
	add	x1, x1, l_.str.1@PAGEOFF
	bl	__ZNSt11logic_errorC2EPKc
Ltmp19:
LBB14_41:
Lloh20:
	adrp	x8, __ZTVSt12out_of_range@GOTPAGE
Lloh21:
	ldr	x8, [x8, __ZTVSt12out_of_range@GOTPAGEOFF]
	add	x8, x8, #16
	str	x8, [x21]
Ltmp24:
Lloh22:
	adrp	x1, __ZTISt12out_of_range@GOTPAGE
Lloh23:
	ldr	x1, [x1, __ZTISt12out_of_range@GOTPAGEOFF]
Lloh24:
	adrp	x2, __ZNSt12out_of_rangeD1Ev@GOTPAGE
Lloh25:
	ldr	x2, [x2, __ZNSt12out_of_rangeD1Ev@GOTPAGEOFF]
	mov	x0, x21
	bl	___cxa_throw
Ltmp25:
; %bb.42:
	brk	#0x1
LBB14_43:
	mov	w0, #16                         ; =0x10
	bl	___cxa_allocate_exception
	mov	x19, x0
Ltmp15:
Lloh26:
	adrp	x1, l_.str.2@PAGE
Lloh27:
	add	x1, x1, l_.str.2@PAGEOFF
	bl	__ZNSt16invalid_argumentC1B9nqe210106EPKc
Ltmp16:
; %bb.44:
	mov	x0, x19
	bl	__ZN9inference16matmul_referenceERKNS_6MatrixES2_.cold.1
LBB14_45:
Ltmp17:
	mov	x20, x0
	mov	x0, x19
	bl	___cxa_free_exception
	mov	x0, x20
	bl	__Unwind_Resume
LBB14_46:
Ltmp20:
	b	LBB14_48
LBB14_47:
Ltmp23:
LBB14_48:
	mov	x20, x0
	mov	x0, x21
	bl	___cxa_free_exception
	b	LBB14_50
LBB14_49:
Ltmp26:
	mov	x20, x0
LBB14_50:
	ldr	x0, [x19, #16]
	cbnz	x0, LBB14_52
; %bb.51:
	mov	x0, x20
	bl	__Unwind_Resume
LBB14_52:
	str	x0, [x19, #24]
	bl	__ZdlPv
	mov	x0, x20
	bl	__Unwind_Resume
	.loh AdrpAdd	Lloh16, Lloh17
	.loh AdrpAdd	Lloh18, Lloh19
	.loh AdrpLdrGot	Lloh24, Lloh25
	.loh AdrpLdrGot	Lloh22, Lloh23
	.loh AdrpLdrGot	Lloh20, Lloh21
	.loh AdrpAdd	Lloh26, Lloh27
Lfunc_end3:
	.cfi_endproc
	.section	__TEXT,__gcc_except_tab
	.p2align	2, 0x0
GCC_except_table14:
Lexception3:
	.byte	255                             ; @LPStart Encoding = omit
	.byte	255                             ; @TType Encoding = omit
	.byte	1                               ; Call site Encoding = uleb128
	.uleb128 Lcst_end3-Lcst_begin3
Lcst_begin3:
	.uleb128 Lfunc_begin3-Lfunc_begin3      ; >> Call Site 1 <<
	.uleb128 Ltmp21-Lfunc_begin3            ;   Call between Lfunc_begin3 and Ltmp21
	.byte	0                               ;     has no landing pad
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp21-Lfunc_begin3            ; >> Call Site 2 <<
	.uleb128 Ltmp22-Ltmp21                  ;   Call between Ltmp21 and Ltmp22
	.uleb128 Ltmp23-Lfunc_begin3            ;     jumps to Ltmp23
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp22-Lfunc_begin3            ; >> Call Site 3 <<
	.uleb128 Ltmp18-Ltmp22                  ;   Call between Ltmp22 and Ltmp18
	.byte	0                               ;     has no landing pad
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp18-Lfunc_begin3            ; >> Call Site 4 <<
	.uleb128 Ltmp19-Ltmp18                  ;   Call between Ltmp18 and Ltmp19
	.uleb128 Ltmp20-Lfunc_begin3            ;     jumps to Ltmp20
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp24-Lfunc_begin3            ; >> Call Site 5 <<
	.uleb128 Ltmp25-Ltmp24                  ;   Call between Ltmp24 and Ltmp25
	.uleb128 Ltmp26-Lfunc_begin3            ;     jumps to Ltmp26
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp25-Lfunc_begin3            ; >> Call Site 6 <<
	.uleb128 Ltmp15-Ltmp25                  ;   Call between Ltmp25 and Ltmp15
	.byte	0                               ;     has no landing pad
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp15-Lfunc_begin3            ; >> Call Site 7 <<
	.uleb128 Ltmp16-Ltmp15                  ;   Call between Ltmp15 and Ltmp16
	.uleb128 Ltmp17-Lfunc_begin3            ;     jumps to Ltmp17
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp16-Lfunc_begin3            ; >> Call Site 8 <<
	.uleb128 Lfunc_end3-Ltmp16              ;   Call between Ltmp16 and Lfunc_end3
	.byte	0                               ;     has no landing pad
	.byte	0                               ;   On action: cleanup
Lcst_end3:
	.p2align	2, 0x0
                                        ; -- End function
	.section	__TEXT,__text,regular,pure_instructions
	.private_extern	__ZNSt16invalid_argumentC1B9nqe210106EPKc ; -- Begin function _ZNSt16invalid_argumentC1B9nqe210106EPKc
	.globl	__ZNSt16invalid_argumentC1B9nqe210106EPKc
	.weak_def_can_be_hidden	__ZNSt16invalid_argumentC1B9nqe210106EPKc
	.p2align	2
__ZNSt16invalid_argumentC1B9nqe210106EPKc: ; @_ZNSt16invalid_argumentC1B9nqe210106EPKc
	.cfi_startproc
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	bl	__ZNSt11logic_errorC2EPKc
Lloh28:
	adrp	x8, __ZTVSt16invalid_argument@GOTPAGE
Lloh29:
	ldr	x8, [x8, __ZTVSt16invalid_argument@GOTPAGEOFF]
	add	x8, x8, #16
	str	x8, [x0]
	ldp	x29, x30, [sp], #16             ; 16-byte Folded Reload
	ret
	.loh AdrpLdrGot	Lloh28, Lloh29
	.cfi_endproc
                                        ; -- End function
	.globl	__ZN9inference10matmul_ikjERKNS_6MatrixES2_ ; -- Begin function _ZN9inference10matmul_ikjERKNS_6MatrixES2_
	.p2align	2
__ZN9inference10matmul_ikjERKNS_6MatrixES2_: ; @_ZN9inference10matmul_ikjERKNS_6MatrixES2_
Lfunc_begin4:
	.cfi_startproc
	.cfi_personality 155, ___gxx_personality_v0
	.cfi_lsda 16, Lexception4
; %bb.0:
	stp	x26, x25, [sp, #-80]!           ; 16-byte Folded Spill
	stp	x24, x23, [sp, #16]             ; 16-byte Folded Spill
	stp	x22, x21, [sp, #32]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #48]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #64]             ; 16-byte Folded Spill
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	mov	x19, x8
	ldr	x8, [x0, #8]
	ldr	x9, [x1]
	cmp	x8, x9
	b.ne	LBB16_26
; %bb.1:
	mov	x20, x1
	mov	x21, x0
	ldr	x1, [x0]
	ldr	x2, [x20, #8]
	mov	x0, x19
	bl	__ZN9inference6MatrixC2Emm
	ldr	x8, [x21]
	cbz	x8, LBB16_21
; %bb.2:
	ldr	x9, [x21, #8]
	cbz	x9, LBB16_20
; %bb.3:
	mov	x10, #0                         ; =0x0
	mov	x11, #0                         ; =0x0
	mov	w12, #16                        ; =0x10
	b	LBB16_5
LBB16_4:                                ;   in Loop: Header=BB16_5 Depth=1
	add	x11, x11, #1
	add	x10, x10, #4
	cmp	x11, x8
	b.eq	LBB16_21
LBB16_5:                                ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB16_7 Depth 2
                                        ;       Child Loop BB16_12 Depth 3
                                        ;       Child Loop BB16_15 Depth 3
                                        ;     Child Loop BB16_19 Depth 2
	ldr	x13, [x20, #8]
	cbz	x13, LBB16_18
; %bb.6:                                ;   in Loop: Header=BB16_5 Depth=1
	mov	x14, #0                         ; =0x0
	mov	x15, #0                         ; =0x0
	lsl	x16, x11, #2
	mul	x17, x9, x11
	ldr	x0, [x21, #16]
	add	x17, x0, x17, lsl #2
	ldr	x0, [x20]
	sub	x1, x13, #1
	lsl	x2, x13, #2
	mov	w3, #32                         ; =0x20
LBB16_7:                                ;   Parent Loop BB16_5 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB16_12 Depth 3
                                        ;       Child Loop BB16_15 Depth 3
	cmp	x15, x0
	b.hs	LBB16_25
; %bb.8:                                ;   in Loop: Header=BB16_7 Depth=2
	ldr	x4, [x19]
	cmp	x11, x4
	b.hs	LBB16_22
; %bb.9:                                ;   in Loop: Header=BB16_7 Depth=2
	ldr	s0, [x17, x15, lsl #2]
	ldr	x6, [x20, #16]
	ldp	x4, x5, [x19, #8]
	cmp	x1, x4
	csel	x7, x1, x4, lo
	cmp	x7, #15
	b.ls	LBB16_13
; %bb.10:                               ;   in Loop: Header=BB16_7 Depth=2
	mul	x22, x2, x15
	mul	x23, x13, x15
	add	x23, x6, x23, lsl #2
	mul	x24, x4, x11
	add	x24, x5, x24, lsl #2
	madd	x25, x16, x4, x5
	lsl	x26, x7, #2
	add	x25, x25, x26
	add	x25, x25, #4
	add	x22, x6, x22
	add	x22, x22, x26
	add	x22, x22, #4
	cmp	x24, x22
	ccmp	x23, x25, #2, lo
	b.lo	LBB16_13
; %bb.11:                               ;   in Loop: Header=BB16_7 Depth=2
	add	x7, x7, #1
	ands	x22, x7, #0xf
	csel	x22, x12, x22, eq
	sub	x7, x7, x22
	add	x22, x6, x3
	madd	x23, x10, x4, x5
	add	x23, x23, #32
	mov	x24, x7
LBB16_12:                               ;   Parent Loop BB16_5 Depth=1
                                        ;     Parent Loop BB16_7 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	ldp	q1, q2, [x22, #-32]
	ldp	q3, q4, [x22], #64
	ldp	q5, q6, [x23, #-32]
	ldp	q7, q16, [x23]
	fmla.4s	v5, v1, v0[0]
	fmla.4s	v6, v2, v0[0]
	fmla.4s	v7, v3, v0[0]
	fmla.4s	v16, v4, v0[0]
	stp	q5, q6, [x23, #-32]
	stp	q7, q16, [x23], #64
	subs	x24, x24, #16
	b.ne	LBB16_12
	b	LBB16_14
LBB16_13:                               ;   in Loop: Header=BB16_7 Depth=2
	mov	x7, #0                          ; =0x0
LBB16_14:                               ;   in Loop: Header=BB16_7 Depth=2
	sub	x22, x4, x7
	sub	x23, x13, x7
	lsl	x7, x7, #2
	add	x24, x14, x7
	add	x6, x6, x24
	madd	x4, x10, x4, x7
	add	x4, x5, x4
LBB16_15:                               ;   Parent Loop BB16_5 Depth=1
                                        ;     Parent Loop BB16_7 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	cbz	x22, LBB16_22
; %bb.16:                               ;   in Loop: Header=BB16_15 Depth=3
	ldr	s1, [x6], #4
	ldr	s2, [x4]
	fmadd	s1, s0, s1, s2
	str	s1, [x4], #4
	sub	x22, x22, #1
	subs	x23, x23, #1
	b.ne	LBB16_15
; %bb.17:                               ;   in Loop: Header=BB16_7 Depth=2
	add	x15, x15, #1
	add	x3, x3, x2
	add	x14, x14, x2
	cmp	x15, x9
	b.ne	LBB16_7
	b	LBB16_4
LBB16_18:                               ;   in Loop: Header=BB16_5 Depth=1
	mov	x13, x9
LBB16_19:                               ;   Parent Loop BB16_5 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	subs	x13, x13, #1
	b.ne	LBB16_19
	b	LBB16_4
LBB16_20:                               ; =>This Inner Loop Header: Depth=1
	subs	x8, x8, #1
	b.ne	LBB16_20
LBB16_21:
	ldp	x29, x30, [sp, #64]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #48]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #32]             ; 16-byte Folded Reload
	ldp	x24, x23, [sp, #16]             ; 16-byte Folded Reload
	ldp	x26, x25, [sp], #80             ; 16-byte Folded Reload
	ret
LBB16_22:
	mov	w0, #16                         ; =0x10
	bl	___cxa_allocate_exception
	mov	x21, x0
Ltmp33:
Lloh30:
	adrp	x1, l_.str.1@PAGE
Lloh31:
	add	x1, x1, l_.str.1@PAGEOFF
	bl	__ZNSt11logic_errorC2EPKc
Ltmp34:
LBB16_23:
Lloh32:
	adrp	x8, __ZTVSt12out_of_range@GOTPAGE
Lloh33:
	ldr	x8, [x8, __ZTVSt12out_of_range@GOTPAGEOFF]
	add	x8, x8, #16
	str	x8, [x21]
Ltmp36:
Lloh34:
	adrp	x1, __ZTISt12out_of_range@GOTPAGE
Lloh35:
	ldr	x1, [x1, __ZTISt12out_of_range@GOTPAGEOFF]
Lloh36:
	adrp	x2, __ZNSt12out_of_rangeD1Ev@GOTPAGE
Lloh37:
	ldr	x2, [x2, __ZNSt12out_of_rangeD1Ev@GOTPAGEOFF]
	mov	x0, x21
	bl	___cxa_throw
Ltmp37:
; %bb.24:
	brk	#0x1
LBB16_25:
	mov	w0, #16                         ; =0x10
	bl	___cxa_allocate_exception
	mov	x21, x0
Ltmp30:
Lloh38:
	adrp	x1, l_.str.1@PAGE
Lloh39:
	add	x1, x1, l_.str.1@PAGEOFF
	bl	__ZNSt11logic_errorC2EPKc
Ltmp31:
	b	LBB16_23
LBB16_26:
	mov	w0, #16                         ; =0x10
	bl	___cxa_allocate_exception
	mov	x19, x0
Ltmp27:
Lloh40:
	adrp	x1, l_.str.2@PAGE
Lloh41:
	add	x1, x1, l_.str.2@PAGEOFF
	bl	__ZNSt16invalid_argumentC1B9nqe210106EPKc
Ltmp28:
; %bb.27:
	mov	x0, x19
	bl	__ZN9inference10matmul_ikjERKNS_6MatrixES2_.cold.1
LBB16_28:
Ltmp29:
	mov	x20, x0
	mov	x0, x19
	bl	___cxa_free_exception
	mov	x0, x20
	bl	__Unwind_Resume
LBB16_29:
Ltmp32:
	b	LBB16_31
LBB16_30:
Ltmp35:
LBB16_31:
	mov	x20, x0
	mov	x0, x21
	bl	___cxa_free_exception
	b	LBB16_33
LBB16_32:
Ltmp38:
	mov	x20, x0
LBB16_33:
	ldr	x0, [x19, #16]
	cbnz	x0, LBB16_35
; %bb.34:
	mov	x0, x20
	bl	__Unwind_Resume
LBB16_35:
	str	x0, [x19, #24]
	bl	__ZdlPv
	mov	x0, x20
	bl	__Unwind_Resume
	.loh AdrpAdd	Lloh30, Lloh31
	.loh AdrpLdrGot	Lloh36, Lloh37
	.loh AdrpLdrGot	Lloh34, Lloh35
	.loh AdrpLdrGot	Lloh32, Lloh33
	.loh AdrpAdd	Lloh38, Lloh39
	.loh AdrpAdd	Lloh40, Lloh41
Lfunc_end4:
	.cfi_endproc
	.section	__TEXT,__gcc_except_tab
	.p2align	2, 0x0
GCC_except_table16:
Lexception4:
	.byte	255                             ; @LPStart Encoding = omit
	.byte	255                             ; @TType Encoding = omit
	.byte	1                               ; Call site Encoding = uleb128
	.uleb128 Lcst_end4-Lcst_begin4
Lcst_begin4:
	.uleb128 Lfunc_begin4-Lfunc_begin4      ; >> Call Site 1 <<
	.uleb128 Ltmp33-Lfunc_begin4            ;   Call between Lfunc_begin4 and Ltmp33
	.byte	0                               ;     has no landing pad
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp33-Lfunc_begin4            ; >> Call Site 2 <<
	.uleb128 Ltmp34-Ltmp33                  ;   Call between Ltmp33 and Ltmp34
	.uleb128 Ltmp35-Lfunc_begin4            ;     jumps to Ltmp35
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp36-Lfunc_begin4            ; >> Call Site 3 <<
	.uleb128 Ltmp37-Ltmp36                  ;   Call between Ltmp36 and Ltmp37
	.uleb128 Ltmp38-Lfunc_begin4            ;     jumps to Ltmp38
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp37-Lfunc_begin4            ; >> Call Site 4 <<
	.uleb128 Ltmp30-Ltmp37                  ;   Call between Ltmp37 and Ltmp30
	.byte	0                               ;     has no landing pad
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp30-Lfunc_begin4            ; >> Call Site 5 <<
	.uleb128 Ltmp31-Ltmp30                  ;   Call between Ltmp30 and Ltmp31
	.uleb128 Ltmp32-Lfunc_begin4            ;     jumps to Ltmp32
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp31-Lfunc_begin4            ; >> Call Site 6 <<
	.uleb128 Ltmp27-Ltmp31                  ;   Call between Ltmp31 and Ltmp27
	.byte	0                               ;     has no landing pad
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp27-Lfunc_begin4            ; >> Call Site 7 <<
	.uleb128 Ltmp28-Ltmp27                  ;   Call between Ltmp27 and Ltmp28
	.uleb128 Ltmp29-Lfunc_begin4            ;     jumps to Ltmp29
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp28-Lfunc_begin4            ; >> Call Site 8 <<
	.uleb128 Lfunc_end4-Ltmp28              ;   Call between Ltmp28 and Lfunc_end4
	.byte	0                               ;     has no landing pad
	.byte	0                               ;   On action: cleanup
Lcst_end4:
	.p2align	2, 0x0
                                        ; -- End function
	.section	__TEXT,__text,regular,pure_instructions
	.globl	__ZN9inference14matmul_blockedERKNS_6MatrixES2_NS_11MatmulTilesE ; -- Begin function _ZN9inference14matmul_blockedERKNS_6MatrixES2_NS_11MatmulTilesE
	.p2align	2
__ZN9inference14matmul_blockedERKNS_6MatrixES2_NS_11MatmulTilesE: ; @_ZN9inference14matmul_blockedERKNS_6MatrixES2_NS_11MatmulTilesE
Lfunc_begin5:
	.cfi_startproc
	.cfi_personality 155, ___gxx_personality_v0
	.cfi_lsda 16, Lexception5
; %bb.0:
	sub	sp, sp, #224
	stp	x28, x27, [sp, #128]            ; 16-byte Folded Spill
	stp	x26, x25, [sp, #144]            ; 16-byte Folded Spill
	stp	x24, x23, [sp, #160]            ; 16-byte Folded Spill
	stp	x22, x21, [sp, #176]            ; 16-byte Folded Spill
	stp	x20, x19, [sp, #192]            ; 16-byte Folded Spill
	stp	x29, x30, [sp, #208]            ; 16-byte Folded Spill
	add	x29, sp, #208
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	mov	x19, x8
	str	x0, [sp, #88]                   ; 8-byte Folded Spill
	ldr	x21, [x0, #8]
	ldr	x8, [x1]
	cmp	x21, x8
	b.ne	LBB17_57
; %bb.1:
	mov	x24, x2
	ldr	x8, [x2]
	cbz	x8, LBB17_55
; %bb.2:
	ldr	x8, [x24, #8]
	cbz	x8, LBB17_55
; %bb.3:
	ldr	x8, [x24, #16]
	cbz	x8, LBB17_55
; %bb.4:
	mov	x20, x1
	ldr	x8, [sp, #88]                   ; 8-byte Folded Reload
	ldr	x22, [x8]
	ldr	x23, [x1, #8]
	mov	x0, x19
	mov	x1, x22
	mov	x2, x23
	bl	__ZN9inference6MatrixC2Emm
	cbz	x21, LBB17_47
; %bb.5:
	cbz	x22, LBB17_47
; %bb.6:
	cbz	x23, LBB17_47
; %bb.7:
	mov	x10, #0                         ; =0x0
	ldp	x8, x11, [x24, #8]
	stp	x22, x11, [sp, #16]             ; 16-byte Folded Spill
	ldr	x9, [x24]
	stp	x21, x8, [sp, #56]              ; 16-byte Folded Spill
	stp	x9, x23, [sp]                   ; 16-byte Folded Spill
	b	LBB17_9
LBB17_8:                                ;   in Loop: Header=BB17_9 Depth=1
	ldr	x8, [sp, #104]                  ; 8-byte Folded Reload
	mov	x10, x8
	cmp	x8, x22
	ldr	x9, [sp]                        ; 8-byte Folded Reload
	b.hs	LBB17_47
LBB17_9:                                ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB17_12 Depth 2
                                        ;       Child Loop BB17_34 Depth 3
                                        ;         Child Loop BB17_38 Depth 4
                                        ;         Child Loop BB17_42 Depth 4
                                        ;       Child Loop BB17_15 Depth 3
                                        ;         Child Loop BB17_17 Depth 4
                                        ;           Child Loop BB17_19 Depth 5
                                        ;             Child Loop BB17_25 Depth 6
                                        ;             Child Loop BB17_27 Depth 6
	sub	x8, x22, x10
	cmp	x8, x9
	csel	x8, x8, x9, lo
	add	x9, x8, x10
	str	x9, [sp, #104]                  ; 8-byte Folded Spill
	cmp	x10, x9
	b.hs	LBB17_8
; %bb.10:                               ;   in Loop: Header=BB17_9 Depth=1
	mov	x6, #0                          ; =0x0
	sub	x9, x8, #1
	and	x8, x8, #0x3
	stp	x9, x8, [sp, #40]               ; 16-byte Folded Spill
	lsl	x8, x10, #2
	str	x8, [sp, #32]                   ; 8-byte Folded Spill
	str	x10, [sp, #96]                  ; 8-byte Folded Spill
	b	LBB17_12
LBB17_11:                               ;   in Loop: Header=BB17_12 Depth=2
	mov	x6, x17
	ldp	x23, x22, [sp, #8]              ; 16-byte Folded Reload
	cmp	x17, x23
	ldr	x10, [sp, #96]                  ; 8-byte Folded Reload
	b.hs	LBB17_8
LBB17_12:                               ;   Parent Loop BB17_9 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB17_34 Depth 3
                                        ;         Child Loop BB17_38 Depth 4
                                        ;         Child Loop BB17_42 Depth 4
                                        ;       Child Loop BB17_15 Depth 3
                                        ;         Child Loop BB17_17 Depth 4
                                        ;           Child Loop BB17_19 Depth 5
                                        ;             Child Loop BB17_25 Depth 6
                                        ;             Child Loop BB17_27 Depth 6
	sub	x8, x23, x6
	ldr	x9, [sp, #24]                   ; 8-byte Folded Reload
	cmp	x8, x9
	csel	x8, x8, x9, lo
	add	x17, x8, x6
	cmp	x6, x17
	b.hs	LBB17_32
; %bb.13:                               ;   in Loop: Header=BB17_12 Depth=2
	mov	x28, #0                         ; =0x0
	lsl	x1, x6, #2
	add	x8, x6, #1
	cmp	x17, x8
	csinc	x8, x17, x6, hi
	mvn	x9, x6
	add	x3, x8, x9
	b	LBB17_15
LBB17_14:                               ;   in Loop: Header=BB17_15 Depth=3
	mov	x28, x4
	ldr	x21, [sp, #56]                  ; 8-byte Folded Reload
	cmp	x4, x21
	b.hs	LBB17_11
LBB17_15:                               ;   Parent Loop BB17_9 Depth=1
                                        ;     Parent Loop BB17_12 Depth=2
                                        ; =>    This Loop Header: Depth=3
                                        ;         Child Loop BB17_17 Depth 4
                                        ;           Child Loop BB17_19 Depth 5
                                        ;             Child Loop BB17_25 Depth 6
                                        ;             Child Loop BB17_27 Depth 6
	sub	x8, x21, x28
	ldr	x9, [sp, #64]                   ; 8-byte Folded Reload
	cmp	x8, x9
	csel	x8, x8, x9, lo
	add	x4, x8, x28
	cmp	x28, x4
	b.hs	LBB17_14
; %bb.16:                               ;   in Loop: Header=BB17_15 Depth=3
	stur	xzr, [x29, #-96]                ; 8-byte Folded Spill
	ldp	x8, x26, [sp, #88]              ; 16-byte Folded Reload
	ldr	x8, [x8]
	cmp	x26, x8
	csel	x9, x26, x8, hi
	lsl	x8, x28, #2
	stp	x8, x9, [sp, #72]               ; 16-byte Folded Spill
	ldr	x24, [sp, #32]                  ; 8-byte Folded Reload
LBB17_17:                               ;   Parent Loop BB17_9 Depth=1
                                        ;     Parent Loop BB17_12 Depth=2
                                        ;       Parent Loop BB17_15 Depth=3
                                        ; =>      This Loop Header: Depth=4
                                        ;           Child Loop BB17_19 Depth 5
                                        ;             Child Loop BB17_25 Depth 6
                                        ;             Child Loop BB17_27 Depth 6
	ldr	x8, [sp, #80]                   ; 8-byte Folded Reload
	cmp	x26, x8
	b.eq	LBB17_48
; %bb.18:                               ;   in Loop: Header=BB17_17 Depth=4
	mov	x27, #0                         ; =0x0
	ldr	x8, [sp, #96]                   ; 8-byte Folded Reload
	ldur	x9, [x29, #-96]                 ; 8-byte Folded Reload
	add	x8, x8, x9
	lsl	x8, x8, #2
	stur	x8, [x29, #-88]                 ; 8-byte Folded Spill
	ldr	x9, [sp, #88]                   ; 8-byte Folded Reload
	ldp	x8, x9, [x9, #8]
	mul	x10, x8, x26
	add	x30, x9, x10, lsl #2
	ldr	x9, [x20]
	cmp	x28, x8
	csel	x11, x28, x8, hi
	cmp	x28, x9
	csel	x22, x28, x9, hi
	ldr	x7, [sp, #72]                   ; 8-byte Folded Reload
	mov	x2, x28
LBB17_19:                               ;   Parent Loop BB17_9 Depth=1
                                        ;     Parent Loop BB17_12 Depth=2
                                        ;       Parent Loop BB17_15 Depth=3
                                        ;         Parent Loop BB17_17 Depth=4
                                        ; =>        This Loop Header: Depth=5
                                        ;             Child Loop BB17_25 Depth 6
                                        ;             Child Loop BB17_27 Depth 6
	cmp	x2, x11
	b.eq	LBB17_48
; %bb.20:                               ;   in Loop: Header=BB17_19 Depth=5
	cmp	x2, x22
	b.eq	LBB17_52
; %bb.21:                               ;   in Loop: Header=BB17_19 Depth=5
	ldr	x15, [x20, #8]
	ldr	x8, [x19]
	cmp	x26, x8
	b.hs	LBB17_50
; %bb.22:                               ;   in Loop: Header=BB17_19 Depth=5
	ldr	s0, [x30, x2, lsl #2]
	ldr	x25, [x20, #16]
	ldp	x12, x9, [x19, #8]
	cmp	x6, x15
	csel	x16, x6, x15, hi
	cmp	x6, x12
	csel	x14, x6, x12, hi
	sub	x8, x14, x6
	cmp	x3, x8
	csel	x8, x3, x8, lo
	sub	x10, x16, x6
	cmp	x8, x10
	csel	x10, x8, x10, lo
	add	x8, x10, #1
	mov	x0, x6
	cmp	x8, #17
	b.lo	LBB17_26
; %bb.23:                               ;   in Loop: Header=BB17_19 Depth=5
	add	x13, x28, x27
	lsl	x0, x13, #2
	add	x13, x9, x1
	ldur	x5, [x29, #-88]                 ; 8-byte Folded Reload
	madd	x21, x5, x12, x13
	lsl	x5, x10, #2
	add	x10, x21, x5
	add	x23, x10, #4
	add	x10, x25, x1
	madd	x0, x15, x0, x10
	add	x5, x0, x5
	add	x5, x5, #4
	cmp	x21, x5
	ccmp	x0, x23, #2, lo
	mov	x0, x6
	b.lo	LBB17_26
; %bb.24:                               ;   in Loop: Header=BB17_19 Depth=5
	ands	x0, x8, #0xf
	mov	w5, #16                         ; =0x10
	csel	x0, x5, x0, eq
	sub	x21, x8, x0
	add	x0, x6, x21
	madd	x8, x15, x7, x10
	add	x8, x8, #32
	madd	x10, x24, x12, x13
	add	x13, x10, #32
LBB17_25:                               ;   Parent Loop BB17_9 Depth=1
                                        ;     Parent Loop BB17_12 Depth=2
                                        ;       Parent Loop BB17_15 Depth=3
                                        ;         Parent Loop BB17_17 Depth=4
                                        ;           Parent Loop BB17_19 Depth=5
                                        ; =>          This Inner Loop Header: Depth=6
	ldp	q1, q2, [x8, #-32]
	ldp	q3, q4, [x8], #64
	ldp	q5, q6, [x13, #-32]
	ldp	q7, q16, [x13]
	fmla.4s	v5, v1, v0[0]
	fmla.4s	v6, v2, v0[0]
	fmla.4s	v7, v3, v0[0]
	fmla.4s	v16, v4, v0[0]
	stp	q5, q6, [x13, #-32]
	stp	q7, q16, [x13], #64
	subs	x21, x21, #16
	b.ne	LBB17_25
LBB17_26:                               ;   in Loop: Header=BB17_19 Depth=5
	madd	x8, x24, x12, x9
	madd	x9, x15, x7, x25
LBB17_27:                               ;   Parent Loop BB17_9 Depth=1
                                        ;     Parent Loop BB17_12 Depth=2
                                        ;       Parent Loop BB17_15 Depth=3
                                        ;         Parent Loop BB17_17 Depth=4
                                        ;           Parent Loop BB17_19 Depth=5
                                        ; =>          This Inner Loop Header: Depth=6
	cmp	x16, x0
	b.eq	LBB17_52
; %bb.28:                               ;   in Loop: Header=BB17_27 Depth=6
	cmp	x14, x0
	b.eq	LBB17_51
; %bb.29:                               ;   in Loop: Header=BB17_27 Depth=6
	ldr	s1, [x9, x0, lsl #2]
	ldr	s2, [x8, x0, lsl #2]
	fmadd	s1, s0, s1, s2
	str	s1, [x8, x0, lsl #2]
	add	x0, x0, #1
	cmp	x0, x17
	b.lo	LBB17_27
; %bb.30:                               ;   in Loop: Header=BB17_19 Depth=5
	add	x2, x2, #1
	add	x27, x27, #1
	add	x7, x7, #4
	cmp	x2, x4
	b.ne	LBB17_19
; %bb.31:                               ;   in Loop: Header=BB17_17 Depth=4
	add	x26, x26, #1
	ldur	x8, [x29, #-96]                 ; 8-byte Folded Reload
	add	x8, x8, #1
	stur	x8, [x29, #-96]                 ; 8-byte Folded Spill
	add	x24, x24, #4
	ldr	x8, [sp, #104]                  ; 8-byte Folded Reload
	cmp	x26, x8
	b.ne	LBB17_17
	b	LBB17_14
LBB17_32:                               ;   in Loop: Header=BB17_12 Depth=2
	mov	x12, #0                         ; =0x0
	ldr	x8, [sp, #88]                   ; 8-byte Folded Reload
	ldp	x9, x8, [x8]
	cmp	x10, x9
	csel	x11, x10, x9, hi
	b	LBB17_34
LBB17_33:                               ;   in Loop: Header=BB17_34 Depth=3
	mov	x12, x9
	ldr	x21, [sp, #56]                  ; 8-byte Folded Reload
	cmp	x9, x21
	b.hs	LBB17_11
LBB17_34:                               ;   Parent Loop BB17_9 Depth=1
                                        ;     Parent Loop BB17_12 Depth=2
                                        ; =>    This Loop Header: Depth=3
                                        ;         Child Loop BB17_38 Depth 4
                                        ;         Child Loop BB17_42 Depth 4
	sub	x9, x21, x12
	ldr	x10, [sp, #64]                  ; 8-byte Folded Reload
	cmp	x9, x10
	csel	x10, x9, x10, lo
	add	x9, x10, x12
	cmp	x12, x9
	b.hs	LBB17_33
; %bb.35:                               ;   in Loop: Header=BB17_34 Depth=3
	subs	x12, x8, x12
	csel	x12, xzr, x12, lo
	sub	x10, x10, #1
	cmp	x12, x10
	b.ls	LBB17_48
; %bb.36:                               ;   in Loop: Header=BB17_34 Depth=3
	ldr	x12, [sp, #96]                  ; 8-byte Folded Reload
	ldr	x10, [sp, #48]                  ; 8-byte Folded Reload
	cbz	x10, LBB17_40
; %bb.37:                               ;   in Loop: Header=BB17_34 Depth=3
	ldr	x13, [sp, #48]                  ; 8-byte Folded Reload
	ldr	x12, [sp, #96]                  ; 8-byte Folded Reload
LBB17_38:                               ;   Parent Loop BB17_9 Depth=1
                                        ;     Parent Loop BB17_12 Depth=2
                                        ;       Parent Loop BB17_34 Depth=3
                                        ; =>      This Inner Loop Header: Depth=4
	cmp	x11, x12
	b.eq	LBB17_48
; %bb.39:                               ;   in Loop: Header=BB17_38 Depth=4
	add	x12, x12, #1
	subs	x13, x13, #1
	b.ne	LBB17_38
LBB17_40:                               ;   in Loop: Header=BB17_34 Depth=3
	ldr	x10, [sp, #40]                  ; 8-byte Folded Reload
	cmp	x10, #3
	b.lo	LBB17_33
; %bb.41:                               ;   in Loop: Header=BB17_34 Depth=3
	sub	x13, x11, x12
LBB17_42:                               ;   Parent Loop BB17_9 Depth=1
                                        ;     Parent Loop BB17_12 Depth=2
                                        ;       Parent Loop BB17_34 Depth=3
                                        ; =>      This Inner Loop Header: Depth=4
	cbz	x13, LBB17_48
; %bb.43:                               ;   in Loop: Header=BB17_42 Depth=4
	add	x10, x12, #1
	cmp	x10, x11
	b.eq	LBB17_48
; %bb.44:                               ;   in Loop: Header=BB17_42 Depth=4
	add	x10, x12, #2
	cmp	x10, x11
	b.eq	LBB17_48
; %bb.45:                               ;   in Loop: Header=BB17_42 Depth=4
	add	x10, x12, #3
	cmp	x10, x11
	b.eq	LBB17_48
; %bb.46:                               ;   in Loop: Header=BB17_42 Depth=4
	add	x12, x12, #4
	sub	x13, x13, #4
	ldr	x10, [sp, #104]                 ; 8-byte Folded Reload
	cmp	x12, x10
	b.ne	LBB17_42
	b	LBB17_33
LBB17_47:
	ldp	x29, x30, [sp, #208]            ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #192]            ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #176]            ; 16-byte Folded Reload
	ldp	x24, x23, [sp, #160]            ; 16-byte Folded Reload
	ldp	x26, x25, [sp, #144]            ; 16-byte Folded Reload
	ldp	x28, x27, [sp, #128]            ; 16-byte Folded Reload
	add	sp, sp, #224
	ret
LBB17_48:
	mov	w0, #16                         ; =0x10
	bl	___cxa_allocate_exception
	mov	x21, x0
Ltmp51:
Lloh42:
	adrp	x1, l_.str.1@PAGE
Lloh43:
	add	x1, x1, l_.str.1@PAGEOFF
	bl	__ZNSt11logic_errorC2EPKc
Ltmp52:
; %bb.49:
Lloh44:
	adrp	x8, __ZTVSt12out_of_range@GOTPAGE
Lloh45:
	ldr	x8, [x8, __ZTVSt12out_of_range@GOTPAGEOFF]
	add	x8, x8, #16
	str	x8, [x21]
Ltmp54:
Lloh46:
	adrp	x1, __ZTISt12out_of_range@GOTPAGE
Lloh47:
	ldr	x1, [x1, __ZTISt12out_of_range@GOTPAGEOFF]
Lloh48:
	adrp	x2, __ZNSt12out_of_rangeD1Ev@GOTPAGE
Lloh49:
	ldr	x2, [x2, __ZNSt12out_of_rangeD1Ev@GOTPAGEOFF]
	mov	x0, x21
	bl	___cxa_throw
Ltmp55:
	b	LBB17_54
LBB17_50:
	cmp	x6, x15
	b.hs	LBB17_52
LBB17_51:
	mov	w0, #16                         ; =0x10
	bl	___cxa_allocate_exception
	mov	x21, x0
Ltmp42:
Lloh50:
	adrp	x1, l_.str.1@PAGE
Lloh51:
	add	x1, x1, l_.str.1@PAGEOFF
	bl	__ZNSt11logic_errorC2EPKc
Ltmp43:
	b	LBB17_53
LBB17_52:
	mov	w0, #16                         ; =0x10
	bl	___cxa_allocate_exception
	mov	x21, x0
Ltmp45:
Lloh52:
	adrp	x1, l_.str.1@PAGE
Lloh53:
	add	x1, x1, l_.str.1@PAGEOFF
	bl	__ZNSt11logic_errorC2EPKc
Ltmp46:
LBB17_53:
Lloh54:
	adrp	x8, __ZTVSt12out_of_range@GOTPAGE
Lloh55:
	ldr	x8, [x8, __ZTVSt12out_of_range@GOTPAGEOFF]
	add	x8, x8, #16
	str	x8, [x21]
Ltmp48:
Lloh56:
	adrp	x1, __ZTISt12out_of_range@GOTPAGE
Lloh57:
	ldr	x1, [x1, __ZTISt12out_of_range@GOTPAGEOFF]
Lloh58:
	adrp	x2, __ZNSt12out_of_rangeD1Ev@GOTPAGE
Lloh59:
	ldr	x2, [x2, __ZNSt12out_of_rangeD1Ev@GOTPAGEOFF]
	mov	x0, x21
	bl	___cxa_throw
Ltmp49:
LBB17_54:
	brk	#0x1
LBB17_55:
	mov	w0, #16                         ; =0x10
	bl	___cxa_allocate_exception
	mov	x19, x0
Ltmp57:
Lloh60:
	adrp	x1, l_.str.3@PAGE
Lloh61:
	add	x1, x1, l_.str.3@PAGEOFF
	bl	__ZNSt16invalid_argumentC1B9nqe210106EPKc
Ltmp58:
; %bb.56:
	mov	x0, x19
	bl	__ZN9inference14matmul_blockedERKNS_6MatrixES2_NS_11MatmulTilesE.cold.2
LBB17_57:
	mov	w0, #16                         ; =0x10
	bl	___cxa_allocate_exception
	mov	x19, x0
Ltmp39:
Lloh62:
	adrp	x1, l_.str.2@PAGE
Lloh63:
	add	x1, x1, l_.str.2@PAGEOFF
	bl	__ZNSt16invalid_argumentC1B9nqe210106EPKc
Ltmp40:
; %bb.58:
	mov	x0, x19
	bl	__ZN9inference14matmul_blockedERKNS_6MatrixES2_NS_11MatmulTilesE.cold.1
LBB17_59:
Ltmp41:
	mov	x20, x0
	mov	x0, x19
	bl	___cxa_free_exception
	mov	x0, x20
	bl	__Unwind_Resume
LBB17_60:
Ltmp59:
	mov	x20, x0
	mov	x0, x19
	bl	___cxa_free_exception
	mov	x0, x20
	bl	__Unwind_Resume
LBB17_61:
Ltmp56:
	b	LBB17_66
LBB17_62:
Ltmp53:
	mov	x20, x0
	mov	x0, x21
	bl	___cxa_free_exception
	ldr	x0, [x19, #16]
	cbnz	x0, LBB17_67
	b	LBB17_68
LBB17_63:
Ltmp44:
	mov	x20, x0
	mov	x0, x21
	bl	___cxa_free_exception
	ldr	x0, [x19, #16]
	cbnz	x0, LBB17_67
	b	LBB17_68
LBB17_64:
Ltmp47:
	mov	x20, x0
	mov	x0, x21
	bl	___cxa_free_exception
	ldr	x0, [x19, #16]
	cbnz	x0, LBB17_67
	b	LBB17_68
LBB17_65:
Ltmp50:
LBB17_66:
	mov	x20, x0
	ldr	x0, [x19, #16]
	cbz	x0, LBB17_68
LBB17_67:
	str	x0, [x19, #24]
	bl	__ZdlPv
LBB17_68:
	mov	x0, x20
	bl	__Unwind_Resume
	.loh AdrpAdd	Lloh42, Lloh43
	.loh AdrpLdrGot	Lloh48, Lloh49
	.loh AdrpLdrGot	Lloh46, Lloh47
	.loh AdrpLdrGot	Lloh44, Lloh45
	.loh AdrpAdd	Lloh50, Lloh51
	.loh AdrpAdd	Lloh52, Lloh53
	.loh AdrpLdrGot	Lloh58, Lloh59
	.loh AdrpLdrGot	Lloh56, Lloh57
	.loh AdrpLdrGot	Lloh54, Lloh55
	.loh AdrpAdd	Lloh60, Lloh61
	.loh AdrpAdd	Lloh62, Lloh63
Lfunc_end5:
	.cfi_endproc
	.section	__TEXT,__gcc_except_tab
	.p2align	2, 0x0
GCC_except_table17:
Lexception5:
	.byte	255                             ; @LPStart Encoding = omit
	.byte	255                             ; @TType Encoding = omit
	.byte	1                               ; Call site Encoding = uleb128
	.uleb128 Lcst_end5-Lcst_begin5
Lcst_begin5:
	.uleb128 Lfunc_begin5-Lfunc_begin5      ; >> Call Site 1 <<
	.uleb128 Ltmp51-Lfunc_begin5            ;   Call between Lfunc_begin5 and Ltmp51
	.byte	0                               ;     has no landing pad
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp51-Lfunc_begin5            ; >> Call Site 2 <<
	.uleb128 Ltmp52-Ltmp51                  ;   Call between Ltmp51 and Ltmp52
	.uleb128 Ltmp53-Lfunc_begin5            ;     jumps to Ltmp53
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp54-Lfunc_begin5            ; >> Call Site 3 <<
	.uleb128 Ltmp55-Ltmp54                  ;   Call between Ltmp54 and Ltmp55
	.uleb128 Ltmp56-Lfunc_begin5            ;     jumps to Ltmp56
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp55-Lfunc_begin5            ; >> Call Site 4 <<
	.uleb128 Ltmp42-Ltmp55                  ;   Call between Ltmp55 and Ltmp42
	.byte	0                               ;     has no landing pad
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp42-Lfunc_begin5            ; >> Call Site 5 <<
	.uleb128 Ltmp43-Ltmp42                  ;   Call between Ltmp42 and Ltmp43
	.uleb128 Ltmp44-Lfunc_begin5            ;     jumps to Ltmp44
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp43-Lfunc_begin5            ; >> Call Site 6 <<
	.uleb128 Ltmp45-Ltmp43                  ;   Call between Ltmp43 and Ltmp45
	.byte	0                               ;     has no landing pad
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp45-Lfunc_begin5            ; >> Call Site 7 <<
	.uleb128 Ltmp46-Ltmp45                  ;   Call between Ltmp45 and Ltmp46
	.uleb128 Ltmp47-Lfunc_begin5            ;     jumps to Ltmp47
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp48-Lfunc_begin5            ; >> Call Site 8 <<
	.uleb128 Ltmp49-Ltmp48                  ;   Call between Ltmp48 and Ltmp49
	.uleb128 Ltmp50-Lfunc_begin5            ;     jumps to Ltmp50
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp49-Lfunc_begin5            ; >> Call Site 9 <<
	.uleb128 Ltmp57-Ltmp49                  ;   Call between Ltmp49 and Ltmp57
	.byte	0                               ;     has no landing pad
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp57-Lfunc_begin5            ; >> Call Site 10 <<
	.uleb128 Ltmp58-Ltmp57                  ;   Call between Ltmp57 and Ltmp58
	.uleb128 Ltmp59-Lfunc_begin5            ;     jumps to Ltmp59
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp58-Lfunc_begin5            ; >> Call Site 11 <<
	.uleb128 Ltmp39-Ltmp58                  ;   Call between Ltmp58 and Ltmp39
	.byte	0                               ;     has no landing pad
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp39-Lfunc_begin5            ; >> Call Site 12 <<
	.uleb128 Ltmp40-Ltmp39                  ;   Call between Ltmp39 and Ltmp40
	.uleb128 Ltmp41-Lfunc_begin5            ;     jumps to Ltmp41
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp40-Lfunc_begin5            ; >> Call Site 13 <<
	.uleb128 Lfunc_end5-Ltmp40              ;   Call between Ltmp40 and Lfunc_end5
	.byte	0                               ;     has no landing pad
	.byte	0                               ;   On action: cleanup
Lcst_end5:
	.p2align	2, 0x0
                                        ; -- End function
	.section	__TEXT,__text,regular,pure_instructions
	.private_extern	__ZNSt3__16vectorIfNS_9allocatorIfEEE8__appendEmRKf ; -- Begin function _ZNSt3__16vectorIfNS_9allocatorIfEEE8__appendEmRKf
	.globl	__ZNSt3__16vectorIfNS_9allocatorIfEEE8__appendEmRKf
	.weak_def_can_be_hidden	__ZNSt3__16vectorIfNS_9allocatorIfEEE8__appendEmRKf
	.p2align	2
__ZNSt3__16vectorIfNS_9allocatorIfEEE8__appendEmRKf: ; @_ZNSt3__16vectorIfNS_9allocatorIfEEE8__appendEmRKf
	.cfi_startproc
; %bb.0:
	stp	x26, x25, [sp, #-80]!           ; 16-byte Folded Spill
	stp	x24, x23, [sp, #16]             ; 16-byte Folded Spill
	stp	x22, x21, [sp, #32]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #48]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #64]             ; 16-byte Folded Spill
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	mov	x19, x0
	ldp	x22, x8, [x0, #8]
	sub	x9, x8, x22
	cmp	x1, x9, asr #2
	b.ls	LBB18_5
; %bb.1:
	ldr	x20, [x19]
	sub	x21, x22, x20
	asr	x23, x21, #2
	add	x9, x23, x1
	lsr	x10, x9, #62
	cbnz	x10, LBB18_36
; %bb.2:
	mov	x10, #9223372036854775804       ; =0x7ffffffffffffffc
	sub	x8, x8, x20
	asr	x11, x8, #1
	cmp	x11, x9
	csel	x9, x11, x9, hi
	cmp	x8, x10
	mov	x8, #4611686018427387903        ; =0x3fffffffffffffff
	csel	x24, x9, x8, lo
	cbz	x24, LBB18_9
; %bb.3:
	lsr	x8, x24, #62
	cbnz	x8, LBB18_37
; %bb.4:
	mov	x25, x1
	mov	x26, x2
	lsl	x0, x24, #2
	bl	__Znwm
	mov	x2, x26
	mov	x1, x25
	b	LBB18_10
LBB18_5:
	cbz	x1, LBB18_34
; %bb.6:
	lsl	x9, x1, #2
	add	x8, x22, x9
	ldr	s0, [x2]
	sub	x10, x9, #4
	cmp	x10, #12
	b.lo	LBB18_32
; %bb.7:
	lsr	x9, x10, #2
	add	x9, x9, #1
	cmp	x10, #60
	b.hs	LBB18_20
; %bb.8:
	mov	x10, #0                         ; =0x0
	b	LBB18_24
LBB18_9:
	mov	x0, #0                          ; =0x0
LBB18_10:
	lsl	x9, x1, #2
	add	x8, x0, x21
	add	x25, x8, x9
	ldr	s0, [x2]
	sub	x11, x9, #4
	mov	x10, x8
	cmp	x11, #12
	b.lo	LBB18_28
; %bb.11:
	lsr	x9, x11, #2
	add	x9, x9, #1
	cmp	x11, #60
	b.hs	LBB18_13
; %bb.12:
	mov	x11, #0                         ; =0x0
	b	LBB18_17
LBB18_13:
	and	x11, x9, #0x7ffffffffffffff0
	dup.4s	v1, v0[0]
	add	x10, x21, x0
	add	x10, x10, #32
	mov	x12, x11
LBB18_14:                               ; =>This Inner Loop Header: Depth=1
	stp	q1, q1, [x10, #-32]
	stp	q1, q1, [x10], #64
	subs	x12, x12, #16
	b.ne	LBB18_14
; %bb.15:
	cmp	x9, x11
	b.eq	LBB18_29
; %bb.16:
	tst	x9, #0xc
	b.eq	LBB18_27
LBB18_17:
	and	x12, x9, #0x7ffffffffffffffc
	add	x10, x8, x12, lsl #2
	dup.4s	v1, v0[0]
	add	x13, x22, x11, lsl #2
	sub	x13, x13, x20
	add	x13, x0, x13
	sub	x11, x11, x12
LBB18_18:                               ; =>This Inner Loop Header: Depth=1
	str	q1, [x13], #16
	adds	x11, x11, #4
	b.ne	LBB18_18
; %bb.19:
	cmp	x9, x12
	b.ne	LBB18_28
	b	LBB18_29
LBB18_20:
	and	x10, x9, #0x7ffffffffffffff0
	dup.4s	v1, v0[0]
	add	x11, x22, #32
	mov	x12, x10
LBB18_21:                               ; =>This Inner Loop Header: Depth=1
	stp	q1, q1, [x11, #-32]
	stp	q1, q1, [x11], #64
	subs	x12, x12, #16
	b.ne	LBB18_21
; %bb.22:
	cmp	x9, x10
	b.eq	LBB18_33
; %bb.23:
	tst	x9, #0xc
	b.eq	LBB18_31
LBB18_24:
	and	x11, x9, #0x7ffffffffffffffc
	add	x12, x22, x11, lsl #2
	dup.4s	v1, v0[0]
	add	x13, x22, x10, lsl #2
	sub	x10, x10, x11
LBB18_25:                               ; =>This Inner Loop Header: Depth=1
	str	q1, [x13], #16
	adds	x10, x10, #4
	b.ne	LBB18_25
; %bb.26:
	mov	x22, x12
	cmp	x9, x11
	b.ne	LBB18_32
	b	LBB18_33
LBB18_27:
	add	x10, x8, x11, lsl #2
LBB18_28:                               ; =>This Inner Loop Header: Depth=1
	str	s0, [x10], #4
	cmp	x10, x25
	b.ne	LBB18_28
LBB18_29:
	add	x24, x0, x24, lsl #2
	sub	x22, x8, x23, lsl #2
	mov	x0, x22
	mov	x1, x20
	mov	x2, x21
	bl	_memcpy
	stp	x22, x25, [x19]
	str	x24, [x19, #16]
	cbz	x20, LBB18_35
; %bb.30:
	mov	x0, x20
	ldp	x29, x30, [sp, #64]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #48]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #32]             ; 16-byte Folded Reload
	ldp	x24, x23, [sp, #16]             ; 16-byte Folded Reload
	ldp	x26, x25, [sp], #80             ; 16-byte Folded Reload
	b	__ZdlPv
LBB18_31:
	add	x22, x22, x10, lsl #2
LBB18_32:                               ; =>This Inner Loop Header: Depth=1
	str	s0, [x22], #4
	cmp	x22, x8
	b.ne	LBB18_32
LBB18_33:
	mov	x22, x8
LBB18_34:
	str	x22, [x19, #8]
LBB18_35:
	ldp	x29, x30, [sp, #64]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #48]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #32]             ; 16-byte Folded Reload
	ldp	x24, x23, [sp, #16]             ; 16-byte Folded Reload
	ldp	x26, x25, [sp], #80             ; 16-byte Folded Reload
	ret
LBB18_36:
	bl	__ZNSt3__16vectorIfNS_9allocatorIfEEE20__throw_length_errorB9nqe210106Ev
LBB18_37:
	bl	__ZSt28__throw_bad_array_new_lengthB9nqe210106v
	.cfi_endproc
                                        ; -- End function
	.private_extern	__ZNSt3__16vectorIfNS_9allocatorIfEEE20__throw_length_errorB9nqe210106Ev ; -- Begin function _ZNSt3__16vectorIfNS_9allocatorIfEEE20__throw_length_errorB9nqe210106Ev
	.globl	__ZNSt3__16vectorIfNS_9allocatorIfEEE20__throw_length_errorB9nqe210106Ev
	.weak_def_can_be_hidden	__ZNSt3__16vectorIfNS_9allocatorIfEEE20__throw_length_errorB9nqe210106Ev
	.p2align	2
__ZNSt3__16vectorIfNS_9allocatorIfEEE20__throw_length_errorB9nqe210106Ev: ; @_ZNSt3__16vectorIfNS_9allocatorIfEEE20__throw_length_errorB9nqe210106Ev
	.cfi_startproc
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
Lloh64:
	adrp	x0, l_.str.4@PAGE
Lloh65:
	add	x0, x0, l_.str.4@PAGEOFF
	bl	__ZNSt3__120__throw_length_errorB9nqe210106EPKc
	.loh AdrpAdd	Lloh64, Lloh65
	.cfi_endproc
                                        ; -- End function
	.private_extern	__ZNSt3__120__throw_length_errorB9nqe210106EPKc ; -- Begin function _ZNSt3__120__throw_length_errorB9nqe210106EPKc
	.globl	__ZNSt3__120__throw_length_errorB9nqe210106EPKc
	.weak_def_can_be_hidden	__ZNSt3__120__throw_length_errorB9nqe210106EPKc
	.p2align	2
__ZNSt3__120__throw_length_errorB9nqe210106EPKc: ; @_ZNSt3__120__throw_length_errorB9nqe210106EPKc
Lfunc_begin6:
	.cfi_startproc
	.cfi_personality 155, ___gxx_personality_v0
	.cfi_lsda 16, Lexception6
; %bb.0:
	stp	x20, x19, [sp, #-32]!           ; 16-byte Folded Spill
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	mov	x20, x0
	mov	w0, #16                         ; =0x10
	bl	___cxa_allocate_exception
	mov	x19, x0
Ltmp60:
	mov	x1, x20
	bl	__ZNSt12length_errorC1B9nqe210106EPKc
Ltmp61:
; %bb.1:
Lloh66:
	adrp	x1, __ZTISt12length_error@GOTPAGE
Lloh67:
	ldr	x1, [x1, __ZTISt12length_error@GOTPAGEOFF]
Lloh68:
	adrp	x2, __ZNSt12length_errorD1Ev@GOTPAGE
Lloh69:
	ldr	x2, [x2, __ZNSt12length_errorD1Ev@GOTPAGEOFF]
	mov	x0, x19
	bl	___cxa_throw
LBB20_2:
Ltmp62:
	mov	x20, x0
	mov	x0, x19
	bl	___cxa_free_exception
	mov	x0, x20
	bl	__Unwind_Resume
	.loh AdrpLdrGot	Lloh68, Lloh69
	.loh AdrpLdrGot	Lloh66, Lloh67
Lfunc_end6:
	.cfi_endproc
	.section	__TEXT,__gcc_except_tab
	.p2align	2, 0x0
GCC_except_table20:
Lexception6:
	.byte	255                             ; @LPStart Encoding = omit
	.byte	255                             ; @TType Encoding = omit
	.byte	1                               ; Call site Encoding = uleb128
	.uleb128 Lcst_end6-Lcst_begin6
Lcst_begin6:
	.uleb128 Lfunc_begin6-Lfunc_begin6      ; >> Call Site 1 <<
	.uleb128 Ltmp60-Lfunc_begin6            ;   Call between Lfunc_begin6 and Ltmp60
	.byte	0                               ;     has no landing pad
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp60-Lfunc_begin6            ; >> Call Site 2 <<
	.uleb128 Ltmp61-Ltmp60                  ;   Call between Ltmp60 and Ltmp61
	.uleb128 Ltmp62-Lfunc_begin6            ;     jumps to Ltmp62
	.byte	0                               ;   On action: cleanup
	.uleb128 Ltmp61-Lfunc_begin6            ; >> Call Site 3 <<
	.uleb128 Lfunc_end6-Ltmp61              ;   Call between Ltmp61 and Lfunc_end6
	.byte	0                               ;     has no landing pad
	.byte	0                               ;   On action: cleanup
Lcst_end6:
	.p2align	2, 0x0
                                        ; -- End function
	.section	__TEXT,__text,regular,pure_instructions
	.private_extern	__ZSt28__throw_bad_array_new_lengthB9nqe210106v ; -- Begin function _ZSt28__throw_bad_array_new_lengthB9nqe210106v
	.globl	__ZSt28__throw_bad_array_new_lengthB9nqe210106v
	.weak_def_can_be_hidden	__ZSt28__throw_bad_array_new_lengthB9nqe210106v
	.p2align	2
__ZSt28__throw_bad_array_new_lengthB9nqe210106v: ; @_ZSt28__throw_bad_array_new_lengthB9nqe210106v
	.cfi_startproc
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	w0, #8                          ; =0x8
	bl	___cxa_allocate_exception
	bl	__ZNSt20bad_array_new_lengthC1Ev
Lloh70:
	adrp	x1, __ZTISt20bad_array_new_length@GOTPAGE
Lloh71:
	ldr	x1, [x1, __ZTISt20bad_array_new_length@GOTPAGEOFF]
Lloh72:
	adrp	x2, __ZNSt20bad_array_new_lengthD1Ev@GOTPAGE
Lloh73:
	ldr	x2, [x2, __ZNSt20bad_array_new_lengthD1Ev@GOTPAGEOFF]
	bl	___cxa_throw
	.loh AdrpLdrGot	Lloh72, Lloh73
	.loh AdrpLdrGot	Lloh70, Lloh71
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function _ZN9inference6MatrixclEmm.cold.1
__ZN9inference6MatrixclEmm.cold.1:      ; @_ZN9inference6MatrixclEmm.cold.1
	.cfi_startproc
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	bl	_OUTLINED_FUNCTION_1
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function _ZNK9inference6MatrixclEmm.cold.1
__ZNK9inference6MatrixclEmm.cold.1:     ; @_ZNK9inference6MatrixclEmm.cold.1
	.cfi_startproc
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	bl	_OUTLINED_FUNCTION_1
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function _ZN9inference16matmul_referenceERKNS_6MatrixES2_.cold.1
__ZN9inference16matmul_referenceERKNS_6MatrixES2_.cold.1: ; @_ZN9inference16matmul_referenceERKNS_6MatrixES2_.cold.1
	.cfi_startproc
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	bl	_OUTLINED_FUNCTION_0
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function _ZN9inference10matmul_ikjERKNS_6MatrixES2_.cold.1
__ZN9inference10matmul_ikjERKNS_6MatrixES2_.cold.1: ; @_ZN9inference10matmul_ikjERKNS_6MatrixES2_.cold.1
	.cfi_startproc
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	bl	_OUTLINED_FUNCTION_0
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function _ZN9inference14matmul_blockedERKNS_6MatrixES2_NS_11MatmulTilesE.cold.1
__ZN9inference14matmul_blockedERKNS_6MatrixES2_NS_11MatmulTilesE.cold.1: ; @_ZN9inference14matmul_blockedERKNS_6MatrixES2_NS_11MatmulTilesE.cold.1
	.cfi_startproc
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	bl	_OUTLINED_FUNCTION_0
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function _ZN9inference14matmul_blockedERKNS_6MatrixES2_NS_11MatmulTilesE.cold.2
__ZN9inference14matmul_blockedERKNS_6MatrixES2_NS_11MatmulTilesE.cold.2: ; @_ZN9inference14matmul_blockedERKNS_6MatrixES2_NS_11MatmulTilesE.cold.2
	.cfi_startproc
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	bl	_OUTLINED_FUNCTION_0
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function OUTLINED_FUNCTION_0
_OUTLINED_FUNCTION_0:                   ; @OUTLINED_FUNCTION_0 Thunk
	.cfi_startproc
; %bb.0:
	adrp	x1, __ZTISt16invalid_argument@GOTPAGE
	ldr	x1, [x1, __ZTISt16invalid_argument@GOTPAGEOFF]
	adrp	x2, __ZNSt16invalid_argumentD1Ev@GOTPAGE
	ldr	x2, [x2, __ZNSt16invalid_argumentD1Ev@GOTPAGEOFF]
	b	___cxa_throw
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function OUTLINED_FUNCTION_1
_OUTLINED_FUNCTION_1:                   ; @OUTLINED_FUNCTION_1 Thunk
	.cfi_startproc
; %bb.0:
	adrp	x1, __ZTISt12out_of_range@GOTPAGE
	ldr	x1, [x1, __ZTISt12out_of_range@GOTPAGEOFF]
	adrp	x2, __ZNSt12out_of_rangeD1Ev@GOTPAGE
	ldr	x2, [x2, __ZNSt12out_of_rangeD1Ev@GOTPAGEOFF]
	b	___cxa_throw
	.cfi_endproc
                                        ; -- End function
	.section	__TEXT,__cstring,cstring_literals
l_.str:                                 ; @.str
	.asciz	"Matrix dimensions are too large"

l_.str.1:                               ; @.str.1
	.asciz	"Given input is out of range"

l_.str.2:                               ; @.str.2
	.asciz	"Columns of first matrix must match rows of second matrix"

l_.str.3:                               ; @.str.3
	.asciz	"Tile dimensions must be positive"

l_.str.4:                               ; @.str.4
	.asciz	"vector"

.subsections_via_symbols
