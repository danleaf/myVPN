using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Runtime;
using System.Runtime.InteropServices;

namespace vpnagent
{
    [StructLayout(LayoutKind.Explicit, Pack = 1)]
    public struct VpnHeader
    {
        [FieldOffset(0)]
        public uint ip;

        [FieldOffset(4)]
        public ushort port;

        [FieldOffset(6)]
        public byte op;
    }

    public static class VPNConsts
    {
        public const int VPNAGENT_PORT = 8123;
        public const int SERVER_PORT = 8823;
        public const string SERVER_IP = "192.168.1.2";
        public const int OP_CONNECTOK = 2;
        public const int MAX_BUFFER_SIZE = 4096;
    }
}
