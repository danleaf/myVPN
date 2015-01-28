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
        Dictionary<IPEndPoint, Socket> virtualClientMap = new Dictionary<IPEndPoint,Socket>();

        unsafe private void OnNetTcpToServer(byte[] buffer, byte* pBuffer, int len)
        {
            VPNHeader* hdr = (VPNHeader*)pBuffer;

            if (hdr->Operation == VPNConsts.OP_CONNECT)
            {
                Socket s = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
                try
                {
                    s.Connect(new IPEndPoint(VPNConsts.LOOPBACK, hdr->DestPort));
                    virtualClientMap.Add(hdr->SourceEndPoint, s);
                    hdr->Signature = VPNConsts.OP_CONNECTOK;

                    StateObject so = new StateObject(s);
                    s.BeginReceive(so.buffer, 0, so.BufferSize, SocketFlags.None, new AsyncCallback(OnReceiveClient), so);
                }
                catch (Exception)
                {
                    hdr->Signature = VPNConsts.OP_CONNECTNOK;
                }

                uint sip = hdr->SourceIP;
                ushort sport = hdr->SourcePort;

                hdr->DestIP = sip;
                hdr->DestPort = sport;
                hdr->SourceIP = hdr->DestIP;
                hdr->SourcePort = hdr->DestPort;
                ac.Send(buffer, sizeof(VPNHeader));
            }
            else
            {
                try
                {
                    Socket s = virtualClientMap[hdr->SourceEndPoint];

                    s.Send(buffer, sizeof(VPNHeader), len - sizeof(VPNHeader), SocketFlags.None);
                }
                catch (Exception e)
                {
                    Console.WriteLine(e.Message);
                }
            }
        }

        private void OnReceiveServer(IAsyncResult ar)
        {
            StateObject so = ar.AsyncState as StateObject;

            byte[] buffer = so.buffer;
            Socket s = so.s;

            int len = s.EndReceive(ar);

            AgentTcpServer(s, buffer, len);
            s.BeginReceive(so.buffer, 0, VPNConsts.BUFFER_SIZE, SocketFlags.None, new AsyncCallback(OnReceiveClient), so);
        }

        unsafe private void AgentTcpServer(Socket s, byte[] buffer, int len)
        {
            fixed (byte* pBuf = buffer)
            {
                VPNHeader* hdr = (VPNHeader*)pBuf;
                hdr->SourceIP = ac.VirtualIP;
                hdr->SourcePort = (ushort)((IPEndPoint)s.RemoteEndPoint).Port;

                ac.Send(buffer, sizeof(VPNHeader));
            }
        }
    }
}
