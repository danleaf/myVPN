using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net;
using System.Net.Sockets;

namespace vpnagent
{
    class UdpAgent
    {
        Socket sudp = new Socket(AddressFamily.InterNetwork, SocketType.Dgram, ProtocolType.Udp);

        public UdpAgent()
        {
            sudp.Bind(new IPEndPoint(IPAddress.Any, VPNConsts.VPNAGENT_PORT));
        }
    }
}
