using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace vpnagent
{
    public static class VPNConsts
    {
        public const int VPNAGENT_PORT = 8123;
        public const int SERVER_PORT = 8823;
        public const string SERVER_IP = "192.168.1.2";
        public const int OP_CONNECT = 1;
        public const int OP_CONNECTOK = 2;
        public const int OP_CONNECTNOK = 3;
        public const int BUFFER_SIZE = 4096;
        public const int PROT_UDP = 1;
        public const int PROT_TCP = 2;
    }
}
