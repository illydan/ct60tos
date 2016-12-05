/* TOS 4.04 Xbios dispatcher for the CT60/CTPCI boards
 * and Ram-Disk utility
 * Didier Mequignon 2005-2009, e-mail: aniplay@wanadoo.fr
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include "config.h"
#include "../include/vars.h"

// #define RAM_DISK_FAT12
#define RAM_DISK_SEC_FAT    64
#define RAM_DISK_SIZE_KB    8192

#define Modecode    0x184C

#undef DEBUG

	.global _det_xbios,_old_vector_xbios,_video_found
	.global _physbase,_vsetscreen,_vsetmode,_montype,_vgetsize,_vsetrgb,_vgetrgb
#ifdef SOUND_AC97
#endif
	.global _validmode,_vmalloc
	.global _vixGetVersion,_vixProbe,_vixInit,_vixDestroy,_vixGetCapability
	.global _vixQueryFourcc,_vixConfigPlayback,_vixPlaybackOn,_vixPlaybackOff
	.global _vixPlaybackFrameSelect,_vixGetGrKeys,_vixSetGrKeys
	.global _vixPlaybackGetEq,_vixPlaybackSetEq,_vixPlaybackGetDeint,_vixPlaybackSetDeint
	.global _InitVideo
	.global _asm_set_ipl
#ifdef NETWORK
	.global _install_ram_disk,_address_ram_disk,_size_ram_disk,_change_ram_disk,_ext_write_protect_ram_disk
	.global _rinfo_fvdi
	.global _alert_tos
#endif
#ifdef DEBUG
	.global display_string,hex_long,hex_word,hex_byte,display_char,wait_key,_debug
#endif

	.data

#ifdef DEBUG
debug1:	.asciz "XBIOS #0x"
debug2:	.asciz "Setscreen 0x"
debug3:	.asciz "hdv_rw 0x"
debug4:	.ascii "hdv_bpb"
	.byte 13,10,0
debug5:	.ascii "hdv_mediach"
	.byte 13,10,0
debug6:	.asciz "Vsetmode 0x"
debug7:	.asciz "ValidMode 0x"
debug8:	.asciz "Gettime 0x"
	
	.align 2
#endif

	dc.l 0x58425241          // XBRA
	dc.l 0x5F504349          // _PCI
	dc.l 0                   // cannot store here because we are in flash

_det_xbios:

	move.l USP,A0
	btst #5,(SP)             // call in supervisor state
	beq.s .x2
	lea.l 6(SP),A0
	tst.w proc_type
	beq.s .x2
	tst.w (A0)+              // if > 68000
.x2:
#ifdef DEBUG
	move.l A0,-(SP)
	moveq #0,D0
	move.w (A0),D0           // function
	cmp.l #2,D0              // Physbase
	beq.s .x0
	cmp.l #5,D0              // Setscreen
	beq.s .x0
	cmp.l #22,D0             // Gettime
	beq.s .x0
	cmp.l #23,D0             // Settime
	beq.s .x0
	cmp.l #64,D0             // Blitmode
	beq.s .x0
	cmp.l #88,D0             // Vsetmode
	beq.s .x0
	cmp.l #89,D0             // Mon_type
	beq.s .x0
	cmp.l #91,D0             // Vgetsize
	beq.s .x0
	cmp.l #93,D0             // Vsetrgb
	beq.s .x0
	cmp.l #94,D0             // Vgetrgb
	beq.s .x0
	cmp.l #95,D0             // ValidMode (undocumented)
	beq.s .x0
	cmp.l #141,D0            // Buffptr
	bhi.s .x0b
	cmp.l #128,D0            // Locksnd
	bcs.s .x0b	
.x0:
	lea debug1,A0
	jsr display_string
	move.l (SP),A0
	move.w (A0),D0           // opcode function
	jsr hex_word
	moveq #13,D0
	jsr display_char
	moveq #10,D0
	jsr display_char
.x0b:
	move.l (SP)+,A0
#endif
	move.w (A0),D0           // function
	tst.w _video_found
	beq .x1
#ifndef TEST_NOPCI
	cmp.w #2,D0              // Physbase
	bne.s .x9
	jsr _physbase
	rte	
.x9:
#endif	// TEST_NOPCI
	cmp.w #5,D0              // Setscreen
	bne .x3
#ifdef DEBUG
	move.l A0,-(SP)
	lea debug2(PC),A0
	jsr display_string
	move.l (SP)+,A0
	move.l 2(A0),D0
	jsr hex_long
	moveq #0x20,D0
	jsr display_char
	moveq #0x30,D0
	jsr display_char
	moveq #0x78,D0
	jsr display_char
	move.l 6(A0),D0
	jsr hex_long
	moveq #0x20,D0
	jsr display_char
	moveq #0x30,D0
	jsr display_char
	moveq #0x78,D0
	jsr display_char
	move.w 10(A0),D0
	jsr hex_word
	moveq #0x20,D0
	jsr display_char
	moveq #0x30,D0
	jsr display_char
	moveq #0x78,D0
	jsr display_char
	move.w 12(A0),D0
	jsr hex_word	
	moveq #13,D0
	jsr display_char
	moveq #10,D0
	jsr display_char
#endif
	moveq #1,D0
	move.l D0,-(SP)          // init var VDI
	move.w 12(A0),D0         // modecode
	ext.l D0
	move.l D0,-(SP)
	move.w 10(A0),D0         // rez
	ext.l D0
	move.l D0,-(SP)
	move.l 6(A0),-(SP)       // logical address
	move.l 2(A0),-(SP)       // physical address
	jsr _vsetscreen
	and.l #0xFFFF,D0
	lea 20(SP),SP
	rte
.x3:
	cmp.w #64,D0             // Blitmode
	bne.s .x4
	moveq #0,D0              // no blitter  
	rte
.x4:
	cmp.w #88,D0             // Vsetmode
	bne.s .x5
#ifdef DEBUG
	move.l A0,-(SP)
	lea debug6(PC),A0
	jsr display_string
	move.l (SP)+,A0
	move.w 2(A0),D0
	jsr hex_word
	moveq #13,D0
	jsr display_char
	moveq #10,D0
	jsr display_char
#endif
	move.w 2(A0),D0          // modecode
	ext.l D0
	move.l D0,-(SP)
	jsr _vsetmode
	and.l #0xFFFF,D0
	addq.l #4,SP
	rte
.x5:
	cmp.w #89,D0             // Mon_type
	bne.s .x6
	jsr _montype
	rte
.x6:
	cmp.w #91,D0             // Vgetsize
	bne.s .x7
	move.w 2(A0),D0          // modecode
	ext.l D0
	move.l D0,-(SP)
	jsr _vgetsize
	addq.l #4,SP
	rte
.x7:
#ifndef TEST_NOPCI
	cmp.w #93,D0             // Vsetrgb
	bne.s .x8
	move.l 6(A0),-(SP)       // array	
	moveq #0,D0
	move.w 4(A0),D0          // count		
	move.l D0,-(SP)
	move.w 2(A0),D0          // index
	move.l D0,-(SP)
	jsr _vsetrgb
	lea 12(SP),SP
	rte
.x8:
	cmp.w #94,D0             // Vgetrgb
	bne.s .x10
	move.l 6(A0),-(SP)       // array
	moveq #0,D0
	move.w 4(A0),D0          // count		
	move.l D0,-(SP)
	move.w 2(A0),D0          // index
	move.l D0,-(SP)
	jsr _vgetrgb
	lea 12(SP),SP
	rte
#endif	// TEST_NOPCI
.x10:
	cmp.l #95,D0             // ValidMode (undocumented, used by AES)
	bne.s .x11
#ifdef DEBUG
	move.l A0,-(SP)
	lea debug7(PC),A0
	jsr display_string
	move.l (SP)+,A0
	move.w 2(A0),D0
	jsr hex_word
	moveq #13,D0
	jsr display_char
	moveq #10,D0
	jsr display_char
#endif
	move.w 2(A0),D0          // modecode
	ext.l D0
	move.l D0,-(SP)
	jsr _validmode
	addq.l #4,SP
	rte
.x11:		
	cmp.w #0xc60e,D0         // ct60_vmalloc
	beq.s .x12
	cmp.w #0xc6e,D0          // bis
	bne.s .x14
.x12:
	move.l 4(A0),-(SP)
	move.w 2(A0),D0          // value
	ext.l D0
	move.l D0,-(SP)          // mode
	jsr _vmalloc
	addq.l #8,SP
	rte
.x14:
#define VIDIX
	cmp.w #420,D0
	bhi .x1
	cmp.w #400,D0            // VIDIX
	bcs .x1
	sub.w #400,D0
	move.w tab_vidix_bios(PC,D0.w*2),D0
	bmi .x1                // original TOS XBIOS
	jsr tab_vidix_bios(PC,D0.w)
	rte
#ifdef VIDIX
tab_vidix_bios:
	dc.w vixGetVersion-tab_vidix_bios // 400
	dc.w vixProbe-tab_vidix_bios // 401
	dc.w vixInit-tab_vidix_bios // 402
	dc.w vixDestroy-tab_vidix_bios // 403
	dc.w vixGetCapability-tab_vidix_bios // 404
	dc.w vixQueryFourcc-tab_vidix_bios // 405
	dc.w vixConfigPlayback-tab_vidix_bios // 406
	dc.w vixPlaybackOn-tab_vidix_bios // 407
	dc.w vixPlaybackOff-tab_vidix_bios // 408
	dc.w vixPlaybackFrameSelect-tab_vidix_bios // 409
	dc.w vixGetGrKeys-tab_vidix_bios // 410
	dc.w vixSetGrKeys-tab_vidix_bios // 411
	dc.w vixPlaybackGetEq-tab_vidix_bios // 412
	dc.w vixPlaybackSetEq-tab_vidix_bios // 413
	dc.w vixPlaybackGetDeint-tab_vidix_bios // 414
	dc.w vixPlaybackSetDeint-tab_vidix_bios // 415
	dc.w vixPlaybackCopyFrame-tab_vidix_bios // 416
	dc.w vixQueryDMAStatus-tab_vidix_bios // 417
	dc.w -1 // 418
	dc.w -1 // 419
	dc.w InitVideo-tab_vidix_bios // 420
#endif /* VIDIX */
.x1:
	move.l _old_vector_xbios,-(SP)
	rts

