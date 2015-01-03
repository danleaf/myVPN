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
        Dictionary<IPEndPoint, Socket> epMap;

        unsafe private void OnNetTcpToServer(byte[] buffer, byte* pBuffer, int len)
        {
            VPNHeader* hdr = (VPNHeader*)pBuffer;

            if(hdr->Operation == VPNConsts.OP_CONNECT)
            {
                try
                {
                    Socket s = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
                    s.Connect(new IPEndPoint(VPNConsts.LOOPBACK, hdr->DestPort));

                    epMap.Add(hdr->SourceEndPoint, s);
                }
                catch(Exception)
                {
                    uint dip = hdr->SourceIP;
                    ushort dport = hdr->SourcePort;

                    hdr->Signature = VPNConsts.OP_CONNECTNOK;
                    hdr->SourceIP = hdr->DestIP;
                    hdr->SourcePort = hdr->SourcePort;
                    hdr->DestIP = dip;
                    hdr->DestPort = dport;

                    ac.Send(buffer, sizeof(VPNHeader));
                }
            }
            else
            {
                try
                {
                    Socket s = epMap[hdr->SourceEndPoint];

                    s.Send(buffer, sizeof(VPNHeader), len - sizeof(VPNHeader), SocketFlags.None);
                }
                catch(Exception e)
                {
                    Console.WriteLine(e.Message);
                }
            }
        }
    }
}
