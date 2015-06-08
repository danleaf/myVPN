#include <stdio.h>

#define EXPR 0x04C11DB7
#define EXPRH8 4
//#define LSB
unsigned int map[256];

struct Reg32
{
	union {
		unsigned int r;
		struct
		{
#ifndef LSB
			unsigned int b0 : 1;
			unsigned int b1 : 1;
			unsigned int b2 : 1;
			unsigned int b3 : 1;
			unsigned int b4 : 1;
			unsigned int b5 : 1;
			unsigned int b6 : 1;
			unsigned int b7 : 1;

			unsigned int b8 : 1;
			unsigned int b9 : 1;
			unsigned int b10 : 1;
			unsigned int b11 : 1;
			unsigned int b12 : 1;
			unsigned int b13 : 1;
			unsigned int b14 : 1;
			unsigned int b15 : 1;

			unsigned int b16 : 1;
			unsigned int b17 : 1;
			unsigned int b18 : 1;
			unsigned int b19 : 1;
			unsigned int b20 : 1;
			unsigned int b21 : 1;
			unsigned int b22 : 1;
			unsigned int b23 : 1;

			unsigned int b24 : 1;
			unsigned int b25 : 1;
			unsigned int b26 : 1;
			unsigned int b27 : 1;
			unsigned int b28 : 1;
			unsigned int b29 : 1;
			unsigned int b30 : 1;
			unsigned int b31 : 1;
#else
			unsigned int b31 : 1;
			unsigned int b30 : 1;
			unsigned int b29 : 1;
			unsigned int b28 : 1;
			unsigned int b27 : 1;
			unsigned int b26 : 1;
			unsigned int b25 : 1;
			unsigned int b24 : 1;

			unsigned int b23 : 1;
			unsigned int b22 : 1;
			unsigned int b21 : 1;
			unsigned int b20 : 1;
			unsigned int b19 : 1;
			unsigned int b18 : 1;
			unsigned int b17 : 1;
			unsigned int b16 : 1;

			unsigned int b15 : 1;
			unsigned int b14 : 1;
			unsigned int b13 : 1;
			unsigned int b12 : 1;
			unsigned int b11 : 1;
			unsigned int b10 : 1;
			unsigned int b9 : 1;
			unsigned int b8 : 1;

			unsigned int b7 : 1;
			unsigned int b6 : 1;
			unsigned int b5 : 1;
			unsigned int b4 : 1;
			unsigned int b3 : 1;
			unsigned int b2 : 1;
			unsigned int b1 : 1;
			unsigned int b0 : 1;
#endif
		}bits;
	}un;

	Reg32(unsigned int n)
	{
		un.r = n;
	}

	Reg32()
	{

	}
};

struct Reg8
{
	union{
		unsigned char r;
		struct
		{
			unsigned int b0 : 1;
			unsigned int b1 : 1;
			unsigned int b2 : 1;
			unsigned int b3 : 1;
			unsigned int b4 : 1;
			unsigned int b5 : 1;
			unsigned int b6 : 1;
			unsigned int b7 : 1;
		}bits;
		struct
		{
#ifndef LSB
			unsigned int d7 : 1;
			unsigned int d6 : 1;
			unsigned int d5 : 1;
			unsigned int d4 : 1;
			unsigned int d3 : 1;
			unsigned int d2 : 1;
			unsigned int d1 : 1;
			unsigned int d0 : 1;
#else
			unsigned int d0 : 1;
			unsigned int d1 : 1;
			unsigned int d2 : 1;
			unsigned int d3 : 1;
			unsigned int d4 : 1;
			unsigned int d5 : 1;
			unsigned int d6 : 1;
			unsigned int d7 : 1;
#endif
		}tm;
	}un;

	Reg8(unsigned char n)
	{
		un.r = n;
	}

	Reg8()
	{

	}
};

