; Ataboot 3.3 for the CT60, assembly version without MiNT library (TOS calls),
; PC adressing, A5 used as bss segment pointer
; and memory sizes alignment (ST-RAM/fast-ram inside get_mem_infos)
;
;  Didier Mequignon 2004, e-mail: aniplay@wanadoo.fr
;
;  Copyright (c) 1993-98 by
;    Arjan Knor
;    Robert de Vries
;    Roman Hodek <Roman.Hodek@informatik.uni-erlangen.de>
;    Andreas Schwab <schwab@issan.informatik.uni-dortmund.de>
; 
;  This file is subject to the terms and conditions of the GNU General Public
;  License.  See the file COPYING in the main directory of this archive
;  for more details.
;

ssp_init	=	0
ev_buserr	=	8
ev_f_line	=	$2c

resvalid	=	$426
resvector	=	$42a
phystop	=	$42e
_hz_200	=	$4ba
_cookies	=	$5A0
TT_ramtop	=	$5A4

MAX_MALLOC	=	256

	.text

	MC68040
	
ataboot:
	
	move.l	4(SP),A6 ; base page
	move.l	12(A6),D0 ; text segment size
	add.l	20(A6),D0 ; data segment size
	lea	ataboot(PC),A5
	add.l	D0,A5 ; bss segment
	add.l	28(A6),D0 ; bss segment size
	add.l	#32768+256,D0 ; stack size + base page size
	andi.b	#$FE,D0
	lea	-104(A6,D0.L),SP
	move.l	D0,-(SP)
	pea	(A6)
	clr	-(SP)
	move	#$4A,-(SP)	; Mshrink
	trap	#1		; Gemdos
	lea	12(SP),SP
	move.l	#-1,-(SP)
	move	#$48,-(SP)	; Malloc
	trap	#1		; Gemdos
	addq	#6,SP
	lsr.l	#1,D0
	move.l	D0,malloc_size-_bss(A5)
	beq	err_ataboot
	move.l	D0,-(SP)
	move	#$48,-(SP)	; Malloc
	trap	#1		; Gemdos
	addq	#6,SP
	tst.l	D0
	beq	err_ataboot
	move.l	D0,malloc_ptr-_bss(A5)
	move.l	#MAX_MALLOC*8,-(SP)
	pea	tab_malloc-_bss(A5)
	bsr	_bzero
	addq	#8,SP
	moveq	#1,D0
	move.l	D0,optind-_bss(A5)
	move.l	D0,suboptionpos-_bss(A5)
	clr.l	insize-_bss(A5)
	clr.l	inptr-_bss(A5)
	clr.l	outcnt-_bss(A5)
	clr.l	exit_code-_bss(A5)
	clr.l	bytes_out-_bss(A5)
	moveq	#-1,D0
	move.l	D0,crc-_bss(A5)
	lea	head_mod-_bss(A5),A0
	lea	head_name(PC),A1
	move.l	A1,(A0)+
	moveq	#12,D0
init1:
		clr.l	(A0)+
	dbf	D0,init1
	lea	file_mod-_bss(A5),A0
	lea	file_name(PC),A1
	move.l	A1,(A0)+
	move.l	#$8000,(A0)+
	lea	file_open(PC),A1
	move.l	A1,(A0)+
	lea	file_fillbuf(PC),A1
	move.l	A1,(A0)+
	lea	file_skip(PC),A1
	move.l	A1,(A0)+
	lea	file_close(PC),A1
	move.l	A1,(A0)+
	moveq	#7,D0
init2:
		clr.l	(A0)+
	dbf	D0,init2
	lea	gunzip_mod-_bss(A5),A0
	lea	gunzip_name(PC),A1
	move.l	A1,(A0)+
	move.l	#$8000,(A0)+
	lea	gunzip_open(PC),A1
	move.l	A1,(A0)+
	lea	gunzip_fillbuf(PC),A1
	move.l	A1,(A0)+
	clr.l	(A0)+
	lea	gunzip_close(PC),A1
	move.l	A1,(A0)+
	moveq	#7,D0
init3:
		clr.l	(A0)+
	dbf	D0,init3
	clr.l	stream_dont_display-_bss(A5)
	clr.l	debugflag-_bss(A5) ; default options
	clr.l	ignore_ttram-_bss(A5)
	clr.l	load_to_stram-_bss(A5)
	moveq	#-1,D0
	move.l	D0,force_st_size-_bss(A5)
	move.l	D0,force_tt_size-_bss(A5)
	clr.l	extramem_start-_bss(A5)
	clr.l	extramem_size-_bss(A5)
	lea 	_kernel_name(PC),A0
	move.l	A0,kernel_name-_bss(A5)
	clr.l	ramdisk_name-_bss(A5)
	clr.l	argv-_bss(A5)
	clr.l	argc-_bss(A5)
	move.l	argv-_bss(A5),-(SP)
	move.l	argc-_bss(A5),-(SP)
	bsr	_main
	addq	#8,SP
err_ataboot:
	move.l	D0,-(SP)
	tst.l	malloc_size-_bss(A5)
	beq.s	end_ataboot
	move.l	malloc_ptr-_bss(A5),-(SP)
	move	#$49,-(SP) ; Mfree
	trap	#1          ; Gemdos
	addq	#6,SP
end_ataboot:
	move	#7,-(SP)	; Crawcin
	trap	#1		; Gemdos
	addq	#2,SP
	bsr	_exit
	nop

help:

	move.l	A2,-(SP)
	pea	menu_help(PC)
	bsr	_printline
	addq	#4,SP
	move	#7,-(SP)	; Crawcin
	trap	#1		; Gemdos
	addq	#2,SP
	clr.l	-(SP)
	bsr	_exit
	nop

usage:

	move.l	A2,-(SP)
	pea	menu_usage(PC)
	bsr	_printline
	addq	#4,SP
	move	#7,-(SP)	; Crawcin
	trap	#1		; Gemdos
	addq	#2,SP
	pea	1.w
	bsr	_exit
	nop
	
_main:

	link	A6,#0
	pea	menu_info(PC)
	bsr	_printline
	pea	menu_authors(PC)
	bsr	_printline
	addq	#8,SP
	pea	12(A6) ; argv
	pea	8(A6) ; argc
	bsr	get_default_args
	addq	#8,SP
	tst.l	12(A6)
	beq	end_main
	pea	options(PC)
	bsr	_printline
	addq	#4,SP
main_getopt_loop:
	pea	options_list(PC); opts: dntsS:T:k:r:m:
	move.l	12(A6),-(SP) ; argv
	move.l	8(A6),-(SP) ; argc
	bsr	_getopt
	movea.l	D0,A0
	addq	#8,SP
	addq	#4,SP
	moveq	#-1,D3
	cmp.l	A0,D3
	beq	end_opt
	adda	#-$3F,A0
	moveq	#$35,D3
	cmp.l	A0,D3
	bcs	usage_opt
	move	tab_jmp_opt(PC,A0.L*2),D0
	jmp	tab_jmp_opt(PC,D0)
tab_jmp_opt:
	dc.w	help_opt-tab_jmp_opt; ?
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	force_st_size_opt-tab_jmp_opt; S
	dc.w	force_tt_size_opt-tab_jmp_opt; T
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	debug_opt-tab_jmp_opt; d
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	help_opt-tab_jmp_opt; h
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	kernel_name_opt-tab_jmp_opt; k
	dc.w	usage_opt-tab_jmp_opt
	dc.w	extramem_opt-tab_jmp_opt; m
	dc.w	main_getopt_loop-tab_jmp_opt; n
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	usage_opt-tab_jmp_opt
	dc.w	ramdisk_name_opt-tab_jmp_opt; r
	dc.w	load_stram_opt-tab_jmp_opt; s
	dc.w	ignore_ttram_opt-tab_jmp_opt; t
debug_opt:
	moveq	#1,D3; d
	move.l	D3,debugflag-_bss(A5)
	pea	_debugflag(PC)
	bsr	_printline
	addq	#4,SP	
	bra	main_getopt_loop
ignore_ttram_opt:
	moveq	#1,D3; t
	move.l	D3,ignore_ttram-_bss(A5)
	pea	_ignore_ttram(PC)
	bsr	_printline
	addq	#4,SP	
	bra	main_getopt_loop
force_tt_size_opt:
	move.l	optarg-_bss(A5),-(SP); T
	bsr	parse_size
	move.l	D0,force_tt_size-_bss(A5)
	addq	#4,SP
	pea	_force_tt_size(PC)
	bsr	_printline
	move.l	force_tt_size-_bss(A5),D0
	bsr	hex_long
	pea	crlf(PC)
	bsr	_printline
	addq	#8,SP
	bra	main_getopt_loop
load_stram_opt:
	moveq	#1,D3; s
	move.l	D3,load_to_stram-_bss(A5)
	pea	_load_to_stram(PC)
	bsr	_printline
	addq	#4,SP	
	bra	main_getopt_loop
force_st_size_opt:
	move.l	optarg-_bss(A5),-(SP); S
	bsr	parse_size
	move.l	D0,force_st_size-_bss(A5)
	addq	#4,SP
	pea	_force_st_size(PC)
	bsr	_printline
	move.l	force_st_size-_bss(A5),D0
	bsr	hex_long
	pea	crlf(PC)
	bsr	_printline
	addq	#8,SP
	bra	main_getopt_loop
kernel_name_opt:
	move.l	optarg-_bss(A5),kernel_name-_bss(A5); k
	pea	__kernel_name(PC)
	bsr	_printline
	move.l	kernel_name-_bss(A5),-(SP)
	bsr	_printline
	pea	crlf(PC)
	bsr	_printline
	addq	#8,SP
	addq	#4,SP	
	bra	main_getopt_loop
ramdisk_name_opt:
	move.l	optarg-_bss(A5),ramdisk_name-_bss(A5); r
	pea	_ramdisk_name(PC)
	bsr	_printline
	move.l	ramdisk_name-_bss(A5),-(SP)
	bsr	_printline
	pea	crlf(PC)
	bsr	_printline
	addq	#8,SP
	addq	#4,SP
	bra	main_getopt_loop
extramem_opt:
	move.l	optarg-_bss(A5),-(SP); m
	bsr	parse_extramem
	addq	#4,SP
	pea	_extramem_start(PC)
	bsr	_printline
	move.l	extramem_start-_bss(A5),D0
	bsr	hex_long
	pea	_extramem_size(PC)
	bsr	_printline
	move.l	extramem_size-_bss(A5),D0
	bsr	hex_long
	pea	crlf(PC)
	bsr	_printline
	addq	#8,SP	
	addq	#4,SP
	bra	main_getopt_loop
help_opt:
	bsr	help; h
usage_opt:
	bsr	usage
	bra	main_getopt_loop
end_opt:
	move.l	optind-_bss(A5),D0
	movea.l	8(A6),A1
	suba.l	D0,A1
	move.l	A1,8(A6)
	movea.l	12(A6),A0
	lea	(A0,D0.L*4),A0
	move.l	A0,12(A6)
	clr.l	D2
	lea	command_line-_bss(A5),A0
	clr.b	(A0)
	lea	-1(A1),A4
	move.l	A4,8(A6)
	tst.l	A1
	beq	main_argc_end
	movea.l	A0,A3
main_argc_loop:
		movea.l	12(A6),A0
		movea.l	(A0),A2
		movea.l	A2,A0
main_strlen_argv_1:
		tst.b	(A0)+
		bne	main_strlen_argv_1
		suba.l	A2,A0
		adda.l	D2,A0
		cmpa.l	#$FE,A0
		bhi.s	main_omit_parameter
		movea.l	A2,A0
main_strlen_argv_2:
		tst.b	(A0)+
		bne	main_strlen_argv_2
		suba.l	A2,A0
		add.l	A0,D2
		tst.b	(A3)
		beq.s	main_cmd_line_nul
		movea.l	A3,A1
		lea	space(PC),A0
main_end_cmd_line_1:
		tst.b	(A1)+
		bne	main_end_cmd_line_1
		subq.l	#1,A1
main_strcat_space:
		move.b	(A0)+,(A1)+
		bne	main_strcat_space
main_cmd_line_nul:
		addq.l	#4,12(A6)
		movea.l	A3,A1
main_end_cmd_line_2:
		tst.b	(A1)+
		bne	main_end_cmd_line_2
		subq.l	#1,A1
main_strcat_argv:
		move.b	(A2)+,(A1)+
		bne	main_strcat_argv
		bra.s	main_argc_next
main_omit_parameter:
		move.l	A2,-(SP)
		pea	warning_1(PC)
		bsr	_printline
		addq	#4,SP
		bsr	_printline
		pea	warning_1a(PC)
		bsr	_printline
		addq	#8,SP
main_argc_next:
		movea.l	8(A6),A0
		lea	-1(A0),A4
		move.l	A4,8(A6)
	tst.l	A0
	bne	main_argc_loop
main_argc_end:
	bsr	_linux_boot
end_main:
	pea	error_57(PC)
	bsr	_printline
	addq	#4,SP
	moveq	#1,D0
	unlk	A6
	rts

parse_extramem:

	link	A6,#-4
	move.l	D2,-(SP)
	move.l	8(A6),D2
	clr.l	-(SP)
	pea	-4(A6)
	move.l	D2,-(SP)
	bsr	conv_string
	move.l	D0,extramem_start-_bss(A5)
	move.l	-4(A6),D0
	addq	#8,SP
	addq	#4,SP
	cmp.l	D0,D2
	bne.s	pe2
	move.l	D0,-(SP)
	pea	error_1(PC)
	bsr	_printline
	addq	#4,SP
	bsr	_printline
	pea	crlf(PC)
	bsr	_printline
	bsr	usage
	addq	#8,SP
pe2:
	movea.l	-4(A6),A0
	cmpi.b	#$3A,(A0)
	beq.s	pe1
	pea	error_2(PC)
	bsr	_printline
	bsr	usage
	addq	#4,SP
pe1:
	move.l	-4(A6),D1
	addq.l	#1,D1
	move.l	D1,-(SP)
	bsr.s	parse_size
	move.l	D0,extramem_size-_bss(A5)
	addq	#4,SP
	move.l	-8(A6),D2
	unlk	A6
	rts

parse_size:

	link	A6,#-4
	movem.l	D2-D3,-(SP)
	move.l	8(A6),D2
	clr.l	-(SP)
	pea	-4(A6)
	move.l	D2,-(SP)
	bsr	conv_string
	move.l	D0,D3
	move.l	-4(A6),D0
	addq	#8,SP
	addq	#4,SP
	cmp.l	D0,D2
	bne.s	ps4
	move.l	D0,-(SP)
	pea	error_3(PC)
	bsr	_printline
	addq	#4,SP
	bsr	_printline
	pea	crlf(PC)
	bsr	_printline
	bsr	usage
	addq	#8,SP
ps4:
	movea.l	-4(A6),A0
	clr.l	D0
	move.b	(A0),D0
	lea	islower(PC),A0
	move.b	(A0,D0.L),D0
	andi.b	#8,D0
	cmpi.b	#$6B,D0
	bne.s	ps3
	moveq	#10,D1
	bra.s	ps2
ps3:
	cmpi.b	#$6D,D0
	bne.s	ps1
	moveq	#20,D1
ps2:
	asl.l	D1,D3
ps1:
	move.l	D3,D0
	movem.l	(SP)+,D2-D3
	unlk	A6
	rts

get_default_args:

	link	A6,#-256
	movem.l	D2-D6/A2-A3,-(SP)
	movea.l	8(A6),A3 ; argc
	movea.l	12(A6),A2 ; argv
	clr.l	-(SP)
	pea	bootargs_name(PC)
	bsr	_open
	move.l	D0,D5
	addq	#8,SP
	bmi	gd1
 	moveq	#1,D6
	move.l	D6,(A3) ; argc
	lea	bootstrap_name(PC),A0
	lea	nargv-_bss(A5),A1
	move.l	A0,(A1)
	move.l	A1,(A2) ; argv
	clr.l	D2
	clr.l	D3
	lea	-256(A6),A2
	clr.l	D4
gd11:
		link	A6,#-2
		moveq	#1,D0
		move.l	D0,-(SP)
		pea	-2(A6)
		move.l	D5,-(SP)
		bsr	_read
		addq	#8,SP
		addq	#4,SP
		tst.l	D0
		ble.s	gd10
		moveq	#0,D0
		move.b	-2(A6),D0
gd10:	
		unlk A6
		tst.l	D0
		ble.s	gd3
		tst.l	D2
		bne.s	gd8
		move.b	D0,D4
		lea	islower(PC),A0
		btst	#4,(A0,D4.L)
		bne.s	gd9
		moveq	#1,D2
		lea	-256(A6),A2
gd9:
		tst.l	D2
		beq.s	gd11
gd8:
		tst.l	D3
		bne.s	gd6
		moveq	#$27,D6
		cmp.l	D0,D6
		beq.s	gd7
		moveq	#$22,D6
		cmp.l	D0,D6
		bne.s	gd5
gd7:
		move.l	D0,D3
		bra.s	gd11
gd6:
		cmp.l	D0,D3
		bne.s	gd4
		clr.l	D3
		bra.s	gd11
gd5:
		clr.l	D1
		move.b	D0,D1
		lea	islower(PC),A0
		btst	#4,(A0,D1.L)
		beq.s	gd4
		clr.b	(A2)
		pea	-256(A6)
		bsr	_strdup
		move.l	(A3),D1
		lea	nargv-_bss(A5),A0
		move.l	D0,(A0,D1.L*4)
		addq.l	#1,(A3)
		clr.l	D2
		addq	#4,SP
		bra	gd11
gd4:
		move.b	D0,(A2)+
	bra	gd11
gd3:
	tst.l	D2
	beq.s	gd2
	clr.b	(A2)
	pea	-256(A6)
	bsr	_strdup
	move.l	(A3),D1
	lea	nargv-_bss(A5),A0
	move.l	D0,(A0,D1.L*4)
	addq.l	#1,(A3)
	addq	#4,SP
gd2:
	move.l	D5,-(SP)
	bsr	_close
	move.l	(A3),D0
	lea	nargv-_bss(A5),A0
	clr.l	(A0,D0.L*4)
	addq	#4,SP
gd1:
	movem.l	(SP)+,D2-D6/A2-A3
	unlk	A6
	rts
	
_linux_boot:

	link	A6,#-96
	movem.l	D2-D7/A2-A4,-(SP)
	suba.l	A4,A4
	clr.l	-96(A6)
	move.l	A4,-(SP)
	move	#$20,-(SP)	; Super
	trap	#1		; Gemdos
	addq	#6,SP
	move.l	D0,userstk-_bss(A5)
	move.l	_cookies,cookiejar-_bss(A5)
	bne.s	lb63
	pea	error_4(PC)
	bsr	_printline
	addq	#4,SP
	move.l	userstk-_bss(A5),-(SP)
	move	#$20,-(SP)	; Super
	trap	#1		; Gemdos
	addq	#6,SP
	move	#7,-(SP)	; Crawcin
	trap	#1		; Gemdos
	addq	#2,SP
	pea	1.w
	bsr	_exit
lb63:
	moveq	#2,D7
	move.l	D7,bi_machtype-_bss(A5)
	lea	bi_command_line-_bss(A5),A3
	lea	command_line-_bss(A5),A0
	movea.l	A3,A1
lb62:
	move.b	(A0)+,(A1)+
	bne	lb62
	movea.l	kernel_name-_bss(A5),A2
	lea	local(PC),A0
	moveq	#6,D0
	movea.l	A2,A1
	move.l	D0,D1
	moveq	#0,D0
	moveq	#0,D2
	subq.l	#1,D1
	bmi	lb60
lb61:
		move.b	(A1)+,D0
		move.b	(A0)+,D2
		beq	lb60
	cmp.b	D2,D0
	dbne	D1,lb61
	bne	lb60
	move.l	D2,D0
lb60:
	sub.l	D2,D0
	tst.l	D0
	bne.s	lb59
	addq	#6,A2
lb59:
	movea.l	A2,A0
lb58:
	tst.b	(A0)+
	bne	lb58
	suba.l	A2,A0
	addq	#8,A0
	addq	#3,A0
	cmpa.l	#$FE,A0
	bhi.s	lb50
	tst.b	(A3)
	beq.s	lb55
	lea	space(PC),A0
	movea.l	A3,A1
lb57:
	tst.b	(A1)+
	bne	lb57
	subq.l	#1,A1
lb56:
	move.b	(A0)+,(A1)+
	bne	lb56
lb55:
	lea	boot_image(PC),A0
	movea.l	A3,A1
lb54:
	tst.b	(A1)+
	bne	lb54
	subq.l	#1,A1
lb53:
	move.b	(A0)+,(A1)+
	bne	lb53
lb52:
	tst.b	(A3)+
	bne	lb52
	subq.l	#1,A3
lb51:
	move.b	(A2)+,(A3)+
	bne	lb51
lb50:
	pea	kernel_command_line(PC)
	bsr	_printline
	pea	bi_command_line-_bss(A5)
	bsr	_printline
	pea	crlf(PC)
	bsr	_printline
	bsr	get_cpu_infos
	bsr	get_mch_type
	addq	#8,SP
	addq	#4,SP
	moveq	#3,D7
	cmp.l	bi_mch_type-_bss(A5),D7
	bne.s	lb49
	lea	_linux_boot(PC),A0
	move.l	A0,D0
	andi.l	#$FF000000,D0
	beq.s	lb49
	pea	error_5(PC)
	bsr	_printline
	addq	#4,SP
	move.l	userstk-_bss(A5),-(SP)
	move	#$20,-(SP)	; Super
	trap	#1		; Gemdos
	addq	#6,SP
	move	#7,-(SP)	; Crawcin
	trap	#1		; Gemdos
	addq	#2,SP
	pea	1.w
	bsr	_exit
lb49:
	clr.l	-(SP)
	pea	cookie_ct2(PC)
	bsr	getcookie
	addq	#8,SP
	moveq	#-1,D7
	cmp.l	D0,D7
	beq.s	lb48
	lea	_linux_boot(PC),A0
	move.l	A0,D0
	andi.l	#$FF000000,D0
	beq.s	lb48
	pea	error_6(PC)
	bsr	_printline
	addq	#4,SP
	move.l	userstk-_bss(A5),-(SP)
	move	#$20,-(SP)	; Super
	trap	#1		; Gemdos
	addq	#6,SP
	move	#7,-(SP)	; Crawcin
	trap	#1		; Gemdos
	addq	#2,SP
	pea	1.w
	bsr	_exit
lb48:
	bsr	get_mem_infos
	move.l	bi_memory_0_addr-_bss(A5),D6
	move.l	bi_memory_0_size-_bss(A5),D5
	tst.l	ramdisk_name-_bss(A5)
	beq	lb42
	clr.l	D2
	bsr	_stream_init
	pea	file_mod-_bss(A5)
	bsr	_stream_push
	move.l	ramdisk_name-_bss(A5),-(SP)
	bsr	_sopen
	addq	#8,SP
	tst.l	D0
	bge.s	lb47
	pea	error_7(PC)
	bsr	_printline
	move.l	ramdisk_name-_bss(A5),-(SP)
	bsr	_printline
	pea	crlf(PC)
	bsr	_printline
	addq	#8,SP
	addq	#4,SP
	move.l	userstk-_bss(A5),-(SP)
	move	#$20,-(SP)	; Super
	trap	#1		; Gemdos
	addq	#6,SP
	move	#7,-(SP)	; Crawcin
	trap	#1		; Gemdos
	addq	#2,SP
	pea	1.w
	bsr	_exit
lb47:
		move.l	D2,D0
		asl.l	#2,D0
		movea.l	D0,A0
		pea	4(A0)
		move.l	-96(A6),-(SP)
		bsr	_realloc
		move.l	D0,-96(A6)
		addq	#8,SP
		beq.s	lb46
		move.l	#$20000,-(SP)
		bsr	_malloc
		movea.l	-96(A6),A0
		move.l	D0,(A0,D2.L*4)
		addq	#4,SP
		bne.s	lb45
lb46:
		pea	error_8(PC)
		bsr	_printline
		bsr	_sclose
		addq	#4,SP
		move.l	userstk-_bss(A5),-(SP)
		move	#$20,-(SP)	; Super
		trap	#1		; Gemdos
		addq	#6,SP
		move	#7,-(SP)	; Crawcin
		trap	#1		; Gemdos
		addq	#2,SP
		pea	1.w
		bsr	_exit
lb45:
		move.l	#$20000,-(SP)
		movea.l	-96(A6),A0
		move.l	(A0,D2.L*4),-(SP)
		bsr	_sread
		addq	#8,SP
		tst.l	D0
		bge.s	lb44
		pea	error_9(PC)
		bsr	_printline
		bsr	_sclose
		addq	#4,SP
		move.l	userstk-_bss(A5),-(SP)
		move	#$20,-(SP)	; Super
		trap	#1		; Gemdos
		addq	#6,SP
		move	#7,-(SP)	; Crawcin
		trap	#1		; Gemdos
		addq	#2,SP
		pea	1.w
		bsr	_exit
lb44:
		tst.l	D0
		beq	lb29
		adda.l	D0,A4
		addq.l	#1,D2
	cmpi.l	#$20000,D0
	beq	lb47
lb43:
	bsr	_sclose
lb42:
	move.l	A4,bi_ramdisk_size-_bss(A5)
	bsr	_stream_init
	pea	file_mod-_bss(A5)
	bsr	_stream_push
	pea	gunzip_mod-_bss(A5)
	bsr	_stream_push
	move.l	kernel_name-_bss(A5),-(SP)
	bsr	_sopen
	addq	#8,SP
	addq	#4,SP
	tst.l	D0
	bge.s	lb41
	pea	error_10(PC)
	bsr	_printline
	move.l	kernel_name-_bss(A5),-(SP)
	bsr	_printline
	pea	crlf(PC)
	bsr	_printline
	addq	#8,SP
	addq	#4,SP
	move.l	userstk-_bss(A5),-(SP)
	move	#$20,-(SP)	; Super
	trap	#1		; Gemdos
	addq	#6,SP
	move	#7,-(SP)	; Crawcin
	trap	#1		; Gemdos
	addq	#2,SP
	pea	1.w
	bsr	_exit
lb41:
	pea	52.w
	pea	-52(A6)
	bsr	_sread
	addq	#8,SP
	moveq	#52,D7
	cmp.l	D0,D7
	beq.s	lb40
	pea	error_11(PC)
	bsr	_printline
	bsr	_sclose
	addq	#4,SP
	move.l	userstk-_bss(A5),-(SP)
	move	#$20,-(SP)	; Super
	trap	#1		; Gemdos
	addq	#6,SP
	move	#7,-(SP)	; Crawcin
	trap	#1		; Gemdos
	addq	#2,SP
	pea	1.w
	bsr	_exit
