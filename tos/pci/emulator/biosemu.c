#include "../../radeon/radeonfb.h"
#include <mint/osbind.h>
#include <mint/sysvars.h>
#include <string.h>
#include <pcixbios.h>
#include <x86emu/x86emu.h>
// #include "vgatables.h"

#define USE_SDRAM

#define MEM_WB(where, what) wrb(where, what)
#define MEM_WW(where, what) wrw(where, what)
#define MEM_WL(where, what) wrl(where, what)

#define MEM_RB(where) rdb(where)
#define MEM_RW(where) rdw(where)
#define MEM_RL(where) rdl(where)

#define PCI_VGA_RAM_IMAGE_START 0xC0000
#define PCI_RAM_IMAGE_START     0xD0000
#define SYS_BIOS                0xF0000
#define SIZE_EMU               0x100000

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

struct rom_header
{
	u16	signature;
	u8 size;
	u8 init[3];
	u8 reserved[0x12];
	u16	data;
};

struct pci_data
{
	u32 signature;
	u16 vendor;
	u16 device;
	u16 reserved_1;
	u16 dlen;
	u8 drevision;
	u8 class_lo;
	u16 class_hi;
	u16 ilen;
	u16 irevision;
	u8 type;
	u8 indicator;
	u16	reserved_2;
};

struct radeonfb_info *rinfo_biosemu;
u32 config_address_reg;
u16 offset_port;

extern int pcibios_handler();
extern COOKIE *get_cookie(long id);

/* general software interrupt handler */
u32 getIntVect(int num)
{
	return MEM_RW(num << 2) + (MEM_RW((num << 2) + 2) << 4);
}

/* FixME: There is already a push_word() in the emulator */
void pushw(u16 val)
{
	X86_ESP -= 2;
	MEM_WW(((u32) X86_SS << 4) + X86_SP, val);
}

int run_bios_int(int num)
{
	u32 eflags;
	eflags = X86_EFLAGS;
	pushw(eflags);
	pushw(X86_CS);
	pushw(X86_IP);
	X86_CS = MEM_RW((num << 2) + 2);
	X86_IP = MEM_RW(num << 2);
	return 1;
}

u8 inb(u16 port)
{
	u8 val = 0;
	if((port >= offset_port) && (port <= offset_port+0xFF))
	{
#ifdef DEBUG_X86EMU_PCI
		DPRINTVALHEX("inb(", port);
#endif
#ifdef PCI_XBIOS
		val = fast_read_io_byte(rinfo_biosemu->handle,rinfo_biosemu->io_base_phys+(u32)port-(u32)offset_port);
#else
		val = Fast_read_io_byte(rinfo_biosemu->handle,rinfo_biosemu->io_base_phys+(u32)port-(u32)offset_port);
#endif
#ifdef DEBUG_X86EMU_PCI
		DPRINTVALHEX(") = ", val);
		DPRINT("\r\n");
#endif
	}
	return val;
}

u16 inw(u16 port)
{
	u16 val = 0;
	if((port >= offset_port) && (port <= offset_port+0xFF))
	{
#ifdef DEBUG_X86EMU_PCI
		DPRINTVALHEX("inw(", port);
#endif
#ifdef PCI_XBIOS
		val = fast_read_io_word(rinfo_biosemu->handle,rinfo_biosemu->io_base_phys+(u32)port-(u32)offset_port);
#else
		val = Fast_read_io_word(rinfo_biosemu->handle,rinfo_biosemu->io_base_phys+(u32)port-(u32)offset_port);
#endif
#ifdef DEBUG_X86EMU_PCI
		DPRINTVALHEX(") = ", val);
		DPRINT("\r\n");
#endif
	}
	return val;
}

