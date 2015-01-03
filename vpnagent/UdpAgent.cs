using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net;
using System.Net.Sockets;

namespace vpnagent
{
    partial class Agent
    {
        unsafe private void ProcessReceiveFromData(byte[] buffer, int len, IPEndPoint ep)
        {
            fixed (byte* pBuf = buffer)
            {
                VPNHeader* hdr = (VPNHeader*)pBuf;
                hdr->sip = ac.VirtualIP;
                hdr->sport = (ushort)ep.Port;

                ac.Send(buffer, sizeof(VPNHeader));
            }
        }
    }
}
