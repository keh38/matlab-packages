function [address, port] = Discover(name, useSubnet)

address = '';
port = -1;

if nargin < 2, useSubnet = false; end

try
   remoteAddress = '234.5.6.7';
   if useSubnet
      remoteAddress = net.GetSubnetAddress();
   end

   uSender = udpport();
   uSender.Timeout = 1;
   write(uSender, name, "uint8", remoteAddress, 10000);

   startTime = tic;
   while (uSender.NumBytesAvailable == 0 && toc(startTime) < 2)
   end

   if uSender.NumBytesAvailable > 0
      response = read(uSender, uSender.NumBytesAvailable, 'char');

      parts = split(response, ':');
      address = parts{1};
      port = str2double(parts{2});

      fprintf('%s [INFO] discovered ''%s'' at %s.%d\n', datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS'), name, address, port);
   else
      fprintf('%s [ERROR] timed out waiting for response from ''%s''\n', datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS'), name);
   end
catch ex
   fprintf('%s [ERROR] %s\n', datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS'), ex.message);
end