u32 inl(u16 port)
{
	u32 val = 0;
	if((port >= offset_port) && (port <= offset_port+0xFF))
	{
#ifdef DEBUG_X86EMU_PCI
		DPRINTVALHEX("inl(", port);
#endif
#ifdef PCI_XBIOS
		val = fast_read_io_longword(rinfo_biosemu->handle, rinfo_biosemu->io_base_phys+(u32)port-(u32)offset_port);
#else
		val = Fast_read_io_longword(rinfo_biosemu->handle, rinfo_biosemu->io_base_phys+(u32)port-(u32)offset_port);
#endif
#ifdef DEBUG_X86EMU_PCI
		DPRINTVALHEX(") = ", val);
		DPRINT("\r\n");
#endif
	}
	else if(port == 0xCF8)
	{
		val = config_address_reg;
#ifdef DEBUG_X86EMU_PCI
		DPRINTVALHEX("inl(", port);
		DPRINTVALHEX(") = ", val);
		DPRINT("\r\n");
#endif
	}
	else if((port == 0xCFC) && ((config_address_reg & 0x80000000) !=0))
	{
		if((config_address_reg & 0xFC) == PCIBAR1)
			val = (u32)offset_port+1;
		else
		{
#ifdef DEBUG_X86EMU_PCI
			DPRINTVALHEX("inl(", port);
#endif
#ifdef PCI_XBIOS
			val = fast_read_config_longword(rinfo_biosemu->handle, config_address_reg & 0xFC);
#else
			val = Fast_read_config_longword(rinfo_biosemu->handle, config_address_reg & 0xFC);
#endif
#ifdef DEBUG_X86EMU_PCI
			DPRINTVALHEX(") = ", val);
			DPRINT("\r\n");
#endif
		}
	}
	return val;
}

void outb(u8 val, u16 port)
{
	if((port >= offset_port) && (port <= offset_port+0xFF))
	{
#ifdef DEBUG_X86EMU_PCI
		DPRINTVALHEX("outb(", port);
		DPRINTVALHEX(") = ", val);
		DPRINT("\r\n");
#endif
#ifdef PCI_XBIOS
		write_io_byte(rinfo_biosemu->handle,rinfo_biosemu->io_base_phys+(u32)port-(u32)offset_port,(u16)val);
#else
		Write_io_byte(rinfo_biosemu->handle,rinfo_biosemu->io_base_phys+(u32)port-(u32)offset_port,(u16)val);
#endif
	}
}

void outw(u16 val, u16 port)
{
	if((port >= offset_port) && (port <= offset_port+0xFF))
	{
#ifdef DEBUG_X86EMU_PCI
		DPRINTVALHEX("outw(", port);
		DPRINTVALHEX(") = ", val);
		DPRINT("\r\n");
#endif
#ifdef PCI_XBIOS
		write_io_byte(rinfo_biosemu->handle,rinfo_biosemu->io_base_phys+(u32)port-(u32)offset_port,(u16)val & 0xFF);
		port++;
		val>>=8;
		write_io_byte(rinfo_biosemu->handle,rinfo_biosemu->io_base_phys+(u32)port-(u32)offset_port,(u16)val & 0xFF);	
#else
		Write_io_byte(rinfo_biosemu->handle,rinfo_biosemu->io_base_phys+(u32)port-(u32)offset_port,(u16)val & 0xFF);
		port++;
		val>>=8;
		Write_io_byte(rinfo_biosemu->handle,rinfo_biosemu->io_base_phys+(u32)port-(u32)offset_port,(u16)val & 0xFF);	
#endif
	}
}

void outl(u32 val, u16 port)
{
	if((port >= offset_port) && (port <= offset_port+0xFF))
	{
#ifdef DEBUG_X86EMU_PCI
		DPRINTVALHEX("outl(", port);
		DPRINTVALHEX(") = ", val);
		DPRINT("\r\n");
#endif
#ifdef PCI_XBIOS
		write_io_longword(rinfo_biosemu->handle,rinfo_biosemu->io_base_phys+(u32)port-(u32)offset_port,val);
#else
		Write_io_longword(rinfo_biosemu->handle,rinfo_biosemu->io_base_phys+(u32)port-(u32)offset_port,val);
#endif
	}
	else if(port == 0xCF8)
	{
#ifdef DEBUG_X86EMU_PCI
		DPRINTVALHEX("outl(", port);
		DPRINTVALHEX(") = ", val);
		DPRINT("\r\n");
#endif
		config_address_reg = val;
	}
	else if((port == 0xCFC) && ((config_address_reg & 0x80000000) !=0))
	{
		if((config_address_reg & 0xFC) == PCIBAR1)
			offset_port = (u16)val & 0xFFFC;
		else
		{
#ifdef DEBUG_X86EMU_PCI
			DPRINTVALHEX("outl(", port);
			DPRINTVALHEX(") = ", val);
			DPRINT("\r\n");
#endif
#ifdef PCI_XBIOS
			write_config_longword(rinfo_biosemu->handle, config_address_reg & 0xFC, val);
#else
			Write_config_longword(rinfo_biosemu->handle, config_address_reg & 0xFC, val);
#endif
		}
	}
}