lb40:
	lea	elf_header(PC),A0
	lea	-52(A6),A1
	cmpm.b	(A0)+,(A1)+
	bne	lb36
	cmpm.b	(A0)+,(A1)+
	bne	lb36
	cmpm.b	(A0)+,(A1)+
	bne	lb36
	cmpm.b	(A0)+,(A1)+
	bne	lb36
	cmpi.l	#$20004,-36(A6)
	bne.s	lb39
	moveq	#1,D7
	cmp.l	-32(A6),D7
	beq.s	lb38
lb39:
	pea	error_12(PC)
	bsr	_printline
	bsr	_sclose
	addq	#4,SP
	move.l	userstk-_bss(A5),-(SP)
	move	#$20,-(SP)	; Super
	trap	#1		; Gemdos
	addq	#6,SP
	move	#7,-(SP)	; Crawcin
	trap	#1		; Gemdos
	addq	#2,SP
	pea	1.w
	bsr	_exit
lb38:
	move	-8(A6),D0
	asl.l	#5,D0
	andi.l	#$1FFFE0,D0
	move.l	D0,-(SP)
	bsr	_malloc
	movea.l	D0,A3
	addq	#4,SP
	tst.l	A3
	bne.s	lb37
	pea	error_13(PC)
	bsr	_printline
	bsr	_sclose
	addq	#4,SP
	move.l	userstk-_bss(A5),-(SP)
	move	#$20,-(SP)	; Super
	trap	#1		; Gemdos
	addq	#6,SP
	move	#7,-(SP)	; Crawcin
	trap	#1		; Gemdos
	addq	#2,SP
	pea	1.w
	bsr	_exit
lb37:
	clr.l	-(SP)
	move.l	-24(A6),-(SP)
	bsr	_sseek
	move	-8(A6),D0
	asl.l	#5,D0
	andi.l	#$1FFFE0,D0
	move.l	D0,-(SP)
	move.l	A3,-(SP)
	bsr	_sread
	clr.l	D1
	move	-8(A6),D1
	asl.l	#5,D1
	addq	#8,SP
	addq	#8,SP
	cmp.l	D0,D1
	beq	lb35
	pea	error_14(PC)
	bsr	_printline
	move.l	kernel_name-_bss(A5),-(SP)	
	bsr	_printline
	pea	crlf(PC)
	bsr	_printline
	bsr	_sclose
	addq	#8,SP
	addq	#4,SP
	move.l	userstk-_bss(A5),-(SP)
	move	#$20,-(SP)	; Super
	trap	#1		; Gemdos
	addq	#6,SP
	move	#7,-(SP)	; Crawcin
	trap	#1		; Gemdos
	addq	#2,SP
	pea	1.w
	bsr	_exit
lb36:
	pea	error_15(PC)
	bsr	_printline
	bsr	_sclose
	addq	#4,SP
	move.l	userstk-_bss(A5),-(SP)
	move	#$20,-(SP)	; Super
	trap	#1		; Gemdos
	addq	#6,SP
	move	#7,-(SP)	; Crawcin
	trap	#1		; Gemdos
	addq	#2,SP
	pea	1.w
	bsr	_exit
lb35:
	addi.l	#$00001000,D6
	addi.l	#$FFFFF000,D5
	moveq	#-1,D2
	suba.l	A0,A0
	move	-8(A6),D0
	clr.l	D3
	tst	D0
	beq.s	lb31
	movea	D0,A1
	clr.l	D4
lb34:
		move.l	D3,D1
		asl.l	#5,D1
		move.l	8(A3,D1.L),D0
		cmp.l	D2,D0
		bcc.s	lb33
		move.l	D0,D2
lb33:
		add.l	20(A3,D1.L),D0
		cmp.l	A0,D0
		bls.s	lb32
		movea.l	D0,A0
lb32:
		addq.l	#1,D3
		move	A1,D4
	cmp.l	D3,D4
	bgt.s	lb34
lb31:
	tst.l	D2
	bne.s	lb30
	move.l	#$00001000,D2
	addi.l	#$00001000,8(A3)
	addi.l	#$00001000,4(A3)
	addi.l	#$FFFFF000,16(A3)
	addi.l	#$FFFFF000,20(A3)
lb30:
	suba.l	D2,A0
	move.l	A0,-92(A6)
	tst.l	A4
	beq.s	lb26
	movea.l	A0,A1
	adda.l	A4,A1
	movea.l	D5,A0
	adda.l	#$FFF80000,A0
	cmpa.l	A1,A0
	bcc.s	lb28
	moveq	#1,D7
	cmp.l	bi_num_memory-_bss(A5),D7
	bge.s	lb28
	move.l	bi_memory_1_addr-_bss(A5),D0
	add.l	bi_memory_1_size-_bss(A5),D0
	bra.s	lb27
lb29:
	movea.l	-96(A6),A0
	move.l	(A0,D2.L*4),-(SP)
	bsr	_free
	addq	#4,SP
	bra	lb43
lb28:
	move.l	D6,D0
	add.l	D5,D0
lb27:
	sub.l	A4,D0
	move.l	D0,bi_ramdisk-_bss(A5)
lb26:
	bsr	create_bootinfo
	tst.l	D0
	bne.s	lb25
	pea	error_16(PC)
	bsr	_printline
	bsr	_sclose
	addq	#4,SP
	move.l	userstk-_bss(A5),-(SP)
	move	#$20,-(SP)	; Super
	trap	#1		; Gemdos
	addq	#6,SP
	move	#7,-(SP)	; Crawcin
	trap	#1		; Gemdos
	addq	#2,SP
	pea	1.w
	bsr	_exit
lb25:
	move.l	bi_size-_bss(A5),D0
	movea.l	-92(A6),A0
	adda.l	D0,A0
	move.l	A0,-88(A6)
	cmpi.l	#$58D,D0
	bhi.s	lb24
	movea.l	-92(A6),A0
	adda	#$58E,A0
	move.l	A0,-88(A6)
lb24:
	move.l	-88(A6),D0
	addq.l	#3,D0
	moveq	#-4,D7
	and.l	D7,D0
	lea	(A4,D0.L),A0
	move.l	A0,-88(A6)
	move.l	A0,-(SP)
	bsr	_malloc
	move.l	D0,D5
	addq	#4,SP
	bne.s	lb23
	pea	error_17(PC)
	bsr	_printline
	bsr	_sclose
	addq	#4,SP
	move.l	userstk-_bss(A5),-(SP)
	move	#$20,-(SP)	; Super
	trap	#1		; Gemdos
	addq	#6,SP
	move	#7,-(SP)	; Crawcin
	trap	#1		; Gemdos
	addq	#2,SP
	pea	1.w
	bsr	_exit
lb23:
	moveq	#3,D7
	cmp.l	bi_mch_type-_bss(A5),D7
	bne.s	lb22
	move.l	D5,D0
	andi.l	#$FF000000,D0
	beq.s	lb22
	pea	error_18(PC)
	bsr	_printline
	bsr	_sclose
	addq	#4,SP
	move.l	userstk-_bss(A5),-(SP)
	move	#$20,-(SP)	; Super
	trap	#1		; Gemdos
	addq	#6,SP
	move	#7,-(SP)	; Crawcin
	trap	#1		; Gemdos
	addq	#2,SP
	pea	1.w
	bsr	_exit
lb22:
	clr.l	-(SP)
	pea	cookie_ct2(PC)
	bsr	getcookie
	addq	#8,SP
	moveq	#-1,D7
	cmp.l	D0,D7
	beq.s	lb21
	move.l	D5,D0
	andi.l	#$FF000000,D0
	beq.s	lb21
	pea	error_19(PC)
	bsr	_printline
	bsr	_sclose
	addq	#4,SP
	move.l	userstk-_bss(A5),-(SP)
	move	#$20,-(SP)	; Super
	trap	#1		; Gemdos
	addq	#6,SP
	move	#7,-(SP)	; Crawcin
	trap	#1		; Gemdos
	addq	#2,SP
	pea	1.w
	bsr	_exit
lb21:
	movea.l	-88(A6),A0
	suba.l	A4,A0
	move.l	A0,-(SP)
	clr.l	-(SP)
	move.l	D5,-(SP)
	bsr	_memset
	addq	#8,SP
	addq	#4,SP
	tst.l	A4
	beq.s	lb17
	movea.l	-96(A6),A2
	movea.l	-88(A6),A0
	adda.l	D5,A0
	move.l	A0,D3
	sub.l	A4,D3
	move.l	A4,D2
	cmpa.l	#$20000,A4
	bls.s	lb19
lb20:
		move.l	#$20000,-(SP)
		move.l	(A2),-(SP)
		move.l	D3,-(SP)
		bsr	_memmove
		addq	#8,SP
		move.l	(A2)+,(SP)
		bsr	_free
		addq	#4,SP
		addi.l	#$00020000,D3
		addi.l	#$FFFE0000,D2
	cmpi.l	#$00020000,D2
	bhi.s	lb20
lb19:
	tst.l	D2
	beq.s	lb18
	move.l	D2,-(SP)
	move.l	(A2),-(SP)
	move.l	D3,-(SP)
	bsr	_memmove
	addq	#8,SP
	move.l	(A2),(SP)
	bsr	_free
	addq	#4,SP
lb18:
	move.l	-96(A6),-(SP)
	bsr	_free
	addq	#4,SP
lb17:
	clr.l	D3
	tst	-8(A6)
	beq	lb13
	suba.l	A2,A2
lb16:
		clr.l	-(SP)
		move.l	4(A3,A2.L),-(SP)
		bsr	_sseek
		addq	#8,SP
		moveq	#-1,D7
		cmp.l	D0,D7
		bne.s	lb15
		pea	error_20(PC)
		bsr	_printline
		move.l	D3,D0
		bsr	display_deci
		pea	crlf(PC)
		bsr	_printline
		bsr	_sclose
		addq	#8,SP
		move.l	userstk-_bss(A5),-(SP)
		move	#$20,-(SP)	; Super
		trap	#1		; Gemdos
		addq	#6,SP
		move	#7,-(SP)	; Crawcin
		trap	#1		; Gemdos
		addq	#2,SP
		pea	1.w
		bsr	_exit
lb15:
		move.l	16(A3,A2.L),-(SP)
		movea.l	D5,A0
		adda.l	8(A3,A2.L),A0
		pea	-$1000(A0)
		bsr	_sread
		addq	#8,SP
		cmp.l	16(A3,A2.L),D0
		beq.s	lb14
		pea	error_21(PC)
		bsr	_printline
		move.l	D3,D0
		bsr	display_deci
		pea	crlf(PC)
		bsr	_printline
		bsr	_sclose
		addq	#8,SP
		move.l	userstk-_bss(A5),-(SP)
		move	#$20,-(SP)	; Super
		trap	#1		; Gemdos
		addq	#6,SP
		move	#7,-(SP)	; Crawcin
		trap	#1		; Gemdos
		addq	#2,SP
		pea	1.w
		bsr	_exit
lb14:
		adda	#32,A2
		addq.l	#1,D3
		clr.l	D0
		move	-8(A6),D0
	cmp.l	D3,D0
	bgt	lb16
lb13:
	bsr	_sclose
	move.l	D5,-(SP)
	bsr	check_bootinfo_version
	addq	#4,SP
	moveq	#1,D7
	cmp.l	D0,D7
	beq.s	lb12
	moveq	#2,D7
	cmp.l	D0,D7
	bne	lb10
	lea	bi_union_record-_bss(A5),A0
	bra	lb9
lb12:
	bsr	create_compat_bootinfo
	tst.l	D0
	bne.s	lb11
	pea	error_22(PC)
	bsr	_printline
	addq	#4,SP
	move.l	userstk-_bss(A5),-(SP)
	move	#$20,-(SP)	; Super
	trap	#1		; Gemdos
	addq	#6,SP
	move	#7,-(SP)	; Crawcin
	trap	#1		; Gemdos
	addq	#2,SP
	pea	1.w
	bsr	_exit
lb11:
	lea	compat_bootinfo_machtype-_bss(A5),A0
	move.l	#$58E,bi_size-_bss(A5)
	bra.s	lb9
lb10:
	pea	error_23(PC)
	bsr	_printline
	addq	#4,SP
	move.l	userstk-_bss(A5),-(SP)
	move	#$20,-(SP)	; Super
	trap	#1		; Gemdos
	addq	#6,SP
	move	#7,-(SP)	; Crawcin
	trap	#1		; Gemdos
	addq	#2,SP
	pea	1.w
	bsr	_exit
lb9:
	move.l	bi_size-_bss(A5),-(SP)
	move.l	A0,-(SP)
	movea.l	-92(A6),A0
	pea	(A0,D5.L)
	bsr	_memmove
	addq	#8,SP
	addq	#4,SP
	tst.l	debugflag-_bss(A5)
	beq	lb5
	tst.l	A4
	beq.s	lb8
	move.l	D5,D7
	sub.l	A4,D7
	pea	ramdisk_src(PC)
	bsr	_printline
	move.l	D7,D0
	bsr	hex_long
	pea	ramdisk_src_a(PC)
	bsr	_printline
	move.l	bi_ramdisk_size-_bss(A5),D0
	bsr	display_deci	
	pea	crlf(PC)
	bsr	_printline
	pea	ramdisk_dest(PC)
	bsr	_printline
	movea.l	bi_ramdisk-_bss(A5),A0
	pea	-1(A4,A0.L)
	move.l	A0,D0
	bsr	hex_long
	pea	ramdisk_dest_a(PC)
	bsr	_printline
	addq	#4,SP
	move.l	(SP)+,D0
	bsr	hex_long
	pea	crlf(PC)
	bsr	_printline
	adda	#20,SP
lb8:
	pea	kernel_src(PC)
	bsr	_printline
	move.l	D5,D0
	bsr	hex_long
	pea	kernel_src_a(PC)
	bsr	_printline
	move.l	-88(A6),D0
	bsr	display_deci
	pea	crlf(PC)
	bsr	_printline
	addq	#8,SP
	addq	#4,SP	
	clr.l	D3
	tst	-8(A6)
	beq.s	lb6
	clr.l	D2
lb7:
		pea	kernel_segment(PC)
		bsr	_printline
		move.l	D3,D0
		bsr	display_deci
		pea	kernel_segment_a(PC)
		bsr	_printline
		move.l	D3,D0
		asl.l	#5,D0
		movea.l	D6,A0
		adda.l	8(A3,D0.L),A0
		lea	-$1000(A0),A0
		move.l	A0,D0
		bsr	hex_long
		pea	kernel_segment_b(PC)
		bsr	_printline
		move.l	D3,D0
		asl.l	#5,D0
		move.l	20(A3,D0.L),D0
		bsr	display_deci
		pea	crlf(PC)
		bsr	_printline
		addq	#8,SP
		addq	#8,SP
		addq.l	#1,D3
		move	-8(A6),D2
	cmp.l	D3,D2
	bgt.s	lb7
lb6:
	movea.l	-92(A6),A0
	pea	(A0,D6.L)
	pea	boot_info_adr(PC)
	bsr	_printline
	addq	#4,SP
	move.l	(SP)+,D0
	bsr	hex_long
	pea	crlf(PC)
	bsr	_printline
	pea	type_a_key(PC)
	bsr	_printline
	addq	#8,SP
	move	#7,-(SP)	; Crawcin
	trap	#1		; Gemdos
	addq	#2,SP
lb5:
	pea	booting(PC)
	bsr	_printline
	addq	#4,SP
	ori	#$700,SR ; disable_interrupts
	move.l	bi_cputype-_bss(A5),D1; disable_cache
	btst	#3,D1
	beq.s	lb4; <> 68060
	dc.l	$4e7A0808; movec	pcr,D0
	bclr	#1,D0    ; enable PFU
	bset	#0,D0    ; superscalar
	dc.l	$4e7b0808; movec	D0,pcr
	dc.w	$f478    ; cpusha	dc
	moveq	#0,D0
	movec	D0,CACR
	dc.w	$f4d8    ; cinva	bc
	dc.w	$f518    ; pflusha	
	bra.s	lb3
lb4:
	moveq	#0,D0
	movec	D0,CACR
lb3:
	moveq	#$C,D0; disable_mmu
	and.l	D1,D0; bi_cputype
	beq.s	lb2
	moveq	#0,D0; 68040/60
	movec	D0,TC
	move.l	#$807FE040,D0; cache inhibit precise
	movec	D0,ITT0
	movec	D0,DTT0
	move.l	#$007FE040,D0
	movec	D0,ITT1
	movec	D0,DTT1
	bra.s	lb1
lb2:
	MC68030	

	subq.l	#4,SP
	pmove	TC,(SP)
	bclr	#7,(SP)
	pmove	(SP),TC
	addq.l	#4,SP
	btst	#1,D1
	beq.s	lb1
	clr.l	-(SP)
	pmove	(SP),TT0
	pmove	(SP),TT1
	addq.l	#4,SP
	
	MC68040
lb1:
	clr.l	resvalid.w
	lea	copyall(PC),A0
	lea	copyallend(PC),A1
	suba.l	A0,A1
	move.l	A1,-(SP)
	move.l	A0,-(SP)
	pea	$400.w
	bsr	_memmove
	lea	$1000,SP
	move.l	bi_ramdisk-_bss(A5),D4
	add.l	A4,D4
	move.l	-88(A6),D3
	add.l	D5,D3
	move.l	-92(A6),D2
	add.l	bi_size-_bss(A5),D2
	lea	$400,A6
	movea.l	D6,A0
	movea.l	D5,A1
	movea.l	D4,A2
	movea.l	D3,A3
	move.l	D2,D0
	move.l	A4,D1
	jmp	(A6)

get_cpu_infos:

	adda	#-220,SP
	movem.l	D2-D4/A2-A4,-(SP)
	bsr	test_cpu_type
	movea.l	D0,A3
	moveq	#30,D4
	cmp.l	A3,D4
	beq	gci12
	bcs.s	gci15
	tst.l	A3
	beq.s	gci14
	moveq	#20,D4
	cmp.l	A3,D4
	beq.s	gci13
	bra	gci8
gci15:
	moveq	#40,D4
	cmp.l	A3,D4
	beq.s	gci11
	moveq	#60,D4
	cmp.l	A3,D4
	beq.s	gci10
	bra	gci8
gci14:
	pea	error_24(PC)
	bsr	_printline
	addq	#4,SP
	move.l	userstk-_bss(A5),-(SP)
	move	#$20,-(SP)	; Super
	trap	#1		; Gemdos
	addq	#6,SP
	move	#7,-(SP)	; Crawcin
	trap	#1		; Gemdos
	addq	#2,SP
	pea	1.w
	bsr	_exit
gci13:
	moveq	#1,D4
	bra.s	gci9
gci12:
	moveq	#2,D4
	bra.s	gci9
gci11:
	moveq	#4,D4
	bra.s	gci9
gci10:
	moveq	#8,D4
gci9:
	move.l	D4,bi_cputype-_bss(A5)
	move.l	D4,bi_mmutype-_bss(A5)
	bra.s	gci7
gci8:
	pea	error_25(PC)
	bsr	_printline
	addq	#4,SP
	move.l	userstk-_bss(A5),-(SP)
	move	#$20,-(SP)	; Super
	trap	#1		; Gemdos
	addq	#6,SP
	move	#7,-(SP)	; Crawcin
	trap	#1		; Gemdos
	addq	#2,SP
	pea	1.w
	bsr	_exit
gci7:
	pea	type_cpu(PC)
	bsr	_printline
	movea.l	#68000,A4
	adda.l	A3,A4
	move.l	A4,D0
	bsr	display_deci
	pea	type_cpu_a(PC)
	bsr	_printline
	pea	type_fpu(PC)
	bsr	_printline
	addq	#8,SP
	addq	#4,SP
	moveq	#40,D4
	cmp.l	A3,D4
	beq.s	gci6
	moveq	#60,D4
	cmp.l	A3,D4
	beq.s	gci5
	bra.s	gci4
gci6:
	moveq	#4,D4
	move.l	D4,bi_fputype-_bss(A5)
	pea	type_fpu_68040(PC)
	bra.s	gci1
gci5:
	moveq	#8,D4
	move.l	D4,bi_fputype-_bss(A5)
	pea	type_fpu_68060(PC)
	bra.s	gci1
gci4:
	bsr	test_software_fpu
	tst.l	D0
	beq.s	gci3
	pea	type_fpu_none(PC)
	bra.s	gci1
gci3:
	dc.l	$F2800000
	lea	24(SP),A0
	dc.w	$F310
	cmpi.b	#$18,$19(SP)
	beq.s	gci2
	moveq	#2,D4
	move.l	D4,bi_fputype-_bss(A5)
	pea	type_fpu_68882(PC)
	bra.s	gci1
gci2:
	moveq	#1,D4
	move.l	D4,bi_fputype-_bss(A5)
	pea	type_fpu_68881(PC)
gci1:
	bsr	_printline
	pea	crlf(PC)
	bsr	_printline
	addq	#8,SP
	movem.l	(SP)+,D2-D4/A2-A4
	adda	#220,SP
	rts

get_mch_type:

	link	A6,#-4
	movem.l	D2-D3/A2-A3,-(SP)
	pea	-4(A6)
	pea	cookie_mch(PC)
	bsr	getcookie
	move.l	-4(A6),bi_mch_cookie-_bss(A5)
	lea	bi_mch_type-_bss(A5),A3
	clr.l	(A3)
	clr.l	-(SP)
	pea	cookie_ct2(PC)
	bsr	getcookie
	addq	#8,SP
	addq	#8,SP
	moveq	#-1,D3
	cmp.l	D0,D3
	bne	gm13
	movea.l	ev_buserr.w,A0
	movea.l	SP,A1
	move	SR,D2
	ori	#$700,SR
	move.b	ssp_init.w,D1
	lea	gm21(PC),A2
	move.l	A2,ev_buserr.w
	moveq	#0,D0
	clr.b	ssp_init.w
	nop
	moveq	#1,D0
	move.b	D1,ssp_init.w
	nop
	tst.b	$FF82FE
	nop
	moveq	#2,D0
	nop
	tst.b	$B0000000
	nop
	moveq	#3,D0
gm21:
	movea.l	A1,SP
	move.l	A0,ev_buserr.w
	move	D2,SR
	moveq	#2,D3
	cmp.l	D0,D3
	beq.s	gm18
	blt.s	gm20
	moveq	#1,D3
	cmp.l	D0,D3
	beq.s	gm19
	bra.s	gm15
gm20:
	moveq	#3,D3
	cmp.l	D0,D3
	beq.s	gm17
	bra.s	gm15
gm19:
	moveq	#3,D3
	bra.s	gm16
gm18:
	moveq	#1,D3
	bra.s	gm16
gm17:
	moveq	#2,D3
gm16:
	move.l	D3,(A3)
gm15:
	lea	bi_mch_type-_bss(A5),A2
	tst.l	(A2)
	bne.s	gm13
	clr.l	-(SP)
	pea	cookie_ab40(PC)
	bsr	getcookie
	addq	#8,SP
	moveq	#-1,D3
	cmp.l	D0,D3
	bne.s	gm14
	cmpi	#3,bi_mch_cookie-_bss(A5)
	bne.s	gm13
	moveq	#4,D3
	cmp.l	bi_cputype-_bss(A5),D3
	bne.s	gm13
gm14:
	moveq	#3,D3
	move.l	D3,(A2)
gm13:
	pea	model(PC)
	bsr	_printline
	addq	#4,SP
	move.l	bi_mch_cookie-_bss(A5),D1
	move.l	D1,D0
	clr	D0
	swap	D0
	moveq	#1,D3
	cmp.l	D0,D3
	beq.s	gm11
	bhi.s	gm12
	moveq	#2,D3
	cmp.l	D0,D3
	beq.s	gm9
	moveq	#3,D3
	cmp.l	D0,D3
	beq.s	gmt5
	bra	gmt2
gm12:
	pea	model_st(PC)
	bra.s	gmt6
gm11:
	tst	D1
	beq.s	gm10
	pea	model_mega_ste(PC)
	bra.s	gmt6
gm10:
	pea	model_ste(PC)
	bra.s	gmt6
gm9:
	move.l	bi_mch_type-_bss(A5),D0
	moveq	#1,D3
	cmp.l	D0,D3
	bne.s	gmt8
	pea	model_medusa(PC)
	bra.s	gmt6
gmt8:
	moveq	#2,D3
	cmp.l	D0,D3
	bne.s	gmt7
	pea	model_hades(PC)
	bra.s	gmt6
gmt7:
	pea	model_tt(PC)
gmt6:
	bsr	_printline
	addq	#4,SP
	bra.s	gmt1
gmt5:
	pea	model_falcon(PC)
	bsr	_printline
	addq	#4,SP
	clr.l	-(SP)
	pea	cookie_ct60(PC)
	bsr	getcookie
	addq	#8,SP
	moveq	#-1,D3
	cmp.l	D0,D3
	beq.s	gmt4
	pea	with_ct60(PC)
	bsr	_printline
	addq	#4,SP
	bra.s	gmt3
gmt4:
	moveq	#3,D3
	cmp.l	bi_mch_type-_bss(A5),D3
	bne.s	gmt3
	pea	with_ab040(PC)
	bsr	_printline
	addq	#4,SP
gmt3:
	pea	crlf(PC)
	bsr	_printline
	addq	#4,SP
	bra.s	gmt1
gmt2:
	pea	error_26(PC)
	bsr	_printline
	move.l	bi_mch_cookie-_bss(A5),D0
	bsr	hex_long	
	addq	#4,SP
gmt1:
	movem.l	-20(A6),D2-D3/A2-A3
	unlk	A6
	rts

get_mem_infos:

	link	A6,#-32
	movem.l	D2-D6/A2-A4,-(SP)
	clr.l	D4
	suba.l	A2,A2
	cmpi.l	#$3FFFF,force_st_size-_bss(A5)
	bhi.s	gmi31
	move.l	#$40000,force_st_size-_bss(A5)
	pea	warning_2(PC)
	bsr	_printline
	addq	#4,SP
gmi31:
	move.l	bi_mch_type-_bss(A5),D0
	moveq	#1,D5
	cmp.l	D0,D5
	bne	gmi19
	pea	-8(A6)
	pea	-4(A6)
	bsr	get_medusa_bank_sizes
	move.l	phystop.w,D3
	andi.l	#$FFF00000,D3
	sub.l	D3,-4(A6)
	addq	#8,SP
	tst.l	load_to_stram-_bss(A5)
	beq.s	gmi30
	pea	warning_3(PC)
	bsr	_printline
	addq	#4,SP
gmi30:
	move.l	D3,D0
	move.l	force_st_size-_bss(A5),D1
	blt.s	gmi29
	move.l	D1,D0
