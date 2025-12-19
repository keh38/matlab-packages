function address = GetSubnetAddress()

myAddress = net.GetHostAddress();

if startsWith(myAddress, '169.254')
   address = '169.254.255.255';
elseif startsWith(myAddress, '11.12.13')
   address = '11.12.13.255';
else
   address = '192.168.1.255';
end

