using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net;
using System.Net.Sockets;
using System.Threading;

namespace vpnagent
{
    /// <summary>
    /// Agent when an App communicate as a TCP Client
    /// </summary>
    partial class Agent
    {
        Dictionary<ushort, Socket> sClients = new Dictionary<ushort, Socket>();

        public void End()
        {
            foreach (var s in sClients)
            {
                s.Value.Close();
            }

            stcp.Close();
            ac.Close();
        }

        private void OnAccept(IAsyncResult ar)
        {
            Socket s = stcp.EndAccept(ar);
            sClients.Add((ushort)((IPEndPoint)s.RemoteEndPoint).Port, s);

            stcp.BeginAccept(new AsyncCallback(this.OnAccept), null);

            StateObject so = new StateObject(s);
            s.BeginReceive(so.buffer, 0, VPNConsts.BUFFER_SIZE, SocketFlags.None, new AsyncCallback(this.OnReceive), so);
        }

        private void OnReceive(IAsyncResult ar)
        {
            StateObject so = ar.AsyncState as StateObject;

            byte[] buffer = so.buffer;
            Socket s = so.s;

            int len = s.EndReceive(ar);

            ProcessReceiveData(s, buffer, len);
            s.BeginReceive(so.buffer, 0, VPNConsts.BUFFER_SIZE, SocketFlags.None, new AsyncCallback(this.OnReceive), so);
        }

        unsafe private void ProcessReceiveData(Socket s, byte[] buffer, int len)
        {
            fixed (byte* pBuf = buffer)
            {
                VPNHeader* hdr = (VPNHeader*)pBuf;
                hdr->SourceIP = ac.VirtualIP;
                hdr->SourcePort = (ushort)((IPEndPoint)s.RemoteEndPoint).Port;

                ac.Send(buffer, sizeof(VPNHeader));
            }
        }

        unsafe private void OnNetTcpToClient(byte[] buffer, byte* pBuffer, int len) 
        {
            VPNHeader* hdr = (VPNHeader*)pBuffer;
            Socket s = sClients[hdr->DestPort];

            if (hdr->Operation == VPNConsts.OP_CONNECTOK)
            {
                s.Send(Encoding.ASCII.GetBytes("CONNECTOK"));
            }
            else if (hdr->Operation == VPNConsts.OP_CONNECTNOK)
            {
                s.Send(Encoding.ASCII.GetBytes("FAILED"));
            }
            else
            {
                s.Send(buffer, sizeof(VPNHeader), len - sizeof(VPNHeader), SocketFlags.None);
            }
        }

        class StateObject
        {
            public byte[] buffer = new byte[VPNConsts.BUFFER_SIZE];
            public Socket s;

            public StateObject(Socket s)
            {
                this.s = s;
            }
        }
    }

}