gmi29:
	tst.l	D0
	beq.s	gmi28
	clr.l	bi_memory_0_addr-_bss(A5)
	move.l	D0,bi_memory_0_size-_bss(A5)
	movea.l	D0,A2
	pea	medusa_ram(PC)
	bsr	_printline
	move.l	A2,-(SP)
	bsr	display_format_mb
	pea	st_ram_a(PC)
	bsr	_printline
	moveq	#1,D4
	addq	#8,SP
	addq	#4,SP
gmi28:
	move.l	force_tt_size-_bss(A5),D0
	blt.s	gmi27
	move.l	-4(A6),D1
	move.l	D0,D2
	cmp.l	D2,D1
	bcc.s	gmi26
	move.l	D1,D2
	bra.s	gmi26
gmi27:
	moveq	#-1,D2
gmi26:
	tst.l	ignore_ttram-_bss(A5)
	bne.s	gmi24
	move.l	-4(A6),D0
	beq.s	gmi24
	addi.l	#$20000000,D3
	move.l	D0,D1
	andi.l	#$FFFC0000,D1
	tst.l	D2
	blt.s	gmi25
	move.l	D2,D1
gmi25:
	tst.l	D1
	beq.s	gmi24
	move.l	D4,D0
	asl.l	#3,D0
	lea	bi_machtype-_bss(A5),A0
	move.l	D3,20(A0,D0.L)
	move.l	D1,24(A0,D0.L)
	adda.l	D1,A2
	pea	tt_ram_bank_1(PC)
	bsr	_printline
	move.l	D1,-(SP)
	bsr	display_format_mb
	pea	alternate_ram_a(PC)
	bsr	_printline
	move.l	D3,D0
	bsr	hex_long
	pea	crlf(PC)
	bsr	_printline
	addq.l	#1,D4
	addq	#8,SP
	addq	#8,SP
gmi24:
	move.l	force_tt_size-_bss(A5),D0
	blt.s	gmi23
	move.l	-4(A6),D1
	clr.l	D2
	cmp.l	D0,D1
	bcc.s	gmi22
	move.l	D0,D2
	sub.l	D1,D2
	bra.s	gmi22
gmi23:
	moveq	#-1,D2
gmi22:
	tst.l	ignore_ttram-_bss(A5)
	bne.s	gmi20
	move.l	-8(A6),D0
	beq.s	gmi20
	move.l	#$24000000,D3
	move.l	D0,D1
	andi.l	#$FFFC0000,D1
	tst.l	D2
	blt.s	gmi21
	move.l	D2,D1
gmi21:
	tst.l	D1
	beq.s	gmi20
	move.l	D4,D0
	asl.l	#3,D0
	lea	bi_machtype-_bss(A5),A0
	move.l	D3,20(A0,D0.L)
	move.l	D1,24(A0,D0.L)
	adda.l	D1,A2
	pea	tt_ram_bank_2(PC)
	bsr	_printline
	move.l	D1,-(SP)
	bsr	display_format_mb
	pea	alternate_ram_a(PC)
	bsr	_printline
	move.l	D3,D0
	bsr	hex_long
	pea	crlf(PC)
	bsr	_printline
	addq.l	#1,D4
	addq	#8,SP
	addq	#8,SP
gmi20:
	move.l	D4,bi_num_memory-_bss(A5)
	bra	gmi6
gmi19:
	moveq	#3,D6
	cmp.l	D0,D6
	bne	gmi16
	pea	-24(A6)
	pea	2.w
	bsr	get_ab040_bank_sizes
	move.l	D0,D3
	addq	#8,SP
	tst.l	ignore_ttram-_bss(A5)
	bne	gmi6
	tst.l	D3
	ble.s	gmi17
	move.l	-24(A6),D2
	move.l	-20(A6),D0
	andi.l	#$FFFC0000,D0
	move.l	force_tt_size-_bss(A5),D1
	blt.s	gmi18
	move.l	D1,D0
gmi18:
	tst.l	D0
	beq.s	gmi17
	move.l	D2,bi_memory_0_addr-_bss(A5)
	move.l	D0,bi_memory_0_size-_bss(A5)
	movea.l	D0,A2
	pea	fast_ram_bank_1(PC)
	bsr	_printline
	move.l	A2,-(SP)
	bsr	display_format_mb
	pea	alternate_ram_a(PC)
	bsr	_printline
	move.l	D2,D0
	bsr	hex_long
	pea	crlf(PC)
	bsr	_printline
	addq	#8,SP
	addq	#8,SP	
	moveq	#1,D4
gmi17:
	tst.l	ignore_ttram-_bss(A5)
	bne	gmi6
	moveq	#1,D5
	cmp.l	D3,D5
	bge	gmi6
	tst.l	force_tt_size-_bss(A5)
	bge	gmi6
	move.l	-16(A6),D2
	move.l	-12(A6),D1
	andi.l	#$FFFC0000,D1
	beq	gmi6
	move.l	D4,D0
	asl.l	#3,D0
	lea	bi_machtype-_bss(A5),A0
	move.l	D2,20(A0,D0.L)
	move.l	D1,24(A0,D0.L)
	adda.l	D1,A2
	pea	fast_ram_bank_2(PC)
	bsr	_printline
	move.l	D1,-(SP)
	bsr	display_format_mb
	pea	alternate_ram_a(PC)
	bsr	_printline
	move.l	D2,D0
	bsr	hex_long
	pea	crlf(PC)
	bsr	_printline
	addq.l	#1,D4
	bra	gmi7
gmi16:
	tst.l	ignore_ttram-_bss(A5)
	bne	gmi6
	lea	TT_ramtop,A3
	tst.l	(A3)
	beq	gmi12
	clr.l	-(SP)
	pea	cookie_ct2(PC)
	bsr	getcookie
	addq	#8,SP
	moveq	#-1,D6
	cmp.l	D0,D6
	beq.s	gmi14
	move.l	#$04000000,D2
	move.l	(A3),D0
	addi.l	#$FF000000,D0
	andi.l	#$FFFC0000,D0
	move.l	force_tt_size-_bss(A5),D1
	blt.s	gmi15
	move.l	D1,D0
gmi15:
	tst.l	D0
	beq	gmi6
	move.l	D2,bi_memory_0_addr-_bss(A5)
	move.l	D0,bi_memory_0_size-_bss(A5)
	movea.l	D0,A2
	pea	tt_ram(PC)
	bra	gmi8
gmi14:
	move.l	#$01000000,D2
	move.l	(A3),D0
	addi.l	#$FF000000,D0
	addi.l	#$001FFFFF,D0          ;<<<<<<<<	
	andi.l	#$FFE00000,D0          ;<<<<<<<<
;	andi.l	#$FFFC0000,D0
	move.l	force_tt_size-_bss(A5),D1
	blt.s	gmi13
	move.l	D1,D0
gmi13:
	tst.l	D0
	beq	gmi6
	move.l	D2,bi_memory_0_addr-_bss(A5)
	move.l	D0,bi_memory_0_size-_bss(A5)
	movea.l	D0,A2
	pea	tt_ram(PC)
	bra	gmi8
gmi12:
	pea	-28(A6)
	pea	cookie_magn(PC)
	bsr	getcookie
	addq	#8,SP
	moveq	#-1,D5
	cmp.l	D0,D5
	beq.s	gmi10
	movea.l	-28(A6),A0
	move.l	2(A0),D2
	move.l	6(A0),D0
	andi.l	#$FFFC0000,D0
	move.l	force_tt_size-_bss(A5),D1
	blt.s	gmi11
	move.l	D1,D0
gmi11:
	tst.l	D0
	beq	gmi6
	move.l	D2,bi_memory_0_addr-_bss(A5)
	move.l	D0,bi_memory_0_size-_bss(A5)
	movea.l	D0,A2
	pea	magnum_ram(PC)
	bra.s	gmi8
gmi10:
	pea	-2(A6)
	pea	cookie_bpfx(PC)
	bsr	getcookie
	addq	#8,SP
	moveq	#-1,D6
	cmp.l	D0,D6
	beq.s	gmi6
	movea.l	-32(A6),A0
	tst.l	A0
	beq.s	gmi6
	move.l	4(A0),D2
	move.l	8(A0),D0
	andi.l	#$FFFC0000,D0
	move.l	force_tt_size-_bss(A5),D1
	blt.s	gmi9
	move.l	D1,D0
gmi9:
	tst.l	D0
	beq.s	gmi6
	move.l	D2,bi_memory_0_addr-_bss(A5)
	move.l	D0,bi_memory_0_size-_bss(A5)
	movea.l	D0,A2
	pea	fx_ram(PC)
gmi8:
	bsr	_printline
	move.l	A2,-(SP)
	bsr	display_format_mb
	pea	alternate_ram_a(PC)
	bsr	_printline
	move.l	D2,D0
	bsr	hex_long
	pea	crlf(PC)
	bsr	_printline
	moveq	#1,D4
gmi7:
	addq	#8,SP
	addq	#8,SP
gmi6:
	moveq	#1,D5
	cmp.l	bi_mch_type-_bss(A5),D5
	beq	gmi3
	move.l	phystop.w,D1
	addi.l	#$0003FFFF,D1          ;<<<<<<<<
	andi.l	#$FFFC0000,D1
	move.l	force_st_size-_bss(A5),D0
	blt.s	gmi5
	move.l	D0,D1
gmi5:
	tst.l	D1
	beq.s	gmi4
	move.l	D4,D0
	asl.l	#3,D0
	lea	bi_machtype-_bss(A5),A0
	clr.l	20(A0,D0.L)
	move.l	D1,24(A0,D0.L)
	adda.l	D1,A2
	pea	st_ram(PC)
	bsr	_printline
	move.l	D1,-(SP)
	bsr	display_format_mb
	pea	st_ram_a(PC)
	bsr	_printline
	addq.l	#1,D4
	addq	#8,SP
	addq	#4,SP
gmi4:
	move.l	D4,bi_num_memory-_bss(A5)
	tst.l	load_to_stram-_bss(A5)
	beq.s	gmi3
	moveq	#1,D6
	cmp.l	D4,D6
	bge.s	gmi3
	lea	bi_mmutype-_bss(A5),A1
	move.l	(A1,D4.L*8),D0
	move.l	4(A1,D4.L*8),D1
	lea	bi_memory_0_addr-_bss(A5),A0
	move.l	(A0),D5
	move.l	4(A0),D6
	move.l	D5,(A1,D4.L*8)
	move.l	D6,4(A1,D4.L*8)
	move.l	D0,(A0)
	move.l	D1,4(A0)
gmi3:
	move.l	extramem_start-_bss(A5),D2
	beq.s	gmi2
	move.l	extramem_size-_bss(A5),D0
	beq.s	gmi2
	move.l	D0,D1
	andi.l	#$FFFC0000,D1
	beq.s	gmi2
	move.l	D4,D0
	asl.l	#3,D0
	lea	bi_machtype-_bss(A5),A0
	move.l	D2,20(A0,D0.L)
	move.l	D1,24(A0,D0.L)
	adda.l	D1,A2
	pea	alternate_ram(PC)
	bsr	_printline
	move.l	D1,-(SP)
	bsr	display_format_mb
	pea	alternate_ram_a(PC)
	bsr	_printline
	move.l	D2,D0
	bsr	hex_long
	pea	crlf(PC)
	bsr	_printline
	addq	#8,SP
	addq	#8,SP
gmi2:
	moveq	#2,D6
	cmp.l	A2,D6
	bcs.s	gmi1
	pea	error_27(PC)
	bsr	_printline
	addq	#4,SP
	move.l	userstk-_bss(A5),-(SP)
	move	#$20,-(SP)	; Super
	trap	#1		; Gemdos
	addq	#6,SP
	move	#7,-(SP)	; Crawcin
	trap	#1		; Gemdos
	addq	#2,SP
	pea	1.w
	bsr	_exit
gmi1:
	pea	total_ram(PC)
	bsr	_printline
	move.l	A2,-(SP)
	bsr.s	display_format_mb
	pea	total_ram_a(PC)
	bsr	_printline
	addq	#8,SP
	addq	#4,SP
	movem.l	-64(A6),D2-D6/A2-A4
	unlk	A6
	rts

display_format_mb:

	move.l	A2,-(SP)
	move.l	D2,-(SP)
	move.l	12(SP),D2
	move.l	D2,D0
	moveq	#20,D1
	lsr.l	D1,D0
	bsr	display_deci
	bftst	D2{12:20}
	beq.s	df1
	moveq	#$2E,D0
	bsr	display_char
	moveq	#10,D1
	lsr.l	D1,D2
	movea.l	D2,A0
	lea	(A0,A0.L*2),A1
	move.l	A1,D0
	lea	(A0,D0.L*8),A0
	move.l	A0,D0
	asl.l	#2,D0
	addi.l	#$200,D0
	lsr.l	D1,D0
	cmp.l	#10,D0
	bcc.s        df2
	move.l	D0,-(SP)
	moveq	#$30,D0
	bsr	display_char
	move.l	(SP)+,D0
df2:		
	bsr	display_deci
df1:
	move.l	(SP)+,D2
	movea.l	(SP)+,A2
	rts

getcookie:

	move.l	A2,-(SP)
	movea.l	8(SP),A2
	movea.l	12(SP),A1
	clr.l	D0
	move.l	cookiejar-_bss(A5),A0
	tst.l	(A0)
	beq.s	gc2
gc3:
		move.l	(A0,D0.L*4),D1
		cmp.l	(A2),D1
		bne.s	gc5
		tst.l	A1
		beq.s	gc4
		move.l	4(A0,D0.L*4),(A1)
gc4:
		moveq	#1,D0
		bra.s	gc1
gc5:
		addq.l	#2,D0
	tst.l	(A0,D0.L*4)
	bne.s	gc3
gc2:
	moveq	#-1,D0
gc1:
	movea.l	(SP)+,A2
	rts

check_bootinfo_version:

	movem.l	D2-D5/A2,-(SP)
	movea.l	24(SP),A2
	clr.l	D3
	pea	crlf(PC)
	bsr	_printline
	addq	#4,SP
	cmpi.l	#$4249561A,2(A2)
	bne.s	cbv8
	tst.l	6(A2)
	beq.s	cbv8
	clr.l	D1
cbv9:
		move.l	D1,D0
		moveq	#2,D5
		cmp.l	6(A2,D0.L),D5
		beq	cbv6
		addq.l	#8,D1
	tst.l	6(A2,D1.L)
	bne.s	cbv9
cbv8:
	tst.l	D3
	bne.s	cbv7
	pea	warning_4(PC)
	bsr	_printline
	addq	#4,SP
cbv7:
	move.l	D3,D2
	clr	D2
	swap	D2
	andi.l	#$FFFF,D3
	moveq	#2,D4
	pea	bootstrap_bootinfo_version(PC)
	bsr	_printline
	pea	kernel_bootinfo_version(PC)
	bsr	_printline
	move.l	D2,D0
	bsr	display_deci
	moveq	#$2E,D0
	bsr	display_char
	move.l	D3,D0
	bsr	display_deci
	pea	crlf(PC)
	bsr	_printline
	addq	#8,SP
	addq	#4,SP
	moveq	#1,D5
	cmp.l	D2,D5
	beq.s	cbv5
	cmp.l	D2,D4
	bne.s	cbv4
	cmp.l	D3,D5
	bge.s	cbv2
	pea	warning_5(PC)
	bsr	_printline
	pea	warning_6(PC)
	bsr	_printline
	addq	#8,SP
	bra.s	cbv2
cbv6:
	move.l	10(A2,D1.L),D3
	bra	cbv8
cbv5:
	pea	warning_7(PC)
	bsr	_printline
	addq	#4,SP
	bra.s	cbv2
cbv4:
	lea	bootstrap_new(PC),A0
	cmp.l	D4,D2
	ble.s	cbv3
	lea	bootstrap_old(PC),A0
cbv3:
	move.l	A0,-(SP)
	pea	error_28(PC)
	bsr	_printline
	addq	#4,SP
	bsr	_printline	
	pea	error_28a(PC)
	bsr	_printline
	clr.l	D0
	addq	#8,SP
	bra.s	cbv1
cbv2:
	move.l	D2,D0
cbv1:
	movem.l	(SP)+,D2-D5/A2
	rts

create_bootinfo:

	movem.l	D2-D3/A2,-(SP)
	clr.l	bi_size-_bss(A5)
	pea	bi_machtype-_bss(A5)
	pea	4.w
	pea	1.w
	bsr	add_bi_record
	addq	#8,SP
	addq	#4,SP
	tst.l	D0
	beq	cb2
	pea	bi_cputype-_bss(A5)
	pea	4.w
	pea	2.w
	bsr	add_bi_record
	addq	#8,SP
	addq	#4,SP
	tst.l	D0
	beq	cb2
	pea	bi_fputype-_bss(A5)
	pea	4.w
	pea	3.w
	bsr	add_bi_record
	addq	#8,SP
	addq	#4,SP
	tst.l	D0
	beq	cb2
	pea	bi_mmutype-_bss(A5)
	pea	4.w
	pea	4.w
	bsr	add_bi_record
	addq	#8,SP
	addq	#4,SP
	tst.l	D0
	beq	cb2
	clr.l	D2
	cmp.l	bi_num_memory-_bss(A5),D2
	bge.s	cb4
	lea	bi_memory_0_addr-_bss(A5),A0
	move.l	A0,D3
cb5:
		move.l	D3,-(SP)
		pea	8.w
		pea	5.w
		bsr	add_bi_record
		addq	#8,SP
		addq	#4,SP
		tst.l	D0
		beq	cb2
		addq.l	#8,D3
		addq.l	#1,D2
	cmp.l	bi_num_memory-_bss(A5),D2
	blt.s	cb5
cb4:
	tst.l	bi_ramdisk_size-_bss(A5)
	beq.s	cb3
	pea	bi_ramdisk-_bss(A5)
	pea	8.w
	pea	6.w
	bsr	add_bi_record
	addq	#8,SP
	addq	#4,SP
	tst.l	D0
	beq.s	cb2
cb3:
	pea	bi_command_line-_bss(A5)
	pea	7.w
	bsr	add_bi_string
	addq	#8,SP
	tst.l	D0
	beq.s	cb2
	pea	bi_mch_cookie-_bss(A5)
	pea	4.w
	move.l	#$8000,-(SP)
	bsr	add_bi_record
	addq	#8,SP
	addq	#4,SP
	tst.l	D0
	beq.s	cb2
	pea	bi_mch_type-_bss(A5)
	pea	4.w
	move.l	#$8001,-(SP)
	bsr	add_bi_record
	addq	#8,SP
	addq	#4,SP
	tst.l	D0
	beq.s	cb2
	movea.l	bi_size-_bss(A5),A1
	lea	bi_union_record-_bss(A5),A0
	adda.l	A1,A0
	clr	(A0)
	addq	#2,A1
	move.l	A1,bi_size-_bss(A5)
	moveq	#1,D0
	bra.s	cb1
cb2:
	clr.l	D0
cb1:
	movem.l	(SP)+,D2-D3/A2
	rts

add_bi_record:

	movem.l	D2-D3/A2,-(SP)
	move	18(SP),D3
	movea	22(SP),A1
	move	A1,D0
	addq	#7,D0
	move	D0,D1
	andi	#-4,D1
	move.l	D1,D2
	andi.l	#$FFFC,D2
	movea.l	bi_size-_bss(A5),A0
	lea	2(A0,D2.L),A2
	move.l	A2,D0
	cmpi.l	#$1000,D0
	bls.s	abr2
	pea	error_29(PC)
	bsr	_printline
	clr.l	D0
	addq	#4,SP
	bra.s	abr1
abr2:
	lea	bi_union_record-_bss(A5),A2
	adda.l	A2,A0
	move	D3,(A0)
	move	D1,2(A0)
	move	A1,-(SP)
	clr	-(SP)
	move.l	28(SP),-(SP)
	pea	4(A0)
	bsr	_memmove
	addq	#8,SP
	addq	#4,SP
	add.l	D2,bi_size-_bss(A5)
	moveq	#1,D0
abr1:
	movem.l	(SP)+,D2-D3/A2
	rts

add_bi_string:

	movea.l	8(SP),A0
	move	6(SP),D0
	move.l	A0,-(SP)
	movea.l	A0,A1
abs1:
	tst.b	(A1)+
	bne	abs1
	suba.l	A0,A1
	move	A1,-(SP)
	clr	-(SP)
	move	D0,-(SP)
	clr	-(SP)
	bsr	add_bi_record
	addq	#8,SP
	addq	#4,SP
	rts

create_compat_bootinfo:

	movem.l	D2/A2-A3,-(SP)
	move.l	bi_machtype-_bss(A5),compat_bootinfo_machtype-_bss(A5)
	move.l	bi_cputype-_bss(A5),D0
	btst	#0,D0
	beq.s	ccb17
	moveq	#1,D2
	bra.s	ccb13
ccb17:
	btst	#1,D0
	beq.s	ccb16
	moveq	#2,D2
	bra.s	ccb13
ccb16:
	btst	#2,D0
	beq.s	ccb15
	moveq	#4,D2
	bra.s	ccb13
ccb15:
	btst	#3,D0
	bne.s	ccb14
	move.l	D0,-(SP)
	pea	error_30(PC)
	bra.s	ccb9
ccb14:
	moveq	#8,D2
ccb13:
	move.l	D2,compat_bootinfo_cputype-_bss(A5)
	move.l	bi_fputype-_bss(A5),D0
	btst	#0,D0
	beq.s	ccb12
	moveq	#$20,D2
	or.l	D2,compat_bootinfo_cputype-_bss(A5)
	bra.s	ccb7
ccb12:
	btst	#1,D0
	beq.s	ccb11
	moveq	#$40,D2
	or.l	D2,compat_bootinfo_cputype-_bss(A5)
	bra.s	ccb7
ccb11:
	btst	#2,D0
	beq.s	ccb10
	ori	#$80,compat_bootinfo_cputype-_bss+2(A5)
	bra.s	ccb7
ccb10:
	btst	#3,D0
	bne.s	ccb8
	tst.l	D0
	beq.s	ccb7
	move.l	D0,-(SP)
	pea	error_31(PC)
ccb9:
	bsr	_printline
	addq	#4,SP
	move.l	(SP)+,D0
	bsr	hex_long
	pea	error_30_a(PC)
	bsr	_printline
	clr.l	D0
	addq	#4,SP
	bra	ccb1
ccb8:
	ori	#$100,compat_bootinfo_cputype-_bss+2(A5)
ccb7:
	lea	compat_bootinfo_num_memory-_bss(A5),A2
	lea	bi_num_memory-_bss(A5),A3
	move.l	(A3),(A2)
	moveq	#4,D2
	cmp.l	(A3),D2
	bge.s	ccb6
	pea	warning_8(PC)
	bsr	_printline
	move.l	D2,(A2)
	addq	#4,SP
ccb6:
	clr.l	D1
	cmp.l	(A2),D1
	bcc.s	ccb4
	lea	-40(A2),A1
	lea	-16(A3),A0
ccb5:
		move.l	D1,D0
		asl.l	#3,D0
		move.l	20(A0,D0.L),8(A1,D0.L)
		move.l	24(A0,D0.L),12(A1,D0.L)
		addq.l	#1,D1
	cmp.l	(A2),D1
	bcs.s	ccb5
ccb4:
	move.l	bi_ramdisk_size-_bss(A5),D0
	beq.s	ccb3
	lea	bi_ramdisk-_bss(A5),A0
	move.l	(A0),D1
	andi	#-$400,D1
	move.l	D1,(A0)
	addi.l	#$3FF,D0
	moveq	#10,D2
	lsr.l	D2,D0
	move.l	D0,compat_bootinfo_ramdisk_size-_bss(A5)
	move.l	D1,compat_bootinfo_ramdisk_addr-_bss(A5)
	bra.s	ccb2
ccb3:
	clr.l	compat_bootinfo_ramdisk_size-_bss(A5)
	clr.l	compat_bootinfo_ramdisk_addr-_bss(A5)
ccb2:
	pea	256.w
	pea	bi_command_line-_bss(A5)
	pea	compat_bootinfo_command_line-_bss(A5)
	bsr	_strncpy
	clr.b	compat_bootinfo_command_line_end-_bss(A5)
	clr.l	compat_bootinfo_bi_atari_hw_present-_bss(A5)
	move.l	bi_mch_cookie-_bss(A5),compat_bootinfo_bi_atari_mch_cookie-_bss(A5)
	moveq	#1,D0
	addq	#8,SP
	addq	#4,SP
ccb1:
	movem.l	(SP)+,D2/A2-A3
	rts

copyall:

	movea.l	A0,A4
ca1:
		move.l	(A1)+,(A0)+
	subq.l	#4,D0
	bcc.s	ca1
	tst.l	D1
	beq	ca2
ca3:
		move.l	-(A3),-(A2)
	subq.l	#4,D1
	bcc.s	ca3
ca2:
	jmp	(A4)
copyallend:

test_cpu_type:

	movem.l	D2/A2,-(SP)
	movea.l	ev_f_line.w,A0
	movea.l	SP,A1
	move	SR,D2
	ori	#$700,SR
	moveq	#20,D0
	lea	tc2(PC),A2
	move.l	A2,ev_f_line.w
	movea.l	A3,A2
	
	MC68030
	
	nop
	pmove	TT0,(A2)
	nop
	moveq	#30,D0
	bra	tc1
	
	MC68040

tc2:
	lea	tc1(PC),A2
	move.l	A2,ev_f_line.w
	movea.l	A3,A2
	nop
	move16	(A2)+,(A2)+
	nop
	moveq	#40,D0
	nop
	dc.w	$f5ca;	plpar	(A2)
	nop
	moveq	#60,D0
tc1:
	movea.l	A1,SP
	move.l	A0,ev_f_line.w
	move	D2,SR
	movem.l	(SP)+,D2/A2
	rts

test_software_fpu:

	movem.l	D2/A2,-(SP)
	movea.l	ev_f_line.w,A0
	movea.l	SP,A1
	move	SR,D2
	ori	#$700,SR
	lea	tsf1(PC),A2
	move.l	A2,ev_f_line.w
	moveq	#1,D0
	dc.l	$F2800000
	nop
	moveq	#0,D0
tsf1:
	movea.l	A1,SP
	move.l	A0,ev_f_line.w
	move	D2,SR
	movem.l	(SP)+,D2/A2
	rts

get_medusa_bank_sizes:

	adda	#-68,SP
	movem.l	D2-D3/A2-A3,-(SP)
	lea	get_medusa_bank_sizes(PC),A2
	move.l	A2,D0
	movea.l	88(SP),A2
	movea.l	92(SP),A3
	andi.l	#$007FFFFF,D0
	bset	#29,D0
	movea.l	D0,A1
	clr.l	(A3)
	clr.l	(A2)
	move	SR,D2
	ori	#$700,SR
	clr.l	D3
	movec	D3,CACR
	btst	#3,bi_cputype-_bss+3(A5)
	beq.s	gmb12
	moveq	#$40,D3
	swap	D3
	movec	D3,CACR
	moveq	#0,D0
	dc.l	$4e7b0808; movec	D0,pcr
