function address = GetHostAddress()

host = java.net.InetAddress.getLocalHost();
address = char(host.getHostAddress());