#ifdef VIDIX	
vixGetVersion:
	
	jmp _vixGetVersion
	
vixProbe:

	move.l 6(A0),-(SP) // force
	move.l 2(A0),-(SP) // verbose
	jsr _vixProbe
	addq.l #8,SP
	rts
	
vixInit:

	jmp _vixInit
	
vixDestroy:

	jmp _vixDestroy

vixGetCapability:

	move.l 2(A0),-(SP) // to
	jsr _vixGetCapability
	addq.l #4,SP
	rts
	
vixQueryFourcc:

	move.l 2(A0),-(SP) // to
	jsr _vixQueryFourcc
	addq.l #4,SP
	rts

vixConfigPlayback:

	move.l 2(A0),-(SP) // info
	jsr _vixConfigPlayback
	addq.l #4,SP
	rts
	
vixPlaybackOn:

	jmp _vixPlaybackOn
	
vixPlaybackOff:

	jmp _vixPlaybackOff

vixPlaybackFrameSelect:

	move.l 2(A0),-(SP) // frame
	jsr _vixPlaybackFrameSelect
	addq.l #4,SP
	rts
	
vixGetGrKeys:

	move.l 2(A0),-(SP) // grkey
	jsr _vixGetGrKeys
	addq.l #4,SP
	rts
	
