/* TOS 4.04 Xbios calls for the CT60/CTPCI boards
 * Coldfire Xbios AC97 Sound 
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
 * along with program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include "config.h" 
#include <mint/osbind.h>
#include <mint/falcon.h>
#include <string.h>
#include <mint/sysvars.h>
#include "radeon/fb.h"
#include "radeon/radeonfb.h"
#include "ct60.h"
#ifdef NETWORK
#endif

#ifdef TEST_NOPCI
#ifndef Screalloc
#define Screalloc(size) (void *)trap_1_wl((short)(0x15),(long)(size))
#endif
extern void init_var_linea(void);
extern void init_videl_320_240_65K(unsigned short *screen_addr);
extern void init_videl_640_480_65K(unsigned short *screen_addr);
#endif
   
#define Modecode (*((short*)0x184C))

extern const struct fb_videomode modedb[];
extern const struct fb_videomode vesa_modes[];
extern long total_modedb;

unsigned long physbase(void);
long vgetsize(long modecode);

extern void ltoa(char *buf, long n, unsigned long base);                                    
extern void init_var_linea(void);
extern void cursor_home(void);

typedef struct
{
	long ident;
	union
	{
		long l;
		short i[2];
		char c[4];
	} v;
} COOKIE;

extern COOKIE *get_cookie(long id);
extern int add_cookie(COOKIE *cook);

/* global */
extern struct radeonfb_info *rinfo_fvdi;
extern struct mode_option resolution;
extern short virtual;
long fix_modecode, second_screen, second_screen_aligned;

#undef SEMAPHORE

#ifndef TEST_NOPCI

static long bios_colors[256]; 

/* some XBIOS functions for the radeon driver */

void vsetrgb(long index, long count, long *array)
{
	short i;
	unsigned red,green,blue;
	struct fb_info *info;
#ifdef SEMAPHORE
	xSemaphoreTakeRADEON();
#endif
	info = rinfo_fvdi->info;
	for(i = index; i < (count + index); i++)
	{
		bios_colors[i] = *array;
		if(info->var.bits_per_pixel <= 8)
		{
			red = (*array>>16) & 0xFF;
			green = (*array>>8) & 0xFF;
			blue = *array & 0xFF;
			radeonfb_setcolreg((unsigned)i, red << 8, green << 8, blue << 8, 0, info);
		}
		array++;
	}
#ifdef SEMAPHORE
	xSemaphoreGiveRADEON();
#endif
}

void vgetrgb(long index, long count, long *array)
{
	short i;
	for(i = index; i < (count + index); i++)
		*array++ = bios_colors[i];
}

void display_composite_texture(long op, char *src_tex, long src_x, long src_y, long w_tex, long h_tex, long dst_x, long dst_y, long width, long height)
{
	struct fb_info *info = rinfo_fvdi->info;
	unsigned long dstFormat;
	switch(info->var.bits_per_pixel)
	{
		case 16: dstFormat = PICT_r5g6b5; break;
		case 32: dstFormat = PICT_x8r8g8b8; break;
		default: return;	
	}
	if(RADEONSetupForCPUToScreenTextureMMIO(rinfo_fvdi, (int)op, PICT_a8r8g8b8, dstFormat, src_tex, (int)w_tex << 2 , (int)w_tex, (int)h_tex, 0))
	{
		long x, y, x0 = dst_x;
		for(y = 0; y < height; y += h_tex)
		{
			int h = height - y;
			if(h >= h_tex)
				h = h_tex;
			dst_x = x0;
			for(x = 0; x < width; x += w_tex)
			{
				int w = width - x;
				if(w >= w_tex)
					w = w_tex;
				RADEONSubsequentCPUToScreenTextureMMIO(rinfo_fvdi, (int)dst_x, (int)dst_y, (int)src_x, (int)src_y, (int)w, (int)h);
				dst_x += w_tex;		
			}
			dst_y += h_tex;
		}
	}
}

void display_mono_block(char *src_buf, long dst_x, long dst_y, long w, long h, long foreground, long background, long src_wrap)
{
	int skipleft;
#ifdef SEMAPHORE
	xSemaphoreTakeRADEON();
#endif
	RADEONSetClippingRectangleMMIO(rinfo_fvdi, (int)dst_x, (int)dst_y, (int)w - 1, (int)h -1);
	skipleft = ((int)src_buf & 3) << 3;
	src_buf = (unsigned char*)((int)src_buf & ~3);
	dst_x -= skipleft;
	w += skipleft;
	RADEONSetupForScanlineCPUToScreenColorExpandFillMMIO(rinfo_fvdi, (int)foreground, (int)background, 3, 0xffffffff);
	RADEONSubsequentScanlineCPUToScreenColorExpandFillMMIO(rinfo_fvdi, (int)dst_x, (int)dst_y, (int)w, (int)h, (int)skipleft);
	while(--h >= 0)
	{
		RADEONSubsequentScanlineMMIO(rinfo_fvdi, (unsigned long*)src_buf);
		src_buf += src_wrap;
	}
	RADEONDisableClippingMMIO(rinfo_fvdi);
	radeonfb_sync(rinfo_fvdi->info);	
#ifdef SEMAPHORE
	xSemaphoreGiveRADEON();
#endif
}

long clear_screen(long bg_color, long x, long y, long w, long h)
{
	struct fb_info *info = rinfo_fvdi->info;
#ifdef SEMAPHORE
	xSemaphoreTakeRADEON();
#endif
	if(bg_color == -1)
	{
		x = y = 0;
		w = info->var.xres_virtual;
		h = info->var.yres_virtual;
		if(info->var.bits_per_pixel >= 16)
			RADEONSetupForSolidFillMMIO(rinfo_fvdi, 0, 15, 0xffffffff);  /* set */
		else
			RADEONSetupForSolidFillMMIO(rinfo_fvdi, 0, 0, 0xffffffff);   /* clr */
	}
	else if(bg_color == -2)
	{
		switch(info->var.bits_per_pixel)
		{
			case 8: bg_color = 0xff; break;
			case 16: bg_color = 0xffff; break;
			default: bg_color = 0xffffff; break;
		}
		RADEONSetupForSolidFillMMIO(rinfo_fvdi, (int)bg_color, 6, 0xffffffff);  /* xor */
	}
	else
		RADEONSetupForSolidFillMMIO(rinfo_fvdi, (int)bg_color, 3, 0xffffffff);  /* copy */
	RADEONSubsequentSolidFillRectMMIO(rinfo_fvdi, (int)x, (int)y, (int)w, (int)h);
	radeonfb_sync(rinfo_fvdi->info);
#ifdef SEMAPHORE
	xSemaphoreGiveRADEON();
#endif
	return(1);
}

