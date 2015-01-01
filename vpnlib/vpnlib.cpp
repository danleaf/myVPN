// vpnlib.cpp : 定义 DLL 应用程序的导出函数。
//

#include "stdafx.h"
#include "vpnlib.h"

#define LOCLSVR_PORT 8123

struct vpnhdr
{
	u_long	ip;
	u_short port;
};

void fillvpnhdr(void* buf, const sockaddr* addr)
{
	((vpnhdr*)buf)->ip = ((sockaddr_in*)addr)->sin_addr.S_un.S_addr;
	((vpnhdr*)buf)->port = ((sockaddr_in*)addr)->sin_port;
}

void filladdr(sockaddr* addr, const void* buf)
{
	((sockaddr_in*)addr)->sin_addr.S_un.S_addr = ((vpnhdr*)buf)->ip;
	((sockaddr_in*)addr)->sin_port = ((vpnhdr*)buf)->port;
}

sockaddr_in loclsvr()
{
	sockaddr_in to;
	memset(&to, 0, sizeof(to));
	to.sin_family = AF_INET;
	to.sin_addr.S_un.S_un_b.s_b1 = 127;
	to.sin_addr.S_un.S_un_b.s_b4 = 1;
	to.sin_port = htons(LOCLSVR_PORT);
	return to;
}

sockaddr_in _lcsto = loclsvr();
const sockaddr* lcsto = (sockaddr*)&_lcsto;
int lcstolen = sizeof(sockaddr_in);

int
WSAAPI
_sendto(
	_In_ SOCKET s,
	_In_reads_bytes_(len) const char * buf,
	_In_ int len,
	_In_ int flags,
	_In_reads_bytes_(tolen) const struct sockaddr * to,
	_In_ int tolen
)
{
	int newlen = len + sizeof(vpnhdr);
	char* newbuf = new char[newlen];

	memcpy(newbuf + sizeof(vpnhdr), buf, len);
	fillvpnhdr(newbuf, to);

	do{
		int ret = sendto(s, newbuf, newlen, 0, lcsto, lcstolen);
		if (ret < 1)
			return ret;

		newlen -= ret;
		newbuf += ret;
	} while (newlen > 0);
	
	return len;
}

int
WSAAPI
_recvfrom(
	_In_ SOCKET s,
	_Out_writes_bytes_to_(len, return) char * buf,
	_In_ int len,
	_In_ int flags,
	_Out_writes_bytes_to_opt_(*fromlen, *fromlen) struct sockaddr * from,
	_Inout_opt_ int * fromlen
)
{
	int newlen = len + sizeof(vpnhdr);
	char* newbuf = new char[newlen];

	int ret = recvfrom(s, newbuf, newlen, 0, from, fromlen);
	if (ret < sizeof(vpnhdr))
		return -1;

	filladdr(from, newbuf);
	memcpy(buf, newbuf + sizeof(vpnhdr), ret - sizeof(vpnhdr));
	
	return ret - sizeof(vpnhdr);
}

VPNLIB_API
int
WSAAPI
_connect(
	_In_ SOCKET s,
	_In_reads_bytes_(namelen) const struct sockaddr * name,
	_In_ int namelen
)
{
	char buf[32];
	int ret = connect(s, lcsto, lcstolen);
	if (ret < 0)
		return ret;

	if (1 > recv(s, buf, 32, 0))
		return -1;
	if (memcmp(buf, "CONNECTOK", 9))
		return -1;
	return ret;
}