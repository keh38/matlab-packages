function response = SendMessageReceiveString(address, port, message, data)

response = '';

try
   t = tcpclient(address, port, "Timeout", 5, "ConnectTimeout", 10);

   command = message;
   if nargin > 3
      command = [command ':' data];
   end

   nbytes = int32(length(command));
   t.write([typecast(nbytes, 'uint8') uint8(command)]);
   t.flush();

   result = t.read(1, 'int32');
   if result > 0
      n = t.read(1, 'int32');
      response = t.read(n, 'char');
   end

   clear t;
catch ex
   fprintf('%s [ERROR] %s'\n', datestr(now, 'YYYY-mm-dd HH:MM:SS.fff'), ex.message);
end