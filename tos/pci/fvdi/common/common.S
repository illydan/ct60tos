/****
* fVDI->driver interface (assembly functions), by Johan Klockars
*
* $Id: common.s,v 1.5 2005/04/23 18:53:17 johan Exp $
*
* Most fVDI device drivers are expected to make use of this file.
*
* Since it would be difficult to do without this file when
* writing new device drivers, and to make it possible for
* some such drivers to be commercial, this file is put in
* the public domain. It's not copyrighted or under any sort
* of license.
****/

#define both			1	// Write in both FastRAM and on screen
#define upto8		0	// Handle 8 bit drawing

#include		"vdi.inc"
#include		"macros.inc"

//	.xdef		_line
//	.xdef		_set_pixel
//	.xdef		_get_pixel
//	.xdef		_expand
//	.xdef		_fill
//	.xdef		_fillpoly
//	.xdef		_blit
//	.xdef		_text
	.xdef		_mouse
//	.xdef		_set_palette
//	.xdef		_colour
//	.xdef		_initialize_palette
//	.xdef		get_colour_masks

//	.xref		_line_draw_r,_write_pixel_r,_read_pixel_r,_expand_area_r
//	.xref		_fill_area_r,_fill_poly_r,_blit_area_r,_text_area_r
	.xref		_mouse_draw_r
	.xref		_set_colours_r,_get_colour_r
//	.xref		_fallback_line,_fallback_text,_fallback_fill
//	.xref		_fallback_fillpoly,_fallback_expand,_fallback_blit
//	.xref		clip_line
//	.xref		_mask


	.text

	.asciz		"mouse"
	.align		2
/*--------
* Draw the mouse
* In:	a1	Pointer to Workstation struct
*	d0	x (low), old op bits (high)
*	d1	y
*	d2	0 (move), 1 (hide), 2 (show), Mouse* (change)
* Call:	a1	Pointer to Workstation struct
*	d0	x (low), old op bits (high)
*	d1	y
*	d2	0 (move shown), 1 (move hidden), 2 (hide), 3 (show), Mouse* (change)
* Out:	d0	mouse op to try again (low), pointer delay (high)
*-------*/
_mouse:
mouse:
	ijsr		_mouse_draw_r
	rts