gmb12:
	move.l	#$200FE040,D3
	movec	DTT0,D1
	movec	D3,DTT0
	nop
	clr.l	D0
	movea.l	A1,A0
gmb11:
		move.l	(A0),16(SP,D0.L*4)
		adda.l	#$800000,A0
		addq.l	#1,D0
		moveq	#15,D3
	cmp.l	D0,D3
	bge.s	gmb11
	moveq	#15,D0
	movea.l	#$07800000,A0
	adda.l	A1,A0
gmb10:
			clr.l	(A0)
			adda.l	#$FF800000,A0
		dbf	D0,gmb10
		clr	D0
	subq.l	#1,D0
	bcc.s	gmb10
	move.l	#$12345678,(A1)
	movea.l	#$00800000,A0
	move.l	(A0,A1.L),D0
	cmpi.l	#$12345678,D0
	beq.s	gmb9
	movea.l	#$01000000,A0
	move.l	(A0,A1.L),D0
	cmpi.l	#$12345678,D0
	beq.s	gmb9
	movea.l	#$02000000,A0
	move.l	(A0,A1.L),D0
	cmpi.l	#$12345678,D0
	bne.s	gmb8
gmb9:
	move.l	A0,(A2)
	bra.s	gmb7
gmb8:
	move.l	#$04000000,(A2)
gmb7:
	movea.l	#$04000000,A2
	move.l	(A2,A1.L),D0
	beq.s	gmb6
	clr.l	(A3)
	bra.s	gmb2
gmb6:
	move.l	#$12345678,(A2,A1.L)
	movea.l	#$04800000,A0
	move.l	(A0,A1.L),D0
	beq.s	gmb4
	movea.l	#$05000000,A0
	move.l	(A0,A1.L),D0
	cmpi.l	#$12345678,D0
	bne.s	gmb5
	move.l	#$00800000,(A3)
	bra.s	gmb2
gmb5:
	move.l	#$02000000,(A3)
	bra.s	gmb2
gmb4:
	move.l	#$12345678,(A0,A1.L)
	movea.l	#$05000000,A0
	move.l	(A0,A1.L),D0
	cmpi.l	#$12345678,D0
	bne.s	gmb3
	move.l	#$01000000,(A3)
	bra.s	gmb2
gmb3:
	move.l	A2,(A3)
gmb2:
	clr.l	D0
	movea.l	A1,A0
gmb1:
		move.l	16(SP,D0.L*4),(A0)
		adda.l	#$800000,A0
		addq.l	#1,D0
		moveq	#15,D3
	cmp.l	D0,D3
	bge.s	gmb1
	movec	D1,DTT0
	nop
	move	D2,SR
	movem.l	(SP)+,D2-D3/A2-A3
	adda	#68,SP
	rts

get_ab040_bank_sizes:

	adda	#-68,SP
	movem.l	D2-D7/A2-A3,-(SP)
	move.l	$68(SP),D4
	movea.l	$6C(SP),A2
	clr.l	D5
	move	SR,D6
	ori	#$700,SR
	movea	D6,A3
	nop
	pflusha
	nop
	movea.l	#$05000000,A0
	movea	#16,A1
gab8:
		adda.l	#$FFC00000,A0
		move.l	A0,D0
		andi.l	#$FF000000,D0
		ori	#-$1FC0,D0
		movec	DTT0,D1
		movec	D0,DTT0
		nop
		move.l	(A0),D7
		nop
		movec	D1,DTT0
		move.l	D7,28(SP,A1.L*4)
		move.l	A0,D7
		movec	DTT0,D6
		movec	D0,DTT0
		nop
		move.l	D7,(A0)
		nop
		movec	D6,DTT0
		subq	#1,A1
	tst.l	A1
	bne.s	gab8
	nop
	pflusha
	nop
	movea.l	#$01000000,A0
	movea	#16,A1
gab7:
		move.l	A0,D2
		move.l	A0,D0
		andi.l	#$FF000000,D0
		ori	#-$1FC0,D0
		movec	DTT0,D6
		movec	D0,DTT0
		nop
		move.l	(A0),D1
		nop
		movec	D6,DTT0
		subq	#1,A1
		adda.l	#$00400000,A0
		cmp.l	D1,D2
		bne.s	gab2
		move.l	D2,D3
gab6:       	
			move.l	A0,D2
			move.l	A0,D0
			andi.l	#$FF000000,D0
			ori	#-$1FC0,D0
			movec	DTT0,D7
			movec	D0,DTT0
			nop
			move.l	(A0),D1
			nop
			movec	D7,DTT0
			subq	#1,A1
			adda.l	#$00400000,A0
			cmp.l	D1,D2
			bne.s	gab5
		tst.l	A1
		bne.s	gab6
gab5:
		move.l	A0,D0
		tst.l	A1
		beq.s	gab4
		move.l	D2,D0
gab4:
		move.l	D0,D1
		sub.l	D3,D1
		cmpi.l	#$000FFFFF,D1
		bls.s	gab2
		move.l	D4,D0
		subq.l	#1,D4
		tst.l	D0
		ble.s	gab3
		move.l	D3,(A2)+
		move.l	D1,(A2)+
		addq.l	#1,D5
		bra.s	gab2
gab3:
		suba.l	A1,A1
gab2:
	tst.l	A1
	bne	gab7
	movea.l	#$05000000,A0
	movea	#16,A1
gab1:
		adda.l	#$FFC00000,A0
		move.l	28(SP,A1.L*4),D0
		move.l	A0,D1
		andi.l	#$FF000000,D1
		ori	#-$1FC0,D1
		movec	DTT0,D6
		movec	D1,DTT0
		nop
		move.l	D0,(A0)
		nop
		movec	D6,DTT0
	subq	#1,A1
	tst.l	A1
	bne.s	gab1
	nop
	pflusha
	nop
	move	A3,D7
	move	D7,SR
	move.l	D5,D0
	movem.l	(SP)+,D2-D7/A2-A3
	adda	#68,SP
	rts

_stream_init:

	lea	head_mod-_bss(A5),A0
	move.l	A0,currmod-_bss(A5)
	clr.l	48(A0)
	clr.l	52(A0)
	rts

_stream_push:

	movea.l	4(SP),A0
	lea	head_mod-_bss(A5),A1
	move.l	48(A1),48(A0)
	move.l	A1,52(A0)
	move.l	A0,48(A1)
	movea.l	48(A0),A1
	move.l	A0,52(A1)
	rts

_sopen:

	move.l	D2,-(SP)
	addq.l	#1,stream_dont_display-_bss(A5)
	movea.l	currmod-_bss(A5),A0
	move.l	48(A0),D0
	move.l	D0,currmod-_bss(A5)
	bne.s	so7
	pea	error_32(PC)
	bsr	_printline
	move.l	(A0),-(SP) ; name
	bsr	_printline
	pea	error_32a(PC)
	bsr	_printline
	pea	1.w
	bsr	_exit
so7:
	movea.l	currmod-_bss(A5),A0
	move.l	8(SP),-(SP)
	movea.l	8(A0),A0
	jsr	(A0)
	move.l	D0,D2
	addq	#4,SP
	ble.s	so4
	movea.l	currmod-_bss(A5),A1
	move.l	48(A1),D0
	beq.s	so5
	movea.l	52(A1),A0
so6:
	move.l	D0,48(A0)
	movea.l	48(A1),A0
	move.l	52(A1),52(A0)
	move.l	48(A1),currmod-_bss(A5)
	bra.s	so2
so5:
	moveq	#-1,D2
	bra.s	so2
so4:
	tst.l	D2
	bne.s	so2
	movea.l	currmod-_bss(A5),A0
	clr.l	40(A0)
	clr.l	32(A0)
	clr.l	36(A0)
	moveq	#-1,D1
	move.l	D1,44(A0)
	move.l	4(A0),-(SP)
	bsr	_malloc
	movea.l	currmod-_bss(A5),A0
	move.l	D0,24(A0)
	addq	#4,SP
	bne.s	so3
	move.l	(A0),-(SP)
	pea	error_33(PC)
	bsr	_printline
	addq	#4,SP
	bsr	_printline
	pea	crlf(PC)
	bsr	_printline
	pea	1.w
	bsr	_exit
so3:
	move.l	D0,28(A0)
so2:
	movea.l	currmod-_bss(A5),A0
	move.l	52(A0),D0
	move.l	D0,currmod-_bss(A5)
	bne.s	so1
	pea	error_34(PC)
	bsr	_printline
	move.l	(A0),-(SP) ; name
	bsr	_printline
	pea	error_34a(PC)
	bsr	_printline
	pea	1.w
	bsr	_exit
so1:
	subq.l	#1,stream_dont_display-_bss(A5)
	move.l	D2,D0
	move.l	(SP)+,D2
	rts

_sread:

	movem.l	D2-D6,-(SP)
	move.l	24(SP),D4
	move.l	28(SP),D3
	move.l	D4,D5
	movea.l	currmod-_bss(A5),A0
	move.l	48(A0),D0
	move.l	D0,currmod-_bss(A5)
	bne.s	srd17
	pea	error_32(PC)
	bsr	_printline
	move.l	(A0),-(SP) ; name
	bsr	_printline
	pea	error_32a(PC)
	bsr	_printline
	pea	1.w
	bsr	_exit
srd17:
	movea.l	currmod-_bss(A5),A0
	tst.l	40(A0)
	beq.s	srd16
	clr.l	D0
	bra	srd1
srd16:
	move.l	32(A0),D0
	beq.s	srd10
	cmp.l	D0,D3
	bge.s	srd15
	move.l	D3,D0
srd15:
	move.l	D0,D2
	move.l	D2,-(SP)
	move.l	28(A0),-(SP)
	move.l	D4,-(SP)
	bsr	_memmove
	addq	#8,SP
	addq	#4,SP
	add.l	D2,D4
	sub.l	D2,D3
	movea.l	currmod-_bss(A5),A0
	add.l	D2,36(A0)
	add.l	D2,28(A0)
	sub.l	D2,32(A0)
	bra.s	srd11
srd14:
		move.l	D4,-(SP)
		movea.l	12(A0),A0
		jsr	(A0)
		move.l	D0,D2
		addq	#4,SP
		bge.s	srd13
		move.l	D2,D1
		bra	srd3
srd13:
		tst.l	D2
		bne.s	srd12
		movea.l	currmod-_bss(A5),A0
		bra.s	srd7
srd12:
		add.l	D2,D4
		sub.l	D2,D3
		movea.l	currmod-_bss(A5),A0
		add.l	D2,36(A0)
srd11:
		bsr	stream_show_progress
srd10:
		movea.l	currmod-_bss(A5),A0
	cmp.l	4(A0),D3
	bge.s	srd14
	tst.l	D3
	beq.s	srd4
srd9:
		movea.l	currmod-_bss(A5),A0
		move.l	24(A0),-(SP)
		movea.l	12(A0),A0
		jsr	(A0)
		movea.l	currmod-_bss(A5),A0
		move.l	D0,32(A0)
		move.l	24(A0),28(A0)
		addq	#4,SP
		move.l	32(A0),D0
		bge.s	srd8
		move.l	D0,D1
		bra.s	srd3
srd8:
		tst.l	D0
		bne.s	srd6
srd7:
		moveq	#1,D6
		move.l	D6,40(A0)
		bra.s	srd4
srd6:
		movea.l	currmod-_bss(A5),A0
		move.l	32(A0),D0
		cmp.l	D0,D3
		bge.s	srd5
		move.l	D3,D0
srd5:
		move.l	D0,D2
		move.l	D2,-(SP)
		move.l	24(A0),-(SP)
		move.l	D4,-(SP)
		bsr	_memmove
		addq	#8,SP
		addq	#4,SP
		add.l	D2,D4
		sub.l	D2,D3
		movea.l	currmod-_bss(A5),A0
		add.l	D2,36(A0)
		add.l	D2,28(A0)
		sub.l	D2,32(A0)
		bsr	stream_show_progress
	tst.l	D3
	bne.s	srd9
srd4:
	move.l	D4,D1
	sub.l	D5,D1
srd3:
	movea.l	currmod-_bss(A5),A0
	move.l	52(A0),D0
	move.l	D0,currmod-_bss(A5)
	bne.s	srd2
	pea	error_34(PC)
	bsr	_printline
	move.l	(A0),-(SP) ; name
	bsr	_printline
	pea	error_34a(PC)
	bsr	_printline
	pea	1.w
	bsr	_exit
srd2:
	move.l	D1,D0
srd1:
	movem.l	(SP)+,D2-D6
	rts
	
_sseek:

	move.l	D3,-(SP)
	move.l	D2,-(SP)
	move.l	12(SP),D2
	move.l	16(SP),D1
	movea.l	currmod-_bss(A5),A0
	move.l	48(A0),D0
	move.l	D0,currmod-_bss(A5)
	bne.s	sk20
	pea	error_32(PC)
	bsr	_printline
	move.l	(A0),-(SP) ; name
	bsr	_printline
	pea	error_32a(PC)
	bsr	_printline
	pea	1.w
	bsr	_exit
sk20:
	moveq	#1,D3
	cmp.l	D1,D3
	beq.s	sk19
	blt.s	sk18
	tst.l	D1
	bne.s	sk18
	bra.s	sk17
sk19:
	movea.l	currmod-_bss(A5),A0
	add.l	36(A0),D2
	bra.s	sk17
sk18:
	movea.l	currmod-_bss(A5),A0
	move.l	(A0),-(SP)
	pea	error_35(PC)
	bsr	_printline
	addq	#4,SP
	bsr	_printline
	pea	crlf(PC)
	bsr	_printline
	addq	#8,SP
	moveq	#-1,D1
	bra	sk2
sk17:
	movea.l	currmod-_bss(A5),A0
	move.l	36(A0),D1
	cmp.l	D2,D1
	beq	sk3
	ble	sk13
	move.l	28(A0),D0
	sub.l	24(A0),D0
	movea.l	D1,A1
	suba.l	D0,A1
	move.l	32(A0),D1
	beq.s	sk16
	cmpa.l	D2,A1
	ble.s	sk14
sk16:
	moveq	#-1,D0
	tst.l	D1
	beq.s	sk15
	move.l	A1,D0
sk15:
	move.l	D0,-(SP)
	pea	error_36(PC)
	bsr	_printline
	addq	#4,SP
	move.l	(A0),-(SP)
	bsr	_printline
	addq	#4,SP
	pea	error_36a(PC)
	bsr	_printline
	addq	#4,SP
	move.l	(SP)+,D0
	bsr	display_deci
	pea	error_36b(PC)
	bsr	_printline
	move.l	D2,D0
	bsr	display_deci
	pea	error_36c(PC)
	bsr	_printline
	addq	#8,SP
	moveq	#-1,D1
	bra	sk2
sk14:
	movea.l	currmod-_bss(A5),A0
	move.l	36(A0),D0
	sub.l	D2,D0
	sub.l	D0,28(A0)
	add.l	D0,32(A0)
	move.l	D2,36(A0)
	bra	sk3
sk13:
	move.l	32(A0),D0
	beq.s	sk11
	add.l	D1,D0
	cmp.l	D2,D0
	blt.s	sk12
	move.l	D2,D0
	sub.l	D1,D0
	add.l	D0,28(A0)
	sub.l	D0,32(A0)
	add.l	D0,36(A0)
	bra	sk3
sk12:
	move.l	D0,36(A0)
	clr.l	32(A0)
sk11:
	movea.l	currmod-_bss(A5),A0
	movea.l	16(A0),A1
	tst.l	A1
	beq.s	sk10
	move.l	D2,D3
	sub.l	36(A0),D3
	move.l	D3,-(SP)
	jsr	(A1)
	addq	#4,SP
	tst.l	D0
	blt.s	sk8
	movea.l	currmod-_bss(A5),A0
	move.l	D0,36(A0)
sk10:
	movea.l	currmod-_bss(A5),A0
	cmp.l	36(A0),D2
	ble.s	sk4
sk9:
		move.l	24(A0),-(SP)
		movea.l	12(A0),A0
		jsr	(A0)
		movea.l	currmod-_bss(A5),A0
		move.l	D0,32(A0)
		move.l	24(A0),28(A0)
		addq	#4,SP
		move.l	32(A0),D0
		bge.s	sk7
sk8:
		move.l	D0,D1
		bra.s	sk2
sk7:
		tst.l	D0
		bne.s	sk6
		moveq	#1,D3
		move.l	D3,40(A0)
		bra.s	sk3
sk6:
		movea.l	currmod-_bss(A5),A0
		move.l	D2,D1
		sub.l	36(A0),D1
		move.l	32(A0),D0
		cmp.l	D0,D1
		bge.s	sk5
		move.l	D1,D0
sk5:
		add.l	D0,28(A0)
		sub.l	D0,32(A0)
		add.l	36(A0),D0
		move.l	D0,36(A0)
	cmp.l	D0,D2
	bgt.s	sk9
sk4:
	bsr	stream_show_progress
sk3:
	movea.l	currmod-_bss(A5),A0
	move.l	36(A0),D1
sk2:
	movea.l	currmod-_bss(A5),A0
	move.l	52(A0),D0
	move.l	D0,currmod-_bss(A5)
	bne.s	sk1
	pea	error_34(PC)
	bsr	_printline
	move.l	(A0),-(SP) ; name
	bsr	_printline
	pea	error_34a(PC)
	bsr	_printline
	pea	1.w
	bsr	_exit
sk1:
	move.l	D1,D0
	move.l	(SP)+,D2
	move.l	(SP)+,D3
	rts

_sclose:

	move.l	D2,-(SP)
	bsr	stream_show_progress
	pea	crlf(PC)
	bsr	_printline
	addq.l	#1,stream_dont_display-_bss(A5)
	addq	#4,SP
	movea.l	currmod-_bss(A5),A0
	move.l	48(A0),D0
	move.l	D0,currmod-_bss(A5)
	bne.s	scl2
	pea	error_32(PC)
	bsr	_printline
	move.l	(A0),-(SP) ; name
	bsr	_printline
	pea	error_32a(PC)
	bsr	_printline
	pea	1.w
	bsr	_exit
scl2:
	movea.l	currmod-_bss(A5),A0
	movea.l	20(A0),A0
	jsr	(A0)
	move.l	D0,D2
	movea.l	currmod-_bss(A5),A0
	move.l	24(A0),-(SP)
	bsr	_free
	addq	#4,SP
	movea.l	currmod-_bss(A5),A0
	move.l	52(A0),D0
	move.l	D0,currmod-_bss(A5)
	bne.s	scl1
	pea	error_34(PC)
	bsr	_printline
	move.l	(A0),-(SP) ; name
	bsr	_printline
	pea	error_34a(PC)
	bsr	_printline
	pea	1.w
	bsr	_exit
scl1:
	subq.l	#1,stream_dont_display-_bss(A5)
	move.l	D2,D0
	move.l	(SP)+,D2
	rts

stream_show_progress:

	movem.l	D2-D3/A2,-(SP)
	clr.l	D2
	movea.l	currmod-_bss(A5),A0
	move.l	36(A0),D0
	moveq	#13,D3
	asr.l	D3,D0
	tst.l	stream_dont_display-_bss(A5)
	bne	sps1
	cmp.l	44(A0),D0
	beq	sps1
	move.l	D0,44(A0)
	moveq	#13,D0
	bsr	display_char
	movea.l	head_mod-_bss+48(A5),A2
	tst.l	A2
	beq.s	sps1
sps5:
		tst.l	36(A2)
		bne.s	sps4
		tst.l	D2
		bne.s	sps1
		bra.s	sps3
sps4:
		moveq	#1,D2
sps3:
		move.l	#$2000,D1
		move.l	4(A2),D0
		cmp.l	D0,D1
		ble.s	sps2
		move.l	D1,D0
sps2:
		move.l	36(A2),D1
		divs.l	D0,D1
		moveq	#3,D3
		and.l	D3,D1
		lea	rotchar(PC),A0
		move.b	(A0,D1.L),D1
		extb.l	D1
		moveq	#$20,D0
		bsr	display_char
		move.l	D1,D0
		bsr	display_char
		moveq	#$20,D0
		bsr	display_char
		move.l	36(A2),D0
		bsr	display_deci
		moveq	#$20,D0
		bsr	display_char
		move.l	(A2),-(SP)		
		bsr	_printline
		addq	#4,SP
		movea.l	48(A2),A2
	tst.l	A2
	bne.s	sps5
sps1:
	movem.l	(SP)+,D2-D3/A2
	rts

file_open:

	move.l	A2,-(SP)
	move.l	D2,-(SP)
	movea.l	12(SP),A2
	lea	local(PC),A0
	moveq	#6,D0
	movea.l	A2,A1
	move.l	D0,D1
	moveq	#0,D0
	moveq	#0,D2
	subq.l	#1,D1
	bmi	fo3
fo4:
		move.b	(A1)+,D0
		move.b	(A0)+,D2
		beq	fo3
	cmp.b	D2,D0
	dbne	D1,fo4
	bne	fo3
	move.l	D2,D0
fo3:
	sub.l	D2,D0
	tst.l	D0
	bne.s	fo2
	addq	#6,A2
fo2:
	clr.l	-(SP)
	move.l	A2,-(SP)
	bsr	_open
	move.l	D0,handle_file-_bss(A5)
	addq	#8,SP
	clr.l	D1
	tst.l	D0
	bge.s	fo1
	moveq	#-1,D1
fo1:
	move.l	D1,D0
	move.l	(SP)+,D2
	movea.l	(SP)+,A2
	rts

file_fillbuf:

	move.l	#$8000,-(SP)
	move.l	8(SP),-(SP)
	move.l	handle_file-_bss(A5),-(SP)
	bsr	_read
	addq	#8,SP
	addq	#4,SP
	rts

file_skip:

	pea	1.w ; SEEK_CUR
	move.l	8(SP),-(SP)
	move.l	handle_file-_bss(A5),-(SP)
	bsr	_lseek
	addq	#8,SP
	addq	#4,SP
	rts

file_close:

	move.l	handle_file-_bss(A5),-(SP)
	bsr	_close
	addq	#4,SP
	rts

gunzip_open:

	link	A6,#-4
	movem.l	D2-D4/A2-A4,-(SP)
	movea.l	8(A6),A2
	move.l	SP,D3
	movea.l	A2,A0
go17:
	tst.b	(A0)+
	bne	go17
	suba.l	A2,A0
	move.l	A0,D0
	addq.l	#4,D0
	moveq	#-2,D4
	and.l	D4,D0
	suba.l	D0,SP
	movea.l	SP,A3
	movea.l	SP,A1
	movea.l	A2,A0
go16:
	move.b	(A0)+,(A1)+
	bne	go16
	move.l	SP,-(SP)
	bsr	_sopen
	addq	#4,SP
	tst.l	D0
	bge.s	go9
	lea	gz_ext(PC),A0
	movea.l	A3,A1
go15:
	tst.b	(A1)+
	bne	go15
	subq.l	#1,A1
go14:
	move.b	(A0)+,(A1)+
	bne	go14
	move.l	A3,-(SP)
	bsr	_sopen
	addq	#4,SP
	tst.l	D0
	bge.s	go9
	lea	_kernel_name(PC),A0
	moveq	#0,D0
	moveq	#0,D1
go13:
		move.b	(A2)+,D0
		move.b	(A0)+,D1
		beq	go12
	cmp.b	D1,D0
	beq	go13
	sub.l	D1,D0
go12:
	tst.l	D0
	bne.s	go10
	lea	_kernel_name_bis(PC),A0
	movea.l	A3,A1
go11:
	move.b	(A0)+,(A1)+
	bne	go11
	move.l	A3,-(SP)
	bsr	_sopen
	addq	#4,SP
	tst.l	D0
	bge.s	go9
go10:
	movea.l	D3,SP
	moveq	#-1,D0
	bra	go1
go9:
	pea	2.w
	pea	-2(A6)
	bsr	_sread
	move.l	D0,D2
	clr.l	-(SP)
	clr.l	-(SP)
	bsr	_sseek
	addq	#8,SP
	addq	#8,SP
	moveq	#1,D4
	cmp.l	D2,D4
	blt.s	go8
	pea	error_37(PC)
	bra.s	go4
go8:
	cmpi.b	#$1F,-2(A6)
	bne.s	go7
	move.b	-1(A6),D0
	cmpi.b	#$8B,D0
	beq.s	go6
	cmpi.b	#$9E,D0
	beq.s	go6
go7:
	movea.l	D3,SP
	moveq	#1,D0
	bra.s	go1
go6:
	pea	$1000.w
	bsr	_malloc
	move.l	D0,gunzip_stack-_bss(A5)
	addq	#4,SP
	bne.s	go5
	pea	error_38(PC)
	bra.s	go4
go5:
	clr.l	gunzip_sp-_bss(A5)
	move.l	#$8000,-(SP)
	bsr	_malloc
	move.l	D0,inbuf-_bss(A5)
	addq	#4,SP
	bne.s	go3
	pea	error_39(PC)
go4:
	bsr	_printline
	movea.l	D3,SP
	moveq	#-1,D0
	bra.s	go2
go3:
	move.l	A3,-(SP)
	pea	decompressing(PC)
	bsr	_printline
	addq	#4,SP
	bsr	_printline
	pea	crlf(PC)
	bsr	_printline
	addq	#4,SP
	movea.l	D3,SP
	clr.l	D0
go2:
	addq	#4,SP
go1:
	movem.l	-28(A6),D2-D4/A2-A4
	unlk	A6
	rts

gunzip_fillbuf:

	move.l	window-_bss(A5),previous_window-_bss(A5)
	move.l	4(SP),window-_bss(A5)
	bsr	call_gunzip
	rts

gunzip_close:

	move.l	A2,-(SP)
	move.l	gunzip_stack-_bss(A5),-(SP)
	bsr	_free
	move.l	inbuf-_bss(A5),-(SP)
	bsr	_free
	bsr	_sclose
	clr.l	D0
	addq	#8,SP
	movea.l	(SP)+,A2
	rts

huft_build:

	link	A6,#-$564
	movem.l	D2-D7/A2-A5,-(SP)
	subq	#4,SP
	move.l	8(A6),D5
	move.l	32(A6),D6
	pea	68.w
	clr.l	-(SP)
	pea	-68(A6)
	bsr	_memset
	addq	#8,SP
	addq	#4,SP
	movea.l	D5,A2
	move.l	12(A6),D4
