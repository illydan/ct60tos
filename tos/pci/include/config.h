#ifndef _CONFIG_H_
#define _CONFIG_H_

/* DEBUG */
#define DEBUG

/* DBUG */
#define DBUG

/* PCI XBIOS */
#undef PCI_XBIOS              /* faster by cookie */

/* NETWORK */

/* fVDI */
#undef TEST_NOPCI

/* X86 emulator */
#undef DEBUG_X86EMU
#undef DEBUG_X86EMU_PCI
#define __BIG_ENDIAN__
#define NO_LONG_LONG

/* Radeon */
#define DEFAULT_MONITOR_LAYOUT "TMDS,CRT"
#define ATI_LOGO
#define CONFIG_FB_RADEON_I2C
#define CONFIG_FB_MODE_HELPERS
#undef RADEON_TILING /* normally faster but tile 16 x 16 not compatible with accel.c read_pixel, blit/expand_area and writes on screen frame buffer */
#undef RADEON_THEATRE /* unfinished */

/* VIDIX */
#undef VIDIX_FILTER
#undef VIDIX_ENABLE_BM /* unfinished */

/* AC97 */
#define SOUND_AC97

/* USB */
#define USB_DEVICE

#endif /* _CONFIG_H_ */
