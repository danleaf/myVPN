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
                hdr->SourceIP = ac.VirtualIP;
                hdr->SourcePort = (ushort)ep.Port;

                ac.Send(buffer, sizeof(VPNHeader));
            }
        }

        unsafe private void OnNetUdpReceive(byte[] buffer, byte* pBuffer, int len)
        {

        }
    }
}