hb40:
		move.l	(A2)+,D0
		addq.l	#1,-68(A6,D0.L*4)
	subq.l	#1,D4
	bne.s	hb40
	move.l	12(A6),D3
	cmp.l	-68(A6),D3
	bne.s	hb39
	movea.l	28(A6),A3
	clr.l	(A3)
	movea.l	D6,A3
	clr.l	(A3)
	clr.l	D0
	bra	hb1
hb39:
	movea.l	D6,A3
	move.l	(A3),(SP)
	moveq	#1,D2
hb38:
		tst.l	-68(A6,D2.L*4)
		bne.s	hb37
		addq.l	#1,D2
		moveq	#16,D3
	cmp.l	D2,D3
	bcc.s	hb38
hb37:
	movea.l	D2,A4
	cmpa.l	(SP),A4
	bls.s	hb36
	move.l	A4,(SP)
hb36:
	moveq	#16,D4
hb35:
		tst.l	-68(A6,D4.L*4)
		bne.s	hb34
	subq.l	#1,D4
	bne.s	hb35
hb34:
	move.l	D4,-$552(A6)
	cmp.l	(SP),D4
	bcc.s	hb33
	move.l	D4,(SP)
hb33:
	movea.l	D6,A3
	move.l	(SP),(A3)
	moveq	#1,D0
	asl.l	D2,D0
	move.l	D0,-$556(A6)
	cmp.l	-$552(A6),D2
	bcc.s	hb31
hb32:
		move.l	-68(A6,D2.L*4),D3
		sub.l	D3,-$556(A6)
		bmi.s	hb30
		addq.l	#1,D2
		move.l	-$556(A6),D3
		add.l	D3,D3
		move.l	D3,-$556(A6)
	cmp.l	D2,D4
	bhi.s	hb32
hb31:
	move.l	-68(A6,D4.L*4),D0
	sub.l	D0,-$556(A6)
	bpl.s	hb29
hb30:
	moveq	#2,D0
	bra	hb1
hb29:
	add.l	-$556(A6),D0
	move.l	D0,-68(A6,D4.L*4)
	clr.l	D2
	clr.l	-$54A(A6)
	lea	-64(A6),A2
	lea	-$546(A6),A0
	bra.s	hb27
hb28:
		add.l	(A2)+,D2
		move.l	D2,(A0)+
hb27:
	subq.l	#1,D4
	bne.s	hb28
	movea.l	D5,A2
	clr.l	D4
hb26:
		move.l	(A2)+,D2
		beq.s	hb25
		lea	(A6,D2.L*4),A1
		movea.l	-$54E(A1),A0
		lea	(A6,A0.L*4),A0
		move.l	D4,-$50A(A0)
		addq.l	#1,-$54E(A1)
hb25:
		addq.l	#1,D4
	cmp.l	12(A6),D4
	bcs.s	hb26
	clr.l	D4
	clr.l	-$54E(A6)
	lea	-$50A(A6),A2
	moveq	#-1,D7
	move.l	(SP),D5
	neg.l	D5
	clr.l	-138(A6)
	suba.l	A1,A1
	clr.l	D6
	cmpa.l	-$552(A6),A4
	bgt	hb2
hb24:
	movea.l	-68(A6,A4.L*4),A3
	subq	#1,A3
	move.l	A3,-$55E(A6)
	moveq	#-1,D3
	cmp.l	A3,D3
	beq	hb3
	lea	(A6,D7.L*4),A3
	move.l	A3,-$55A(A6)
hb23:
	move.l	D5,D0
	add.l	(SP),D0
	cmp.l	A4,D0
	bge	hb14
	lea	(A6,D7.L*4),A3
	move.l	A3,-$562(A6)
hb22:
		addq.l	#4,-$562(A6)
		addq.l	#4,-$55A(A6)
		addq.l	#1,D7
		move.l	D0,D5
		move.l	-$552(A6),D6
		sub.l	D5,D6
		move.l	D6,D0
		cmp.l	(SP),D0
		bcs.s	hb21
		move.l	(SP),D0
hb21:
		move.l	D0,D6
		move.l	A4,D2
		sub.l	D5,D2
		moveq	#1,D1
		asl.l	D2,D1
		movea.l	-$55E(A6),A0
		addq	#1,A0
		cmpa.l	D1,A0
		bcc.s	hb18
		move.l	D1,D0
		subq.l	#1,D0
		move.l	D0,D1
		sub.l	-$55E(A6),D1
		lea	-68(A6,A4.L*4),A0
		bra.s	hb19
hb20:
			add.l	D1,D1
			addq	#4,A0
			move.l	(A0),D0
			cmp.l	D1,D0
			bcc.s	hb18
			sub.l	D0,D1
hb19:
			addq.l	#1,D2
		cmp.l	D2,D6
		bhi.s	hb20
hb18:
		moveq	#1,D6
		asl.l	D2,D6
		movea.l	D6,A3
		lea	3(A3,D6.L*2),A3
		move.l	A3,D0
		add.l	D0,D0
		move.l	D0,-(SP)
		bsr	_malloc
		addq	#4,SP
		movea.l	D0,A1
		tst.l	A1
		bne.s	hb16
		tst.l	D7
		beq.s	hb17
		move.l	-138(A6),-(SP)
		bsr	huft_free
		addq	#4,SP
hb17:
		moveq	#3,D0
		bra	hb1
hb16:
		move.l	hufts-_bss(A5),D0
		addq.l	#1,D0
		add.l	D6,D0
		move.l	D0,hufts-_bss(A5)
		lea	6(A1),A0
		movea.l	28(A6),A3
		move.l	A0,(A3)
		addq	#2,A1
		move.l	A1,28(A6)
		clr.l	(A1)
		movea.l	A0,A1
		movea.l	-$562(A6),A3
		move.l	A1,-138(A3)
		tst.l	D7
		beq.s	hb15
		move.l	D4,-$54E(A3)
		move.b	3(SP),-73(A6)
		addi.b	#16,D2
		move.b	D2,-74(A6)
		move.l	A1,-72(A6)
		move.l	D5,D0
		sub.l	(SP),D0
		move.l	D4,D2
		lsr.l	D0,D2
		movea.l	-142(A3),A0
		movea.l	D2,A3
		lea	(A3,D2.L*2),A3
		move.l	A3,D0
		add.l	D0,D0
		move.l	-74(A6),(A0,D0.L)
		move	-70(A6),4(A0,D0.L)
hb15:
		move.l	D5,D0
		add.l	(SP),D0
	cmp.l	A4,D0
	blt	hb22
hb14:
	move	A4,D3
	sub.b	D5,D3
	move.b	D3,-73(A6)
	lea	-$50A(A6),A0
	movea.l	12(A6),A3
	lea	(A0,A3.L*4),A3
	move.l	A3,D0
	cmp.l	A2,D0
	bhi.s	hb13
	move.b	#99,-74(A6)
	bra.s	hb10
hb13:
	move.l	(A2),D0
	cmp.l	16(A6),D0
	bcc.s	hb11
	move.b	#15,D1
	cmpi.l	#$FF,D0
	bhi.s	hb12
	move.b	#16,D1
hb12:
	move.b	D1,-74(A6)
	move.l	(A2)+,D0
	move	D0,-72(A6)
	bra.s	hb10
hb11:
	sub.l	16(A6),D0
	movea.l	24(A6),A3
	move.b	1(A3,D0.L*2),-74(A6)
	move.l	(A2)+,D0
	sub.l	16(A6),D0
	movea.l	20(A6),A3
	move	(A3,D0.L*2),-72(A6)
hb10:
	move.l	A4,D0
	sub.l	D5,D0
	moveq	#1,D1
	asl.l	D0,D1
	move.l	D4,D2
	lsr.l	D5,D2
	cmp.l	D2,D6
	bls.s	hb8
	movea.l	D2,A3
	lea	(A3,D2.L*2),A0
hb9:
		move.l	A0,D0
		add.l	D0,D0
		move.l	-74(A6),(A1,D0.L)
		move	-70(A6),4(A1,D0.L)
		movea.l	D1,A3
		lea	(A3,D1.L*2),A3
		move.l	A3,D0
		adda.l	D0,A0
		add.l	D1,D2
	cmp.l	D2,D6
	bhi.s	hb9
hb8:
	move.l	A4,D0
	subq.l	#1,D0
	moveq	#1,D2
	asl.l	D0,D2
	bra.s	hb6
hb7:
		eor.l	D2,D4
		lsr.l	#1,D2
hb6:
		move.l	D4,D0
	and.l	D2,D0
	bne.s	hb7
	eor.l	D2,D4
	moveq	#1,D0
	asl.l	D5,D0
	subq.l	#1,D0
	and.l	D4,D0
	move.l	D7,D1
	asl.l	#2,D1
	movea.l	-$55A(A6),A3
	cmp.l	-$54E(A3),D0
	beq.s	hb4
	moveq	#1,D2
	lea	(A6,D1.L),A0
hb5:
		subq	#4,A0
		subq.l	#4,-$55A(A6)
		subq.l	#1,D7
		sub.l	(SP),D5
		move.l	D2,D0
		asl.l	D5,D0
		subq.l	#1,D0
		and.l	D4,D0
	cmp.l	-$54E(A0),D0
	bne.s	hb5
hb4:
	subq.l	#1,-$55E(A6)
	bcc	hb23
hb3:
	addq	#1,A4
	cmpa.l	-$552(A6),A4
	ble	hb24
hb2:
	clr.l	D0
	tst.l	-$556(A6)
	beq.s	hb1
	moveq	#1,D3
	cmp.l	-$552(A6),D3
	beq.s	hb1
	moveq	#1,D0
hb1:
	addq	#4,SP
	movem.l	-$58C(A6),D2-D7/A2-A5
	unlk	A6
	rts

huft_free:

	move.l	D2,-(SP)
	movea.l	8(SP),A0
	tst.l	A0
	beq.s	huft_free_end
huft_free_loop:
		subq	#6,A0
		move.l	2(A0),D2
		move.l	A0,-(SP)
		bsr	_free
		movea.l	D2,A0
		addq	#4,SP
	tst.l	A0
	bne.s	huft_free_loop
huft_free_end:
	clr.l	D0
	move.l	(SP)+,D2
	rts

inflate_codes:

	adda	#-20,SP
	movem.l	D2-D7/A2-A6,-(SP)
	move.l	bb-_bss(A5),D4
	move.l	bk-_bss(A5),D3
	movea.l	outcnt-_bss(A5),A4
	lea	mask_bits(PC),A0
	move.l	76(SP),D7
	move	(A0,D7.L*2),D7
	andi.l	#$FFFF,D7
	move.l	D7,56(SP)
	move.l	80(SP),D7
	move	(A0,D7.L*2),D7
	andi.l	#$FFFF,D7
	move.l	D7,52(SP)
	clr.l	44(SP)
	movea.l	A0,A6
	clr.l	48(SP)
ic43:
	cmp.l	76(SP),D3
	bcc.s	ic39
	clr.l	D2
ic42:
		movea.l	inptr-_bss(A5),A1
		cmpa.l	insize-_bss(A5),A1
		bcc.s	ic41
		movea.l	inbuf-_bss(A5),A0
		move.b	(A1,A0.L),D2
		move.l	D2,D0
		asl.l	D3,D0
		or.l	D0,D4
		addq.l	#1,inptr-_bss(A5)
		bra.s	ic40
ic41:
		bsr	fill_inbuf
		move.b	D0,47(SP)
		move.l	44(SP),D0
		asl.l	D3,D0
		or.l	D0,D4
ic40:
		addq.l	#8,D3
	cmp.l	76(SP),D3
	bcs.s	ic42
ic39:
	move.l	56(SP),D0
	and.l	D4,D0
	move.l	D0,D7
	add.l	D0,D0
	add.l	D7,D0
	movea.l	68(SP),A3
	adda.l	D0,A3
	adda.l	D0,A3
	clr.l	D7
	move.b	(A3),D7
	movea.l	D7,A2
	moveq	#16,D7
	cmp.l	A2,D7
	bcc.s	ic33
	clr.l	D5
ic38:
		moveq	#99,D7
		cmp.l	A2,D7
		beq	ic22
		move.b	1(A3),D5
		lsr.l	D5,D4
		sub.l	D5,D3
		subq	#8,A2
		subq	#8,A2
		cmpa.l	D3,A2
		bls.s	ic34
		clr.l	D2
ic37:       	
			movea.l	inptr-_bss(A5),A1
			cmpa.l	insize-_bss(A5),A1
			bcc.s	ic36
			movea.l	inbuf-_bss(A5),A0
			move.b	(A1,A0.L),D2
			move.l	D2,D0
			asl.l	D3,D0
			or.l	D0,D4
			addq.l	#1,inptr-_bss(A5)
			bra.s	ic35
ic36:
			bsr	fill_inbuf
			andi.l	#$FF,D0
			asl.l	D3,D0
			or.l	D0,D4
ic35:
			addq.l	#8,D3
		cmpa.l	D3,A2
		bhi.s	ic37
ic34:
		move	(A6,A2.L*2),50(SP)
		move.l	48(SP),D0
		and.l	D4,D0
		move.l	D0,D7
		add.l	D0,D0
		add.l	D7,D0
		movea.l	2(A3),A0
		lea	(A0,D0.L*2),A3
		clr.l	D7
		move.b	(A3),D7
		movea.l	D7,A2
		moveq	#16,D7
	cmp.l	A2,D7
	bcs.s	ic38
ic33:
	clr.l	D0
	move.b	1(A3),D0
	lsr.l	D0,D4
	sub.l	D0,D3
	moveq	#16,D7
	cmp.l	A2,D7
	bne.s	ic32
	movea.l	window-_bss(A5),A0
	move.b	3(A3),(A4,A0.L)
	addq	#1,A4
	cmpa.l	#$8000,A4
	bne	ic43
	move.l	A4,outcnt-_bss(A5)
	bsr	flush_window
	suba.l	A4,A4
	bra	ic43
ic32:
	moveq	#15,D7
	cmp.l	A2,D7
	beq	ic2
	cmpa.l	D3,A2
	bls.s	ic28
	clr.l	D2
ic31:
		movea.l	inptr-_bss(A5),A1
		cmpa.l	insize-_bss(A5),A1
		bcc.s	ic30
		movea.l	inbuf-_bss(A5),A0
		move.b	(A1,A0.L),D2
		move.l	D2,D0
		asl.l	D3,D0
		or.l	D0,D4
		addq.l	#1,inptr-_bss(A5)
		bra.s	ic29
ic30:
		bsr	fill_inbuf
		andi.l	#$FF,D0
		asl.l	D3,D0
		or.l	D0,D4
ic29:
		addq.l	#8,D3
	cmpa.l	D3,A2
	bhi.s	ic31
ic28:
	clr.l	D1
	move	2(A3),D1
	clr.l	D0
	move	(A6,A2.L*2),D0
	and.l	D4,D0
	move.l	D1,D6
	add.l	D0,D6
	move.l	A2,D7
	lsr.l	D7,D4
	sub.l	A2,D3
	cmp.l	80(SP),D3
	bcc.s	ic24
	clr.l	D2
ic27:
		movea.l	inptr-_bss(A5),A1
		cmpa.l	insize-_bss(A5),A1
		bcc.s	ic26
		movea.l	inbuf-_bss(A5),A0
		move.b	(A1,A0.L),D2
		move.l	D2,D0
		asl.l	D3,D0
		or.l	D0,D4
		addq.l	#1,inptr-_bss(A5)
		bra.s	ic25
ic26:
		bsr	fill_inbuf
		andi.l	#$FF,D0
		asl.l	D3,D0
		or.l	D0,D4
ic25:
		addq.l	#8,D3
	cmp.l	80(SP),D3
	bcs.s	ic27
ic24:
	move.l	52(SP),D0
	and.l	D4,D0
	move.l	D0,D7
	add.l	D0,D0
	add.l	D7,D0
	movea.l	72(SP),A3
	adda.l	D0,A3
	adda.l	D0,A3
	clr.l	D7
	move.b	(A3),D7
	movea.l	D7,A2
	moveq	#16,D7
	cmp.l	A2,D7
	bcc.s	ic16
	clr.l	D5
ic23:
		moveq	#99,D7
		cmp.l	A2,D7
		bne.s	ic21
ic22:
		moveq	#1,D0
		bra	ic1
ic21:
		move.b	1(A3),D5
		lsr.l	D5,D4
		sub.l	D5,D3
		subq	#8,A2
		subq	#8,A2
		cmpa.l	D3,A2
		bls.s	ic17
		clr.l	D2
ic20:
			movea.l	inptr-_bss(A5),A1
			cmpa.l	insize-_bss(A5),A1
			bcc.s	ic19
			movea.l	inbuf-_bss(A5),A0
			move.b	(A1,A0.L),D2
			move.l	D2,D0
			asl.l	D3,D0
			or.l	D0,D4
			addq.l	#1,inptr-_bss(A5)
			bra.s	ic18
ic19:
			bsr	fill_inbuf
			andi.l	#$FF,D0
			asl.l	D3,D0
			or.l	D0,D4
ic18:
			addq.l	#8,D3
		cmpa.l	D3,A2
		bhi.s	ic20
ic17:
		clr.l	D0
		move	(A6,A2.L*2),D0
		and.l	D4,D0
		move.l	D0,D7
		add.l	D0,D0
		add.l	D7,D0
		movea.l	2(A3),A0
		lea	(A0,D0.L*2),A3
		clr.l	D7
		move.b	(A3),D7
		movea.l	D7,A2
		moveq	#16,D7
	cmp.l	A2,D7
	bcs.s	ic23
ic16:
	clr.l	D0
	move.b	1(A3),D0
	lsr.l	D0,D4
	sub.l	D0,D3
	cmpa.l	D3,A2
	bls.s	ic12
	clr.l	D2
ic15:
		movea.l	inptr-_bss(A5),A1
		cmpa.l	insize-_bss(A5),A1
		bcc.s	ic14
		movea.l	inbuf-_bss(A5),A0
		move.b	(A1,A0.L),D2
		move.l	D2,D0
		asl.l	D3,D0
		or.l	D0,D4
		addq.l	#1,inptr-_bss(A5)
		bra.s	ic13
ic14:
		bsr	fill_inbuf
		andi.l	#$FF,D0
		asl.l	D3,D0
		or.l	D0,D4
ic13:
		addq.l	#8,D3
	cmpa.l	D3,A2
	bhi.s	ic15
ic12:
	clr.l	D0
	move	2(A3),D0
	move.l	A4,D1
	sub.l	D0,D1
	clr.l	D0
	move	(A6,A2.L*2),D0
	and.l	D4,D0
	move.l	D1,D2
	sub.l	D0,D2
	move.l	A2,D7
	lsr.l	D7,D4
	sub.l	A2,D3
ic11:
		andi.l	#$7FFF,D2
		cmpa.l	D2,A4
		bcc.s	ic10
		movea.l	#$8000,A2
		suba.l	D2,A2
		bra.s	ic9
ic10:
		movea.l	#$8000,A2
		suba.l	A4,A2
ic9:
		move.l	A2,D0
		cmp.l	D0,D6
		bcc.s	ic8
		move.l	D6,D0
ic8:
		movea.l	D0,A2
		sub.l	A2,D6
		move.l	A4,D0
		sub.l	D2,D0
		cmpa.l	D0,A2
		bhi.s	ic5
		cmpa.l	D2,A4
		bcc.s	ic7
		movea.l	previous_window-_bss(A5),A3
		suba.l	window-_bss(A5),A3
		bra.s	ic6
ic7:
		suba.l	A3,A3
ic6:
		movea.l	window-_bss(A5),A0
		lea	(A0,D2.L),A1
		move.l	A2,-(SP)
		pea	(A3,A1.L)
		pea	(A4,A0.L)
		bsr	_memmove
		addq	#8,SP
		addq	#4,SP
		adda.l	A2,A4
		add.l	A2,D2
		bra.s	ic4
ic5:
			movea.l	window-_bss(A5),A0
			move.b	(A0,D2.L),(A4,A0.L)
			addq.l	#1,D2
			addq	#1,A4
			subq	#1,A2
		tst.l	A2
		bne.s	ic5
ic4:
		cmpa.l	#$8000,A4
		bne.s	ic3
		move.l	A4,outcnt-_bss(A5)
		bsr	flush_window
		suba.l	A4,A4
ic3:
	tst.l	D6
	bne	ic11
	bra	ic43
ic2:
	move.l	A4,outcnt-_bss(A5)
	move.l	D4,bb-_bss(A5)
	move.l	D3,bk-_bss(A5)
	clr.l	D0
ic1:
	movem.l	(SP)+,D2-D7/A2-A6
	adda	#20,SP
	rts

inflate_stored:

	movem.l	D2-D6/A2,-(SP)
	move.l	bb-_bss(A5),D3
	move.l	bk-_bss(A5),D2
	movea.l	outcnt-_bss(A5),A2
	moveq	#7,D6
	and.l	D2,D6
	lsr.l	D6,D3
	sub.l	D6,D2
	moveq	#15,D1
	cmp.l	D2,D1
	bcs.s	is14
	clr.l	D4
is17:
		movea.l	inptr-_bss(A5),A1
		cmpa.l	insize-_bss(A5),A1
		bcc.s	is16
		movea.l	inbuf-_bss(A5),A0
		move.b	(A1,A0.L),D4
		move.l	D4,D0
		asl.l	D2,D0
		or.l	D0,D3
		addq.l	#1,inptr-_bss(A5)
		bra.s	is15
is16:
		bsr	fill_inbuf
		andi.l	#$FF,D0
		asl.l	D2,D0
		or.l	D0,D3
is15:
		addq.l	#8,D2
		moveq	#15,D1
	cmp.l	D2,D1
	bcc.s	is17
is14:
	move.l	D3,D6
	andi.l	#$FFFF,D6
	clr	D3
	swap	D3
	moveq	#-16,D1
	add.l	D1,D2
	moveq	#15,D1
	cmp.l	D2,D1
	bcs.s	is10
	clr.l	D4
is13:
		movea.l	inptr-_bss(A5),A1
		cmpa.l	insize-_bss(A5),A1
		bcc.s	is12
		movea.l	inbuf-_bss(A5),A0
		move.b	(A1,A0.L),D4
		move.l	D4,D0
		asl.l	D2,D0
		or.l	D0,D3
		addq.l	#1,inptr-_bss(A5)
		bra.s	is11
is12:
		bsr	fill_inbuf
		andi.l	#$FF,D0
		asl.l	D2,D0
		or.l	D0,D3
is11:
		addq.l	#8,D2
		moveq	#15,D1
	cmp.l	D2,D1
	bcc.s	is13
is10:
	move.l	D3,D0
	not.l	D0
	andi.l	#$FFFF,D0
	cmp.l	D6,D0
	beq.s	is9
	moveq	#1,D0
	bra	is1
is9:
	clr	D3
	swap	D3
	moveq	#-16,D1
	add.l	D1,D2
	subq.l	#1,D6
	moveq	#-1,D1
	cmp.l	D6,D1
	beq.s	is2
	clr.l	D5
is8:
		moveq	#7,D1
		cmp.l	D2,D1
		bcs.s	is4
		clr.l	D4
is7:
			movea.l	inptr-_bss(A5),A1
			cmpa.l	insize-_bss(A5),A1
			bcc.s	is6
			movea.l	inbuf-_bss(A5),A0
			move.b	(A1,A0.L),D4
			move.l	D4,D0
			asl.l	D2,D0
			or.l	D0,D3
			addq.l	#1,inptr-_bss(A5)
			bra.s	is5
is6:
			bsr	fill_inbuf
			move.b	D0,D5
			move.l	D5,D0
			asl.l	D2,D0
			or.l	D0,D3
is5:
			addq.l	#8,D2
			moveq	#7,D1
		cmp.l	D2,D1
		bcc.s	is7
is4:
		movea.l	window-_bss(A5),A0
		move.b	D3,(A2,A0.L)
		addq	#1,A2
		cmpa.l	#$8000,A2
		bne.s	is3
		move.l	A2,outcnt-_bss(A5)
		bsr	flush_window
		suba.l	A2,A2
is3:
		lsr.l	#8,D3
		subq.l	#8,D2
		dbf	D6,is8
		clr	D6
	subq.l	#1,D6
	bcc.s	is8
is2:
	move.l	A2,outcnt-_bss(A5)
	move.l	D3,bb-_bss(A5)
	move.l	D2,bk-_bss(A5)
	clr.l	D0
is1:
	movem.l	(SP)+,D2-D6/A2
	rts

inflate_fixed:

	link	A6,#-$490
	move.l	A2,-(SP)
	move.l	D2,-(SP)
	move.l	#143,D2
	lea	$23C(A6),A0
if10:
			moveq	#8,D1
			move.l	D1,-$480(A0)
			subq	#4,A0
		dbf	D2,if10
		clr	D2
	subq.l	#1,D2
	bcc.s	if10
	move.l	#144,D2
	lea	$240(A6),A0
if9:
		moveq	#9,D1
		move.l	D1,-$480(A0)
		addq	#4,A0
		addq.l	#1,D2
	cmpi.l	#255,D2
	ble.s	if9
	cmpi.l	#279,D2
	bgt.s	if7
	lea	(A6,D2.L*4),A0
if8:
		moveq	#7,D1
		move.l	D1,-$480(A0)
		addq	#4,A0
		addq.l	#1,D2
	cmpi.l	#279,D2
	ble.s	if8
if7:
	cmpi.l	#287,D2
	bgt.s	if5
	lea	(A6,D2.L*4),A0
if6:
		moveq	#8,D1
		move.l	D1,-$480(A0)
		addq	#4,A0
		addq.l	#1,D2
	cmpi.l	#287,D2
	ble.s	if6
if5:
	moveq	#7,D1
	move.l	D1,-$488(A6)
	pea	-$488(A6)
	pea	-$484(A6)
	pea	cplext(PC)
	pea	cplens(PC)
	pea	257.w
	pea	288.w
	pea	-$480(A6)
	bsr	huft_build
	move.l	D0,D2
	adda	#28,SP
	bne	if1
	movea.l	A6,A0
if4:
		moveq	#5,D1
		move.l	D1,-$480(A0)
		addq	#4,A0
		addq.l	#1,D2
		moveq	#29,D1
	cmp.l	D2,D1
	bge.s	if4
	moveq	#5,D1
	move.l	D1,-$490(A6)
	pea	-$490(A6)
	pea	-$48C(A6)
	pea	cpdext(PC)
	pea	cpdist(PC)
	clr.l	-(SP)
	pea	30.w
	pea	-$480(A6)
	bsr	huft_build
	move.l	D0,D2
	adda	#28,SP
	moveq	#1,D1
	cmp.l	D2,D1
	bge.s	if3
	move.l	-$484(A6),-(SP)
	bsr	huft_free
	move.l	D2,D0
	addq	#4,SP
	bra.s	if1
