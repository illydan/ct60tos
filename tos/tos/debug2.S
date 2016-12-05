/*  Debug the CT60
 * 
 * Didier Mequignon, 2003-2006, e-mail: aniplay@wanadoo.fr
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 2.1 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with this library; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

	.globl	exception
	
#include "vars.h"

// #define DEBUG

	.text
	
exception:

	clr.l memvalid
	lea.l mess1(PC),A0
	bsr display_string
	addq.w #1,D1
	move.w D1,D7       // vector number
	moveq #0,D0
	move.w D7,D0
	divu #10,D0
	and.w #7,D0
	beq.s .ex1
	or.w #0x30,D0
	bsr display_char
.ex1:
	swap d0
	or.w #0x30,D0
	bsr display_char
	moveq #0x3A,D0
	bsr display_char
	moveq #0x20,D0
	bsr display_char
	lea.l tab_mess_exc(PC),A0
	move.w D7,D0
	bsr display_tab
	moveq #13,D0
	bsr display_char
	moveq #10,D0
	bsr display_char
	lea.l mess2(PC),A0 // SR
	bsr display_string
	move.l 0x3C0,A0    //SSP
	move.w (A0),D0
	bsr hex_word       // SR
	lea.l mess3(PC),A0
	bsr display_string
	move.l 0x3C0,A0    //SSP
	move.w (A0),D2     // SR
	and.w #0xB71F,D2
	lea.l tab_status(PC),A1
	moveq #15,D1
.ex5:
		btst.l D1,D2
		beq.s .ex6
		moveq #0,D0
		move.b (A1,D1),D0
		move.w D0,D3
		and.w #0xF8,D3
		cmp.w #0x30,D3
		bne.s .ex4
		move.w D0,-(SP)
		moveq #0x49,D0 // I
		bsr display_char
		move.w (SP)+,D0
.ex4:
		bsr display_char
		moveq #0x20,D0
		bsr display_char
.ex6:
	dbf D1,.ex5
	lea.l mess4(PC),A0 // PC
	bsr display_string
	move.l 0x3C0,A0    // SSP
	move.l 2(A0),D0    // PC
	bsr hex_long
	lea.l mess10(PC),A0 // Basepage
	bsr display_string
	move.l 0x6EE4,D0
	bsr hex_long
	lea.l mess5(PC),A0 // CACR
	bsr display_string  
	movec.l CACR,D0
	bsr hex_long
	cmp.w #2,D7
	beq.s .ex3         // Acces Fault
	cmp.w #3,D7
	beq.s .ex3         // Adress Error
	cmp.w #5,D7
	beq.s .ex3         // Zero Divide
	cmp.w #9,D7
	bne .ex2           // <> Trace
.ex3:
	lea.l mess6(PC),A0 // address fault
	bsr display_string
	move.l 0x3C0,A0    // SSP
	move.l 8(A0),D0    // address fault
	bsr hex_long
	cmp.w #2,D7
	bne .ex2           // <> Acces Fault
	lea.l mess7(PC),A0 // FSLW
	bsr display_string
	move.l 0x3C0,A0    // SSP
	move.l 12(A0),D0   // FSLW
	bsr hex_long
	lea.l mess3(PC),A0
	bsr display_string
	moveq #13,D0
	bsr display_char
	moveq #10,D0
	bsr display_char
	move.l 0x3C0,A0  // SSP
	move.l 12(A0),D2 // FSLW
	and.l #0x0BFFFFFD,D2
	lea.l tab_fslw1(PC),A1
	lea.l tab_fslw2(PC),A2
	lea.l tab_fslw3(PC),A3
	moveq #31,D1
	moveq #0,D3
.ex13:
		btst.l D1,D2
		beq.s .ex14
		moveq #0,D0
		move.b (A1,D3),D0
		bsr display_char
		moveq #0,D0
		move.b (A2,D3),D0
		cmp.b #0x20,D0
		beq.s .ex12
		bsr display_char
		moveq #0,D0
		move.b (A3,D3),D0
		cmp.b #0x20,D0
		beq.s .ex12
		bsr display_char
.ex12:
		moveq #0x20,D0
		bsr display_char
.ex14:
		addq.w #1,D3
	dbf D1,.ex13
.ex2:
	lea.l mess8(PC),A0 // SSP
	bsr display_string
	move.l 0x3C0,D0    // SSP
	bsr hex_long
	lea.l mess9(PC),A0 // USP
	bsr display_string
	move.l 0x3C8,D0    // USP
	bsr hex_long
	lea.l 0x384,A1     // registers
	lea.l 32(A1),A2
	moveq #7,D1
.ex8:
		moveq #13,D0
		bsr display_char
		moveq #10,D0
		bsr display_char
		moveq #0x44,D0
		bsr display_char
		moveq #7,D0
		sub.w D1,D0
		or.w #0x30,D0
		move.w D0,-(SP)
		bsr display_nb
		move.l (A1),D0
		bsr hex_long // data registers
		moveq #0x20,D0
		bsr display_char
		tst.w D1
		beq.s .ex9
		moveq #0x41,D0
		bsr display_char
		move.w (SP),D0
		bsr display_nb
		move.l (A2),D0
		bsr hex_long // address registers
		moveq #0x20,D0
		bsr display_char
.ex9:		
		addq.l #2,SP
		addq.l #4,A1
		addq.l #4,A2
	dbf D1,.ex8
	moveq #13,D0
	bsr display_char
.loop_wait_key:
		move.w #2,-(SP)          // CON
		move.w #2,-(SP)          // Bconin
		trap #13
		addq.l #4,SP
		ext.l D0
		move.l D0,-(SP)
		move.l #0x5F504349,D0 
		lea 0xED0000,A0          // 128 KB
		cmp.l (A0),D0            // _PCI
		beq.s .pci_drivers
		lea 0xEC0000,A0          // 192 KB
		cmp.l (A0),D0            // _PCI
		beq.s .pci_drivers
		lea 0xEB0000,A0          // 256 KB
		cmp.l (A0),D0            // _PCI
		beq.s .pci_drivers
		lea 0xEA0000,A0          // 320 KB
		cmp.l (A0),D0            // _PCI
		bne.s .no_pci_drivers
.pci_drivers:
		jsr 40(A0)               // drivers PCI in flash, add dbug (68k disassembler)
		move.l D0,(SP)
		bne .no_pci_drivers
		addq.l #4,SP
		bra.s .loop_wait_key
.no_pci_drivers:
		move.l (SP)+,D0
		cmp.b #0x6D,D0     // m
		beq.s .memory_dump
		cmp.b #0x70,D0     // p
		beq.s .patch_memory
#ifdef DEBUG
		cmp.b #0x20,D0
		bne .loop_wait_key
		lea mess14(PC),A0
		bsr display_string
#endif
		rts
.memory_dump:
		lea mess11(PC),A0  // memory dump
		bsr display_string
		bsr get_hex_value	
		move.l D0,A0
		bsr dump
		bra .loop_wait_key
.patch_memory:
		lea mess12(PC),A0  // patch memory
		bsr display_string
		bsr get_hex_value
		move.l D0,A1
		lea mess13(PC),A0  // value
		bsr display_string		
		bsr get_hex_value
		cmp.l #0x100,D0
		bcc.s .word_value
		move.b D0,(A1)
		lea crlf(PC),A0
		bsr display_string
		move.l A1,D0
		bsr hex_long
		moveq #0x20,D0
		bsr display_char
		move.b (A1),D0
		bsr hex_byte
		bra .loop_wait_key
.word_value:
		cmp.l #0x10000,D0
		bcc.s .long_value
		move.w D0,(A1)
		lea crlf(PC),A0
		bsr display_string
		move.l A1,D0
		bsr hex_long
		moveq #0x20,D0
		bsr display_char
		move.w (A1),D0
		bsr hex_word	
		bra .loop_wait_key
.long_value:
		move.l D0,(A1)
		lea crlf(PC),A0
		bsr display_string
		move.l A1,D0
		bsr hex_long
		moveq #0x20,D0
		bsr display_char
		move.l (A1),D0
		bsr hex_long
	bra .loop_wait_key
	
display_nb:

	bsr display_char
	moveq #0x3A,D0
	bsr display_char
	moveq #0x24,D0
	bsr display_char
	rts
	
display_tab:

	move.w D0,-(SP)
	moveq #0,D0
.dt1:
		cmp.b #-1,(A0)
		beq.s .dt3
		cmp.w (SP),D0
		beq.s .dt4
.dt2:
		tst.b (A0)+
		bne.s .dt2
		addq.w #1,D0
	bra.s .dt1
.dt4:
	bsr display_string
.dt3:

	addq.l #2,SP
	rts
		
hex_long:
	move.l D0,-(SP)
	swap D0
	bsr.s hex_word
	move.l (SP)+,D0
hex_word:
	move.w D0,-(SP)
	lsr.w #8,D0          
	bsr.s hex_byte     
	move.w (SP)+,D0
hex_byte:
	move.w D0,-(SP)
	lsr.b #4,D0        
	bsr.s hex_char      
	move.w (SP)+,D0      
hex_char:
	and.b #0xF,D0      
	or.b #0x30,D0      
	cmp.b #0x3A,D0     
	bcs.s display_char  
	addq.b #7,D0   
	    
display_char:
	and.w #0xFF,D0  
	movem.l D0-D2/A0-A2,-(SP)
	move.w D0,-(sp)
	move.w #2,-(SP)
	move.w #3,-(SP)       // Bconout
	trap #13
	addq.l #6,SP
	movem.l (SP)+,D0-D2/A0-A2
	rts
	
display_string:

	movem.l D0/A0,-(SP)
.os2:
	move.b (A0)+,D0
	beq.s .os1
	bsr display_char
	bra.s .os2
.os1:
	movem.l (SP)+,D0/A0
	rts
	
get_hex_value:

	movem.l D1-A5,-(SP)
	link A6,#-8
	moveq #0,D7
.loop_get_value:
		move.w #2,-(SP)          // CON
		move.w #2,-(SP)          // Bconin
		trap #13
		addq.l #4,SP
		cmp.b #13,D0
		beq.s .conv_get_value
		cmp.b #8,D0
		bne.s .not_backspace
		tst.w D7
		ble.s .loop_get_value
		bsr display_char
		subq.w #1,D7
		bra.s .loop_get_value
.not_backspace:
		cmp.b #0x30,D0
		bcs.s .loop_get_value
		cmp.b #0x39,D0
		bls.s .number_value
		cmp.b #0x41,D0
		bcs.s .loop_get_value
		cmp.b #0x46,D0
		bls.s .letter_value
		cmp.b #0x61,D0
		bcs.s .loop_get_value
		cmp.b #0x66,D0
		bhi.s .loop_get_value
.letter_value:
		bsr display_char
		and.b #0x0F,D0
		add.b #9,D0
		bra.s .store_value		
.number_value:
		bsr display_char
		and.b #0x0F,D0
.store_value:
		move.b D0,-8(A6,D7)
		addq.w #1,D7
	cmp.w #8,D7
	bcs.s .loop_get_value
.conv_get_value:
	moveq #0,D0
	subq.w #1,D7
	bmi.s .end_get_value
	moveq #0,D6
.loop_value:
		asl.l #4,D0
		or.b -8(A6,D6),D0
		addq.w #1,D6
	dbf D7,.loop_value		
.end_get_value:	
	tst.l D0
	unlk A6
	movem.l (SP)+,D1-A5
	rts
	
dump:

	movem.l D0-D2/A0-A1,-(SP)
	move.l A0,A1
	moveq #3,D1
.loop_dump1:
		lea crlf(PC),A0
		bsr display_string
		move.l A1,D0
		bsr hex_long
		moveq #0x20,D0
		bsr display_char		
		moveq #15,D2
.loop_dump2:
			move.b (A1)+,D0
			bsr hex_byte
			moveq #0x20,D0
			bsr display_char
		dbf D2,.loop_dump2
		lea -16(A1),A1
		moveq #15,D2
.loop_dump3:
			move.b (A1)+,D0
			cmp.b #0x20,D0
			bcs.s .dump_bad_char
			cmp.b #0x7F,D0
			bcs.s .dump_ok
.dump_bad_char:
			moveq #0x2E,D0
.dump_ok:
			bsr display_char
		dbf D2,.loop_dump3
	dbf D1,.loop_dump1
	movem.l (SP)+,D0-D2/A0-A1
	rts
	
crlf:	.byte 13,10,0
mess1:	.byte 13,10
	.asciz "EXCEPTION PROCESSING "
mess2:	.byte 13,10
	.asciz "Status Register (SR): $"
mess3:	.asciz ", bits to 1: "
mess4:	.byte 13,10
	.asciz "Program Counter (PC): $"
mess5:	.byte 13,10
	.asciz "Cache Register (CACR): $"
mess6:	.byte 13,10
	.asciz "Address Fault: $"	
mess7:	.byte 13,10
	.asciz "Fault Status Word (FSLW): "
mess8:	.byte 13,10
	.asciz "Supervisor Stack (SSP): $"
mess9:	.byte 13,10
	.asciz "User Stack (USP): $"
mess10:	.byte 13,10
	.asciz "Basepage: $"
mess11:	.byte 13,10	
	.asciz "Memory dump (hex) ? "
mess12:	.byte 13,10	
	.asciz "Patch memory (hex) ? "
mess13:	.byte 13,10	
	.asciz "Value (hex) ? "
mess14:	.byte 13,10	
	.ascii "Pterm"
	.byte 13,10,0
 
tab_mess_exc:
	.byte 0
	.byte 0
	.asciz "Access Fault"
	.asciz "Address Error"
	.asciz "Illegal Instruction"
	.asciz "Integer Zero Divide"
	.byte 0
	.byte 0
	.asciz "Privilege Violation"
	.asciz "Trace"
	.asciz "Line A"
	.asciz "Line F"
	.asciz "Emulator Interrupt"
	.byte 0
	.asciz "Format Error"
	.asciz "Uninitialised Interrupt"
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.asciz "Spurious Interrupt"
	.asciz "Interrupt level 1"
	.asciz "Interrupt level 2" 
	.asciz "Interrupt level 3" 
	.asciz "Interrupt level 4"
	.asciz "Interrupt level 5" 
	.asciz "Interrupt level 6"
	.asciz "Interrupt level 7"
	.asciz "Trap #0"
	.asciz "Trap #1"
	.asciz "Trap #2"
	.asciz "Trap #3"
	.asciz "Trap #4"
	.asciz "Trap #5"
	.asciz "Trap #6"
	.asciz "Trap #7"
	.asciz "Trap #8"
	.asciz "Trap #9"
	.asciz "Trap #10"
	.asciz "Trap #11"
	.asciz "Trap #12"
	.asciz "Trap #13"
	.asciz "Trap #14"
	.asciz "Trap #15"
	.byte -1

tab_status:	.ascii "CVZNX   012 MS T"

tab_fslw1:	.ascii "    M LRWSSTTTTTIPSPPIPSWTRWTB S"
tab_fslw2:	.ascii "    A K  ZZTTMMMOBBTTLFPPWEETP S"
tab_fslw3:	.ascii "         1010210 EEAB    E  RE E"