long move_screen(long src_x, long src_y, long dst_x, long dst_y, long w, long h)
{
	int xdir, ydir;
#ifdef SEMAPHORE
	xSemaphoreTakeRADEON();
#endif
	xdir = (int)(src_x - dst_x);
	ydir = (int)(src_y - dst_y);
	RADEONSetupForScreenToScreenCopyMMIO(rinfo_fvdi, xdir, ydir, 3, 0xffffffff, -1);
	RADEONSubsequentScreenToScreenCopyMMIO(rinfo_fvdi, (int)src_x, (int)src_y, (int)dst_x, (int)dst_y, (int)w, (int)h);
	radeonfb_sync(rinfo_fvdi->info);
#ifdef SEMAPHORE
	xSemaphoreGiveRADEON();
#endif
	return(1);
}

long print_screen(char *character_source, long x, long y, long w, long h, long cell_wrap, long fg_color, long bg_color)
{
	static char buffer[256*16]; /* maximum width 2048 pixels, 256 characters, height 16 */
	static long pos_x, pos_y, length, height, foreground, background, old_timer;
	char *ptr;
	if(character_source == (char *)-1)
	{
		pos_x = -1;
		old_timer = *_hz_200;
	}
	else if(character_source)
	{
		if((pos_x >= 0) && ((pos_y != y) /* if line is different  => flush buffer */
		 || (*_hz_200 != old_timer)))
		{
			ptr = &buffer[pos_x];
			pos_x <<= 3;
			pos_y *= height;
			length <<= 3;
			display_mono_block(ptr, pos_x, pos_y, length, height, foreground, background, 256);
			pos_x = -1;
		}
		w >>= 3;
		if(pos_x < 0)
		{
			pos_x = x;        /* save starting pos */
			pos_y = y;
			length = 0;
			height = h;
			foreground = fg_color;
			background = bg_color;
		}
		if((x < 256) && (h <= 16))
		{
			ptr = &buffer[x]; /* store character inside a line buffer */
			switch(w)
			{
				case 0:
				case 1:
					while(--h >= 0)
					{
						*ptr = *character_source;
						character_source += cell_wrap;
						ptr += 256;
					}
					length++;
					break;
				default:
					while(--h >= 0)
					{
						*(short *)ptr = *(short *)character_source;
						character_source += cell_wrap;
						ptr += 256;
					}
					length += w;
					break;
			}
		}
	}
	else if(pos_x >= 0)   /* if character < ' ' => flush buffer */
	{
		ptr = &buffer[pos_x];
		pos_x <<= 3;
		pos_y *= height;
		length <<= 3;
		display_mono_block(ptr, pos_x, pos_y, length, height, foreground, background, 256);
		pos_x = -1;
	}
	old_timer = *_hz_200;
	return(1);
}

static unsigned long mul32(unsigned long a, unsigned long b) // GCC Colfire bug ???
{
	return(a * b);
}

void display_atari_logo()
{
#define WIDTH_LOGO 96
#define HEIGHT_LOGO 86
	unsigned long base_addr = (unsigned long)Physbase();
	struct fb_info *info = rinfo_fvdi->info;
	unsigned char *buf_tex = NULL;
	unsigned long *ptr32 = NULL;
	unsigned short *ptr16 = NULL;
	unsigned char *ptr8 = NULL;
	int i, j, k, cnt = 1;
	int bpp = info->var.bits_per_pixel;
	unsigned short val, color = 0, r, g, b;
	unsigned long color2 = 0, r2, g2, b2;
	unsigned long incr = mul32(info->var.xres_virtual, bpp >> 3);
//	unsigned long incr = (unsigned long)(info->var.xres_virtual * (bpp >> 3));
#ifndef TEST_NOPCI
	if(bpp >= 16)
	{
		buf_tex = (char *)Malloc(HEIGHT_LOGO * WIDTH_LOGO * 4);
		if(buf_tex != NULL)
		{
			incr = WIDTH_LOGO * 4;
			bpp = 32;
			cnt = 2;
		}
	}
	else
#endif
		base_addr += (incr * 4); // line 4
	while(--cnt >= 0)
	{
		unsigned short *logo_atari = (unsigned short *)0xE49434; /* logo ATARI monochrome inside TOS 4.04 */
#ifndef TEST_NOPCI
		if(buf_tex != NULL)
			base_addr = (unsigned long)buf_tex;
#endif
		g = 3;
		g2 = 3;
		for(i = 0; i < 86; i++) // lines
		{
			switch(bpp)
			{
				case 16:
					if(i < 56)
					{
						r = (unsigned short)((63 - i) >> 1) & 0x1F;
						if(i < 28)
							g++;
						else
							g--;
						b = (unsigned short)((i + 8) >> 1) & 0x1F;
						color = (r << 11) + (g << 6) + b;
					}
					else
						color = 0;
					ptr16 = (unsigned short *)base_addr;
					break;
				case 32:
					if(i < 56)
					{
						r2 = (unsigned long)(63 - i) & 0x3F;
						if(i < 28)
							g2++;
						else
							g2--;
						b2 = (unsigned long)(i + 8) & 0x3F;
						if((buf_tex != NULL) && cnt)
						{
							color2 = ((r2 << 15) & 0xFF0000) + (g2 << 8) + ((b2 >> 1) & 0xFF);
							color2 |= 0xE0E0E0;
						}
						else
							color2 = (r2 << 18) + (g2 << 11) + (b2 << 2);
					}
					else
					{
						if((buf_tex != NULL) && cnt)
							color2 = 0xE0E0E0;
						else
							color2 = 0;
					}
					if(buf_tex != NULL)
						color2 |= 0xFF000000; /* alpha */
					ptr32 = (unsigned long *)base_addr;
					break;
				default:
					ptr8 = (unsigned char *)base_addr;
					break;
			}
			for(j = 0; j < 6; j++)
			{
				switch(bpp)
				{
					case 8:
						val = *logo_atari++;
						for(k = 0x8000; k; k >>= 1)
						{
							if(val & k)
								*ptr8++ = 0xFF;
							else
								*ptr8++ = 0; 
						}		
						break; 
					case 16:
						val = *logo_atari++;
						for(k = 0x8000; k ; k >>= 1)
						{
							if(val & k)
								*ptr16++ = color;
							else
								*ptr16++ = 0xFFFF;
						}					
						break;
					case 32:
						val = *logo_atari++;
						for(k = 0x8000; k; k >>= 1)
						{
							if(val & k)
								*ptr32++ = color2;
							else
								*ptr32++ = 0xFFFFFF;
						}					
						break;
			  }
			}
			base_addr += incr;
		}
#ifndef TEST_NOPCI
		if(buf_tex != NULL)
		{
			if(cnt)
				display_composite_texture(3, buf_tex, 0, 0, WIDTH_LOGO, HEIGHT_LOGO, 0, 0, info->var.xres_virtual, info->var.yres_virtual);
			else
				display_composite_texture(1, buf_tex, 0, 0, WIDTH_LOGO, HEIGHT_LOGO, 0, 0, WIDTH_LOGO, HEIGHT_LOGO);
		}
#endif
	}
#ifndef TEST_NOPCI
	if(buf_tex != NULL)
		Mfree(buf_tex);
#endif
}

void display_ati_logo(void)
{
#ifdef ATI_LOGO
#define WIDTH_ATI_LOGO 96
#define HEIGHT_ATI_LOGO 62
	static unsigned short logo[] =
	{
		0x01FF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,
		0x01FF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF, 
		0x01FF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,
		0x01FF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,
		0x01FF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,
		0x01FF,0xFFFF,0xFFFF,0x8000,0x0000,0x007F,
		0x01FF,0xFFFF,0xFFFE,0x0000,0x0000,0x003F,
		0x01FF,0xFFFF,0xFFFC,0x0000,0x0000,0x1F1F,
		0x01FF,0xFFFF,0xFFF0,0x0000,0x0000,0x3F8F,
		0x01FF,0xFFFF,0xFFF0,0x0000,0x0000,0x7FC7,
		0x01FF,0xFFFF,0xFFC0,0x0000,0x0000,0x7FE7,
		0x01FF,0xFFFF,0xFF80,0x0000,0x0000,0xFFE7,
		0x01FF,0xFFFF,0xFF00,0x0000,0x0000,0xFFE7,
		0x01FF,0xFFFF,0xFE00,0x0000,0x0000,0xFFE7,
		0x01FF,0xFFFF,0xFC00,0x0000,0x0000,0x7FC7,
		0x01FF,0xFFFF,0xF800,0x0000,0x0000,0x7FC7,
		0x01FF,0xFFFF,0xF000,0x0000,0x0000,0x3F8F,
		0x01FF,0xFFFF,0xE000,0x0000,0x0000,0x0E1F,
		0x01FF,0xFFFF,0xC000,0x0000,0x0000,0x003F,
		0x01FF,0xFFFF,0x8000,0x0000,0x0000,0x00FF,
		0x01FF,0xFFFF,0x0000,0x0700,0x00FF,0xFFFF,
		0x01FF,0xFFFE,0x0000,0x0F00,0x01FF,0xFFFF,
		0x01FF,0xFFFC,0x0000,0x1F00,0x01FF,0xC07F,
		0x01FF,0xFFF8,0x0000,0x3F80,0x01FF,0x003F,
		0x01FF,0xFFF0,0x0000,0x7F80,0x01FF,0x001F,
		0x01FF,0xFFE0,0x0000,0xFF80,0x01FE,0x000F,
		0x01FF,0xFFC0,0x0001,0xFF80,0x01FE,0x000F,
		0x01FF,0xFF80,0x0003,0xFF80,0x01FC,0x000F,
		0x01FF,0xFF00,0x0007,0xFF80,0x01FC,0x000F,
		0x01FF,0xFE00,0x000F,0xFF80,0x01FC,0x000F,
		0x01FF,0xFC00,0x001C,0x3F80,0x01FC,0x000F,
		0x01FF,0xF800,0x0030,0x0F80,0x01FC,0x000F,
		0x01FF,0xF000,0x0070,0x0780,0x01FC,0x000F,
		0x01FF,0xE000,0x00E0,0x0380,0x01FC,0x000F,
		0x01FF,0xC000,0x01E0,0x0380,0x01FC,0x000F,
		0x01FF,0x8000,0x03E0,0x0380,0x01FC,0x000F,
		0x01FF,0x0000,0x07E0,0x0380,0x01FC,0x000F,
		0x01FE,0x0000,0x0FE0,0x0380,0x01FC,0x000F,
		0x01FC,0x0000,0x1FE0,0x0380,0x01FC,0x000F,
		0x01F8,0x0000,0x3FE0,0x0780,0x01FC,0x000F,
		0x01F8,0x0000,0x7FF0,0x0780,0x01FC,0x000F,
		0x01F0,0x0000,0xFFFC,0x1F80,0x01FC,0x000F,
		0x01F0,0x0001,0xFFFF,0xFF80,0x01FC,0x000F,
		0x01F0,0x0003,0xFFFF,0xFF80,0x01FC,0x000F,
		0x01E0,0x0007,0xFFFF,0xFF80,0x01FC,0x000F,
		0x01E0,0x000F,0xFFFF,0xFF80,0x01FC,0x000F,
		0x01F0,0x001F,0xFFFF,0xFF80,0x01FE,0x000F,
		0x01F0,0x003F,0xFFFF,0xFF80,0x03FE,0x000F,
		0x01F8,0x007F,0xFFFF,0xFFC0,0x03FE,0x000F,
		0x01F8,0x00FF,0xFFFF,0xFFC0,0x07FF,0x001F, 
		0x01FC,0x01FF,0xFFFF,0xFFE0,0x0FFF,0x803F,
		0x01FF,0x03FF,0xFFFF,0xFFF8,0x3FFF,0xE0FF,
		0x01FF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,
		0x01FF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,
		0x01FF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,
		0x01FF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,
		0x01FF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,
		0x01FF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,
		0x01FF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,
		0x01FF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF, 
		0x01FF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,
		0x01FF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF };
	long dst_y = 0, w = WIDTH_ATI_LOGO - 8, h = HEIGHT_ATI_LOGO, src_wrap = WIDTH_ATI_LOGO / 8;
	struct fb_info *info = rinfo_fvdi->info;
	long foreground, background;
	long dst_x = (long)info->var.xres - w;
	switch(info->var.bits_per_pixel)
	{
		case 8: foreground = 1; background = 7; break; /* red & grey */
		case 16: foreground = 0xF800; background = 0xB596; break;
		default: foreground = 0xFF0000; background = 0xB0B0B0; break;
	}
	display_mono_block(((char *)logo)+1, dst_x, dst_y, w, h, foreground, background, src_wrap);
#endif
}

void init_screen_info(SCREENINFO *si, long modecode)
{
	char buf[16];
	long flags = 0;
	struct fb_info *info;
	info = rinfo_fvdi->info;
	switch(modecode & NUMCOLS)
	{
		case BPS32:
			si->scrPlanes = 32;
			si->scrColors = 16777216;
			si->redBits = 0xFF0000;                 /* mask of red bits */
			si->greenBits = 0xFF00;                 /* mask of green bits */
			si->blueBits = 0xFF;                    /* mask of blue bits */
			si->unusedBits = 0xFF000000;            /* mask of unused bits */
			break;
		case BPS16:
			si->scrPlanes = 16;
			si->scrColors = 65536;
			si->redBits = 0xF800;                    /* mask of red bits */
			si->greenBits = 0x3E0;                   /* mask of green bits */
			si->blueBits = 0x1F;                     /* mask of blue bits */
			si->unusedBits = 0;                      /* mask of unused bits */
			break;
		case BPS8:
			si->scrPlanes = 8;
			si->scrColors = 256;
			si->redBits = si->greenBits = si->blueBits = 255;
			si->unusedBits = 0;
			break;
		default:
			si->scrFlags = 0;
			return;
	}
	si->alphaBits = si->genlockBits = 0;
	if(!(modecode & DEVID)) /* modecode normal */
	{
		switch(modecode & (VERTFLAG2|VESA_768|VESA_600|HORFLAG2|HORFLAG|VERTFLAG|STMODES|VGA|COL80))
		{
			case (VERTFLAG+VGA):                      /* 320 * 240 */
			case 0:
				si->scrWidth = 320;
				si->scrHeight = 240;
				break;
			case (VGA+COL80):                         /* 640 * 480 */
			case (VERTFLAG+COL80):
				si->scrWidth = 640;
				si->scrHeight = 480;
				break;
			case (VESA_600+HORFLAG2+VGA+COL80):       /* 800 * 600 */
				si->scrWidth = 800;
				si->scrHeight = 600;
				break;
			case (VESA_768+HORFLAG2+VGA+COL80):       /* 1024 * 768 */
				si->scrWidth = 1024;
				si->scrHeight = 768;
				break;
			case (VERTFLAG2+HORFLAG+VGA+COL80):       /* 1280 * 960 */
				si->scrWidth = 1280;
				si->scrHeight = 960;
				break;
			case (VERTFLAG2+VESA_600+HORFLAG2+HORFLAG+VGA+COL80): /* 1600 * 1200 */
				si->scrWidth = 1600;
				si->scrHeight = 1200;
				break;
			default:
				si->scrFlags = 0;
				return;
		}
		if(modecode & OVERSCAN)
		{
			if(modecode & PAL)
				si->refresh=85;
			else
				si->refresh=70;
		}
		else
		{
			if(modecode & PAL)
				si->refresh = 60;
			else
				si->refresh = 56;
		}
		si->pixclock = 0;
	}
	else /* bits 11-3 used for devID */
	{
		const struct fb_videomode *db;
		long devID = GET_DEVID(modecode);
		if(devID < 34)
			db = &vesa_modes[devID];		
		else
		{
			devID -= 34;
			if(devID < total_modedb)
				db = &modedb[devID];
			else
			{
      	devID -= total_modedb;
      	if(devID < rinfo_fvdi->mon1_dbsize)
					db = &rinfo_fvdi->mon1_modedb[devID];
      	else
				{
					si->scrFlags=0;
					return;
				}
			}
		}
		si->scrWidth = (long)db->xres;
		si->scrHeight = (long)db->yres;
    si->refresh = (long)db->refresh;
		si->pixclock = (long)db->pixclock;
		flags = (long)db->flag;
	}
	if(modecode & VIRTUAL_SCREEN)
	{
		si->virtWidth = si->scrWidth*2;
		if(si->virtWidth > 2048)
			si->virtWidth = 2048;
		si->virtHeight = si->scrHeight*2;
		if(si->virtHeight > 2048)
			si->virtHeight = 2048;
	}
	else
	{
		si->virtWidth = si->scrWidth;
		si->virtHeight = si->scrHeight;
	}
	ltoa(buf, si->scrWidth, 10); 
	strcpy(si->name, buf);
	strcat(si->name, "x");
	ltoa(buf, si->scrHeight, 10); 
	strcat(si->name, buf);
	strcat(si->name, "-");
	ltoa(buf, si->scrPlanes, 10); 
	strcat(si->name, buf);
	strcat(si->name, "@");
	ltoa(buf, si->refresh, 10); 
	strcat(si->name, buf);
	strcat(si->name, "Hz");
	if(modecode & VIRTUAL_SCREEN)
		strcat(si->name, " x4");
	else
		strcat(si->name, "   ");
	buf[0] = ' ';
	buf[1] = buf[2] ='\0';
	if(flags & FB_MODE_IS_VESA)
		buf[1] = 'V';
	if(flags & FB_MODE_IS_CALCULATED)
		buf[1] = 'C';
	if(flags & FB_MODE_IS_STANDARD)
		buf[1] = 'S';
	if(flags & FB_MODE_IS_DETAILED)
		buf[1] = 'D';
	if(flags & FB_MODE_IS_FIRST)
		buf[1] = '*';
	if(buf[1])
		strcat(si->name, buf);
	si->frameadr = (long)physbase();
	si->lineWrap = si->virtWidth * (si->scrPlanes / 8);
	si->planeWarp = 0;
	si->scrFormat = PACKEDPIX_PLANES;
	if(si->scrPlanes <= 8)
		si->scrClut = HARD_CLUT;
	else
		si->scrClut = SOFT_CLUT;
	si->bitFlags = STANDARD_BITS;					
	si->max_x = si->max_y = 8192; /* max. possible heigth/width ??? */
	si->maxmem = si->max_x * si->max_y * (si->scrPlanes / 8);
	si->pagemem = vgetsize(modecode);
	if(!si->devID)
	{
		si->refresh = info->var.refresh;
		si->pixclock = info->var.pixclock;
		si->devID = modecode;
	}
	si->scrFlags = SCRINFO_OK;
}

