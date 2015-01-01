
#ifdef VPNLIB_EXPORTS
#define VPNLIB_API __declspec(dllexport)
#else
#define VPNLIB_API __declspec(dllimport)
#endif


VPNLIB_API 
int
WSAAPI
_sendto(
	_In_ SOCKET s,
	_In_reads_bytes_(len) const char * buf,
	_In_ int len,
	_In_ int flags,
	_In_reads_bytes_(tolen) const struct sockaddr * to,
	_In_ int tolen
);

VPNLIB_API
int
WSAAPI
_recvfrom(
	_In_ SOCKET s,
	_Out_writes_bytes_to_(len, return) char * buf,
	_In_ int len,
	_In_ int flags,
	_Out_writes_bytes_to_opt_(*fromlen, *fromlen) struct sockaddr * from,
	_Inout_opt_ int * fromlen
);

VPNLIB_API
int
WSAAPI
_connect(
	_In_ SOCKET s,
	_In_reads_bytes_(namelen) const struct sockaddr * name,
	_In_ int namelen
);