vixSetGrKeys:
	
	move.l 2(A0),-(SP) // grkey
	jsr _vixSetGrKeys
	addq.l #4,SP
	rts
	
vixPlaybackGetEq:

	move.l 2(A0),-(SP) // eq
	jsr _vixPlaybackGetEq
	addq.l #4,SP
	rts
	
vixPlaybackSetEq:

	move.l 2(A0),-(SP) // eq
	jsr _vixPlaybackSetEq
	addq.l #4,SP
	rts
	
vixPlaybackGetDeint:

	move.l 2(A0),-(SP) // info
	jsr _vixPlaybackGetDeint
	addq.l #4,SP
	rts
	
vixPlaybackSetDeint:

	move.l 2(A0),-(SP) // info
	jsr _vixPlaybackSetDeint
	addq.l #4,SP
	rts
	
vixPlaybackCopyFrame:

	move.l 2(A0),-(SP) // dmai
	jsr _vixPlaybackCopyFrame
	addq.l #4,SP
	rts

vixQueryDMAStatus:

	jmp _vixQueryDMAStatus
	
InitVideo:
	jmp _InitVideo
#endif /* VIDIX */

#ifdef NETWORK

#ifdef DEBUG
dump:
	lea -20(SP),SP
	movem.l D0-D2/A0-A1,(SP)
	moveq #31,D1
