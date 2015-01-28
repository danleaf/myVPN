using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net;
using System.Net.Sockets;

namespace vpnagent
{
    public partial class Agent
    {
        VpnAC ac;

        Socket sudp = new Socket(SocketType.Dgram, ProtocolType.Udp);
        Socket stcp = new Socket(SocketType.Stream, ProtocolType.Tcp);

        public Agent(VpnAC ac)
        {
            this.ac = ac;
            ac.RegisterReceiver(new VpnReceiveCallback(OnNetReceive));

            sudp.Bind(new IPEndPoint(VPNConsts.LOOPBACK, VPNConsts.VPNAGENT_PORT));
            stcp.Bind(new IPEndPoint(VPNConsts.LOOPBACK, VPNConsts.VPNAGENT_PORT));
            stcp.Listen(5);

            byte[] buffer = new byte[VPNConsts.BUFFER_SIZE];
            sudp.BeginReceive(buffer, 0, buffer.Length, SocketFlags.None, new AsyncCallback(OnReceiveFrom), buffer);
            stcp.BeginAccept(new AsyncCallback(OnAccept), null);
        }

        unsafe private void OnNetReceive(byte[] buffer, int len)
        {
            fixed (byte* pBuffer = buffer)
            {
                VPNHeader* hdr = (VPNHeader*)pBuffer;

                if(hdr->Protocol == VPNConsts.PROT_TCP)
                {
                    OnNetTcpReceive(buffer, pBuffer, len);
                }
                else
                {
                    OnNetUdpReceive(buffer, pBuffer, len);
                }
            }
        }

        unsafe private void OnNetTcpReceive(byte[] buffer, byte* pBuffer, int len)
        {
            VPNHeader* hdr = (VPNHeader*)pBuffer;
            if((hdr->Signature & VPNConsts.MASK_TOSERVER) == 0)
            {
                OnNetTcpToClient(buffer, pBuffer, len);
            }
            else
            {
                OnNetTcpToServer(buffer, pBuffer, len);
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

            public int BufferSize
            {
                get
                {
                    return buffer.Length;
                }
            }
        }
    }
}
