#include <stdio.h>
#include <list>
#include <map>
#include <iostream>
using namespace std;

unsigned char data[] = { 0x54, 0,	
						0x3, 0x34,	
						0, 0,		
						255, 17,	
						192, 168, 1, 5, 
						255, 255, 255, 255 
};

unsigned char data2[] = { 
	0x3, 0x34 
	//192, 168, 1, 5,
	//255, 255, 255, 255 
};

void func1()
{
	int sum = 0;

	for (int i = 0; i < sizeof(data); i+=2)
	{
		sum = sum + data[i] * 256 + data[i + 1];
		sum += (sum >> 16) & 1;
		sum &= 0xffff;
	}

	cout << "No.1: 0x" << hex << sum << endl;
}

void func2()
{
	int sum = 0;
	int c = 0;

	for (int i = sizeof(data) - 2; i >= 0; i -= 2)
	{
		sum = sum + data[i] * 256 + data[i + 1] + c;
		c = (sum >> 16) & 1;
		sum &= 0xffff;
	}

	sum += c;
	sum &= 0xffff;


	cout << "No.2: 0x" << hex << sum << endl;
}

void func3()
{
	unsigned short tmp = 0;
	unsigned short sum = 0x14c0;//51049;
	unsigned short c = 0;
	bool sig = false;

	int index = 0, idx = 1;

	for (int i = 0; i < sizeof(data2); i++)
	{
		if (!sig)
		{
			tmp = (sum & 0xFF) + data2[index * 2 + idx] + c;
			sum &= 0xFF00;
			sum |= tmp & 0xFF;
			c = (tmp >> 8) & 1;
		}
		else
		{
			tmp = (sum >> 8) + data2[index * 2 + idx] + c;
			sum &= 0x00FF;
			sum |= (tmp & 0xFF) << 8;
			c = (tmp >> 8) & 1;
		}

		sig = !sig;
		if (idx == 0)
		{
			index++;
			idx = 1;
		}
		else
			idx = 0;
	}

	sum += c;
	sum &= 0xffff;

	cout << "No.3: 0x" << hex << sum << endl;
}

int  dummys()
{
	return 0;
}

int compares()
{
	return 1;
}

int main()
{
	int i;
	func1();
	func2();
	func3();


	unsigned long vs[] = { (unsigned long)dummys, (unsigned long)compares };
	int(*abc)() = dummys;
	int(*abc2)() = dummys;
	long a = *(long*)abc;
	i = abc();
	i = dummys();
	printf("dummys %lu,compares %lu\n", vs[0], vs[1]);
	printf("dummys %lu,compares %lu\n", (unsigned long)dummys, (unsigned long)compares);


	cin >> i;
	return 0;
}