unsigned int comput1p(unsigned int r, unsigned char d)
{
	Reg32 ro(r);
	Reg32 rn;
	Reg8 sig;
	sig.un.bits.b0 = (d & 1) ^ ro.un.bits.b31;

	rn.un.bits.b31 = ro.un.bits.b30;
	rn.un.bits.b30 = ro.un.bits.b29;
	rn.un.bits.b29 = ro.un.bits.b28;
	rn.un.bits.b28 = ro.un.bits.b27;
	rn.un.bits.b27 = ro.un.bits.b26;
	rn.un.bits.b26 = ro.un.bits.b25 ^ sig.un.bits.b0;
	rn.un.bits.b25 = ro.un.bits.b24;
	rn.un.bits.b24 = ro.un.bits.b23;
	rn.un.bits.b23 = ro.un.bits.b22 ^ sig.un.bits.b0;
	rn.un.bits.b22 = ro.un.bits.b21 ^ sig.un.bits.b0;
	rn.un.bits.b21 = ro.un.bits.b20;
	rn.un.bits.b20 = ro.un.bits.b19;
	rn.un.bits.b19 = ro.un.bits.b18;
	rn.un.bits.b18 = ro.un.bits.b17;
	rn.un.bits.b17 = ro.un.bits.b16;
	rn.un.bits.b16 = ro.un.bits.b15 ^ sig.un.bits.b0;
	rn.un.bits.b15 = ro.un.bits.b14;
	rn.un.bits.b14 = ro.un.bits.b13;
	rn.un.bits.b13 = ro.un.bits.b12;
	rn.un.bits.b12 = ro.un.bits.b11 ^ sig.un.bits.b0;
	rn.un.bits.b11 = ro.un.bits.b10 ^ sig.un.bits.b0;
	rn.un.bits.b10 = ro.un.bits.b9 ^ sig.un.bits.b0;
	rn.un.bits.b9 = ro.un.bits.b8;
	rn.un.bits.b8 = ro.un.bits.b7 ^ sig.un.bits.b0;
	rn.un.bits.b7 = ro.un.bits.b6 ^ sig.un.bits.b0;
	rn.un.bits.b6 = ro.un.bits.b5;
	rn.un.bits.b5 = ro.un.bits.b4 ^ sig.un.bits.b0;
	rn.un.bits.b4 = ro.un.bits.b3 ^ sig.un.bits.b0;
	rn.un.bits.b3 = ro.un.bits.b2;
	rn.un.bits.b2 = ro.un.bits.b1 ^ sig.un.bits.b0;
	rn.un.bits.b1 = ro.un.bits.b0 ^ sig.un.bits.b0;
	rn.un.bits.b0 = sig.un.bits.b0;

	return rn.un.r;
}

