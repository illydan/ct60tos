/* TOS 4.04 Boot order patch for the CT60 board
*  Didier Mequignon 2003-2004, e-mail: aniplay@wanadoo.fr
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

	.text
	
	.globl	menu_boot

	.align	2
	.long	0x798
	.long	end1-begin1
begin1:
	jsr	menu_boot
end1:

	.globl	boot_drive

	.align	2
	.long	0xB42
	.long	end2-begin2
begin2:
	jmp	boot_drive
end2:

	.align	2
	.long	0x17EA
	.long	end3-begin3
begin3:
	.short	0x11
end3:


