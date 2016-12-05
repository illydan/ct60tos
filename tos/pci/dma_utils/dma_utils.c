/*
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
 * along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include "config.h"
#include <mint/osbind.h>
#include "../radeon/radeonfb.h"

#include "dma_utils.h"

extern short use_dma; /* init.c */
extern struct radeonfb_info *rinfo_fvdi; /* fVDI */
extern char *Funcs_allocate_block(long size); /* fVDI */
extern void Funcs_free_block(void *address); /* fVDI */

#define DMAMODE0 0x100   /* DMA Channel 0 Mode                  */
#define DMAPADR0 0x104   /* DMA Channel 0 PCI Address           */
#define DMALADR0 0x108   /* DMA Channel 0 Local Address         */
#define DMASIZ0  0x10C   /* DMA Channel 0 Transfer Size (Bytes) */
#define DMADPR0  0x110   /* DMA Channel 0 Descriptor Pointer    */
#define DMASCR0  0x128   /* DMA Channel 0 Command/Status        */

#undef DMA_XBIOS

static unsigned long Descriptors;

int dma_transfer(char *src, char *dest, int size, int width, int src_incr, int dest_incr, int step)
{
	extern void	cpush_dc(void *base, long size);
	short dir;
	unsigned long direction;
	unsigned char mode;
#ifndef DMA_XBIOS
	unsigned char status;
#endif
	if(step);
	if(!use_dma || !size)
		return(-1);
#ifdef DMA_XBIOS
	if(dma_buffoper(-1) != 0)
		return(-1); /* busy */
#else /* direct PCI BIOS (by cookie) */
	if(tab_funcs_pci == NULL) /* table of functions */
		return(-1);
	status = Fast_read_config_byte(0, DMASCR0);
	if((status & 1) && !(status & 0x10)) /* enable & tranfert not complete */
		return(-1); /* busy */
#endif
	if(src >= (char *)rinfo_fvdi->fb_base)
		dir = 1; /* PCI to Local Bus */
	else if(dest >= (char *)rinfo_fvdi->fb_base)
		dir = 2; /* Local Bus To PCI */
	else
		return(-1);
  if(dir == 1)
  	src -= ((unsigned long)rinfo_fvdi->fb_base - rinfo_fvdi->fb_base_phys); /* PCI mapping local -> offset PCI */
	else
	{
		char *temp = src;
  	dest -= ((unsigned long)rinfo_fvdi->fb_base - rinfo_fvdi->fb_base_phys); /* PCI mapping local -> offset PCI */
  	src = dest;
  	dest = temp;
  }
	direction = (dir == 1) ? 0 : 8;
	if((width || src_incr || dest_incr) && (size > width)) /* line by line */
	{
#ifdef DMA_XBIOS
		if(tab_funcs_pci == NULL) /* table of functions */
			return(-1);
#endif
		Descriptors = (unsigned long)Funcs_allocate_block(((size / width) + 1) * 16); /* descriptor / line */
		if(Descriptors)
		{
			unsigned long *aligned_descriptors = (unsigned long *)((Descriptors + 15) & ~15); /* 16 bytes alignment */
			unsigned long *p = aligned_descriptors;
			if(dir == 2) /* Local Bus To PCI */
				cpush_dc(dest,size); /* flush data cache */
			/* load the 1st descriptor in the PLX registers */
			Write_config_longword(0, DMAPADR0, (unsigned long)src);
			Write_config_longword(0, DMALADR0, (unsigned long)dest);
			Write_config_longword(0, DMASIZ0, (unsigned long)width);
			Write_config_longword(0, DMADPR0, (unsigned long)p + direction);
			while(size > 0)
			{
				unsigned long next = (unsigned long)p + direction;
				*p++ = (unsigned long)src;   /* PCI address */
				*p++ = (unsigned long)dest;  /* local address */
				*p++ = (unsigned long)width; /* transfer size */
				*p++ = next;                 /* next descriptor pointer */
				src += src_incr;
				dest += dest_incr;
				size -= width;
			}		
			p[-1] |= 2; /* end of chain */ 
			cpush_dc(aligned_descriptors,(long)(p-aligned_descriptors)); /* flush data cache */
			mode = Fast_read_config_byte(0, DMAMODE0); 
			mode |= 0x200;                 /* scatter/gather mode */
			Write_config_longword(0, DMAMODE0, mode);
			Write_config_longword(0, DMASCR0, 3); /* start & enable */
		}
		else /* no memory block for descriptors */
			return(-1);
	}
	else /* full block */
	{
		if(dir == 2) /* Local Bus To PCI */
			cpush_dc(dest,size); /* flush data cache */
#ifdef DMA_XBIOS
		dma_setbuffer(src,dest,size);
		dma_buffoper(dir);
#else /* direct PCI BIOS (by cookie) */
		Write_config_longword(0, DMAPADR0, (unsigned long)src);  /* PCI Address */
		Write_config_longword(0, DMALADR0, (unsigned long)dest); /* Local Address */
		Write_config_longword(0, DMASIZ0, (unsigned long)width); /* Transfer Size (Bytes) */
		Write_config_longword(0, DMADPR0, (unsigned long)direction); /* Descriptor Pointer */
		mode = Fast_read_config_byte(0, DMAMODE0); 
		mode &= ~0x200;                       /* block mode */
		Write_config_longword(0, DMAMODE0, mode);
		Write_config_longword(0, DMASCR0, 3); /* start & enable */
#endif
	}
	return(0);
}

int dma_status(void)
{
	if(!use_dma)
		return(-1);
#ifdef DMA_XBIOS
	return(dma_buffoper(-1));
#else /* direct PCI BIOS (by cookie) */
	else
	{
		unsigned char status = Fast_read_config_byte(0, DMASCR0);
		if((status & 1) && !(status & 0x10)) /* enable & tranfert not complete */
			return(1); /* buzy */
	}
	return(0);
#endif
}

void wait_dma(void)
{
	if(use_dma)
		while(dma_status() > 0);
	if(Descriptors)
		Funcs_free_block((void *)Descriptors);
	Descriptors = 0;
}

