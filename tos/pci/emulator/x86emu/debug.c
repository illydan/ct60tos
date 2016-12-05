/****************************************************************************
*
*                       Realmode X86 Emulator Library
*
*               Copyright (C) 1991-2004 SciTech Software, Inc.
*                    Copyright (C) David Mosberger-Tang
*                      Copyright (C) 1999 Egbert Eich
*
*  ========================================================================
*
*  Permission to use, copy, modify, distribute, and sell this software and
*  its documentation for any purpose is hereby granted without fee,
*  provided that the above copyright notice appear in all copies and that
*  both that copyright notice and this permission notice appear in
*  supporting documentation, and that the name of the authors not be used
*  in advertising or publicity pertaining to distribution of the software
*  without specific, written prior permission.  The authors makes no
*  representations about the suitability of this software for any purpose.
*  It is provided "as is" without express or implied warranty.
*
*  THE AUTHORS DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
*  INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO
*  EVENT SHALL THE AUTHORS BE LIABLE FOR ANY SPECIAL, INDIRECT OR
*  CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF
*  USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
*  OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
*  PERFORMANCE OF THIS SOFTWARE.
*
*  ========================================================================
*
* Language:     ANSI C
* Environment:  Any
* Developer:    Kendall Bennett
*
* Description:  This file contains the code to handle debugging of the
*               emulator.
*
****************************************************************************/

#include "x86emui.h"

/*----------------------------- Implementation ----------------------------*/

#ifdef DEBUG

static void     print_encoded_bytes (u16 s, u16 o);
static void     print_decoded_instruction (void);
//static int      parse_line (char *s, int *ps, int *n);

/* should look something like debug's output. */
void X86EMU_trace_regs (void)
{
    if (DEBUG_TRACE()) {
        x86emu_dump_regs();
    }
    if (DEBUG_DECODE() && ! DEBUG_DECODE_NOPRINT()) {
        DPRINTVALHEXWORD("", M.x86.saved_cs);
        DPRINTVALHEXWORD(":", M.x86.saved_ip);
        DPRINT(" ");
        print_encoded_bytes( M.x86.saved_cs, M.x86.saved_ip);
        print_decoded_instruction();
    }
}

void X86EMU_trace_xregs (void)
{
    if (DEBUG_TRACE()) {
        x86emu_dump_xregs();
    }
}

void x86emu_just_disassemble (void)
{
    /*
     * This routine called if the flag DEBUG_DISASSEMBLE is set kind
     * of a hack!
     */
    DPRINTVALHEXWORD("", M.x86.saved_cs);
    DPRINTVALHEXWORD(":", M.x86.saved_ip);
    DPRINT(" ");
    print_encoded_bytes( M.x86.saved_cs, M.x86.saved_ip);
    print_decoded_instruction();
}

void x86emu_check_ip_access (void)
{
    /* NULL as of now */
}

void x86emu_check_sp_access (void)
{
}

void x86emu_check_mem_access (u32 dummy)
{
    /*  check bounds, etc */
}

void x86emu_check_data_access (uint dummy1, uint dummy2)
{
    /*  check bounds, etc */
}

void x86emu_inc_decoded_inst_len (int x)
{
	M.x86.enc_pos += x;
}

void x86emu_decode_printf (char *x)
{
	if(debug)
	{
		Funcs_copy(x, &M.x86.decoded_buf[M.x86.enc_str_pos&127]);
		M.x86.enc_str_pos += Funcs_length(x);
	}
}

void x86emu_decode_printf2 (char *x, int y)
{
	char temp[100], *p;
	if(debug)
	{
		p = temp;
		while(x[0] != 0)
		{
			if(x[0]=='%' && x[1]=='d')
			{
				x+=2;
	      Funcs_ltoa(p, y, 10);
	      while(p[0] != 0)
	      	p++;    
			}
			else if(x[0]=='%' && x[1]=='x')
			{
				x+=2;
				*p++ = '0';
				*p++ = 'x';
				y &= 0xffff;
	      Funcs_ltoa(p, y, 16);
	      while(p[0] != 0)
	      	p++;      
			}
			else
				*p++ = *x++;
		}
		*p = 0;
		Funcs_copy(temp, &M.x86.decoded_buf[M.x86.enc_str_pos&127]);
		M.x86.enc_str_pos += Funcs_length(temp);
	}
}

void x86emu_end_instr (void)
{
    M.x86.enc_str_pos = 0;
    M.x86.enc_pos = 0;
}

static void print_encoded_bytes (u16 s, u16 o)
{
    int i;
    for (i=0; i< M.x86.enc_pos; i++)
        DPRINTVALHEXBYTE("", fetch_data_byte_abs(s,o+i));
    for ( ; i<10; i++)
        DPRINT("  ");
}

static void print_decoded_instruction (void)
{
    DPRINT(M.x86.decoded_buf);
}

void x86emu_print_int_vect (u16 iv)
{
    u16 seg,off;

    if (iv > 256) return;
    seg = fetch_data_word_abs(0,iv*4);
    off = fetch_data_word_abs(0,iv*4+2);
    DPRINTVALHEXWORD("", seg);
    DPRINTVALHEXWORD(":", off);
    DPRINT(" ");
}

