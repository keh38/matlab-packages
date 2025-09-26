function H = open(fn)
% OPEN_DATA_LOG - read header of analog data streamed to disk with Data Logger VI.
% Usage: H = open_data_log(fn)
%
% --- Inputs ---
% fn : filename
%
% --- Outputs ---
% DL : data structure 
%

% Open binary data file for reading
fp = fopen(fn, 'rb', 'b');
if fp < 0
   error('Error opening file.');
end

% Header information
headerSize = 0;

% Look for indicator
indicator = fread(fp, [1 10], '*char');
if strcmp(indicator, 'DataLogger')
   headerSize = headerSize + 10;
   format = fread(fp, 1, 'int32');
   headerSize = headerSize + 4;
else
   format = 1;
   frewind(fp);
end

% Number of channels
nch = fread(fp, 1, 'int32');
headerSize = headerSize + 4;

% Names of channels
names = cell(nch, 1);
for k = 1:nch
   n = fread(fp, 1, 'int32');
   headerSize = headerSize + 4;
   
   if n > 0
      names{k} = fread(fp, [1 n], '*char');
      names{k} = strrep(names{k}, ' ', '');
      headerSize = headerSize + n;
   else
      names{k} = sprintf('AI%02d', k);
   end
end

% Sampling rate
Fs = fread(fp, 1, 'double');
headerSize = headerSize + 8;

% "Frame size"
pts_per_read = fread(fp, 1, 'int32');
headerSize = headerSize + 4;

if format > 1
   t0 = fread(fp, 1, 'double');
   headerSize = headerSize + 8;
else
   t0 = NaN;
end

fclose(fp);

s = dir(fn);
nrecords = (s.bytes - headerSize) / (nch * pts_per_read * 8);

H.fn = fn;
H.format = format;
H.pts_per_read = pts_per_read;
H.nch = nch;
H.names = names;
H.Fs = Fs;
H.headerSize = headerSize;
H.nrecords = nrecords;
H.t0 = epl.util.convertLabVIEWTimeStamp(t0);% - seconds(H.pts_per_read / H.Fs);

%--------------------------------------------------------------------------
% END OF OPEN_DATA_LOG.M
%--------------------------------------------------------------------------
