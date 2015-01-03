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
            ac.RegisterReceiver(new VpnReceiveCallback(this.OnNetReceive));
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
    }
}