if3:
	move.l	-$490(A6),-(SP)
	move.l	-$488(A6),-(SP)
	move.l	-$48C(A6),-(SP)
	move.l	-$484(A6),-(SP)
	bsr	inflate_codes
	addq	#8,SP
	addq	#8,SP
	tst.l	D0
	bne.s	if2
	move.l	-$484(A6),-(SP)
	bsr	huft_free
	move.l	-$48C(A6),-(SP)
	bsr	huft_free
	clr.l	D0
	addq	#8,SP
	bra.s	if1
if2:
	moveq	#1,D0
if1:
	move.l	-$498(A6),D2
	movea.l	-$494(A6),A2
	unlk	A6
	rts

inflate_dynamic:

	link	A6,#-$50C
	movem.l	D2-D7/A2-A4,-(SP)
	move.l	bb-_bss(A5),D4
	move.l	bk-_bss(A5),D3
	moveq	#4,D7
	cmp.l	D3,D7
	bcs.s	id50
	clr.l	D2
id53:
		movea.l	inptr-_bss(A5),A1
		cmpa.l	insize-_bss(A5),A1
		bcc.s	id52
		movea.l	inbuf-_bss(A5),A0
		move.b	(A1,A0.L),D2
		move.l	D2,D0
		asl.l	D3,D0
		or.l	D0,D4
		addq.l	#1,inptr-_bss(A5)
		bra.s	id51
id52:
		bsr	fill_inbuf
		andi.l	#$FF,D0
		asl.l	D3,D0
		or.l	D0,D4
id51:
		addq.l	#8,D3
		moveq	#4,D7
	cmp.l	D3,D7
	bcc.s	id53
id50:
	moveq	#$1F,D0
	and.l	D4,D0
	addi.l	#257,D0
	move.l	D0,-$508(A6)
	lsr.l	#5,D4
	subq.l	#5,D3
	moveq	#4,D7
	cmp.l	D3,D7
	bcs.s	id46
	clr.l	D2
id49:
		movea.l	inptr-_bss(A5),A1
		cmpa.l	insize-_bss(A5),A1
		bcc.s	id48
		movea.l	inbuf-_bss(A5),A0
		move.b	(A1,A0.L),D2
		move.l	D2,D0
		asl.l	D3,D0
		or.l	D0,D4
		addq.l	#1,inptr-_bss(A5)
		bra.s	id47
id48:
		bsr	fill_inbuf
		andi.l	#$FF,D0
		asl.l	D3,D0
		or.l	D0,D4
id47:
		addq.l	#8,D3
		moveq	#4,D7
	cmp.l	D3,D7
	bcc.s	id49
id46:
	moveq	#$1F,D0
	and.l	D4,D0
	addq.l	#1,D0
	move.l	D0,-$504(A6)
	lsr.l	#5,D4
	subq.l	#5,D3
	moveq	#3,D7
	cmp.l	D3,D7
	bcs.s	id42
	clr.l	D2
id45:
		movea.l	inptr-_bss(A5),A1
		cmpa.l	insize-_bss(A5),A1
		bcc.s	id44
		movea.l	inbuf-_bss(A5),A0
		move.b	(A1,A0.L),D2
		move.l	D2,D0
		asl.l	D3,D0
		or.l	D0,D4
		addq.l	#1,inptr-_bss(A5)
		bra.s	id43
id44:
		bsr	fill_inbuf
		andi.l	#$FF,D0
		asl.l	D3,D0
		or.l	D0,D4
id43:
		addq.l	#8,D3
		moveq	#3,D7
	cmp.l	D3,D7
	bcc.s	id45
id42:
	moveq	#$F,D0
	and.l	D4,D0
	movea.l	D0,A2
	addq	#4,A2
	lsr.l	#4,D4
	subq.l	#4,D3
	cmpi.l	#286,-$508(A6)
	bhi	id2
	moveq	#30,D7
	cmp.l	-$504(A6),D7
	bcs	id2
	clr.l	D2
	cmpa.l	D2,A2
	bls.s	id36
	clr.l	D6
id41:
		moveq	#2,D7
		cmp.l	D3,D7
		bcs.s	id37
		clr.l	D5
id40:
			movea.l	inptr-_bss(A5),A1
			cmpa.l	insize-_bss(A5),A1
			bcc.s	id39
			movea.l	inbuf-_bss(A5),A0
			move.b	(A1,A0.L),D5
			move.l	D5,D0
			asl.l	D3,D0
			or.l	D0,D4
			addq.l	#1,inptr-_bss(A5)
			bra.s	id38
id39:
			bsr	fill_inbuf
			move.b	D0,D6
			move.l	D6,D0
			asl.l	D3,D0
			or.l	D0,D4
id38:
			addq.l	#8,D3
			moveq	#2,D7
		cmp.l	D3,D7
		bcc.s	id40
id37:
		lea	border(PC),A0
		movea.l	(A0,D2.L*4),A0
		lea	(A6,A0.L*4),A0
		moveq	#7,D7
		and.l	D4,D7
		move.l	D7,-$4F0(A0)
		lsr.l	#3,D4
		subq.l	#3,D3
		addq.l	#1,D2
	cmpa.l	D2,A2
	bhi.s	id41
id36:
	moveq	#18,D7
	cmp.l	D2,D7
	bcs.s	id34
	move.l	D2,D0
	asl.l	#2,D0
	lea	border(PC),A1
	adda.l	D0,A1
id35:
		movea.l	(A1)+,A0
		lea	(A6,A0.L*4),A0
		clr.l	-$4F0(A0)
		addq.l	#1,D2
		moveq	#18,D7
	cmp.l	D2,D7
	bcc.s	id35
id34:
	moveq	#7,D7
	move.l	D7,-$4F8(A6)
	pea	-$4F8(A6)
	pea	-$4F4(A6)
	clr.l	-(SP)
	clr.l	-(SP)
	pea	19.w
	pea	19.w
	pea	-$4F0(A6)
	bsr	huft_build
	movea.l	D0,A2
	adda	#28,SP
	tst.l	A2
	beq.s	id33
	moveq	#1,D7
	cmp.l	A2,D7
	bne	id6
	move.l	-$4F4(A6),-(SP)
	bsr	huft_free
	addq	#4,SP
	bra	id6
id33:
	move.l	-$504(A6),D6
	add.l	-$508(A6),D6
	move.l	D6,-$50C(A6)
	move.l	-$4F8(A6),D0
	lea	mask_bits(PC),A0
	move	(A0,D0.L*2),D0
	andi.l	#$FFFF,D0
	movea.l	D0,A4
	clr.l	D5
	cmp.l	A2,D6
	bls	id7
	clr.l	D6
	movea.l	A6,A3
id32:
	cmp.l	-$4F8(A6),D3
	bcc.s	id28
	clr.l	D2
id31:
		movea.l	inptr-_bss(A5),A1
		cmpa.l	insize-_bss(A5),A1
		bcc.s	id30
		movea.l	inbuf-_bss(A5),A0
		move.b	(A1,A0.L),D2
		move.l	D2,D0
		asl.l	D3,D0
		or.l	D0,D4
		addq.l	#1,inptr-_bss(A5)
		bra.s	id29
id30:
		bsr	fill_inbuf
		move.b	D0,D6
		move.l	D6,D0
		asl.l	D3,D0
		or.l	D0,D4
id29:
		addq.l	#8,D3
	cmp.l	-$4F8(A6),D3
	bcs.s	id31
id28:
	move.l	A4,D7
	and.l	D4,D7
	movea.l	D7,A0
	lea	(A0,A0.L*2),A0
	movea.l	-$4F4(A6),A1
	lea	(A1,A0.L*2),A0
	move.l	A0,-$4FC(A6)
	clr.l	D2
	move.b	1(A0),D2
	lsr.l	D2,D4
	sub.l	D2,D3
	clr.l	D2
	move	2(A0),D2
	moveq	#15,D7
	cmp.l	D2,D7
	bcs.s	id27
	move.l	D2,D5
	move.l	D5,-$4F0(A3)
	addq	#4,A3
	addq	#1,A2
	bra	id8
id27:
	moveq	#16,D7
	cmp.l	D2,D7
	bne	id21
	moveq	#1,D7
	cmp.l	D3,D7
	bcs.s	id23
	clr.l	D2
id26:
		movea.l	inptr-_bss(A5),A1
		cmpa.l	insize-_bss(A5),A1
		bcc.s	id25
		movea.l	inbuf-_bss(A5),A0
		move.b	(A1,A0.L),D2
		move.l	D2,D0
		asl.l	D3,D0
		or.l	D0,D4
		addq.l	#1,inptr-_bss(A5)
		bra.s	id24
id25:
		bsr	fill_inbuf
		andi.l	#$FF,D0
		asl.l	D3,D0
		or.l	D0,D4
id24:
		addq.l	#8,D3
		moveq	#1,D7
	cmp.l	D3,D7
	bcc.s	id26
id23:
	moveq	#3,D1
	and.l	D4,D1
	lsr.l	#2,D4
	subq.l	#2,D3
	moveq	#3,D0
	add.l	A2,D0
	add.l	D1,D0
	cmp.l	-$50C(A6),D0
	bhi	id2
	move.l	D1,D2
	addq.l	#2,D2
	moveq	#-1,D7
	cmp.l	D2,D7
	beq	id8
	lea	(A6,A2.L*4),A0
id22:
			move.l	D5,-$4F0(A0)
			addq	#4,A0
			addq	#4,A3
			addq	#1,A2
		dbf	D2,id22
		clr	D2
	subq.l	#1,D2
	bcc.s	id22
	bra	id8
id21:
	moveq	#17,D7
	cmp.l	D2,D7
	bne	id15
	moveq	#2,D7
	cmp.l	D3,D7
	bcs.s	id17
	clr.l	D2
id20:
		movea.l	inptr-_bss(A5),A1
		cmpa.l	insize-_bss(A5),A1
		bcc.s	id19
		movea.l	inbuf-_bss(A5),A0
		move.b	(A1,A0.L),D2
		move.l	D2,D0
		asl.l	D3,D0
		or.l	D0,D4
		addq.l	#1,inptr-_bss(A5)
		bra.s	id18
id19:
		bsr	fill_inbuf
		andi.l	#$FF,D0
		asl.l	D3,D0
		or.l	D0,D4
id18:
		addq.l	#8,D3
		moveq	#2,D7
	cmp.l	D3,D7
	bcc.s	id20
id17:
	moveq	#7,D1
	and.l	D4,D1
	lsr.l	#3,D4
	subq.l	#3,D3
	moveq	#3,D0
	add.l	A2,D0
	add.l	D1,D0
	cmp.l	-$50C(A6),D0
	bhi	id2
	move.l	D1,D2
	addq.l	#2,D2
	moveq	#-1,D7
	cmp.l	D2,D7
	beq	id9
	lea	(A6,A2.L*4),A0
id16:
			clr.l	-$4F0(A0)
			addq	#4,A0
			addq	#4,A3
			addq	#1,A2
		dbf	D2,id16
		clr	D2
	subq.l	#1,D2
	bcc.s	id16
	bra.s	id9
id15:
	moveq	#6,D7
	cmp.l	D3,D7
	bcs.s	id11
	clr.l	D2
id14:
		movea.l	inptr-_bss(A5),A1
		cmpa.l	insize-_bss(A5),A1
		bcc.s	id13
		movea.l	inbuf-_bss(A5),A0
		move.b	(A1,A0.L),D2
		move.l	D2,D0
		asl.l	D3,D0
		or.l	D0,D4
		addq.l	#1,inptr-_bss(A5)
		bra.s	id12
id13:
		bsr	fill_inbuf
		andi.l	#$FF,D0
		asl.l	D3,D0
		or.l	D0,D4
id12:
		addq.l	#8,D3
		moveq	#6,D7
	cmp.l	D3,D7
	bcc.s	id14
id11:
	moveq	#$7F,D1
	and.l	D4,D1
	lsr.l	#7,D4
	subq.l	#7,D3
	moveq	#11,D0
	add.l	A2,D0
	add.l	D1,D0
	cmp.l	-$50C(A6),D0
	bhi	id2
	moveq	#10,D2
	add.l	D1,D2
	moveq	#-1,D7
	cmp.l	D2,D7
	beq.s	id9
	lea	(A6,A2.L*4),A0
id10:
			clr.l	-$4F0(A0)
			addq	#4,A0
			addq	#4,A3
			addq	#1,A2
		dbf	D2,id10
		clr	D2
	subq.l	#1,D2
	bcc.s	id10
id9:
	clr.l	D5
id8:
	cmpa.l	-$50C(A6),A2
	bcs	id32
id7:
	move.l	-$4F4(A6),-(SP)
	bsr	huft_free
	move.l	D4,bb-_bss(A5)
	move.l	D3,bk-_bss(A5)
	move.l	#9,-$4F8(A6) ; lbits
	pea	-$4F8(A6)
	pea	-$4F4(A6)
	pea	cplext(PC)
	pea	cplens(PC)
	pea	$101.w
	move.l	-$508(A6),-(SP)
	lea	-$4F0(A6),A3
	move.l	A3,-(SP)
	bsr	huft_build    
	movea.l	D0,A2
	adda	#32,SP
	tst.l	A2
	beq.s	id5
	moveq	#1,D7
	cmp.l	A2,D7
	bne.s	id6
	pea	error_40(PC)
	bsr	gunzip_error
	move.l	-$4F4(A6),-(SP)
	bsr	huft_free
	addq	#8,SP
id6:
	move.l	A2,D0
	bra	id1
id5:
	move.l	#6,-$500(A6) ; dbits
	pea	-$500(A6)
	pea	-$4FC(A6)
	pea	cpdext(PC)
	pea	cpdist(PC)
	clr.l	-(SP)
	move.l	-$504(A6),-(SP)
	movea.l	-$508(A6),A0
	pea	(A3,A0.L*4)
	bsr	huft_build   
	movea.l	D0,A2
	adda	#28,SP
	tst.l	A2
	beq.s	id3
	moveq	#1,D7
	cmp.l	A2,D7
	bne.s	id4
	pea	error_41(PC)
	bsr	gunzip_error
	move.l	-$4FC(A6),-(SP)
	bsr	huft_free
	addq	#8,SP
id4:
	move.l	-$4F4(A6),-(SP)
	bsr	huft_free
	move.l	A2,D0
	addq	#4,SP
	bra.s	id1
id3:
	move.l	-$500(A6),-(SP)
	move.l	-$4F8(A6),-(SP)
	move.l	-$4FC(A6),-(SP)
	move.l	-$4F4(A6),-(SP)
	bsr	inflate_codes
	addq	#8,SP
	addq	#8,SP
	tst.l	D0
	bne.s	id2
	move.l	-$4F4(A6),-(SP)
	bsr	huft_free
	move.l	-$4FC(A6),-(SP)
	bsr	huft_free
	clr.l	D0
	addq	#8,SP
	bra.s	id1
id2:
	moveq	#1,D0
id1:
	movem.l	-$534(A6),D2-D7/A2-A4
	unlk	A6
	rts

inflate_block:

	movem.l	D2-D4/A2,-(SP)
	movea.l	20(SP),A2
	move.l	bb-_bss(A5),D3
	move.l	bk-_bss(A5),D2
	bne.s	ib9
	clr.l	D4
ib12:
		movea.l	inptr-_bss(A5),A1
		cmpa.l	insize-_bss(A5),A1
		bcc.s	ib11
		movea.l	inbuf-_bss(A5),A0
		move.b	(A1,A0.L),D4
		move.l	D4,D0
		asl.l	D2,D0
		or.l	D0,D3
		addq.l	#1,inptr-_bss(A5)
		bra.s	ib10
ib11:
		bsr	fill_inbuf
		andi.l	#$FF,D0
		asl.l	D2,D0
		or.l	D0,D3
ib10:
	addq.l	#8,D2
	beq.s	ib12
ib9:
	moveq	#1,D1
	and.l	D3,D1
	move.l	D1,(A2)
	lsr.l	#1,D3
	subq.l	#1,D2
	moveq	#1,D1
	cmp.l	D2,D1
	bcs.s	ib5
	clr.l	D4
ib8:
		movea.l	inptr-_bss(A5),A1
		cmpa.l	insize-_bss(A5),A1
		bcc.s	ib7
		movea.l	inbuf-_bss(A5),A0
		move.b	(A1,A0.L),D4
		move.l	D4,D0
		asl.l	D2,D0
		or.l	D0,D3
		addq.l	#1,inptr-_bss(A5)
		bra.s	ib6
ib7:
		bsr	fill_inbuf
		andi.l	#$FF,D0
		asl.l	D2,D0
		or.l	D0,D3
ib6:
		addq.l	#8,D2
		moveq	#1,D1
	cmp.l	D2,D1
	bcc.s	ib8
ib5:
	moveq	#3,D0
	and.l	D3,D0
	lsr.l	#2,D3
	move.l	D3,bb-_bss(A5)
	subq.l	#2,D2
	move.l	D2,bk-_bss(A5)
	moveq	#2,D1
	cmp.l	D0,D1
	bne.s	ib4
	bsr	inflate_dynamic
	bra.s	ib1
ib4:
	tst.l	D0
	bne.s	ib3
	bsr	inflate_stored
	bra.s	ib1
ib3:
	moveq	#1,D1
	cmp.l	D0,D1
	beq.s	ib2
	moveq	#2,D0
	bra.s	ib1
ib2:
	bsr	inflate_fixed
ib1:
	movem.l	(SP)+,D2-D4/A2
	rts

inflate:

	link	A6,#-8
	movem.l	D2-D3/A2,-(SP)
	clr.l	outcnt-_bss(A5)
	clr.l	bk-_bss(A5)
	clr.l	bb-_bss(A5)
	clr.l	D3
	lea	-4(A6),A2
inflate_loop_1:
		clr.l	hufts-_bss(A5)
		move.l	A2,-(SP)
		bsr	gzip_mark
		pea	-8(A6)
		bsr	inflate_block
		move.l	D0,D2
		addq	#8,SP
		beq.s	inflate_next_3
		move.l	A2,-(SP)
		bsr	gzip_release
		move.l	D2,D0
		addq	#4,SP
		bra.s	inflate_end
inflate_next_3:
		move.l	A2,-(SP)
		bsr	gzip_release
		move.l	hufts-_bss(A5),D0
		addq	#4,SP
		cmp.l	D0,D3
		bcc.s	inflate_next_1
		move.l	D0,D3
inflate_next_1:
	tst.l	-8(A6)
	beq.s	inflate_loop_1
	move.l	bk-_bss(A5),D0
	bra.s	inflate_next_2
inflate_loop_2:
		subq.l	#8,D0
		move.l	D0,bk-_bss(A5)
		subq.l	#1,inptr-_bss(A5)
inflate_next_2:
		moveq	#7,D1
	cmp.l	D0,D1
	bcs.s	inflate_loop_2
	bsr	flush_window
	clr.l	D0
inflate_end:
	movem.l	-20(A6),D2-D3/A2
	unlk	A6
	rts

makecrc:

	movem.l	D2-D5,-(SP)
	clr.l	D4
	moveq	#1,D2
	lea	makecrc_p_end(PC),A0
	move.l	A0,D1
	lea	makecrc_p(PC),A0
makeexclusive_loop:
		moveq	#31,D0
		sub.l	(A0)+,D0
		move.l	D2,D5
		asl.l	D0,D5
		move.l	D5,D0
		or.l	D0,D4
	cmp.l	A0,D1
	bcc.s	makeexclusive_loop
	lea	crc_32_tab-_bss(A5),A0
	clr.l	(A0)+
	moveq	#1,D3
makecrc_loop:
		clr.l	D1
		move.l	D3,D2
		ori	#$100,D2
		bra.s	mc1
makecrc_loop_2:
			move.l	D1,D0
			lsr.l	#1,D0
			btst	#0,D1
			beq.s	mc3
			eor.l	D4,D0
mc3:
			move.l	D0,D1
			btst	#0,D2
			beq.s	mc2
			eor.l	D4,D1
mc2:
			asr.l	#1,D2
mc1:
			moveq	#1,D5
		cmp.l	D2,D5
		bne.s	makecrc_loop_2
		move.l	D1,(A0)+
		addq.l	#1,D3
	cmpi.l	#255,D3
	ble.s	makecrc_loop
	movem.l	(SP)+,D2-D5
	rts

gunzip:

	adda	#-8,SP
	movem.l	D2-D4,-(SP)
	movea.l	inptr-_bss(A5),A1
	cmpa.l	insize-_bss(A5),A1
	bcc.s	gz68
	movea.l	inbuf-_bss(A5),A0
	move.b	(A1,A0.L),D0
	addq.l	#1,inptr-_bss(A5)
	bra.s	gz67
gz68:
	bsr	fill_inbuf
gz67:
	move.b	D0,14(SP)
	movea.l	inptr-_bss(A5),A1
	cmpa.l	insize-_bss(A5),A1
	bcc.s	gz66
	movea.l	inbuf-_bss(A5),A0
	move.b	(A1,A0.L),D0
	addq.l	#1,inptr-_bss(A5)
	bra.s	gz65
gz66:
	bsr	fill_inbuf
gz65:
	move.b	D0,15(SP)
	movea.l	inptr-_bss(A5),A1
	cmpa.l	insize-_bss(A5),A1
	bcc.s	gz64
	movea.l	inbuf-_bss(A5),A0
	move.b	(A1,A0.L),D0
	addq.l	#1,inptr-_bss(A5)
	bra.s	gz63
gz64:
	bsr	fill_inbuf
gz63:
	cmpi.b	#$1F,14(SP)
	bne.s	gz62
	move.b	15(SP),D1
	cmpi.b	#$8B,D1
	beq.s	gz61
	cmpi.b	#$9E,D1
	beq.s	gz61
gz62:
	pea	error_42(PC)
	bra	gz3
gz61:
	cmpi.b	#8,D0
	beq.s	gz60
	pea	error_43(PC)
	bra	gz3
gz60:
	movea.l	inptr-_bss(A5),A1
	cmpa.l	insize-_bss(A5),A1
	bcc.s	gz59
	movea.l	inbuf-_bss(A5),A0
	move.b	(A1,A0.L),D3
	addq.l	#1,inptr-_bss(A5)
	bra.s	gz58
gz59:
	bsr	fill_inbuf
	move.b	D0,D3
gz58:
	btst	#5,D3 ; ENCRYPTED
	beq.s	gz57
	pea	error_44(PC)
	bra	gz3
gz57:
	btst	#1,D3 ; CONTINUATION
	beq.s	gz56
	pea	error_45(PC)
	bra	gz3
gz56:
	move.b	D3,D0
	andi.b	#$C0,D0 ; RESERVED
	beq.s	gz55
	pea	error_46(PC)
	bra	gz3
gz55:
	move.l	inptr-_bss(A5),D4
	cmp.l	insize-_bss(A5),D4
	bcc.s	gz54
	addq.l	#1,inptr-_bss(A5)
	bra.s	gz53
gz54:
	bsr	fill_inbuf
gz53:
	move.l	inptr-_bss(A5),D4
	cmp.l	insize-_bss(A5),D4
	bcc.s	gz52
	addq.l	#1,inptr-_bss(A5)
	bra.s	gz51
gz52:
	bsr	fill_inbuf
gz51:
	move.l	inptr-_bss(A5),D4
	cmp.l	insize-_bss(A5),D4
	bcc.s	gz50
	addq.l	#1,inptr-_bss(A5)
	bra.s	gz49
gz50:
	bsr	fill_inbuf
gz49:
	move.l	inptr-_bss(A5),D4
	cmp.l	insize-_bss(A5),D4
	bcc.s	gz48
	addq.l	#1,inptr-_bss(A5)
	bra.s	gz47
gz48:
	bsr	fill_inbuf
gz47:
	move.l	inptr-_bss(A5),D4
	cmp.l	insize-_bss(A5),D4
	bcc.s	gz46
	addq.l	#1,inptr-_bss(A5)
	bra.s	gz45
gz46:
	bsr	fill_inbuf
gz45:
	move.l	inptr-_bss(A5),D4
	cmp.l	insize-_bss(A5),D4
	bcc.s	gz44
	addq.l	#1,inptr-_bss(A5)
	bra.s	gz43
gz44:
	bsr	fill_inbuf
gz43:
	btst	#2,D3
	beq	gz35
	movea.l	inptr-_bss(A5),A1
	cmpa.l	insize-_bss(A5),A1
	bcc.s	gz42
	movea.l	inbuf-_bss(A5),A0
	clr.l	D2
	move.b	(A1,A0.L),D2
	addq.l	#1,inptr-_bss(A5)
	bra.s	gz41
gz42:
	bsr	fill_inbuf
	move.l	D0,D2
gz41:
	movea.l	inptr-_bss(A5),A1
	cmpa.l	insize-_bss(A5),A1
	bcc.s	gz40
	movea.l	inbuf-_bss(A5),A0
	clr.l	D0
	move.b	(A1,A0.L),D0
	asl.l	#8,D0
	or.l	D0,D2
	addq.l	#1,inptr-_bss(A5)
	bra.s	gz39
gz40:
	bsr	fill_inbuf
	asl.l	#8,D0
	or.l	D0,D2
gz39:
	subq.l	#1,D2
	moveq	#-1,D4
	cmp.l	D2,D4
	beq.s	gz35
gz38:
			move.l	inptr-_bss(A5),D4
			cmp.l	insize-_bss(A5),D4
			bcc.s	gz37
			addq.l	#1,inptr-_bss(A5)
			bra.s	gz36
gz37:
			bsr	fill_inbuf
gz36:
		dbf	D2,gz38
		clr	D2
	subq.l	#1,D2
	bcc.s	gz38
gz35:
	btst	#3,D3
	beq.s	gz32
	bra.s	gz33
gz34:
		bsr	fill_inbuf
		tst.l	D0
		beq.s	gz32
gz33:
		movea.l	inptr-_bss(A5),A1
		cmpa.l	insize-_bss(A5),A1
		bcc.s	gz34
		movea.l	inbuf-_bss(A5),A0
		move.b	(A1,A0.L),D0
		addq.l	#1,inptr-_bss(A5)
	tst.b	D0
	bne.s	gz33
gz32:
	btst	#4,D3
	beq.s	gz29
	bra.s	gz30
gz31:
		bsr	fill_inbuf
		tst.l	D0
		beq.s	gz29
gz30:
		movea.l	inptr-_bss(A5),A1
		cmpa.l	insize-_bss(A5),A1
		bcc.s	gz31
		movea.l	inbuf-_bss(A5),A0
		move.b	(A1,A0.L),D0
		addq.l	#1,inptr-_bss(A5)
	tst.b	D0
	bne.s	gz30
