/* TOS 4.04 Bios bconout patch for the CT60 board
*  Didier Mequignon 2001 December, e-mail: aniplay@wanadoo.fr
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

#include "vars.h"

#undef DEBUG

	.text

	.globl _bconout2

_bconout2:
	move.w 6(SP),D1
	move.w D1,-(SP)
	bsr _cputc
	addq.l #2,SP
	rts
	
get_cookie:

	move.l D1,-(SP)
	move.l D0,D1
	move.l cookie,D0
	beq.s .cookie_not_found
	move.l D0,A0
.loop_cookie:
		tst.l (A0)
		beq.s .cookie_not_found
		cmp.l (A0),D1
		bne.s .next_cookie
		move.l 4(A0),D0
		bra.s .end_cookie
.next_cookie:
		addq.l #8,A0
	bra.s .loop_cookie
.cookie_not_found:
	moveq #0,D0
	move.l D0,A0
.end_cookie:
	move.l (SP)+,D1
	tst.l D0
	rts
	
test_accel:

	move.l _v_bas_ad,D0
        	cmp.l #0x01000000,D0
        	bcs.s .no_pci_drivers
	move.l #0x5F504349,D0    // cookie _PCI
	bsr get_cookie
	move.l A0,D0
	beq.s .no_pci_drivers
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
	moveq #1,D0
	rts
.no_pci_drivers:
	moveq #0,D0
	rts
	
#include "conout.S"