/* Interrupt multiplexer */

void do_int(int num)
{
	int ret = 0;
//	DPRINTVAL("int ", num);
//	DPRINTVALHEX(" vector at ", getIntVect(num));
//	DPRINT("\r\n");
	switch (num)
	{
#ifndef _PC
	case 0x10:
	case 0x42:
	case 0x6D:
		if (getIntVect(num) == 0x0000)
			DPRINT("un-inited int vector\r\n");
		if (getIntVect(num) == 0xFF065)
		{
			//ret = int42_handler();
			ret = 1;
		}
		break;
#endif
	case 0x15:
		//ret = int15_handler();
		ret = 1;
		break;
	case 0x16:
		//ret = int16_handler();
		ret = 0;
		break;
	case 0x1A:
		ret = pcibios_handler();
		ret = 1;
		break;
	case 0xe6:
		//ret = intE6_handler();
		ret = 0;
		break;
	default:
		break;
	}
	if(!ret)
		ret = run_bios_int(num);
}

static int setup_system_bios(void *base_addr)
{
	char *base = (char *) base_addr;
	int i;
	/*
	 * we trap the "industry standard entry points" to the BIOS
	 * and all other locations by filling them with "hlt"
	 * TODO: implement hlt-handler for these
	 */
//	for(i=0; i<0x10000; base[i++]=0xF4);
	for(i=0; i<SIZE_EMU; base[i++]=0xF4);
	/* set bios date */
	//strcpy(base + 0x0FFF5, "06/11/99");
	/* set up eisa ident string */
	//strcpy(base + 0x0FFD9, "PCI_ISA");
	/* write system model id for IBM-AT */
	//*((unsigned char *) (base + 0x0FFFE)) = 0xfc;
	return(1);
}