gz29:
	bsr	inflate
	tst.l	D0
	beq.s	gz21
	moveq	#1,D4
	cmp.l	D0,D4
	beq.s	gz27
	blt.s	gz28
	tst.l	D0
	beq.s	gz22
	bra.s	gz24
gz28:
	moveq	#2,D4
	cmp.l	D0,D4
	beq.s	gz26
	moveq	#3,D4
	cmp.l	D0,D4
	beq.s	gz25
	bra.s	gz24
gz27:
	pea	error_47(PC)
	bra.s	gz23
gz26:
	pea	error_48(PC)
	bra.s	gz23
gz25:
	pea	error_49(PC)
	bra.s	gz23
gz24:
	pea	error_50(PC)
gz23:
	bsr	gunzip_error
	addq	#4,SP
gz22:
	moveq	#-1,D0
	bra	gz1
gz21:
	movea.l	inptr-_bss(A5),A1
	cmpa.l	insize-_bss(A5),A1
	bcc.s	gz20
	movea.l	inbuf-_bss(A5),A0
	clr.l	D3
	move.b	(A1,A0.L),D3
	addq.l	#1,inptr-_bss(A5)
	bra.s	gz19
gz20:
	bsr	fill_inbuf
	move.l	D0,D3
gz19:
	movea.l	inptr-_bss(A5),A1
	cmpa.l	insize-_bss(A5),A1
	bcc.s	gz18
	movea.l	inbuf-_bss(A5),A0
	clr.l	D0
	move.b	(A1,A0.L),D0
	asl.l	#8,D0
	or.l	D0,D3
	addq.l	#1,inptr-_bss(A5)
	bra.s	gz17
gz18:
	bsr	fill_inbuf
	asl.l	#8,D0
	or.l	D0,D3
gz17:
	movea.l	inptr-_bss(A5),A1
	cmpa.l	insize-_bss(A5),A1
	bcc.s	gz16
	movea.l	inbuf-_bss(A5),A0
	clr.l	D0
	move.b	(A1,A0.L),D0
	swap	D0
	clr	D0
	or.l	D0,D3
	addq.l	#1,inptr-_bss(A5)
	bra.s	gz15
gz16:
	bsr	fill_inbuf
	swap	D0
	clr	D0
	or.l	D0,D3
gz15:
	movea.l	inptr-_bss(A5),A1
	cmpa.l	insize-_bss(A5),A1
	bcc.s	gz14
	movea.l	inbuf-_bss(A5),A0
	move.b	(A1,A0.L),D0
	moveq	#24,D4
	asl.l	D4,D0
	or.l	D0,D3
	addq.l	#1,inptr-_bss(A5)
	bra.s	gz13
gz14:
	bsr	fill_inbuf
	moveq	#24,D4
	asl.l	D4,D0
	or.l	D0,D3
gz13:
	movea.l	inptr-_bss(A5),A1
	cmpa.l	insize-_bss(A5),A1
	bcc.s	gz12
	movea.l	inbuf-_bss(A5),A0
	clr.l	D2
	move.b	(A1,A0.L),D2
	addq.l	#1,inptr-_bss(A5)
	bra.s	gz11
gz12:
	bsr	fill_inbuf
	move.l	D0,D2
gz11:
	movea.l	inptr-_bss(A5),A1
	cmpa.l	insize-_bss(A5),A1
	bcc.s	gz10
	movea.l	inbuf-_bss(A5),A0
	clr.l	D0
	move.b	(A1,A0.L),D0
	asl.l	#8,D0
	or.l	D0,D2
	addq.l	#1,inptr-_bss(A5)
	bra.s	gz9
gz10:
	bsr	fill_inbuf
	asl.l	#8,D0
	or.l	D0,D2
gz9:
	movea.l	inptr-_bss(A5),A1
	cmpa.l	insize-_bss(A5),A1
	bcc.s	gz8
	movea.l	inbuf-_bss(A5),A0
	clr.l	D0
	move.b	(A1,A0.L),D0
	swap	D0
	clr	D0
	or.l	D0,D2
	addq.l	#1,inptr-_bss(A5)
	bra.s	gz7
gz8:
	bsr	fill_inbuf
	swap	D0
	clr	D0
	or.l	D0,D2
gz7:
	movea.l	inptr-_bss(A5),A1
	cmpa.l	insize-_bss(A5),A1
	bcc.s	gz6
	movea.l	inbuf-_bss(A5),A0
	move.b	(A1,A0.L),D0
	moveq	#24,D4
	asl.l	D4,D0
	or.l	D0,D2
	addq.l	#1,inptr-_bss(A5)
	bra.s	gz5
gz6:
	bsr	fill_inbuf
	moveq	#24,D4
	asl.l	D4,D0
	or.l	D0,D2
gz5:
	move.l	crc-_bss(A5),D0
	not.l	D0
	cmp.l	D3,D0
	beq.s	gz4
	pea	error_51(PC)
	bra.s	gz3
gz4:
	cmp.l	bytes_out-_bss(A5),D2
	beq.s	gz2
	pea	error_52(PC)
gz3:
	bsr	gunzip_error
	moveq	#-1,D0
	addq	#4,SP
	bra.s	gz1
gz2:
	clr.l	D0
gz1:
	movem.l	(SP)+,D2-D4
	addq	#8,SP
	rts

gzip_mark:

	rts

gzip_release:

	rts

call_gunzip:

	movem.l	D2-D7/A2-A4,-(SP)
	clr.l	D2
	tst.l	gunzip_sp-_bss(A5)
	bne.s	gunzip_already_active
	bsr	makecrc
	move.l	gunzip_stack-_bss(A5),D0
	addi.l	#$FFC,D0
	move.l	SP,main_sp-_bss(A5)
	move.l	A6,main_fp-_bss(A5)
	movea.l	D0,SP
	bsr	gunzip
return_from_flush:
	movea.l	main_sp-_bss(A5),SP
	movea.l	main_fp-_bss(A5),A6
	move.l	D0,D2
	bra.s	call_gunzip_end
gunzip_already_active:
	move.l	SP,main_sp-_bss(A5)
	move.l	A6,main_fp-_bss(A5)
	movea.l	gunzip_jumpback-_bss(A5),A0
	jmp	(A0)
call_gunzip_end:
	move.l	D2,D0
	movem.l	(SP)+,D2-D7/A2-A4
	rts

fill_inbuf:

	tst.l	exit_code-_bss(A5)
	beq.s	fill_inbuf_next
fill_inbuf_end:
	moveq	#-1,D0
	rts
fill_inbuf_next:
	move.l	#$8000,-(SP)
	move.l	inbuf-_bss(A5),-(SP)
	bsr	_sread
	move.l	D0,insize-_bss(A5)
	addq	#8,SP
	beq.s	fill_inbuf_end
	moveq	#1,D1
	move.l	D1,inptr-_bss(A5)
	movea.l	inbuf-_bss(A5),A0
	clr.l	D0
	move.b	(A0),D0
	rts

flush_window:

	movem.l	D2-D4/A2,-(SP)
	move.l	crc-_bss(A5),D1
	movea.l	window-_bss(A5),A0
	suba.l	A1,A1
	move.l	outcnt-_bss(A5),D3
	cmp.l	A1,D3
	bls.s	flush_window_exit_loop
	clr.l	D2
	lea	crc_32_tab-_bss(A5),A2
flush_window_loop:
		move.b	(A0)+,D0
		move.b	D0,D2
		move.l	D1,D0
		eor.l	D2,D0
		andi.l	#$FF,D0
		lsr.l	#8,D1
		move.l	(A2,D0.L*4),D0
		eor.l	D0,D1
		addq	#1,A1
	cmp.l	A1,D3
	bhi.s	flush_window_loop
flush_window_exit_loop:
	move.l	D1,crc-_bss(A5)
	move.l	outcnt-_bss(A5),D4
	add.l	D4,bytes_out-_bss(A5)
	movem.l	D2-D7/A2-A4/A6,-(SP)
	move.l	SP,gunzip_sp-_bss(A5)
	lea	flush_window_end(PC),A0
	move.l	A0,gunzip_jumpback-_bss(A5)
	move.l	outcnt-_bss(A5),D0
	jmp	return_from_flush(PC)
flush_window_end:
	movea.l	gunzip_sp-_bss(A5),SP
	movem.l	(SP)+,D2-D7/A2-A4/A6
	clr.l	outcnt-_bss(A5)
	movem.l	(SP)+,D2-D4/A2
	rts

gunzip_error:

	move.l	D2,-(SP)
	move.l	8(SP),D2
	pea	crlf(PC)
	bsr	_printline
	move.l	D2,-(SP)
	bsr	_printline
	pea	crlf(PC)
	bsr	_printline
	moveq	#1,D1
	move.l	D1,exit_code-_bss(A5)
	addq	#8,SP
	addq	#4,SP
	move.l	(SP)+,D2
	rts

_exit:

	move.l	4(SP),D0
	move	D0,-(SP)
	move	#$4C,-(SP)	; Pterm
	trap	#1		; Gemdos
	addq	#4,SP
	illegal

_close:

	move.l	4(SP),D0
	movem.l	D2/A2,-(SP)
	move	D0,-(SP); handle
	move	#$3E,-(SP)	; Fclose
	trap	#1		; Gemdos
	addq	#4,SP
	movem.l	(sp)+,D2/A2
	ext.l	D0
	rts

_lseek:

	movem.l	4(SP),D0/A0
	move.l	12(SP),D1
	movem.l	D2/A2,-(SP)
	move	D1,-(SP) ; seek mode
	move	D0,-(SP) ; handle
	move.l	A0,-(SP) ; offset
	move	#$42,-(SP)	; Fseek
	trap	#1		; Gemdos
	lea	10(SP),SP
	movem.l	(SP)+,D2/A2
	rts

_open:

	move.l	8(SP),D0
	move.l	4(SP),A0
	movem.l	D2/A2,-(SP)
	move	D0,-(SP)
	pea	(A0)
	move	#$3D,-(SP)	; Fopen
	trap	#1		; Gemdos
	addq	#8,SP
	movem.l	(sp)+,D2/A2
	ext.l	D0
	rts
	
_read:

	movem.l	D1-D2/A0-A2,-(SP)
	movem.l	24(SP),A0/A1
	move.l	32(SP),D0
	pea	(A1)         ; buff
	move.l	D0,-(SP)     ; count
	move	A0,-(SP)     ; handle
	move	#$3F,-(SP)	; Fread
	trap	#1           ; Gemdos
	lea	12(SP),SP
	movem.l	(SP)+,D1-D2/A0-A2
	rts

_strdup:

	move.l	D2,-(SP)
	move.l	8(SP),D2
	movea.l	D2,A0
	move.l	D2,D0
	addq.l	#1,D0
sd3:
	tst.b	(A0)+
	bne.s	sd3
	suba.l	D0,A0
	pea	1(A0)
	bsr	_malloc
	addq	#4,SP
	move.l	D0,D1
	beq.s	sd1
	movea.l	D2,A1
	movea.l	D1,A0
sd2:
	move.b	(A1)+,(A0)+
	bne.s	sd2
sd1:
	move.l	D1,D0
	move.l	(SP)+,D2
	rts

_strncpy:

	move.l	D2,-(SP)
	move.l	8(SP),D2
	movea.l	D2,A0
	movea.l	12(SP),A1
	move.l	16(SP),D1
	subq.l	#1,D1
	bmi.s	sc3
	move.b	(A1)+,D0
	movea.l	D2,A0
	bra.s	sc4
sc5:
		subq.l	#1,D1
		bmi.s	sc3
		move.b	(A1)+,D0
sc4:
	move.b	D0,(A0)+
	bne.s	sc5
sc3:
	subq.l	#1,D1
	bmi.s	sc1
sc2:
			clr.b	(A0)+
		dbf	D1,sc2
		clr	D1
	subq.l	#1,D1
	bcc.s	sc2
sc1:
	move.l	D2,D0
	move.l	(SP)+,D2
	rts

_memset:

	movea.l	4(SP),A0
	move.b	11(SP),D0
	move.l	12(SP),D1
	beq	ms1
	move.l	D2,-(SP)
	adda.l	D1,A0
	move	A0,D2
	btst	#0,D2
	beq.s	ms8
	move.b	D0,-(A0)
	subq.l	#1,D1
ms8:
	move.b	D0,D2
	lsl	#8,D0
	move.b	D2,D0
	move	D0,D2
	swap	D2
	move	D0,D2
	clr	D0
	move.b	D1,D0
	lsr.l	#8,D1
	beq.s	ms6
	movem.l	D0/D3-D7/A2-A3/A5-A6,-(SP)
	move.l	D2,D0
	move.l	D2,D3
	move.l	D2,D4
	move.l	D2,D5
	move.l	D2,D6
	move.l	D2,D7
	movea.l	D2,A2
	movea.l	D2,A3
	movea.l	D2,A5
	movea.l	D2,A6
ms7:
		movem.l	D0/D2-D7/A2-A3/A5-A6,-(A0)
		movem.l	D0/D2-D7/A2-A3/A5-A6,-(A0)
		movem.l	D0/D2-D7/A2-A3/A5-A6,-(A0)
		movem.l	D0/D2-D7/A2-A3/A5-A6,-(A0)
		movem.l	D0/D2-D7/A2-A3/A5-A6,-(A0)
		movem.l	D0/D2-D7/A2-A3,-(A0)
	subq.l	#1,D1
	bne.s	ms7
	movem.l	(SP)+,D0/D3-D7/A2-A3/A5-A6
ms6:
	move	D0,-(SP)
	lsr	#2,D0
	beq.s	ms4
	move	D0,D1
	neg	D1
	andi	#3,D1
	subq	#1,D0
	lsr	#2,D0
	add	D1,D1
	jmp	ms5(PC,D1)
ms5:
		move.l	D2,-(A0)
		move.l	D2,-(A0)
		move.l	D2,-(A0)
		move.l	D2,-(A0)
	dbf	D0,ms5
ms4:
	move	(SP)+,D0
	btst	#1,D0
	beq.s	ms3
	move	D2,-(A0)
ms3:
	btst	#0,D0
	beq.s	ms2
	move.b	D2,-(A0)
ms2:
	move.l	(SP)+,D2
ms1:
	move.l	4(SP),D0
	rts

_memmove:

	movea.l	4(SP),A1
	movea.l	8(SP),A0
	bra.s	bc3

_bcopy:

	movea.l	4(SP),A0
	movea.l	8(SP),A1
bc3:
	move.l	12(SP),D0
	beq	bc2
	move.l	D2,-(SP)
	cmpa.l	A0,A1
	bgt	bc12
	move	A0,D1
	move	A1,D2
	eor	D2,D1
	btst	#0,D1
	bne	bc10
	btst	#0,D2
	beq.s	bc4
	move.b	(A0)+,(A1)+
	subq.l	#1,D0
bc4:
	clr	D1
	move.b	D0,D1
	lsr.l	#8,D0
	beq.s	bc6
	movem.l	D1/D3-D7/A2-A3/A5-A6,-(SP)
bc5:
		movem.l	(A0)+,D1-D7/A2-A3/A5-A6
		movem.l	D1-D7/A2-A3/A5-A6,(A1)
		movem.l	(A0)+,D1-D7/A2-A3/A5-A6
		movem.l	D1-D7/A2-A3/A5-A6,44(A1)
		movem.l	(A0)+,D1-D7/A2-A3/A5-A6
		movem.l	D1-D7/A2-A3/A5-A6,88(A1)
		movem.l	(A0)+,D1-D7/A2-A3/A5-A6
		movem.l	D1-D7/A2-A3/A5-A6,132(A1)
		movem.l	(A0)+,D1-D7/A2-A3/A5-A6
		movem.l	D1-D7/A2-A3/A5-A6,176(A1)
		movem.l	(A0)+,D1-D7/A2-A3
		movem.l	D1-D7/A2-A3,220(A1)
		lea	256(A1),A1
	subq.l	#1,D0
	bne.s	bc5
	movem.l	(SP)+,D1/D3-D7/A2-A3/A5-A6
bc6:
	move	D1,D0
	lsr	#2,D0
	beq.s	bc8
	move	D0,D2
	neg	D2
	andi	#3,D2
	subq	#1,D0
	lsr	#2,D0
	add	D2,D2
	jmp	bc7(PC,D2)
bc7:
		move.l	(A0)+,(A1)+
		move.l	(A0)+,(A1)+
		move.l	(A0)+,(A1)+
		move.l	(A0)+,(A1)+
	dbf	D0,bc7
bc8:
	btst	#1,D1
	beq.s	bc9
	move	(A0)+,(A1)+
bc9:
	btst	#0,D1
	beq.s	bc1
	move.b	(A0),(A1)
bc1:
	move.l	(SP)+,D2
bc2:
	move.l	4(SP),D0
	rts
bc10:
	move	D0,D1
	neg	D1
	andi	#7,D1
	addq.l	#7,D0
	lsr.l	#3,D0
	add	D1,D1
	jmp	bc11(PC,D1)
bc11:
		move.b	(A0)+,(A1)+
		move.b	(A0)+,(A1)+
		move.b	(A0)+,(A1)+
		move.b	(A0)+,(A1)+
		move.b	(A0)+,(A1)+
		move.b	(A0)+,(A1)+
		move.b	(A0)+,(A1)+
		move.b	(A0)+,(A1)+
	subq.l	#1,D0
	bne.s	bc11
	bra.s	bc1
bc12:
	adda.l	D0,A0
	adda.l	D0,A1
	move	A0,D1
	move	A1,D2
	eor	D2,D1
	btst	#0,D1
	bne	bc19
	btst	#0,D2
	beq.s	bc13
	move.b	-(A0),-(A1)
	subq.l	#1,D0
bc13:
	clr	D1
	move.b	D0,D1
	lsr.l	#8,D0
	beq.s	bc15
	movem.l	D1/D3-D7/A2-A3/A5-A6,-(SP)
bc14:
		movem.l	-44(A0),D1-D7/A2-A3/A5-A6
		movem.l	D1-D7/A2-A3/A5-A6,-(A1)
		movem.l	-88(A0),D1-D7/A2-A3/A5-A6
		movem.l	D1-D7/A2-A3/A5-A6,-(A1)
		movem.l	-132(A0),D1-D7/A2-A3/A5-A6
		movem.l	D1-D7/A2-A3/A5-A6,-(A1)
		movem.l	-176(A0),D1-D7/A2-A3/A5-A6
		movem.l	D1-D7/A2-A3/A5-A6,-(A1)
		movem.l	-220(A0),D1-D7/A2-A3/A5-A6
		movem.l	D1-D7/A2-A3/A5-A6,-(A1)
		movem.l	-256(A0),D1-D7/A2-A3
		movem.l	D1-D7/A2-A3,-(A1)
		lea	-256(A0),A0
	subq.l	#1,D0
	bne.s	bc14
	movem.l	(SP)+,D1/D3-D7/A2-A3/A5-A6
bc15:
	move	D1,D0
	lsr	#2,D0
	beq.s	bc17
	move	D0,D2
	neg	D2
	andi	#3,D2
	subq	#1,D0
	lsr	#2,D0
	add	D2,D2
	jmp	bc16(PC,D2)
bc16:
		move.l	-(A0),-(A1)
		move.l	-(A0),-(A1)
		move.l	-(A0),-(A1)
		move.l	-(A0),-(A1)
	dbf	D0,bc16
bc17:
	btst	#1,D1
	beq.s	bc18
	move	-(A0),-(A1)
bc18:
	btst	#0,D1
	beq	bc1
	move.b	-(A0),-(A1)
	bra	bc1
bc19:
	move	D0,D1
	neg	D1
	andi	#7,D1
	addq.l	#7,D0
	lsr.l	#3,D0
	add	D1,D1
	jmp	bc20(PC,D1)
bc20:
		move.b	-(A0),-(A1)
		move.b	-(A0),-(A1)
		move.b	-(A0),-(A1)
		move.b	-(A0),-(A1)
		move.b	-(A0),-(A1)
		move.b	-(A0),-(A1)
		move.b	-(A0),-(A1)
		move.b	-(A0),-(A1)
	subq.l	#1,D0
	bne.s	bc20
	bra	bc1

_bzero:
	movea.l	4(SP),A0
	move.l	8(SP),D1
	beq	bz1
	clr.b	D0
	move.l	D2,-(SP)
	adda.l	D1,A0
	move	A0,D2
	btst	#0,D2
	beq.s	bz8
	move.b	D0,-(A0)
	subq.l	#1,D1
bz8:
	move.b	D0,D2
	lsl	#8,D0
	move.b	D2,D0
	move	D0,D2
	swap	D2
	move	D0,D2
	clr	D0
	move.b	D1,D0
	lsr.l	#8,D1
	beq.s	bz6
	movem.l	D0/D3-D7/A2-A3/A5-A6,-(SP)
	move.l	D2,D0
	move.l	D2,D3
	move.l	D2,D4
	move.l	D2,D5
	move.l	D2,D6
	move.l	D2,D7
	movea.l	D2,A2
	movea.l	D2,A3
	movea.l	D2,A5
	movea.l	D2,A6
bz7:
		movem.l	D0/D2-D7/A2-A3/A5-A6,-(A0)
		movem.l	D0/D2-D7/A2-A3/A5-A6,-(A0)
		movem.l	D0/D2-D7/A2-A3/A5-A6,-(A0)
		movem.l	D0/D2-D7/A2-A3/A5-A6,-(A0)
		movem.l	D0/D2-D7/A2-A3/A5-A6,-(A0)
		movem.l	D0/D2-D7/A2-A3,-(A0)
	subq.l	#1,D1
	bne.s	bz7
	movem.l	(SP)+,D0/D3-D7/A2-A3/A5-A6
bz6:
	move	D0,-(SP)
	lsr	#2,D0
	beq.s	bz4
	move	D0,D1
	neg	D1
	andi	#3,D1
	subq	#1,D0
	lsr	#2,D0
	add	D1,D1
	jmp	bz5(PC,D1)
bz5:
		move.l	D2,-(A0)
		move.l	D2,-(A0)
		move.l	D2,-(A0)
		move.l	D2,-(A0)
	dbf	D0,bz5
bz4:
	move	(SP)+,D0
	btst	#1,D0
	beq.s	bz3
	move	D2,-(A0)
bz3:
	btst	#0,D0
	beq.s	bz2
	move.b	D2,-(A0)
bz2:
	move.l	(SP)+,D2
bz1:
	move.l	4(SP),D0
	rts

_malloc:

	movem.l	D1-D2/A0-A2,-(SP)
	move.l	24(SP),D0 ; size
	addq.l	#4,D0
	move.l	D0,D1
	bsr	get_block
	tst.l	D0
	beq.s	ma1
	subq.l	#4,D1
	move.l	D0,A0
	move.l	D1,(A0)+ ; size
	move.l	D1,-(SP)
	move.l	A0,-(SP)
	bsr	_bzero
	move.l	(SP)+,D0
	addq	#4,SP
ma1:
	movem.l	(SP)+,D1-D2/A0-A2
	rts
	
_realloc:

	movem.l	D1-D2/A0-A2,-(SP)
	move.l	28(SP),D1 ; size
	movea.l	24(SP),A1 ; buffer
	cmpa	#0,A1
	bne.s	ra4
	move.l	D1,-(SP)
	bsr	_malloc
	addq	#4,SP
	bra	ra1
ra4:
	tst.l	D1
	bne.s	ra3
	move.l	A1,-(SP)
	bsr	_free
	addq	#4,SP
	moveq	#0,D0
	bra	ra1
ra3:
	move.l	D1,-(SP)
	bsr	_malloc
	addq	#4,SP
	movea.l	D0,A2
	tst.l	D0
	beq.s	ra2
	move.l	-4(A1),-(SP) ; old size
	move.l	A2,-(SP) ; new buffer
	move.l	A1,-(SP) ; old buffer
	bsr	_bcopy
	bsr	_free
	addq	#8,SP
	addq	#4,SP
ra2:
	move.l	A2,D0
ra1:
	movem.l	(SP)+,D1-D2/A0-A2
	rts
	
_free:

	move.l	4(SP),D0
	subq.l	#4,D0
	bsr	free_block
	moveq	#0,D0
	rts

get_block:

	movem.l	D1-D5/A0-A2,-(SP)
	tst.l	D0
	beq	gb6   ; error
	moveq	#3,D4
	add.l	D0,D4 ; size
	and.b	#$FC,D4
	lea	tab_malloc-_bss(A5),A0
	move.l	A0,A1
	move	#MAX_MALLOC-1,D2
	moveq	#0,D3
	moveq	#0,D5
gb1:
		move.l	(A0)+,D0 ; ptr
		add.l	(A0)+,D0 ; size
		beq.s	gb2
		move.l	(A0),D1
		bne.s	gb3
		move.l	malloc_ptr-_bss(A5),D1
		add.l	malloc_size-_bss(A5),D1
gb3:
		sub.l	D0,D1
		cmp.l	D3,D1
		bcs.s	gb4
		move.l	D1,D3    ; max free block
		move.l	A0,A1
gb4:
		addq.l	#1,D5
	dbf	D2,gb1
gb2:
	tst.l	D3
	bne.s	gb8
	move.l	malloc_ptr-_bss(A5),D2
	move.l	malloc_size-_bss(A5),D3
	bra.s	gb5
gb8:
	move.l	-8(A1),D2 ; ptr
	add.l	-4(A1),D2 ; size	
gb5:
	cmp.l	D3,D4
	bhi.s	gb6
	cmp	#MAX_MALLOC,D5
	bcc.s	gb7
	lea	tab_malloc-_bss(A5),A0
	adda.l	#MAX_MALLOC*8,A0
	lea	-8(A0),A2
gb10:		
		cmp.l	A1,A2
		bls.s	gb9
		move.l	-(A2),-(A0) ; size
		move.l	-(A2),-(A0) ; ptr
	bra.s	gb10
gb9:
	move.l	D4,-(A0) ; size
	move.l	D2,-(A0) ; ptr
	move.l	D2,D0	
	bra.s	gb7	
gb6:
	moveq	#0,D0 ; error	
gb7:
	movem.l	(SP)+,D1-D5/A0-A2
	rts

free_block:

	movem.l	D0-D1/A0-A1,-(SP)
	lea	tab_malloc-_bss(A5),A0
	move	#MAX_MALLOC-1,D1
fb2:
		cmp.l	(A0)+,D0    ; ptr
		addq	#4,A0       
	dbeq	D1,fb2                  ; not found
	bne.s	fb1
	lea	-8(A0),A1
	subq	#1,D1
	bmi.s	fb4
fb3:
		move.l	(A0)+,(A1)+ ; ptr
		move.l	(A0)+,(A1)+ ; size
	dbf	D1,fb3
fb4:
	clr.l	(A1)+
	clr.l	(A1)
fb1:
	movem.l	(SP)+,D0-D1/A0-A1
	rts

