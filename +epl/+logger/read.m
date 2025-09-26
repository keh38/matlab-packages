function DL = read(H, First, N)
% READ_DATA_LOG - read analog data streamed to disk with Data Logger VI.
% Usage: DL = read_data_log(fn)
%
% --- Inputs ---
% fn : filename
%
% --- Outputs ---
% DL : data structure 
%

if nargin < 2, First = 1; end
if nargin < 3, N = Inf; end

if ischar(H)
   H = epl.logger.open(H);
end

First = max(First, 1);
N = min(N, H.nrecords - First + 1);

Y = NaN(N * H.pts_per_read, H.nch);

fp = fopen(H.fn, 'rb', 'b');
if fp < 0
   error('Error opening file.');
end

fseek(fp, H.headerSize + (First-1)*H.pts_per_read*H.nch*8, 'bof');

offset = 0;
for k = 1:N
   y = fread(fp, [H.pts_per_read H.nch], 'double');
   Y(offset + (1:H.pts_per_read), :) = y;
   offset = offset + H.pts_per_read;
end

fclose(fp);

% Initialize data log structure: time vector + 1 field for each input
% channel
s = cell(H.nch * 2, 1);
for k = 1:H.nch
   s{2*k-1} = H.names{k};
end

DL = struct('time', [], s{:});

% Fill in channel data
for k = 1:H.nch
   DL.(H.names{k}) = Y(:, k);
end

% Create time vector
DL.time = ((First-1)*H.pts_per_read + (0:size(Y, 1)-1))' / H.Fs;


%--------------------------------------------------------------------------
% END OF READ_DATA_LOG.M
%--------------------------------------------------------------------------