#else /* TEST_NOPCI */

long clear_screen(long bg_color, long x, long y, long w, long h)
{
	if(bg_color);
  if(x);
  if(y);
  if(w);
  if(h);
  return(0);
}

long move_screen(long src_x, long src_y, long dst_x, long dst_y, long w, long h)
{
	if(src_x);
	if(src_y);
	if(dst_x);
	if(dst_y);
	if(w);
	if(h);
	return(0);
}

long print_screen(char *car, long x, long y, long w, long h, long fg_color, long bg_color)
{
	if(car);
	if(x);
	if(y);
	if(h);
	if(fg_color);
	if(bg_color);
	return(0);
}

#endif /* TEST_NOPCI */

unsigned long physbase(void)
{
	struct fb_info *info;
	info=rinfo_fvdi->info;
	return((unsigned long)info->screen_base + rinfo_fvdi->fb_offset);
}

void init_screen(void)
{
	Bconout(2,27);
	Bconout(2,'b');
	Bconout(2,0x3F); /* black characters */
	Bconout(2,27);
	Bconout(2,'c');
	Bconout(2,0x30); /* white background */
	Bconout(2,27);
	Bconout(2,'E');  /* clear screen */
	Bconout(2,27);
	Bconout(2,'f');  /* no cursor */
}

void init_resolution(long modecode)
{
	switch(modecode & NUMCOLS)
	{
		case BPS32: resolution.bpp = 32; break;
		case BPS16: resolution.bpp = 16; break;
		default: resolution.bpp = 8; break;
	}
#ifndef TEST_NOPCI
	if(!(modecode & DEVID)) /* modecode normal */
#endif
	{
		if(modecode & OVERSCAN)
		{
			if(modecode & PAL)
				resolution.freq = 85;
			else
				resolution.freq = 70;
		}
		else
		{
			if(modecode & PAL)
				resolution.freq = 60;
			else
				resolution.freq = 56;
		}
		resolution.vesa = 0;
		switch(modecode & (VERTFLAG2|VESA_768|VESA_600|HORFLAG2|HORFLAG|VERTFLAG|STMODES|VGA|COL80))
		{
			case (VERTFLAG+VGA):                      /* 320 * 240 */
			case 0:
				resolution.width = 320;
				resolution.height = 240;
				break;
			case (VGA+COL80):                         /* 640 * 480 */
			case (VERTFLAG+COL80):
				resolution.width = 640;
				resolution.height = 480;
				break;
#ifndef TEST_NOPCI
			case (VESA_600+HORFLAG2+VGA+COL80):       /* 800 * 600 */
				resolution.width = 800;
				resolution.height = 600;
				break;
			case (VESA_768+HORFLAG2+VGA+COL80):       /* 1024 * 768 */
				resolution.width = 1024;
				resolution.height = 768;
				break;
			case (VERTFLAG2+HORFLAG+VGA+COL80):       /* 1280 * 960 */
				resolution.width = 1280;
				resolution.height = 960;
				resolution.vesa = 1;
				break;
			case (VERTFLAG2+VESA_600+HORFLAG2+HORFLAG+VGA+COL80): /* 1600 * 1200 */
				resolution.width = 1600;
				resolution.height = 1200;
				break;
#endif
			default: 
				init_resolution((long)((unsigned long)Modecode));
			 	break;
		}
	}
#ifndef TEST_NOPCI
	else /* bits 11-3 used for devID */
	{
		const struct fb_videomode *db;
		long devID = GET_DEVID(modecode);
		if(devID < 34)
		{
			db = &vesa_modes[devID];
			resolution.vesa = 1;
		}
		else
		{
			devID -= 34;
			resolution.vesa = 0;
			if(devID < total_modedb)
				db = &modedb[devID];
			else
			{
      	devID -= total_modedb;
      	if(devID < rinfo_fvdi->mon1_dbsize)
					db = &rinfo_fvdi->mon1_modedb[devID];
      	else
				{
					init_resolution((long)((unsigned long)Modecode));
					return;
				}
			}
		}
		resolution.width = (short)db->xres;
		resolution.height = (short)db->yres;
		resolution.freq = (short)db->refresh;
	}
#endif /* TEST_NOPCI */
}

short vsetscreen(long logaddr, long physaddr, long rez, long modecode, long init_vdi)
{
#ifndef TEST_NOPCI
	static unsigned short tab_16_col_ntc[16] = {
		0xFFDF,0xF800,0x07C0,0xFFC0,0x001F,0xF81F,0x07DF,0xB596,
		0x8410,0xA000,0x0500,0xA500,0x0014,0xA014,0x0514,0x0000 };
	static unsigned long tab_16_col_tc[16] = {
		0xFFFFFF,0xFF0000,0x00FF00,0xFFFF00,0x0000FF,0xFF00FF,0x00FFFF,0xB0B0B0,
		0x808080,0x8F0000,0x008F00,0x8F8F00,0x00008F,0x8F008F,0x008F8F,0x000000 };
	long y, color = 0, test = 0;
#endif /* TEST_NOPCI */
	struct fb_info *info;
	struct radeonfb_info *rinfo;
	struct fb_var_screeninfo var;
	info = rinfo_fvdi->info;
	rinfo = rinfo_fvdi;
	switch((short)rez)
	{
#ifndef TEST_NOPCI
		case 0x564E: /* 'VN' (Vsetscreen New) */
		case 0x4D49:	/* MI_MAGIC */
			switch((short)modecode)
			{
				case CMD_GETMODE:
					*((long *)physaddr) = (long)((unsigned long)Modecode);
					return(0);
				case CMD_SETMODE:
					modecode = physaddr;
					rez = 3;
					logaddr = physaddr = 0;
					if(((modecode & NUMCOLS) != BPS8)
					 && ((modecode & NUMCOLS) != BPS16)
					 && ((modecode & NUMCOLS) != BPS32))
						return(0);
					init_resolution(modecode);
					Modecode = (short)modecode;
					break;
				case CMD_GETINFO:
					{
						SCREENINFO *si = (SCREENINFO *)physaddr;
						if(si->devID)
							modecode = si->devID;
						else
							modecode = (long)((unsigned long)Modecode);
						init_screen_info(si, modecode);
					}
					return(0);
				case CMD_ALLOCPAGE:
					{
						long addr, addr_aligned;
						long wrap = info->var.xres_virtual * (info->var.bits_per_pixel >> 3);
						modecode = physaddr;
						if(second_screen)
						{
							if(logaddr != -1)
								*((long *)logaddr) = second_screen_aligned;
							return(0);
						}
						addr_aligned = addr = radeon_offscreen_alloc(rinfo_fvdi,vgetsize(modecode)+wrap);
						if(addr)
						{
							addr_aligned = addr - (long)info->screen_base;
							addr_aligned += (wrap-1);
							addr_aligned /= wrap;
							addr_aligned *= wrap;
							addr_aligned += (long)info->screen_base;
							if(logaddr != -1)
								*((long *)logaddr) = addr_aligned;
							if(!second_screen)
							{
								second_screen = addr;
								second_screen_aligned = addr_aligned;
							}
						}
						else
						{
							if(logaddr != -1)
								*((long *)logaddr) = 0;
						}
					}
					return(0);
				case CMD_FREEPAGE:
					if((logaddr == -1) || (logaddr == second_screen_aligned))
						logaddr = second_screen;
					else
						logaddr = 0;
					if(logaddr)
					{
						radeon_offscreen_free(rinfo_fvdi, logaddr);
						if(logaddr == second_screen_aligned)
						{
							if(second_screen_aligned == (long)physbase())
							{
								logaddr = physaddr = (long)info->screen_base;
								rez = -1; /* switch back to the first if second page active */
								init_vdi = 0;
								second_screen = second_screen_aligned = 0;
								break;
							}								
							else				
								second_screen = second_screen_aligned = 0;							
						}
					}
					return(0);
				case CMD_FLIPPAGE:
					if(!second_screen)
						return(0);
					if(second_screen_aligned == (long)physbase())
						logaddr = physaddr = (long)info->screen_base;
					else
						logaddr = physaddr = second_screen_aligned;
					rez = -1;
					init_vdi = 0;
					break;
				case CMD_ALLOCMEM:
					{
						SCRMEMBLK *blk = (SCRMEMBLK *)physaddr;
						if(blk->blk_y)
							blk->blk_h=blk->blk_y;
						if(blk->blk_h)
						{	
							int bpp = info->var.bits_per_pixel >> 3;
							blk->blk_len = (long)(info->var.xres_virtual * bpp) * blk->blk_h;
							blk->blk_start = radeon_offscreen_alloc(rinfo_fvdi, blk->blk_len);
							if(blk->blk_start)
								blk->blk_status = BLK_OK;
							else
								blk->blk_status = BLK_ERR;
							blk->blk_w = (long)info->var.xres_virtual;
							blk->blk_wrap = blk->blk_w * (long)bpp;
							blk->blk_x = (blk->blk_start % (info->var.xres_virtual * bpp)) / bpp;
							blk->blk_y = blk->blk_start / (info->var.xres_virtual * bpp);
						}
					}
					return(0);
				case CMD_FREEMEM:
					{
						SCRMEMBLK *blk	= (SCRMEMBLK *)physaddr;
						radeon_offscreen_free(rinfo_fvdi,blk->blk_start);
						blk->blk_status = BLK_CLEARED;
					}
					return(0);
				case CMD_SETADR:
					rez = -1;
					break;
				case CMD_ENUMMODES:
					{
						long (*enumfunc)(SCREENINFO *inf, long flag) = (void *)physaddr;
						SCREENINFO si;
						long mode;
						si.size = sizeof(SCREENINFO);
						for(mode = 0; mode < 65536; mode++)
						{
							if(!(mode & DEVID)) /* modecode normal */
							{
								if(mode & STMODES)
									continue;
								mode |= VGA;
								mode &= (VIRTUAL_SCREEN|VERTFLAG2|VESA_768|VESA_600|HORFLAG2|HORFLAG|VERTFLAG|OVERSCAN|PAL|VGA|COL80|NUMCOLS);
								if(mode == (long)(Modecode & (VIRTUAL_SCREEN|VERTFLAG2|VESA_768|VESA_600|HORFLAG2|HORFLAG|VERTFLAG|OVERSCAN|PAL|VGA|COL80|NUMCOLS)))
									si.devID = 0;
								else
									si.devID = mode;
							}
							else /* bits 11-3 used for devID */
							{
								if(mode == ((long)Modecode & 0xFFFF))
									si.devID = 0;
								else
									si.devID = mode;
							}							
						  init_screen_info(&si, mode);
						  si.devID = mode;
						  if(si.scrFlags == SCRINFO_OK)
						  {
								if(!(*enumfunc)(&si, 1 /* ??? */))
									break;
							}
						}
					}
					return(0);
				case CMD_TESTMODE:
					debug = 0;
					modecode = physaddr;
					logaddr = physaddr = 0;
					rez = 3;
					init_vdi = 0;
					test = 1;
					if(((modecode & NUMCOLS) != BPS8)
					 && ((modecode & NUMCOLS) != BPS16)
					 && ((modecode & NUMCOLS) != BPS32))
						return(0);
					init_resolution(modecode);
					Modecode = (short)modecode;			
					break;
				case CMD_COPYPAGE:
					if(second_screen)
					{
						long src_x, src_y, dst_x, dst_y;
						int bpp = info->var.bits_per_pixel >> 3;
						long offset = (long)second_screen_aligned - (long)info->screen_base;
						if(physaddr & 1)
						{
					    src_x = (offset % (info->var.xres_virtual * bpp)) / bpp;
							src_y = offset / (info->var.xres_virtual * bpp);
							dst_x = dst_y = 0;
						}
						else
						{
							src_x = src_y = 0;
					    dst_x = (offset % (info->var.xres_virtual * bpp)) / bpp;
							dst_y = offset / (info->var.xres_virtual * bpp);
						}
						move_screen(src_x, src_y, dst_x, dst_y, info->var.xres_virtual, info->var.yres_virtual);
					}
					return(0);
				case -1:
				default: return(0);
			}
			break;
#endif /* TEST_NOPCI */
/*
		case 0:	
			resolution.width = 320;
			resolution.height = 200;
			resolution.bpp = 8;
			resolution.freq = 70;
			if(Modecode & VGA)
				modecode = VERTFLAG|STMODES|VGA|BPS4;
			else
				modecode = STMODES|BPS4;
			break;
*/
		case 3:
			if(((modecode & NUMCOLS) != BPS8)
			 && ((modecode & NUMCOLS) != BPS16)
			 && ((modecode & NUMCOLS) != BPS32))
				return(Modecode);
			init_resolution(modecode);
			Modecode = (short)modecode;
			break;
		default:
			return(Modecode);
	}
	if(modecode & VIRTUAL_SCREEN)
		virtual=1;
	else
		virtual=0;
	if(!logaddr && !physaddr && (rez >= 0))
	{
#ifdef TEST_NOPCI
		if(&var);
		if(Modecode & COL80)
		{
			*((char **)_v_bas_ad) = info->screen_base = (char *)Screalloc(640*480*2);
			init_videl_640_480_65K((unsigned short *)info->screen_base);
		}
		else
		{
			*((char **)_v_bas_ad) = info->screen_base = (char *)Screalloc(320*240*2);
			init_videl_320_240_65K((unsigned short *)info->screen_base);		
		}
		info->var.xres = info->var.xres_virtual = resolution.width;
		info->var.yres = info->var.yres_virtual = resolution.height;
		rinfo_fvdi->bpp = info->var.bits_per_pixel = resolution.bpp;
		if(init_vdi)
		{
			init_var_linea();
			init_screen();
		}
#else /* !TEST_NOPCI */
		resolution.used = 1;
		if(init_vdi)
		{
			DPRINTVALHEX("Setscreen mode ", (long)Modecode & 0xFFFF);
			DPRINTVAL(" ", resolution.width);
			DPRINTVAL("x", resolution.height);
			DPRINTVAL("-", resolution.bpp);
			DPRINTVAL("@", resolution.freq);
			DPRINT("\r\n");
		}
		radeon_check_modes(rinfo_fvdi, &resolution);
		memcpy(&var, &info->var, sizeof(struct fb_var_screeninfo));
		if(virtual)
		{
			var.xres_virtual = var.xres * 2;
			var.yres_virtual = var.yres * 2;
			if(var.xres_virtual > 2048)
				var.xres_virtual = 2048;
			if(var.yres_virtual > 2048)
				var.yres_virtual = 2048;
		}
		var.activate = (FB_ACTIVATE_FORCE|FB_ACTIVATE_NOW);
		rinfo_fvdi->asleep = 0;
		if(!fb_set_var(info, &var))
		{
			int i, red = 0, green = 0, blue = 0;
			*((char **)_v_bas_ad) = info->screen_base;
			switch(rinfo_fvdi->bpp)
			{
				case 16:
					for(i = 0; i < 64; i++)
					{
						if(red > 65535)
							red = 65535;
						if(green > 65535)
							green = 65535;
						if(blue > 65535)
							blue = 65535;
						radeonfb_setcolreg((unsigned)i,red,green,blue,0,info);
						green += 1024;   /* 6 bits */
						red += 2048;     /* 5 bits */
						blue += 2048;    /* 5 bits */
					}
					break;
				case 32:
					for(i = 0; i < 256; i++)
					{
						if(red > 65535)
							red = 65535;
						if(green > 65535)
							green = 65535;
						if(blue > 65535)
							blue = 65535;
						radeonfb_setcolreg((unsigned)i,red,green,blue,0,info);
						green += 256;   /* 8 bits */
						red += 256;     /* 8 bits */
						blue += 256;    /* 8 bits */
					}
					break;
				default:
					vsetrgb(0,256,(long *)0xE1106A); /* default TOS 4.04 palette */
					break;
			}
			if(init_vdi)
			{
				radeon_offscreen_init(rinfo_fvdi);
				init_var_linea();
				init_screen();
			}
			else if(test)
			{
				for(y = 0; y < info->var.yres_virtual; y += 16)
				{
					switch(rinfo_fvdi->bpp)
					{
						case 16: color = (unsigned long)tab_16_col_ntc[(y >> 4) & 15]; break;
						case 32: color = tab_16_col_tc[(y >> 4) & 15]; break;
						default: color = (unsigned long)((y >> 4) & 15); break;
					}
					clear_screen(color, 0, y, info->var.xres_virtual, info->var.yres_virtual-y >= 16 ? 16 : info->var.yres_virtual - y);
				}				
			}
			Modecode = (short)modecode;
		}
#endif /* TEST_NOPCI */
	}
	else
	{
		if(logaddr && (logaddr != -1))
			*((char **)_v_bas_ad) = (char *)logaddr;
		if(physaddr && (physaddr != -1))
		{
#ifndef TEST_NOPCI
			int bpp = info->var.bits_per_pixel >> 3;
			physaddr -= (long)info->screen_base;
			if(physaddr < 0
			 || (physaddr >= (info->var.xres_virtual * 8192 * bpp)))
				return(Modecode);
			memcpy(&var, &info->var, sizeof(struct fb_var_screeninfo));			
			var.xoffset = (physaddr % (info->var.xres_virtual * bpp)) / bpp;
			var.yoffset = physaddr / (info->var.xres_virtual * bpp);
			if(var.yoffset < 8192)
			{
#ifdef SEMAPHORE
				xSemaphoreTakeRADEON();
#endif
				fb_pan_display(info, &var);
#ifdef SEMAPHORE
				xSemaphoreGiveRADEON();
#endif
			}
#endif /* TEST_NOPCI */
		}
	}
	return(Modecode);
}

