using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using System.Runtime;
using System.Runtime.InteropServices;

namespace vpnagent
{
    class Agent
    {
        const int VPNAGENT_PORT = 8123;
        const int SERVER_PORT = 8823;
        const int MAX_BUFFER_SIZE = 4096;
        const int OP_CONNECTOK = 2;

        Socket stcp = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
        Socket sudp = new Socket(AddressFamily.InterNetwork, SocketType.Dgram, ProtocolType.Udp);
        Socket ssvr = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

        public Agent()
        {
            sudp.Bind(new IPEndPoint(IPAddress.Any, VPNAGENT_PORT));
            stcp.Bind(new IPEndPoint(IPAddress.Any, VPNAGENT_PORT));
            stcp.Listen(5);
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
                byte[] buffer = new byte[MAX_BUFFER_SIZE];
                Socket s = stcp.Accept();

                s.Receive(buffer);
                try
                {
                    ssvr.Send(buffer, sizeof(VpnHeader), SocketFlags.None);
                    ssvr.Receive(buffer);
                    fixed (byte* pBuf = buffer)
                    {
                        if(((VpnHeader*)pBuf)->op == OP_CONNECTOK)
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

    [StructLayout(LayoutKind.Explicit, Pack = 1)]
    struct VpnHeader
    {
        [FieldOffset(0)]
        public uint ip;

        [FieldOffset(4)]
        public ushort port;

        [FieldOffset(6)]
        public byte op;
    }
}