.loop_dump1:
		moveq #15,D2
.loop_dump2:
			move.b (A1)+,D0
			jsr hex_byte
			moveq #0x20,D0
			jsr display_char
		subq.l #1,D2
		bpl.s .loop_dump2
		lea -16(A1),A1
		moveq #15,D2
.loop_dump3:
			moveq #0,D0
			move.b (A1)+,D0
			cmp.l #0x20,D0
			bcs.s .dump_bad_char
			cmp.l #0x7F,D0
			bcs.s .dump_ok
.dump_bad_char:
			moveq #0x2E,D0
.dump_ok:
			jsr display_char
		subq.l #1,D2
		bpl.s .loop_dump3
		moveq #13,D0
		jsr display_char
		moveq #10,D0
		jsr display_char
	subq.l #1,D1
	bpl.s .loop_dump1
	movem.l (SP),D0-D2/A0-A1
	lea 20(SP),SP
	rts
#endif

#undef DEBUG

install_xbra:	// A0: handler, D0: vector 

	lea -28(SP),SP
	movem.l D1-D3/A0-A3,(SP)
	moveq #0,D3
	move.w D0,D3             // vector
	move.l A0,A3             // handler
	move.w #3,-(SP)          // TT ram if possible
	move.l #18,-(SP)         // size
	move.w #0x44,-(SP)       // Mxalloc
	trap #1 
	addq.l #8,SP
	tst.l D0
	beq.s .error_xbra
	move.l D0,A0
	move.l #0x58425241,(A0)+ // XBRA
	move.l #0x5F43465F,(A0)+ // _CF_
	clr.l (A0)+	
	move.w #0x4EF9,(A0)+     // JMP
	move.l A3,(A0)+          // handler
	lea -10(A0),A0
	cpusha BC
	move.l D3,A1
	move.l (A1),D0
	move.l D0,(A0)+          // old vector
	move.l A0,(A1)           // JMP, new vector
.error_xbra:
	tst.l D0
	movem.l (SP),D1-D3/A0-A3
	lea 28(SP),SP
	rts

_install_ram_disk:

	lea -20(SP),SP
	movem.l D1-D2/A0-A2,(SP)
	link A6,#-16
	moveq #2,D1              // drive C
	move.l _drvbits,D0
.search_empty_drive:
		btst D1,D0
		beq.s .drive_not_exist
		addq.l #1,D1
	cmp.l #16,D1
	bcs.s .search_empty_drive
	bra .drive_full          // all drives already used
.drive_not_exist:
	move.l D1,ram_disk_drive
	moveq #2,D0
	move.l D0,_change_ram_disk
	clr.l _ext_write_protect_ram_disk
	moveq #0,D0
	move.w tab_bpb+12(PC),D0 // sectors offset
	addq.l #1,D0
	lsr.l #1,D0
	add.l #RAM_DISK_SIZE_KB,D0
	asl.l #8,D0              // * 1024
	asl.l #2,D0
	move.l D0,_size_ram_disk
	addq.l #4,D0
	move.w #3,-(SP)          // TT ram if possible
	move.l D0,-(SP)
	move.w #0x44,-(SP)       // Mxalloc
	trap #1 
	addq.l #8,SP
.test_malloc_ok:
	tst.l D0
	beq .no_ram_disk
	addq.l #3,D0
	and.l #0xFFFFFFFC,D0     // 4 bytes alignment
	move.l D0,_address_ram_disk
	move.w SR,D0
	move.w D0,-(SP)
	or.l #0x700,D0           // mask interrupts
	move.w D0,SR
	lea det_hdv_bpb(PC),A0
	move.w #hdv_bpb,D0
	bsr install_xbra
	move.l D0,old_hdv_bpb
	lea det_hdv_rw(PC),A0
	move.w #hdv_rw,D0
	bsr install_xbra	
	move.l D0,old_hdv_rw
	lea det_hdv_mediach(PC),A0
	move.w #hdv_mediach,D0
	bsr install_xbra
	move.l D0,old_hdv_mediach
	move.w (SP)+,D0
	move.w D0,SR