unsigned int comput8p(unsigned int r, unsigned char d)
{
	Reg32 ro(r);
	Reg32 rn;
	Reg8 dd(d);

	rn.un.bits.b31 = ro.un.bits.b23 ^ ro.un.bits.b29 ^ dd.un.tm.d2;
	rn.un.bits.b30 = ro.un.bits.b22 ^ ro.un.bits.b28 ^ ro.un.bits.b31 ^ dd.un.tm.d0 ^ dd.un.tm.d3;
	rn.un.bits.b29 = ro.un.bits.b21 ^ ro.un.bits.b27 ^ ro.un.bits.b30 ^ ro.un.bits.b31 ^ dd.un.tm.d0 ^ dd.un.tm.d1 ^ dd.un.tm.d4;
	rn.un.bits.b28 = ro.un.bits.b20 ^ ro.un.bits.b30 ^ ro.un.bits.b29 ^ ro.un.bits.b26 ^ dd.un.tm.d1 ^ dd.un.tm.d2 ^ dd.un.tm.d5;
	rn.un.bits.b27 = ro.un.bits.b19 ^ ro.un.bits.b25 ^ ro.un.bits.b28 ^ ro.un.bits.b29 ^ ro.un.bits.b31 ^ dd.un.tm.d0 ^ dd.un.tm.d2 ^ dd.un.tm.d3 ^ dd.un.tm.d6;
	rn.un.bits.b26 = ro.un.bits.b18 ^ ro.un.bits.b24 ^ ro.un.bits.b27 ^ ro.un.bits.b28 ^ ro.un.bits.b30 ^ dd.un.tm.d1 ^ dd.un.tm.d3 ^ dd.un.tm.d4 ^ dd.un.tm.d7;
	rn.un.bits.b25 = ro.un.bits.b17 ^ ro.un.bits.b26 ^ ro.un.bits.b27 ^ dd.un.tm.d4 ^ dd.un.tm.d5;
	rn.un.bits.b24 = ro.un.bits.b16 ^ ro.un.bits.b25 ^ ro.un.bits.b26 ^ ro.un.bits.b31 ^ dd.un.tm.d0 ^ dd.un.tm.d5 ^ dd.un.tm.d6;
	
	rn.un.bits.b23 = ro.un.bits.b15 ^ ro.un.bits.b24 ^ ro.un.bits.b25 ^ ro.un.bits.b30 ^ dd.un.tm.d1 ^ dd.un.tm.d6 ^ dd.un.tm.d7;
	rn.un.bits.b22 = ro.un.bits.b14 ^ ro.un.bits.b24 ^ dd.un.tm.d7;
	rn.un.bits.b21 = ro.un.bits.b13 ^ ro.un.bits.b29 ^ dd.un.tm.d2;
	rn.un.bits.b20 = ro.un.bits.b12 ^ ro.un.bits.b28 ^ dd.un.tm.d3;
	rn.un.bits.b19 = ro.un.bits.b11 ^ ro.un.bits.b27 ^ ro.un.bits.b31 ^ dd.un.tm.d0 ^ dd.un.tm.d4;
	rn.un.bits.b18 = ro.un.bits.b10 ^ ro.un.bits.b26 ^ ro.un.bits.b30 ^ ro.un.bits.b31 ^ dd.un.tm.d0 ^ dd.un.tm.d1 ^ dd.un.tm.d5;
	rn.un.bits.b17 = ro.un.bits.b9 ^ ro.un.bits.b25 ^ ro.un.bits.b29 ^ ro.un.bits.b30 ^ dd.un.tm.d1 ^ dd.un.tm.d2 ^ dd.un.tm.d6;
	rn.un.bits.b16 = ro.un.bits.b8 ^ ro.un.bits.b24 ^ ro.un.bits.b28 ^ ro.un.bits.b29 ^ dd.un.tm.d2 ^ dd.un.tm.d3 ^ dd.un.tm.d7;
	
	rn.un.bits.b15 = ro.un.bits.b7 + ro.un.bits.b27 + ro.un.bits.b28 + ro.un.bits.b29 + ro.un.bits.b31 + dd.un.tm.d0 + dd.un.tm.d2 + dd.un.tm.d3 + dd.un.tm.d4;
	rn.un.bits.b14 = ro.un.bits.b6 + ro.un.bits.b26 + ro.un.bits.b27 + ro.un.bits.b28 + ro.un.bits.b30 + ro.un.bits.b31 + dd.un.tm.d0 + dd.un.tm.d1 + dd.un.tm.d3 + dd.un.tm.d4 + dd.un.tm.d5;
	rn.un.bits.b13 = ro.un.bits.b5 + ro.un.bits.b25 + ro.un.bits.b26 + ro.un.bits.b27 + ro.un.bits.b29 + ro.un.bits.b30 + ro.un.bits.b31 + dd.un.tm.d0 + dd.un.tm.d1 + dd.un.tm.d2 + dd.un.tm.d4 + dd.un.tm.d5 + dd.un.tm.d6;
	rn.un.bits.b12 = ro.un.bits.b4 + ro.un.bits.b24 + ro.un.bits.b25 + ro.un.bits.b26 + ro.un.bits.b28 + ro.un.bits.b29 + ro.un.bits.b30 + dd.un.tm.d1 + dd.un.tm.d2 + dd.un.tm.d3 + dd.un.tm.d5 + dd.un.tm.d6 + dd.un.tm.d7;
	rn.un.bits.b11 = ro.un.bits.b3 + ro.un.bits.b24 + ro.un.bits.b25 + ro.un.bits.b27 + ro.un.bits.b28 + dd.un.tm.d3 + dd.un.tm.d4 + dd.un.tm.d6 + dd.un.tm.d7;
	rn.un.bits.b10 = ro.un.bits.b2 + ro.un.bits.b24 + ro.un.bits.b26 + ro.un.bits.b27 + ro.un.bits.b29 + dd.un.tm.d2 + dd.un.tm.d4 + dd.un.tm.d5 + dd.un.tm.d7;
	rn.un.bits.b9 = ro.un.bits.b1 + ro.un.bits.b25 + ro.un.bits.b26 + ro.un.bits.b28 + ro.un.bits.b29 + dd.un.tm.d2 + dd.un.tm.d3 + dd.un.tm.d5 + dd.un.tm.d6;
	rn.un.bits.b8 = ro.un.bits.b0 + ro.un.bits.b24 + ro.un.bits.b25 + ro.un.bits.b27 + ro.un.bits.b28 + dd.un.tm.d3 + dd.un.tm.d4 + dd.un.tm.d6 + dd.un.tm.d7;
	
	rn.un.bits.b7 = ro.un.bits.b24 + ro.un.bits.b26 + ro.un.bits.b27 + ro.un.bits.b29 + ro.un.bits.b31 + dd.un.tm.d0 + dd.un.tm.d2 + dd.un.tm.d4 + dd.un.tm.d5 + dd.un.tm.d7;
	rn.un.bits.b6 = ro.un.bits.b25 + ro.un.bits.b26 + ro.un.bits.b28 + ro.un.bits.b29 + ro.un.bits.b30 + ro.un.bits.b31 + dd.un.tm.d0 + dd.un.tm.d1 + dd.un.tm.d2 + dd.un.tm.d3 + dd.un.tm.d5 + dd.un.tm.d6;
	rn.un.bits.b5 = ro.un.bits.b24 + ro.un.bits.b25 + ro.un.bits.b27 + ro.un.bits.b28 + ro.un.bits.b29 + ro.un.bits.b30 + ro.un.bits.b31 + dd.un.tm.d0 + dd.un.tm.d1 + dd.un.tm.d2 + dd.un.tm.d3 + dd.un.tm.d4 + dd.un.tm.d6 + dd.un.tm.d7;
	rn.un.bits.b4 = ro.un.bits.b24 + ro.un.bits.b26 + ro.un.bits.b27 + ro.un.bits.b28 + ro.un.bits.b30 + dd.un.tm.d1 + dd.un.tm.d3 + dd.un.tm.d4 + dd.un.tm.d5 + dd.un.tm.d7;
	rn.un.bits.b3 = ro.un.bits.b25 + ro.un.bits.b26 + ro.un.bits.b27 + ro.un.bits.b31 + dd.un.tm.d0 + dd.un.tm.d4 + dd.un.tm.d5 + dd.un.tm.d6;
	rn.un.bits.b2 = ro.un.bits.b24 + ro.un.bits.b25 + ro.un.bits.b26 + ro.un.bits.b30 + ro.un.bits.b31 + dd.un.tm.d0 + dd.un.tm.d1 + dd.un.tm.d5 + dd.un.tm.d6 + dd.un.tm.d7;
	rn.un.bits.b1 = ro.un.bits.b24 + ro.un.bits.b25 + ro.un.bits.b30 + ro.un.bits.b31 + dd.un.tm.d0 + dd.un.tm.d1 + dd.un.tm.d6 + dd.un.tm.d7;
	rn.un.bits.b0 = ro.un.bits.b24 + ro.un.bits.b30 + dd.un.tm.d1 + dd.un.tm.d7;

	return rn.un.r;
}

int main1()
{
	unsigned long long x;
	unsigned int r = 0;

	
	x = 0x0200000000050200;
	r = 0xFFFFFFFF;
	for (int i = 0; i < 64; i++)
	{
		unsigned char d = (x & 0x8000000000000000) >> 63;
		r = comput1p(r, d);
		x <<= 1;
	}

	//printf("%X\n", r);


	x = 0x0200000000050200;
	r = 0xFFFFFFFF;
	for (int i = 0; i < 1; i++)
	{
		unsigned char d = (x & 0xFF00000000000000) >> 56;
		r = comput8p(r, d);
		x <<= 8;
	}

	printf("%X\n", r);

	int a;
	scanf_s("%d", &a);

	return 0;
}