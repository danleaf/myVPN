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
    class TcpClientAgent
    {
        Socket sAgent = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
        Socket sServer = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

        public TcpClientAgent()
        {
            sServer.Connect(new IPEndPoint(IPAddress.Parse(VPNConsts.SERVER_IP), VPNConsts.SERVER_PORT));
            sAgent.Bind(new IPEndPoint(IPAddress.Any, VPNConsts.VPNAGENT_PORT));
            sAgent.Listen(5);
        }

        public void Run()
        {
            Thread accept = new Thread(new ThreadStart(this.TcpAgentProc));
            accept.Start();
        }

        unsafe private void TcpAgentProc()
        {
            while(true)
            {
                byte[] buffer = new byte[VPNConsts.MAX_BUFFER_SIZE];
                Socket s = sAgent.Accept();

                s.Receive(buffer);
                try
                {
                    sServer.Send(buffer, sizeof(VpnHeader), SocketFlags.None);
                    sServer.Receive(buffer);
                    fixed (byte* pBuf = buffer)
                    {
                        if (((VpnHeader*)pBuf)->op == VPNConsts.OP_CONNECTOK)
                        {
                            s.Send(Encoding.Default.GetBytes("CONNECTOK"));
                        }
                    }
                }
                catch
                {
                    s.Send(Encoding.Default.GetBytes("FAILED"));
                }
            }
        }
    }

}
