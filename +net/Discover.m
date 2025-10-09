function [address, port] = Discover(name)

address = '';
port = -1;

try
   uSender = udpport;
   uSender.Timeout = 1;
   write(uSender, name, "uint8", "234.5.6.7", 10000);

   startTime = tic;
   while (uSender.NumBytesAvailable == 0 && toc(startTime) < 2)
   end

   response = read(uSender, uSender.NumBytesAvailable, 'char');

   parts = split(response, ':');
   address = parts{1};
   port = str2double(parts{2});
catch ex
   fprintf('%s [ERROR] %s\n', datestr(now, 'YYYY-mm-dd HH:MM:SS.fff'), ex.message);
end
