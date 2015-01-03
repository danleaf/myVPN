using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net;
using System.Net.Sockets;

namespace vpnagent
{
    public delegate void VpnReceiveCallback(byte[] buffer, int len);

    public class VpnAC
    {
        Socket s = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

        public uint VirtualIP { get; set; }

        public int Send(byte[] buffer, int len)
        {
            return s.Send(buffer, len, SocketFlags.None);
        }

        public void RegisterReceiver(VpnReceiveCallback callback)
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
            public VpnReceiveCallback callback;

            public StateObject(VpnReceiveCallback callback)
            {
                this.callback = callback;
            }
        }
    }
}
