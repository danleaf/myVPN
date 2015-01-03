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

        unsafe private void OnNetClientData(byte[] data, byte* pData, int len)
        {
            VPNHeader* hdr = (VPNHeader*)pData;

            if(hdr->op == VPNConsts.OP_CONNECT)
            {
                try
                {
                    Socket s = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
                    s.Connect(new IPEndPoint(IPAddress.Parse("127.0.0.1"), hdr->dport));
                    sServer.Send();
                }
                catch(Exception)
                {
                    sServer.Send();
                }
            }
        }
    }
}
