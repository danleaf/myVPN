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
        private void OnReceiveFrom(IAsyncResult ar)
        {
            byte[] buffer = (byte[])ar.AsyncState;
            EndPoint ep = new IPEndPoint(0,0);
            int len = sudp.EndReceiveFrom(ar, ref ep);

            AgentUdpData(buffer, len, ep as IPEndPoint);
            sudp.BeginReceive(buffer, 0, buffer.Length, SocketFlags.None, new AsyncCallback(OnReceiveFrom), buffer);
        }

        unsafe private void AgentUdpData(byte[] buffer, int len, IPEndPoint ep)
        {
            fixed (byte* pBuffer = buffer)
            {
                VPNHeader* hdr = (VPNHeader*)pBuffer;
                hdr->SourceIP = ac.VirtualIP;
                hdr->SourcePort = (ushort)ep.Port;

                ac.Send(buffer, len);
            }
        }

        unsafe private void OnNetUdpReceive(byte[] buffer, byte* pBuffer, int len)
        {
            VPNHeader* hdr = (VPNHeader*)pBuffer;

            sudp.SendTo(buffer, new IPEndPoint(VPNConsts.LOOPBACK, hdr->DestPort));
        }
    }
}
