/*
	CT60 Setup
	Misc functions

	Copyright (C) 2009	Patrice Mandin

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#include <stdlib.h>

#include <mint/osbind.h>
#include <mint/sysvars.h>

void format_number(char *str, int value, int num_chars, char null_digit)
{
	int i, divisor;

	divisor = 1;
	for (i=0; i<num_chars-1; i++) {
		divisor *= 10;
	}

	while (num_chars>0) {
		int digit = value/divisor;

		if (num_chars==1) {
			null_digit='0';
		}
		*str++ = ((digit==0) ? null_digit : '0'+digit);
		if (digit) {
			null_digit='0';
		}

		value -= digit*divisor;
		num_chars--;
		divisor /= 10;
	}
}

void format_number_hex(char *str, int value, int num_chars, int prefix)
{
	int divisor;

	if (prefix) {
		*str++ = '0';
		*str++ = 'x';
	}

	divisor = (num_chars-1)*4;

	while (num_chars>0) {
		int digit = (value >> divisor) & 15;

		*str++ = ((digit<10) ? '0'+digit : 'A'+(digit-10));

		num_chars--;
		divisor -= 4;
	}
}

int getCookie(unsigned long name, unsigned long *value)
{
	unsigned long *pCookie;
	void *old_stack;
	
	old_stack = (void *) Super(0);
	pCookie = *_p_cookies;
	Super(old_stack);

	if (pCookie == NULL) {
		return 0;
	}

	while (pCookie[0]) {
		if (pCookie[0] == name) {
			*value = pCookie[1];
			return 1;
		}
		pCookie += 2;
	}

	return 0;
}

unsigned long getTicks(void)
{
	void *old_stack = (void *) Super(0);

	unsigned long value = *((volatile long *)_hz_200);

	Super(old_stack);

	return value;
}

int strLength(const char *str)
{
	int i=0;

	if (str) {
		while (*str++) {
			++i;
		}
	}

	return i;
}

void strCopy(const char *src, char *dest)
{
	while (*src) {
		*dest++ = *src++;
	}
	*dest = 0;
}

int strToInt(const char *src)
{
	int i=0;

	while (*src) {
		unsigned char c = *src++;

		if ((c>='0') && (c<='9')) {
			i = (i*10)+(c-'0');
		} else {
			return 0;
		}
	}

	return i;
}
