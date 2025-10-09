function DL = read_at_time(H, T0, timePre, timePost)

if nargin < 3, timePre = 1; end
if nargin < 4, timePost = timePre; end

if ischar(H)
   H = epl.logger.open(H);
end

if ischar(T0)
   T0 = datetime(T0, 'InputFormat', 'MM/dd/yyyy HH:mm:ss.SSS', 'TimeZone', 'local');
end

toffset = seconds(T0 - H.t0);

tfirst = toffset - timePre;
nsamples = round(tfirst * H.Fs);
firstBuffer = max(1, floor(nsamples / H.pts_per_read));

tlast = toffset + timePost;
nsamples = round(tlast * H.Fs);
lastBuffer = min(H.nrecords, ceil(nsamples / H.pts_per_read));

DL = epl.logger.read(H, firstBuffer, lastBuffer - firstBuffer + 1);
DL.Tref = toffset;

