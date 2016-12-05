/*
 * fVDI polygon fill functions
 *
 * $Id: polygon.c,v 1.4 2004/10/17 21:44:11 johan Exp $
 *
 * Copyright 1999-2003, Johan Klockars 
 * This software is licensed under the GNU General Public License.
 * Please, see LICENSE.TXT for further information.
 *
 * Based on some code found on the net,
 * but very heavily modified.
 */

#include "fvdi.h"
#include "function.h"
#include <mint/osbind.h>

#ifdef __GNUC__
#define SMUL_DIV(x,y,z)	((short)(((short)(x)*(long)((short)(y)))/(short)(z)))
#else
 #ifdef __PUREC__
  #define SMUL_DIV(x,y,z)	((short)(((x)*(long)(y))/(z)))
 #else
int SMUL_DIV(int, int, int);   //   d0d1d0d2
#pragma inline d0 = SMUL_DIV(d0, d1, d2) { "c1c181c2"; }
 #endif
#endif


void filled_poly(Virtual *vwk, short p[][2], long n, long colour,
                 short *pattern, short *points, long mode, long interior_style)
{
	int i, j;
	short tmp, y;
	short miny, maxy;
	short x1, y1;
	short x2, y2;
	int ints;
	int spans;
	short *coords;
	
	if (!n)
		return;
		
	if ((p[0][0] == p[n - 1][0]) && (p[0][1] == p[n - 1][1]))
		n--;

	miny = maxy = p[0][1];
	coords = &p[1][1];
	for(i = 1; i < n; i++) {
		y = *coords;
		coords += 2;		/* Skip to next y */
		if (y < miny) {
			miny = y;
		}
		if (y > maxy) {
			maxy = y;
		}
	}
	if (vwk->clip.on) {
		if (miny < vwk->clip.rectangle.y1)
			miny = vwk->clip.rectangle.y1;
		if (maxy > vwk->clip.rectangle.y2)
			maxy = vwk->clip.rectangle.y2;
	}

	spans = 0;
	coords = &points[n];

	for(y = miny; y <= maxy; y++) {
		ints = 0;
		x1 = p[n - 1][0];
		y1 = p[n - 1][1];
		for(i = 0; i < n; i++) {
			x2 = p[i][0];
			y2 = p[i][1];
			if (y1 < y2) {
				if ((y >= y1) && (y < y2)) {
					points[ints++] = SMUL_DIV((y - y1), (x2 - x1), (y2 - y1)) + x1;
				}
			} else if (y1 > y2) {
				if ((y >= y2) && (y < y1)) {
					points[ints++] = SMUL_DIV((y - y2), (x1 - x2), (y1 - y2)) + x2;
				}
			}
			x1 = x2;
			y1 = y2;
		}
		
		for(i = 0; i < ints - 1; i++) {
			for(j = i + 1; j < ints; j++) {
				if (points[i] > points[j]) {
					tmp = points[i];
					points[i] = points[j];
					points[j] = tmp;
				}
			}
		}

		if (spans > 1000) {			/* Should really check against size of points array! */
			fill_spans(vwk, &points[n], spans, colour, pattern, mode, interior_style);
			spans = 0;
			coords = &points[n];
		}

		x1 = vwk->clip.rectangle.x1;
		x2 = vwk->clip.rectangle.x2;
		for(i = 0; i < ints - 1; i += 2) {
			y1 = points[i];		/* Really x-values, but... */
			y2 = points[i + 1];
			if (y1 < x1)
				y1 = x1;
			if (y2 > x2)
				y2 = x2;
			if (y1 <= y2) {
				*coords++ = y;
				*coords++ = y1;
				*coords++ = y2;
				spans++;
			}
		}
	}
	if (spans)
		fill_spans(vwk, &points[n], spans, colour, pattern, mode, interior_style);
}