_printline:

	movem.l	D0-D2/A0-A2,-(SP)
	move.l	28(SP),D0
	move.l	D0,-(SP)
	move	#9,-(SP)	; Cconws
	trap	#1		; Gemdos
	addq	#6,SP
	movem.l	(SP)+,D0-D2/A0-A2 
	rts
	
display_deci:           ; D0.L:value
              
             movem.l	D1-D2/A0-A2,-(SP)                   
	link	A4,#-16
	moveq	#9,D1
	link	A6,#-16
	lea	-16(A6),A0
	move	D1,-(SP)
	bsr	conv_deci
	move	(SP)+,D1
	lea	-16(A4),A0
	lea	-16(A6),A1
	subq	#1,D1
	bmi.s	dd3
dd1:
		move.b	(A1)+,D0
		cmp.b	#$20,D0
		beq.s	dd2
		move.b	D0,(A0)+
dd2:
	dbf	D1,dd1
	clr.b	(A0)
dd3:
	unlk	A6
	lea	-16(A4),A0
	move.l	A0,-(SP)
	move	#9,-(SP)	; Cconws
	trap	#1		; Gemdos
	addq	#6,SP
	unlk	A4
             movem.l	(SP)+,D1-D2/A0-A2
	rts
	
conv_deci:                     ; A0:target ascii, D0.L:value, D1:len

	move	D1,-(SP)
	subq	#1,D1
	move.l	D0,-(SP)
cd1:
		moveq	#0,D0
		move	(SP),D0
		divu	#10,D0
		move	D0,(SP)
		move	2(SP),D0
		divu	#10,D0
		move	D0,2(SP)
		swap	D0
		or.w	#$30,D0
		move.b	D0,(A0,D1.W)
	dbf	D1,cd1
	addq	#4,SP
	move	(SP)+,D1
	subq	#1,D1
	beq.s	cd2
	swap	D0
	tst	D0
	bne.s	cd3
	moveq	#0,D0
cd4:
		cmp.b	#$30,(A0,D0.W)
		bne.s	cd2
		move.b	#$20,(A0,D0.W)
		addq.w	#1,D0
	cmp.w	D1,D0
	bne.s	cd4
	bra.s	cd2
cd3:
	move.b	#$3F,(A0,D1.W)
	dbf	D1,cd3
cd2:
	rts

	
hex_long:

	move.l	D0,-(SP)
	swap	D0
	bsr.s	hex_word
	move.l	(SP)+,D0
hex_word:
	move	D0,-(SP)
	lsr	#8,D0          
	bsr.s	hex_byte     
	move	(SP)+,D0
hex_byte:
	move	D0,-(SP)
	lsr.b	#4,D0        
	bsr.s	hex_char      
	move	(SP)+,D0      
hex_char:
	and.b	#$F,D0      
	or.b	#$30,D0      
	cmp.b	#$3A,D0     
	bcs.s	display_char  
	addq.b	#7,D0   

display_char:

	movem.l	D0-D2/A0-A2,-(SP)
	move	D0,-(SP)
	move	#2,-(SP)	; Cconout
	trap	#1		; Gemdos
	addq	#4,SP
	movem.l	(SP)+,D0-D2/A0-A2
	rts

conv_string:

	movem.l	D1-D4/A0-A1,-(SP)
	move.l	28(SP),A0 ; string
	moveq	#0,D4 ; deci
	cmp.b	#$30,(A0)
	bne.s	cs5
	cmp.b	#$78,1(A0)
	beq.s	cs6 ; 0x
	cmp.b	#$58,1(A0)
	bne.s	cs5
cs6:
	addq	#2,A0
	moveq	#1,D4 ; hexa
cs5:
	moveq	#0,D2
	moveq	#9,D1
	moveq	#-1,D0
cs1:
		addq.w	#1,D0
		move.b	(A0)+,D3
		tst.w	D4
		beq.s	cs7 ; deci
		cmp.b	#$41,D3
		bcs.s	cs8
		cmp.b	#$46,D3
		bhi.s	cs8
		add.b	#$20,D3; minus
cs8:
		cmp.b	#$61,D3
		bcs.s	cs7
		cmp.b	#$66,D3
		dbhi	D1,cs1
		bra.s	cs12
cs7:
		cmp.b	#$30,D3
		bcs.s	cs2
		cmp.b	#$39,D3
	dbhi	D1,cs1
cs12:
	bhi.s	cs2
	addq.w	#1,D0
	addq	#1,A0
cs2:
	subq	#1,A0
	move.l	32(SP),A1
	move.l	A0,(A1); endptr
	tst.w	D0
	beq.s	cs3
	subq.w	#1,D0
	moveq	#0,D2
	moveq	#1,D3
	tst.w	D4
	beq.s	cs4 ; deci
	moveq	#0,D3
cs11:
		move.b	-(A0),D1
		cmp.b	#$41,D1
		bcs.s	cs10
		cmp.b	#$46,D1
		bhi.s	cs9
		add.b	#$20,D1; minus
cs9:
		sub.b	#$57,D1
cs10:
		and.l	#15,D1
		asl.l	D3,D1
		or.l	D1,D2
		addq.w	#4,D3
	dbf	D0,cs11
	bra.s	cs3
cs4:
		moveq	#$F,D1
		and.b	-(A0),D1
		move.l	D0,-(SP)
		move.l	D3,D0
		bsr	mul32_32; D3 * D1 => D0
		add.l	D0,D2
		move.l	D3,D0
		moveq	#10,D1
		bsr	mul32_32; D3 * 10 => D3
		move.l	D0,D3
		move.l	(SP)+,D0
	dbf	D0,cs4 
cs3:
	move.l	D2,D0
	movem.l	(SP)+,D1-D4/A0-A1
	rts
	
_tolower:

	move.l	4(SP),D1
	clr.l	D0
	move.b	D1,D0
	lea	islower(PC),A0
	btst	#2,(A0,D0.L)
	beq.s	tolower_end
	eori	#$20,D1
tolower_end:
	move.l	D1,D0
	rts

opt_error:

	move.l	12(SP),-(SP)
	move.l	12(SP),-(SP)
	move.l	12(SP),-(SP)
	bsr	_printline
	addq	#4,SP
	move.b	#$3A,D0
	bsr	display_char
	move.b	#$20,D0
	bsr	display_char
	bsr	_printline
	addq	#4,SP
	move.b	#$20,D0
	bsr	display_char
	move.b	#$2D,D0
	bsr	display_char
	move.b	#$2D,D0
	bsr	display_char
	move.b	#$20,D0
	bsr	display_char
	move.l	(SP)+,D0
	bsr	display_char
	pea	crlf(PC)
	bsr	_printline
	addq	#4,SP
	moveq	#$3F,D0
	rts

_getopt:

	movem.l	D2-D3/A2-A3,-(SP)
	move.l	20(SP),D3 ; argc
	movea.l	24(SP),A3 ; argv
	clr.l	optarg-_bss(A5)
	moveq	#1,D1
	cmp.l	suboptionpos-_bss(A5),D1
	bne.s	gopt8
	cmp.l	optind-_bss(A5),D3
	ble.s	gopt9
	move.l	optind-_bss(A5),D0
	asl.l	#2,D0
	movea.l	(A3,D0.L),A0
	cmpi.b	#$2D,(A0)
	bne.s	gopt9
	tst.b	1(A0)
	beq.s	gopt9
	lea	lessless(PC),A1
	cmpm.b	(A0)+,(A1)+
	bne.s	gopt8
	cmpm.b	(A0)+,(A1)+
	bne.s	gopt8
	addq.l	#1,optind-_bss(A5)
gopt9:
	moveq	#-1,D0
	bra	getopt_end
gopt8:
	move.l	optind-_bss(A5),D0
	asl.l	#2,D0
	movea.l	(A3,D0.L),A0
	move.l	suboptionpos-_bss(A5),D2
	move.b	(A0,D2.L),D1
	ext	D1
	movea	D1,A0
	movea	A0,A2
	addq.l	#1,suboptionpos-_bss(A5)
	movea.l	(A3,D0.L),A0
	move.l	suboptionpos-_bss(A5),D0
	tst.b	(A0,D0.L)
	bne.s	gopt7
	addq.l	#1,optind-_bss(A5)
	moveq	#1,D1
	move.l	D1,suboptionpos-_bss(A5)
gopt7:
	moveq	#$3A,D1
	cmp.l	A2,D1
	beq.s	gopt6
	move.l	A2,-(SP) ; c
	move.l	32(SP),-(SP) ; opts
	bsr	_index
	addq	#8,SP
	movea.l	D0,A0 ; place
	cmpa	#0,A0
	bne.s	gopt5
gopt6:
	move.l	A2,-(SP)
	pea	error_53(PC)
	bra.s	getopt_error
gopt5:
	cmpi.b	#$3A,1(A0)
	bne.s	gopt1
	moveq	#1,D1
	cmp.l	D2,D1
	beq.s	gopt4
	move.l	A2,-(SP)
	pea	error_54(PC)
	bra.s	getopt_error
gopt4:
	moveq	#1,D1
	cmp.l	suboptionpos-_bss(A5),D1
	beq.s	gopt3
	move.l	A2,-(SP)
	pea	error_55(PC)
	bra.s	getopt_error
gopt3:
	cmp.l	optind-_bss(A5),D3
	bgt.s	gopt2
	move.l	A2,-(SP)
	pea	error_56(PC)
getopt_error:
	move.l	(A3),-(SP)
	bsr	opt_error
	adda	#12,SP
	bra.s	getopt_end
gopt2:
	move.l	optind-_bss(A5),D0
	asl.l	#2,D0
	move.l	(A3,D0.L),optarg-_bss(A5)
	addq.l	#1,optind-_bss(A5)
gopt1:
	move.l	A2,D0
getopt_end:
	movem.l	(SP)+,D2-D3/A2-A3
	rts

_index:

	movea.l	4(SP),A0
	move.l	8(SP),D1
	bra.s	ind1
ind2:
		tst.b	D0
		bne.s	ind1
		moveq	#0,D0
		rts
ind1:
	move.b	(A0)+,D0
	cmp.b	D0,D1
	bne.s	ind2
	move.l	A0,D0
	subq.l	#1,D0
	rts

mul32_32:	; D0 * D1 => D0

	move.l	D2,-(SP)
	move.l	D0,D2
	swap	D2
	tst.w	D2
	bne.s	mu3
	move.l	D1,D2
	swap	D2
	tst.w	D2
	bne.s	mu2
	mulu	D1,D0
	bra.s	mu1
mu2:
	mulu	D0,D2
	bra.s	mu4
mu3:
	mulu	D1,D2
mu4:
	swap	D2
	mulu	D1,D0
	add.l	D2,D0
mu1:
	move.l	(SP)+,D2
	rts

	.data

warning_1:
	dc.b	"Warning: Must omit parameter '",0
warning_1a:
	dc.b	"', kernel command line too long!",13,10,0
warning_2:
	dc.b	"Need at least 256k ST-RAM! Changing -S to 256k.",13,10,0
warning_3:
	dc.b	"(Note: -s ignored on Medusa)",13,10,0
warning_4:
	dc.b	"Kernel has no bootinfo version info, assuming 0.0",13,10,0
warning_5:
	dc.b	"Warning: Bootinfo version of bootstrap and kernel differ!",13,10,0
warning_6:
	dc.b	"         Certain features may not work.",13,10,0
warning_7:
	dc.b	"(using backwards compatibility mode)",13,10,0 
warning_8:
	dc.b	"Warning: using only 4 blocks of memory",13,10,0
error_1:
	dc.b	"Invalid number for extra mem start: ",0
error_2:
	dc.b 	"':' missing after extra mem start",13,10,0
error_3:
	dc.b	"Invalid number: ",0
error_4:
	dc.b	"Error: No cookiejar found. Is this an ST?",13,10,0
error_5:	
	dc.b	"Error: Bootstrap can't run in FastRAM on Afterburner040",13,10,0
error_6:
	dc.b	"Error: Bootstrap can't run in TT-RAM on Centurbo2",13,10,0
error_7:
	dc.b	"Unable to open ramdisk file ",0
error_8:
	dc.b	"Out of memory for ramdisk image",13,10,0
error_9:
	dc.b	"Error while reading ramdisk image",13,10,0
error_10:
	dc.b	"Unable to get kernel image ",0
error_11:
	dc.b	"Cannot read ELF header of kernel image",13,10,0
error_12:
	dc.b	"Invalid ELF header contents in kernel",13,10,0
error_13:
	dc.b	"Unable to allocate memory for program headers",13,10,0
error_14:
	dc.b	"Unable to read program headers from ",0
error_15:
	dc.b	"Kernel image is no ELF executable",13,10,0
error_16:
	dc.b	"Couldn't create bootinfo",13,10,0
error_17:
	dc.b	"Unable to allocate memory for kernel",13,10,0
error_18:
	dc.b	"Error: Bootstrap may not allocate memory from FastRAM on Afterburner040",13,10,0
error_19:
	dc.b	"Error: Bootstrap may not allocate memory from TT-RAM on Centurbo2",13,10,0
error_20:
	dc.b	"Failed to seek to segment ",0
error_21:
	dc.b	"Failed to read segment ",0
error_22:
	dc.b	"Couldn't create compat bootinfo",13,10,0
error_23:
	dc.b	"Kernel has unsupported bootinfo version",13,10,0
error_24:
	dc.b	"Machine type currently not supported. Aborting...",0
error_25:
	dc.b	"Error: Unknown CPU type. Aborting...",13,10,0
error_26:
	dc.b	"unknown mach cookie 0x",0
error_27:
	dc.b	"Not enough RAM. Aborting...",0
error_28:
	dc.b	13,10,"This bootstrap is too ",0
error_28a:
	dc.b	" for this kernel!",13,10,0
error_29:
	dc.b	"Can't add bootinfo record. Ask a wizard to enlarge me.",0
error_30:
	dc.b	"CPU type 0x",0
error_30_a:
	dc.b	" not supported by kernel",13,10,0
error_31:
	dc.b	"FPU type 0x",0
error_32:
	dc.b	"Internal error: bottom-most module ",0
error_32a:
	dc.b	" calls downstreams!",13,10,0
error_33:
	dc.b	"Out of buffer memory for module ",0
error_34:
	dc.b	"Internal error: topmost module ",0
error_34a:
	dc.b	" calls upstreams!",13,10,0
error_35:
	dc.b	"Unsupported seek operation for module ",0
error_36:
	dc.b	"Unsupported backward seek in module ",0
error_36a:
	dc.b	" (bufstart=",0
error_36b:
	dc.b	", dstpos=",0
error_36c:
	dc.b	")",13,10,0
error_37:
	dc.b	"File shorter than 2 bytes, can't test for gzip",13,10,0
error_38:
	dc.b	"Out of memory for gunzip stack!",13,10,0
error_39:
	dc.b	"Out of memory for gunzip input buffer!",13,10,0
error_40:
	dc.b	" incomplete literal tree",13,10,0
error_41:
	dc.b	" incomplete distance tree",13,10,0
error_42:
	dc.b	"bad gzip magic numbers",0
error_43:
	dc.b	"internal error, invalid method",0
error_44:
	dc.b	"Input is encrypted",13,10,0
error_45:
	dc.b	"Multi part input",13,10,0
error_46:
	dc.b	"Input has invalid flags",13,10,0
error_47:
	dc.b	"invalid compressed format (err=1)",0
error_48:
	dc.b	"invalid compressed format (err=2)",0
error_49:
	dc.b	"out of memory",0
error_50:
	dc.b	"invalid compressed format (other)",0
error_51:
	dc.b	"crc error",0
error_52:
	dc.b	"length error",0
error_53:
	dc.b	"illegal option",0
error_54:
	dc.b	"option must not be clustered",0
error_55:
	dc.b	"option must be followed by white space",0
error_56:
	dc.b	"option requires an argument",0
error_57:
	dc.b	"No bootargs file found !",13,10,0
menu_help:
	dc.b	"Linux/68k Atari Bootstrap version 3.3 (CT60)",13,10
	dc.b	"Options:",13,10
	dc.b	"  -k<file>: Use <file> as kernel image (defaults: vmlinux, vmlinux.gz)",13,10
	dc.b	"  -r<file>: Load ramdisk <file>",13,10
	dc.b	"  -s: load kernel to ST-RAM",13,10
	dc.b	"  -t: ignore TT-RAM",13,10
	dc.b	"  -S<size>: pretend ST-RAM having <size>",13,10
	dc.b	"  -T<size>: pretend TT-RAM having <size>",13,10
	dc.b	"  -m<start>:<size>: pass extra memory block to kernel",13,10
	dc.b	"  -d: print debug infos, wait for key before booting",13,10
	dc.b	"  -h, -?: print this help message",13,10,0
menu_usage:
	dc.b	"Usage:",13,10
	dc.b	"[-dnstST] [-k kernel_executable] "
	dc.b	"[-r ramdisk_file] [-m start:size] [kernel options...]",13,10,0
menu_info:
	dc.b	13,10,"Linux/68k Atari Bootstrap version 3.3 (CT60)",13,10,0
menu_authors:
	dc.b	"Copyright 1993-98 by Arjan Knor, Robert de Vries, Roman Hodek, Andreas Schwab",13,10,10,0
options_list:
	dc.b	"dntsS:T:k:r:m:",0	
space:
	dc.b	" ",0
bootargs_name:
	dc.b	"bootargs",0
bootstrap_name:
	dc.b	"bootstrap",0
_kernel_name:
	dc.b	"vmlinux",0
local:
	dc.b	"local:",0
boot_image:
	dc.b	"BOOT_IMAGE=",0
kernel_command_line:	
	dc.b	"Kernel command line: ",13,10," ",0
cookie_ct2:
	dc.b	"_CT2",0
cookie_ct60:
	dc.b	"CT60",0
cookie_mch:
	dc.b	"_MCH",0
cookie_ab40:	
	dc.b	"AB40",0	
cookie_magn:
	dc.b	"MAGN",0
cookie_bpfx:
	dc.b	"BPFX",0
elf_header:
	dc.b	$7F,"ELF",0
ramdisk_src:
	dc.b	"ramdisk src at 0x",0
ramdisk_src_a:
	dc.b	", size is ",0
ramdisk_dest:
	dc.b	"ramdisk dest is 0x",0
ramdisk_dest_a:
	dc.b	" ... 0x",0
kernel_src:
	dc.b	"Kernel src at 0x",0
kernel_src_a:
	dc.b	", size is ",0
kernel_segment:
	dc.b	"Kernel segment ",0
kernel_segment_a:
	dc.b	" at 0x",0
kernel_segment_b:
	dc.b	", size ",0
boot_info_adr:
	dc.b	"boot_info is at 0x",0
type_a_key:
	dc.b	"Type a key to continue the Linux boot...",13,10,0
booting:
	dc.b	"Booting Linux...",13,10,0
type_cpu:
	dc.b	"CPU: ",0
type_cpu_a:
	dc.b	"; ",0
type_fpu:
	dc.b	"FPU: ",0
type_fpu_68040:
	dc.b	"68040",0
type_fpu_68060:
	dc.b	"68060",0
type_fpu_none:
	dc.b	"none or software emulation",0
type_fpu_68882:
	dc.b	"68882",0
type_fpu_68881:
	dc.b	"68881",0
model:
	dc.b	"Model: ",0
model_st:
	dc.b	"ST",0
model_mega_ste:
	dc.b	"Mega STE",0
model_ste:
	dc.b	"STE",0
model_medusa:
	dc.b	"Medusa",0
model_hades:
	dc.b	"Hades",0
model_tt:
	dc.b	"TT",0
model_falcon:
	dc.b	"Falcon",0
with_ab040:
	dc.b	" (with Afterburner040)",0
with_ct60:
	dc.b	" (with CT60)",0
crlf:	
	dc.b	13,10,0
medusa_ram:
	dc.b	"Medusa pseudo ST-RAM from bank 1: ",0
tt_ram_bank_1:
	dc.b	"TT-RAM bank 1: ",0
tt_ram_bank_2:
	dc.b	"TT-RAM bank 2: ",0
fast_ram_bank_1:
	dc.b	"FastRAM bank 1: ",0
fast_ram_bank_2:
	dc.b	"FastRAM bank 2: ",0
tt_ram:
	dc.b	"TT-RAM: ",0
magnum_ram:
	dc.b	"MAGNUM alternate RAM: ",0
fx_ram:
	dc.b	"FX alternate RAM: ",0
st_ram:
	dc.b	"ST-RAM: ",0
st_ram_a:
	dc.b	" MB at 0x00000000",13,10,0
alternate_ram:
	dc.b	"User-specified alternate RAM: ",0
alternate_ram_a:
	dc.b	" MB at 0x",0
total_ram:
	dc.b	"Total ",0
total_ram_a:
	dc.b	" MB",13,10,0
bootstrap_bootinfo_version:
	dc.b	"Bootstrap's bootinfo version: 2.1",13,10,0
kernel_bootinfo_version:
	dc.b	"Kernel's bootinfo version   : ",0
bootstrap_old:
	dc.b	"old",0
bootstrap_new:
	dc.b	"new",0
head_name:
	dc.b	"head",0
file_name:
	dc.b	"file",0
gunzip_name:
	dc.b	"gunzip",0
gz_ext:
	dc.b	".gz",0
_kernel_name_bis:
	dc.b	"vmlinuz",0
decompressing:
	dc.b	"Decompressing ",0
lessless:
	dc.b	"--",0
options:
	dc.b	"Options:",13,10,0
_debugflag:
	dc.b	"- Debug flag",13,10,0
_ignore_ttram:
	dc.b	"- Ignore TT-RAM",13,10,0
_load_to_stram:
	dc.b	"- Load kernel to ST-RAM",13,10,0
_force_st_size:
	dc.b	"- Force ST-RAM size: 0x",0
_force_tt_size:
	dc.b	"- Force TT-RAM size: 0x",0
_extramem_start:
	dc.b	"- Extramem start: 0x",0
_extramem_size:
	dc.b	", extramem size: 0x",0
__kernel_name:
	dc.b	"- Kernel name: ",0
_ramdisk_name:
	dc.b	"- Ramdisk name: ",0

	align
	
border:
	dc.l	16,17,18,0,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15

cplens:
	dc.w	3,4,5,6,7,8,9,10,11,13,15,17,19,23,27,31
	dc.w	35,43,51,59,67,83,99,115,131,163,195,227,258,0,0

cplext:
	dc.w	0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2
	dc.w	3,3,3,3,4,4,4,4,5,5,5,5,0,99,993

cpdist:
	dc.w	1,2,3,4,5,7,9,13,17,25,33,49,65,97,129,193
	dc.w	257,385,513,769,1025,1537,2049,3073,4097,6145
	dc.w	8193,12289,16385,24577

cpdext:
	dc.w	0,0,0,0,1,1,2,2,3,3,4,4,5,5,6,6
	dc.w	7,7,8,8,9,9,10,10,11,11,12,12,13,13

mask_bits:
	dc.w	$0000,$0001,$0003,$0007,$000F,$001F,$003F,$007F
	dc.w	$00FF,$01FF,$03FF,$07FF,$0FFF,$1FFF,$3FFF,$7FFF
	dc.w	$FFFF

makecrc_p:
	dc.l	0,1,2,4,5,7,8,10,11,12,16,22,23,26
makecrc_p_end:

islower:
	dc.l	$01010101,$01010101,$01111111,$11110101,$01010101,$01010101
	dc.l	$01010101,$01010101,$10202020,$20202020,$20202020,$20202020
	dc.l	$42424242,$42424242,$42422020,$20202020,$20444444,$44444404
	dc.l	$04040404,$04040404,$04040404,$04040404,$04040420,$20202020
	dc.l	$20484848,$48484808,$08080808,$08080808,$08080808,$08080808
	dc.l	$08080820,$20202001,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0

rotchar:
	dc.b	"|/-\"
testarray:
	dc.b	0,0,1,1

	.bss
	
_bss:
optind:
	ds.l	1
optarg:
	ds.l	1
suboptionpos:
	ds.l	1	
nargv:
	ds.l	30
insize:
	ds.l	1
inptr:
	ds.l	1
outcnt:
	ds.l	1
exit_code:
	ds.l	1
bytes_out:
	ds.l	1
crc:
	ds.l	1
head_mod:
	ds.l	14
file_mod:
	ds.l	14
gunzip_mod:
	ds.l	14
stream_dont_display:
	ds.l	1
debugflag:
	ds.l	1
ignore_ttram:
	ds.l	1
load_to_stram:
	ds.l	1
force_st_size:
	ds.l	1
force_tt_size:
	ds.l	1
extramem_start:
	ds.l	1
extramem_size:
	ds.l	1
kernel_name:
	ds.l	1
ramdisk_name:
	ds.l	1
bi_machtype:
	ds.l	1
bi_cputype:
	ds.l	1
bi_fputype:
	ds.l	1
bi_mmutype:
	ds.l	1
bi_num_memory:
	ds.l	1
bi_memory_0_addr:
	ds.l	1
bi_memory_0_size:
	ds.l	1
bi_memory_1_addr:
	ds.l	1
bi_memory_1_size:
	ds.l	5
bi_ramdisk:
	ds.l	1
bi_ramdisk_size:
	ds.l	1
bi_command_line:
	ds.b	256
bi_mch_cookie:
	ds.l	1
bi_mch_type:
	ds.l	2
compat_bootinfo_machtype:
	ds.l	1
compat_bootinfo_cputype:
	ds.l	1
	ds.l	8
compat_bootinfo_num_memory:
	ds.l	1
compat_bootinfo_ramdisk_size:
	ds.l	1
compat_bootinfo_ramdisk_addr:
	ds.l	1
compat_bootinfo_command_line:
	ds.b	255
compat_bootinfo_command_line_end:
	ds.b	1
compat_bootinfo_bi_atari_hw_present:
	ds.l	1
compat_bootinfo_bi_atari_mch_cookie:
	ds.l	278
bi_size:
	ds.l	2
bi_union_record:
	ds.b	$1000
userstk:
	ds.l	1
cookiejar:
	ds.l	1
handle_file:
	ds.l	1
gunzip_stack:
	ds.l	1
gunzip_sp:
	ds.l	1
gunzip_jumpback:
	ds.l	1
main_sp:
	ds.l	1
main_fp:
	ds.l	1
inbuf:
	ds.l	1
window:
	ds.l	1
previous_window:
	ds.l	1
bb:
	ds.l	1
bk:
	ds.l	1
hufts:
	ds.l	2
crc_32_tab:
	ds.l	256
argc:
	ds.l	1
argv:
	ds.l	1
currmod:
	ds.l	2
command_line:
	ds.b	256
malloc_size:
	ds.l	1
malloc_ptr:
	ds.l	1	
tab_malloc:
	ds.l	MAX_MALLOC*2
_end_bss:
	
	end	
