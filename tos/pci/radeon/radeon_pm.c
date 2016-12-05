/*
 *	radeon_pm.c
 *
 *	Copyright 2003,2004 Ben. Herrenschmidt <benh@kernel.crashing.org>
 *	Copyright 2004 Paul Mackerras <paulus@samba.org>
 *
 *	This is the power management code for ATI radeon chipsets. It contains
 *	some dynamic clock PM enable/disable code similar to what X.org does,
 *	some D2-state (APM-style) sleep/wakeup code for use on some PowerMacs,
 *	and the necessary bits to re-initialize from scratch a few chips found
 *	on PowerMacs as well. The later could be extended to more platforms
 *	provided the memory controller configuration code be made more generic,
 *	and you can get the proper mode register commands for your RAMs.
 *	Those things may be found in the BIOS image...
 */

#include "radeonfb.h"
#include "ati_ids.h"

