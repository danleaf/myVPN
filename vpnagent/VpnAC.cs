using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net;
using System.Net.Sockets;
using System.Runtime;
using System.Runtime.InteropServices;

namespace vpnagent
{
    public delegate void TunnelReceiveCallback(byte[] buffer, int len);

    class VpnAC
    {
        Socket s = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

        public uint VirtualIP { get; set; }

        public int Send(byte[] buffer, int len)
        {
            return s.Send(buffer, len, SocketFlags.None);
        }

        public void RegisterReceiver(TunnelReceiveCallback callback)
        {
            StateObject so = new StateObject(callback);
            s.BeginReceive(so.buffer, 0, VPNConsts.BUFFER_SIZE, SocketFlags.None, new AsyncCallback(this.OnReceive), so);
        }

        public void Close()
        {
            s.Close();
        }

        private void OnReceive(IAsyncResult ar)
        {
            StateObject so = ar.AsyncState as StateObject;
            int len = s.EndReceive(ar);
            so.callback(so.buffer, len);
            s.BeginReceive(so.buffer, 0, VPNConsts.BUFFER_SIZE, SocketFlags.None, new AsyncCallback(this.OnReceive), so);
        }

        class StateObject
        {
            public byte[] buffer = new byte[VPNConsts.BUFFER_SIZE];
            public TunnelReceiveCallback callback;

            public StateObject(TunnelReceiveCallback callback)
            {
                this.callback = callback;
            }
        }
    }

    [StructLayout(LayoutKind.Explicit, Pack = 1)]
    public struct VPNHeader
    {
        [FieldOffset(0)]
        public uint sip;

        [FieldOffset(4)]
        public ushort sport;

        [FieldOffset(6)]
        public uint dip;

        [FieldOffset(10)]
        public ushort dport;

        [FieldOffset(12)]
        public byte prot;

        [FieldOffset(13)]
        public byte op;

        public IPEndPoint SourceEP
        {
            get { return new IPEndPoint(new IPAddress(sip), sport); }
        }

        public IPEndPoint DestEP
        {
            get { return new IPEndPoint(new IPAddress(dip), dport); }
        }
    }
}