short vsetmode(long modecode)
{
	if(modecode == -1)
		return(Modecode);
	vsetscreen(0, 0 , 3, modecode & 0xFFFF, 0);
	return(Modecode);
}

short montype(void)
{
	switch(rinfo_fvdi->mon1_type)
	{
		case MT_STV: return(1); /* S-Video out */
		case MT_CRT: return(2); /* VGA */
		case MT_CTV: return(3); /* TV / composite */
		case MT_LCD: return(4);	/* LCD */
		case MT_DFP: return(5); /* DVI */
		default: return(2);     /* VGA */
	}
}

long vgetsize(long modecode)
{
	long size = 0;
	struct fb_info *info;
	info = rinfo_fvdi->info;
	if((short)modecode == Modecode)
		return(info->var.xres_virtual * info->var.yres_virtual * (info->var.bits_per_pixel >> 3));
#ifndef TEST_NOPCI
	if(!(modecode & DEVID)) /* modecode normal */
#endif
	{
		if(modecode & STMODES)
		{
			switch(modecode & NUMCOLS)
			{
				case BPS4: return(320 * 200);
				default: return(640 * 400);
			}
		}	
		switch(modecode & (VESA_768|VESA_600|HORFLAG2|HORFLAG|VERTFLAG|OVERSCAN|VGA|COL80))
		{
			case (VERTFLAG+VGA):                      /* 320 * 240 */
			case 0:
				size = 320 * 240;
				break;
			case (VGA+COL80):                         /* 640 * 480 */
			case (VERTFLAG+COL80):
				size = 640 * 480;
				break;
#ifndef TEST_NOPCI
			case (VESA_600+HORFLAG2+VGA+COL80):       /* 800 * 600 */
				size = 800 * 600;
				break;
			case (VESA_768+HORFLAG2+VGA+COL80):       /* 1024 * 768 */
				size=1024 * 768;
				break;
			case (VERTFLAG2+HORFLAG+VGA+COL80):       /* 1280 x 960 */
				size = 1280 * 960;
				break;
			case (VERTFLAG2+VESA_600+HORFLAG2+HORFLAG+VGA+COL80): /* 1600 * 1200 */
			default:
				size = 1600 * 1200;
				break;
#else
			default:
				size = 640 * 480;
				break;
#endif
		}
	}
#ifndef TEST_NOPCI
	else /* bits 11-3 used for devID */
	{
		const struct fb_videomode *db;
		long devID = GET_DEVID(modecode);
		if(devID < 34)
			db = &vesa_modes[devID];		
		else
		{
			devID -= 34;
			if(devID < total_modedb)
				db = &modedb[devID];
			else
			{
      	devID -= total_modedb;
      	if(devID < rinfo_fvdi->mon1_dbsize)
					db = &rinfo_fvdi->mon1_modedb[devID];
      	else
					return(0);
			}
		}
		size = db->xres * db->yres;
	}
#endif /* TEST_NOPCI */
	switch(modecode & NUMCOLS)
	{
		case BPS32: size <<= 2; break;
		case BPS16: size <<= 1; break;
		default: break;
	}
	if(modecode & VIRTUAL_SCREEN)
		size <<= 2;
	return(size);
}

