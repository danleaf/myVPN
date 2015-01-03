using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Runtime.InteropServices;
using System.Net;

namespace vpnagent
{
    /// <summary>
    /// Consts
    /// </summary>
    public static class VPNConsts
    {
        public const int VPNAGENT_PORT = 8123;
        public const int SERVER_PORT = 8823;
        public const int BUFFER_SIZE = 4096;
        public const byte MASK_TOSERVER = 128;
        public const byte OP_CONNECT = 1;
        public const byte OP_CONNECTOK = 2;
        public const byte OP_CONNECTNOK = 3;
        public const byte PROT_UDP = 1;
        public const byte PROT_TCP = 2;
        public static IPAddress LOOPBACK = IPAddress.Parse("127.0.0.1");
    }

    [StructLayout(LayoutKind.Explicit, Pack = 1)]
    public struct VPNHeader
    {
        [FieldOffset(0)]
        public uint SourceIP;

        [FieldOffset(4)]
        public ushort SourcePort;

        [FieldOffset(6)]
        public uint DestIP;

        [FieldOffset(10)]
        public ushort DestPort;

        [FieldOffset(12)]
        public byte Protocol;

        [FieldOffset(13)]
        public byte Signature;

        public IPEndPoint SourceEndPoint
        {
            get { return new IPEndPoint(new IPAddress(SourceIP), SourcePort); }
        }

        public IPEndPoint DestEndPoint
        {
            get { return new IPEndPoint(new IPAddress(DestIP), DestPort); }
        }

        public byte Operation
        {
            get { return (byte)(Signature & ~VPNConsts.MASK_TOSERVER); }
        }
    }
}