#ifdef RAM_DISK_FAT12
	moveq #0,D0
	move.w tab_bpb+12(PC),D0 // sectors offset
	asl.l #6,D0              // * 512 / 8
	subq.l #1,D0
#else
	move.l #((512*((RAM_DISK_SEC_FAT*2)+1+7))/8)-1,D0
#endif
	move.l _address_ram_disk,A0
.raz_fat:
		clr.l (A0)+
		clr.l (A0)+
	subq.l #1,D0
	bpl.s .raz_fat
	move.l _address_ram_disk,A0
	lea 8(A0),A0
	lea tab_boot(PC),A1
	moveq #5,D0
.init_boot_sector:
		move.l (A1)+,(A0)+
	subq.l #1,D0
	bpl.s .init_boot_sector
	moveq #0,D0
	move.w tab_bpb+12(PC),D0 // sectors offset
	add.l #RAM_DISK_SIZE_KB*2,D0 // number of sectors
	move.l _address_ram_disk,A0 // boot sector bytes 19-20
	moveq #0,D2
	move.b D0,D2
	move.l 16(A0),D1
	and.l #0xFFFFFF00,D1
	or.l D2,D1
	move.l D1,16(A0)
	move.w D0,D2
	swap D2
	and.l #0xFF000000,D2
	move.l 20(A0),D1
	and.l #0x00FFFFFF,D1
	or.l D2,D1
	move.l D1,20(A0)
	move.l _drvbits,D0
	move.l ram_disk_drive,D1
	bset D1,D0
	move.l D0,_drvbits
	lea -16(A6),A0           // name
	add.l #0x41,D1
	move.b D1,(A0)+
	move.b #0x3A,(A0)+       // :
	move.l #0x5C52414D,(A0)+ // \RAM
	move.l #0x2D444953,(A0)+ // -DIS
	move.w #0x4B00,(A0)      // K
	move.w #8,-(SP)
	pea -16(A6)              // name
	move.w #0x3C,-(SP)       // Fcreate
	trap #1
	addq.l #8,SP
	tst.w D0
	bmi .error_fcreate
	move.w D0,-(SP)	
	move.w #0x3E,-(SP)       // Fclose
	trap #1
	addq.l #4,SP	
	moveq #2,D0              // drive C
	cmp.l ram_disk_drive,D0
	bne.s .no_set_drive
	move.w D0,_bootdev
	move.w D0,-(SP)
	move.w #0xE,-(SP)        // Dsetdrv
	trap #1
	addq.l #4,SP
.no_set_drive:
	moveq #0,D0
	move.w 0x3E86,D0         // number of planes
	cmp.l #2,D0
	bls.s .black_and_white
	pea blue(PC)
	move.w #9,-(SP)
	trap #1                  // Cconws
	addq.l #6,SP
.black_and_white:
	pea message(PC)          // Ram-disk installed
	move.w #9,-(SP)
	trap #1                  // Cconws
	addq.l #6,SP
	moveq #0x41,D0           // A
	add.l ram_disk_drive,D0
	move.w D0,-(SP)
	move.w #2,-(SP)
	trap #1                  // Cconout
	addq.l #4,SP
	pea crlf(PC)
	move.w #9,-(SP)
	trap #1                  // Cconws
	addq.l #6,SP
	moveq #0,D0
	move.w 0x3E86,D0         // number of planes
	cmp.l #2,D0
	bls.s .black_and_white_2
	pea black(PC)
	move.w #9,-(SP)
	trap #1                  // Cconws
	addq.l #6,SP
.black_and_white_2:
	move.l ram_disk_drive,D0 // OK
	bra.s .end_ram_disk
.error_fcreate:
	pea error3(PC)
	bra.s .display_error
.drive_full:
	pea error2(PC)
	bra.s .display_error
.no_ram_disk:
	pea error1(PC)
.display_error:
	pea error(PC)
	move.w #9,-(SP)
	trap #1                  // Cconws
	addq.l #6,SP
	move.w #9,-(SP)
	trap #1                  // Cconws
	addq.l #6,SP
	moveq #0,D0              // not installed
.end_ram_disk:
	unlk A6
	movem.l (SP),D1-D2/A0-A2
	lea 20(SP),SP
	rts