short validmode(long modecode)
{
#ifndef TEST_NOPCI
	if((unsigned short)modecode != 0xFFFF)
	{
		if(((modecode & NUMCOLS) < BPS8) || ((modecode & NUMCOLS) > BPS32))
		{
			modecode &= ~NUMCOLS;
			modecode |= BPS16;
		}
		if(!(modecode & DEVID)) /* modecode normal */
		{
			modecode |= VGA;
			if(modecode & STMODES)
			{
				modecode &= (VERTFLAG|VGA|COL80);
				modecode |= BPS16;
			}
			else if(fix_modecode < 0)
			{
				modecode &= (VERTFLAG|VGA|COL80|NUMCOLS);
				modecode |= ((long)Modecode & (VIRTUAL_SCREEN|VERTFLAG2|VESA_768|VESA_600|HORFLAG2|HORFLAG));
			}
		}
		else /* bits 11-3 used for devID */
		{
			if(fix_modecode < 0)
			{
			 	modecode &= NUMCOLS;
			 	modecode |= ((long)Modecode & ~NUMCOLS);
			}
			if(GET_DEVID(modecode) >= (34 + total_modedb + rinfo_fvdi->mon1_dbsize))
			{
				modecode &= NUMCOLS;
				modecode |= (VGA|COL80);
			}
		}
	}
	if(fix_modecode != 1)
		fix_modecode = -1;
#endif /* TEST_NOPCI */
	return((short)modecode);
}

long vmalloc(long mode, long value)
{
#ifndef TEST_NOPCI
	switch(mode)
	{
		case 0:
			if(value)
				return(radeon_offscreen_alloc(rinfo_fvdi,value));
			break;
		case 1:
			return(radeon_offscreen_free(rinfo_fvdi,value));
		case 2:
			if(value > 0)
				rinfo_fvdi = (struct radeonfb_info *)value; 
			radeon_offscreen_init(rinfo_fvdi);
			return(0);
			break;
	}
#endif
	return(-1);
}

long InitVideo(void)
{
#if 0 // #ifndef TEST_NOPCI
	RADEONInitVideo(rinfo_fvdi);
	Cconin();	
	RADEONPutVideo(rinfo_fvdi, 0, 0, 720, 576, 0, 0, 640, 512);
	Cconin();
	RADEONStopVideo(rinfo_fvdi, 1);	
	Cconin();
	RADEONShutdownVideo(rinfo_fvdi);
	Cconin();	
#endif
	return(0);
}

#ifdef NETWORK
#endif /* NETWORK */

