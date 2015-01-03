using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace vpnagent
{
    class Program
    {
        static void Main(string[] args)
        {
            TcpClientAgent ta = new TcpClientAgent();
            ta.Run();
            Thread.Sleep(3000);
            ta.End();
        }
    }
}