det_hdv_bpb:

 	moveq #0,D0
	move.w 4(SP),D0          // drive
	cmp.l ram_disk_drive,D0
	beq.s .dhb1
	move.l old_hdv_bpb,-(SP)
	rts
.dhb1:
	move.l A0,-(SP)
#ifdef DEBUG
	lea debug4(PC),A0
	jsr display_string	
#endif
	lea tab_bpb(PC),A0
	move.l A0,D0
	move.l (SP)+,A0
	rts
	
#ifdef RAM_DISK_FAT12

tab_bpb:
	dc.w 0x200               // sector size
	dc.w 2                   // cluster size in sectors
	dc.w 0x400               // cluster size in bytes
	dc.w 7                   // size directory in sectors
	dc.w RAM_DISK_SEC_FAT    // FAT size
	dc.w RAM_DISK_SEC_FAT+1  // 1st sector of FAT2
	dc.w (RAM_DISK_SEC_FAT*2)+7+1 // 1st data sector
	dc.w RAM_DISK_SIZE_KB    // total clusters
	dc.w 0                   // FAT 12
	dc.w 0
	dc.l 0,0,0
	
tab_boot:
	dc.b 0x16,0x10,0x64      // serial number
	dc.b 0,2                 // bytes/sector
	dc.b 2                   // sectors/cluster
	dc.b 1,0                 // reserved sectors
	dc.b 2                   // number of FATs
	dc.b 112,0               // number of directory entry
	dc.b 0,0                 // number of sectors
	dc.b 0
	dc.b RAM_DISK_SEC_FAT,0  // number of sectors/FAT
	dc.b 9,0                 // number of sectors/track
	dc.b 1,0                 // number of sides
	dc.b 0,0                 // number of hidden sectors
	dc.b 0,0                 // exec flag

#else

tab_bpb:
	dc.w 0x200               // sector size
	dc.w 2                   // cluster size in sectors
	dc.w 0x400               // cluster size in bytes
	dc.w 7                   // size directory in sectors
	dc.w RAM_DISK_SEC_FAT    // FAT size
	dc.w RAM_DISK_SEC_FAT+1  // 1st sector of FAT2
	dc.w (RAM_DISK_SEC_FAT*2)+7+1 // 1st data sector
	dc.w RAM_DISK_SIZE_KB    // total clusters
	dc.w 1                   // FAT 16
	dc.w 0
	dc.l 0,0,0
	
tab_boot:
	dc.b 0x16,0x10,0x64      // serial number
	dc.b 0,2                 // bytes/sector
	dc.b 2                   // sectors/cluster
	dc.b 1,0                 // reserved sectors
	dc.b 2                   // number of FATs
	dc.b 112,0               // number of directory entry
	dc.b 0,0                 // number of sectors
	dc.b 0
	dc.b RAM_DISK_SEC_FAT,0  // number of sectors/FAT
	dc.b 9,0                 // number of sectors/track
	dc.b 1,0                 // number of sides
	dc.b 0,0                 // number of hidden sectors
	dc.b 0,0                 // exec flag

#endif

message:	.byte 13,10
	.asciz "Ram-disk installed in "
crlf:	.byte 13,10,0
error:	.byte 13,10
	.asciz "No ram-disk installed, "
error1:	.ascii "no enough radeon memory"
	.byte 13,10,0
error2:	.ascii "all drives already used"
	.byte 13,10,0
error3:	.ascii "error disk name"
	.byte 13,10,0
blue:	.byte 0x1B,0x62,0x34,0
black:	.byte 0x1B,0x62,0x3F,0

	.align 2
	
det_hdv_rw:

 	moveq #0,D0
	move.w 14(SP),D0         // drive
	cmp.l ram_disk_drive,D0
	beq.s .dhr1
	move.l old_hdv_rw,-(SP)
	rts
.dhr1:
	lea -16(SP),SP
	movem.l D1-D2/A0-A1,(SP)