void X86EMU_dump_memory (u16 seg, u16 off, u32 amt)
{
    u32 start = off & 0xfffffff0;
    u32 end  = (off+16) & 0xfffffff0;
    u32 i;
    u32 current;

    current = start;
    while (end <= off + amt) {
        DPRINTVALHEXWORD("", seg);
        DPRINTVALHEXWORD(":", start);
        DPRINT(" ");
        for (i=start; i< off; i++)
          DPRINT("   ");
        for ( ; i< end; i++)
          DPRINTVALHEXBYTE(" ", fetch_data_byte_abs(seg,i));
        DPRINT("\r\n");
        start = end;
        end = start + 16;
    }
}

void x86emu_single_step (void)
{
}

int X86EMU_trace_on(void)
{
    return M.x86.debug |= DEBUG_STEP_F | DEBUG_DECODE_F | DEBUG_TRACE_F;
}

int X86EMU_trace_off(void)
{
    return M.x86.debug &= ~(DEBUG_STEP_F | DEBUG_DECODE_F | DEBUG_TRACE_F);
}

int X86EMU_set_debug(int debug)
{
	return M.x86.debug = debug;
}

#endif /* DEBUG */

void x86emu_dump_regs (void)
{
    DPRINTVALHEXWORD("  AX=", M.x86.R_AX );
    DPRINTVALHEXWORD("  BX=", M.x86.R_BX );
    DPRINTVALHEXWORD("  CX=", M.x86.R_CX );
    DPRINTVALHEXWORD("  DX=", M.x86.R_DX );
    DPRINTVALHEXWORD("  SP=", M.x86.R_SP );
    DPRINTVALHEXWORD("  BP=", M.x86.R_BP );
    DPRINTVALHEXWORD("  SI=", M.x86.R_SI );
    DPRINTVALHEXWORD("  DI=", M.x86.R_DI );
    DPRINT("\r\n");
    DPRINTVALHEXWORD("  DS=", M.x86.R_DS );
    DPRINTVALHEXWORD("  ES=", M.x86.R_ES );
    DPRINTVALHEXWORD("  SS=", M.x86.R_SS );
    DPRINTVALHEXWORD("  CS=", M.x86.R_CS );
    DPRINTVALHEXWORD("  IP=", M.x86.R_IP );
    DPRINT("\r\n  ");
    if (ACCESS_FLAG(F_OF))    DPRINT("OV ");     /* CHECKED... */
    else                        DPRINT("NV ");
    if (ACCESS_FLAG(F_DF))    DPRINT("DN ");
    else                        DPRINT("UP ");
    if (ACCESS_FLAG(F_IF))    DPRINT("EI ");
    else                        DPRINT("DI ");
    if (ACCESS_FLAG(F_SF))    DPRINT("NG ");
    else                        DPRINT("PL ");
    if (ACCESS_FLAG(F_ZF))    DPRINT("ZR ");
    else                        DPRINT("NZ ");
    if (ACCESS_FLAG(F_AF))    DPRINT("AC ");
    else                        DPRINT("NA ");
    if (ACCESS_FLAG(F_PF))    DPRINT("PE ");
    else                        DPRINT("PO ");
    if (ACCESS_FLAG(F_CF))    DPRINT("CY ");
    else                        DPRINT("NC ");
    DPRINT("\r\n");
}

void x86emu_dump_xregs (void)
{
    DPRINTVALHEXLONG("  EAX=", M.x86.R_EAX );
    DPRINTVALHEXLONG("  EBX=", M.x86.R_EBX );
    DPRINTVALHEXLONG("  ECX=", M.x86.R_ECX );
    DPRINTVALHEXLONG("  EDX=", M.x86.R_EDX );
    DPRINT("\r\n");
    DPRINTVALHEXLONG("  ESP=", M.x86.R_ESP );
    DPRINTVALHEXLONG("  EBP=", M.x86.R_EBP );
    DPRINTVALHEXLONG("  ESI=", M.x86.R_ESI );
    DPRINTVALHEXLONG("  EDI=", M.x86.R_EDI );
    DPRINT("\r\n");
    DPRINTVALHEXWORD("  DS=", M.x86.R_DS );
    DPRINTVALHEXWORD("  ES=", M.x86.R_ES );
    DPRINTVALHEXWORD("  SS=", M.x86.R_SS );
    DPRINTVALHEXWORD("  CS=", M.x86.R_CS );
    DPRINTVALHEXLONG("  EIP=", M.x86.R_EIP );
    DPRINT("\r\n  ");
    if (ACCESS_FLAG(F_OF))    DPRINT("OV ");     /* CHECKED... */
    else                        DPRINT("NV ");
    if (ACCESS_FLAG(F_DF))    DPRINT("DN ");
    else                        DPRINT("UP ");
    if (ACCESS_FLAG(F_IF))    DPRINT("EI ");
    else                        DPRINT("DI ");
    if (ACCESS_FLAG(F_SF))    DPRINT("NG ");
    else                        DPRINT("PL ");
    if (ACCESS_FLAG(F_ZF))    DPRINT("ZR ");
    else                        DPRINT("NZ ");
    if (ACCESS_FLAG(F_AF))    DPRINT("AC ");
    else                        DPRINT("NA ");
    if (ACCESS_FLAG(F_PF))    DPRINT("PE ");
    else                        DPRINT("PO ");
    if (ACCESS_FLAG(F_CF))    DPRINT("CY ");
    else                        DPRINT("NC ");
    DPRINT("\r\n");
}