void run_bios(struct radeonfb_info *rinfo)
{
	long i, j;
	unsigned char *ptr;
	struct rom_header *rom_header;
	struct pci_data *rom_data;
	unsigned long rom_size=0;
	unsigned long image_size=0;
	unsigned long biosmem=0x01000000; /* when run_bios() is called, SDRAM is valid but not add to the system */
	unsigned long addr;
	unsigned short initialcs;
	unsigned short initialip;
	unsigned short devfn = (unsigned short)(rinfo->handle << 3); // dev->bus->secondary << 8 | dev->path.u.pci.devfn;
	X86EMU_intrFuncs intFuncs[256];

	if((rinfo->mmio_base == NULL) || (rinfo->io_base == NULL))
		return;
	rinfo_biosemu = rinfo;
	config_address_reg = 0;
	offset_port = 0x300;
	rom_header = (struct rom_header *)0;
	do
	{
		rom_header = (struct rom_header *)((unsigned long)rom_header + image_size); // get next image
		rom_data = (struct pci_data *)((unsigned long)rom_header + (unsigned long)BIOS_IN16((long)&rom_header->data));
		image_size = (unsigned long)BIOS_IN16((long)&rom_data->ilen) * 512;
	}
	while((BIOS_IN8((long)&rom_data->type) != 0) && (BIOS_IN8((long)&rom_data->indicator) != 0));  // make sure we got x86 version
	if(BIOS_IN8((long)&rom_data->type) != 0)
		return;
	rom_size = (unsigned long)BIOS_IN8((long)&rom_header->size) * 512;
	if(PCI_CLASS_DISPLAY_VGA == BIOS_IN16((long)&rom_data->class_hi))
	{
#ifndef USE_SDRAM
		biosmem = Mxalloc(SIZE_EMU, 0);
		if(biosmem == 0)
			return;
#endif
		memset((char *)biosmem, 0, SIZE_EMU);
		setup_system_bios((char *)biosmem);
		DPRINTVALHEX("Copying VGA ROM Image from ", (long)rinfo->bios_seg+(long)rom_header);
		DPRINTVALHEX(" to ", biosmem+PCI_VGA_RAM_IMAGE_START);
		DPRINTVALHEX(", ", rom_size);
		DPRINT(" bytes\r\n");
		{
			extern u32 swap_long(u32 val);
			long bytes_align = (long)rom_header & 3;
			ptr = (char *)biosmem;
			i = (long)rom_header;
			j = PCI_VGA_RAM_IMAGE_START;
			if(bytes_align)
				for(; i < 4 - bytes_align; ptr[j++] = BIOS_IN8(i++));
			for(; i < (long)rom_header+rom_size; *((unsigned long *)&ptr[j]) = swap_long(BIOS_IN32(i)), i+=4, j+=4);
		}
		addr = PCI_VGA_RAM_IMAGE_START;	
	}
	else
	{
#ifndef USE_SDRAM
		biosmem = Mxalloc(SIZE_EMU, 0);
		if(biosmem == 0)
			return;
#endif
		setup_system_bios((char *)biosmem);
		memset((char *)biosmem, 0, SIZE_EMU);
		DPRINTVALHEX("Copying non-VGA ROM Image from ", (long)rinfo->bios_seg+(long)rom_header);
		DPRINTVALHEX(" to ", biosmem+PCI_RAM_IMAGE_START);
		DPRINTVALHEX(", ", rom_size);
		DPRINT(" bytes\r\n");		
		ptr = (char *)biosmem;
		for(i = (long)rom_header, j = PCI_RAM_IMAGE_START; i < (long)rom_header+rom_size; ptr[j++] = BIOS_IN8(i++));
		addr = PCI_RAM_IMAGE_START;
	}
	initialcs = (addr & 0xF0000) >> 4;
	initialip = (addr + 3) & 0xFFFF;	
	X86EMU_setMemBase((void *)biosmem, SIZE_EMU);
	for(i = 0; i < 256; i++)
		intFuncs[i] = do_int;
	X86EMU_setupIntrFuncs(intFuncs);
	{
		char *date = "01/01/99";
		for(i = 0; date[i]; i++)
			wrb(0xffff5 + i, date[i]);
		wrb(0xffff7, '/');
		wrb(0xffffa, '/');
	}
	{
    /* FixME: move PIT init to its own file */
    outb(0x36, 0x43);
    outb(0x00, 0x40);
    outb(0x00, 0x40);
	}
//	setup_int_vect();
	/* cpu setup */
	X86_AX = devfn ? devfn : 0xff;
	X86_DX = 0x80;
	X86_EIP = initialip;
	X86_CS = initialcs;
	/* Initialize stack and data segment */
	X86_SS = initialcs;
	X86_SP = 0xfffe;
	X86_DS = 0x0040;
	X86_ES = 0x0000;
	/* We need a sane way to return from bios
	 * execution. A hlt instruction and a pointer
	 * to it, both kept on the stack, will do.
	 */
	pushw(0xf4f4);    /* hlt; hlt */
//	pushw(0x10cd);    /* int #0x10 */
//	pushw(0x0013);    /* 320 x 200 x 256 colors */
// //	pushw(0x000F);    /* 640 x 350 x mono */
//	pushw(0xb890);    /* nop, mov ax,#0x13 */
	pushw(X86_SS);
	pushw(X86_SP + 2);
#ifdef DEBUG_X86EMU
	X86EMU_trace_on();
  X86EMU_set_debug(DEBUG_DECODE_F | DEBUG_TRACE_F);
#endif
	DPRINT("X86EMU entering emulator\r\n");
	*vblsem = 0;
	X86EMU_exec();
	*vblsem = 1;
	DPRINT("X86EMU halted\r\n");
//	biosfn_set_video_mode(0x13); /* 320 x 200 x 256 colors */
#ifndef USE_SDRAM
	memset((char *)biosmem, 0, SIZE_EMU);
	Mfree(biosmem);
#endif
}
