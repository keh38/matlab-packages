function DT = convertHighPrecisionTimeStampToDateTime(hpt)

dt = datetime(hpt, 'ConvertFrom', 'epochtime', 'Epoch', datetime(1601,1,1,'TimeZone','utc'), 'TicksPerSecond', 1e7, 'TimeZone', 'UTC');
dt.Format = 'yyyy-MM-dd HH:mm:ss.SSS';
dt.TimeZone = 'local';

if nargout > 0
   DT = dt;
   return;
end

fprintf('%ld = %s\n', hpt, dt);