#ifdef DEBUG
	lea debug3(PC),A0
	jsr display_string	
	move.w 4+16(SP),D0       // rwflag
	jsr hex_word
	moveq #0x20,D0
	jsr display_char
	moveq #0x30,D0
	jsr display_char
	moveq #0x78,D0
	jsr display_char
	move.l 6+16(SP),D0       // buffer
	jsr hex_long
	moveq #0x20,D0
	jsr display_char
	moveq #0x30,D0
	jsr display_char
	moveq #0x78,D0
	jsr display_char
	move.w 10+16(SP),D0      // num sectors
	jsr hex_word
	moveq #0x20,D0
	jsr display_char
	moveq #0x30,D0
	jsr display_char
	moveq #0x78,D0
	jsr display_char
	move.w 12+16(SP),D0      // logical sector
	jsr hex_word
	moveq #0x20,D0
	jsr display_char
	moveq #0x30,D0
	jsr display_char
	moveq #0x78,D0
	jsr display_char
	move.w 14+16(SP),D0      // drive
	jsr hex_word
	moveq #13,D0
	jsr display_char
	moveq #10,D0
	jsr display_char
#endif
	moveq #0,D0
	move.w 12+16(SP),D0      // logical sector
	bpl.s .dhr5
	move.l 16+16(SP),D0      // logical sector	
.dhr5:
	asl.l #8,D0
	add.l D0,D0              // * 512
	move.l 6+16(SP),D1       // buffer
	beq.s .dhr4
	move.l D1,A0
	moveq #0,D1
	move.w 10+16(SP),D1      // num sectors
	subq.l #1,D1
	bmi.s .dhr4
	move.l _address_ram_disk,A1
	add.l D0,A1
	btst #0,5+16(SP)         // rwflag
	beq.s .dhr2              // read
	move.l A0,D0
	move.l A1,A0
	move.l D0,A1
	tst.l _ext_write_protect_ram_disk
	beq.s .dhr2
	moveq #-13,D0            // write protect
	bra.s .dhr6
.dhr2:
#ifdef DEBUG
		bsr dump
		jsr wait_key
#endif
		moveq #15,D0 // 512 bytes transfer
.dhr3:
			move.l (A1)+,(A0)+
			move.l (A1)+,(A0)+
			move.l (A1)+,(A0)+
			move.l (A1)+,(A0)+
			move.l (A1)+,(A0)+
			move.l (A1)+,(A0)+
			move.l (A1)+,(A0)+
			move.l (A1)+,(A0)+  
		subq.l #1,D0
		bpl.s .dhr3
	subq.l #1,D1
	bpl.s .dhr2
.dhr4:
	moveq #0,D0
.dhr6:
	movem.l (SP),D1-D2/A0-A1
	lea 16(SP),SP
 	rts

det_hdv_mediach:

 	moveq #0,D0
	move.w 4(SP),D0          // drive
	cmp.l ram_disk_drive,D0
	beq.s .dhm1
	move.l old_hdv_mediach,-(SP)
	rts
.dhm1:
#ifdef DEBUG
	move.l A0,-(SP)
	lea debug5(PC),A0
	jsr display_string
	move.l (SP)+,A0
#endif
	move.l _change_ram_disk,D0
	clr.l _change_ram_disk
	rts
	
_alert_tos:
	
	lea -52(SP),SP
	movem.l D1-A5,(SP)
	move.l 56(SP),A0         // string
	pea.l (A0)
	move.w #1,-(SP)
	jsr 0xE22A68             // form_alert
	addq.l #6,SP
	movem.l (SP),D1-A5
	lea 52(SP),SP
	ext.l D0
	rts
	
#endif /* NETWORK */
	
_asm_set_ipl:

	link A6,#-8
	movem.l D6-D7,(SP)
	move.w SR,D7             // current SR
	move.l D7,D0             // prepare return value
	and.l #0x0700,D0         // mask out IPL
	lsr.l #8,D0              // IPL
	move.l 8(A6),D6          // get argument
	and.l #7,D6              // least significant three bits
	lsl.l #8,D6              // move over to make mask
	and.l #0x0000F8FF,D7     // zero out current IPL
	or.l D6,D7               // place new IPL in SR
	move.w D7,SR
	movem.l (SP),D6-D7
	lea 8(SP),SP
	unlk A6
	rts

	.lcomm _address_ram_disk,4
	.lcomm _size_ram_disk,4
	.lcomm _change_ram_disk,4
	.lcomm _ext_write_protect_ram_disk,4
	.lcomm ram_disk_drive,4
	.lcomm old_hdv_bpb,4
	.lcomm old_hdv_rw,4
	.lcomm old_hdv_mediach,4
