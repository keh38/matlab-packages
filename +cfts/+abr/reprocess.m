function [data, header] = reprocess(fn, varargin)

Level = [];

epl.file.parse_propval_pairs(varargin{:});

[data, header] = cfts.abr.read(fn);

if isempty(Level)
   Level = header.Info.Levels;
end

for k = 1:length(Level)
   rawDataPath = [fn sprintf('.%d.raw', Level(k))];
   d = reprocess_one(rawDataPath, header);

   if k == 1
      data = d;
   else
      data.neural = [data.neural d.neural];
      data.cm = [data.cm d.cm];
   end
end
data.level = Level;

end

%--------------------------------------------------------------------------
function data = reprocess_one(fn, header)

data = [];
y = cfts.abr.read_raw(fn);

fs = header.Params.Response.Fs_Hz;
rate = header.Params.Stimulus.Rep_rate_sec;

nptsPerTrial = ceil(fs / rate);

y = reshape(y, nptsPerTrial, []);

neural = zeros(nptsPerTrial, 1);
cm = neural;
nkeep = 0;

rejectThreshold = header.Params.Reject;
rejectThreshold = inf;

for k = 1:2:size(y, 2)
   a = y(:, k);
   b = y(:, k+1);
   if range(a) < rejectThreshold && range(b) < rejectThreshold
      neural = neural + a + b;
      cm = cm + a - b;

      nkeep = nkeep + 2;
   end
end

data.time = (0:nptsPerTrial-1) * 1000 / fs;
data.neural = neural / nkeep;
data.cm = cm / nkeep;

end

%--------------------------------------------------------------------------
% END OF CFTS.ABR.REPROCESS.M
%--------------------------------------------------------------------------