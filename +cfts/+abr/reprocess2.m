function [data, header] = reprocess2(fn, varargin)

Level = [];
rejectThreshold = Inf;

epl.file.parse_propval_pairs(varargin{:});

[data, header] = cfts.abr.read(fn);

if isempty(Level)
   Level = header.Info.Levels;
end

for k = 1:length(Level)
   rawDataPath = [fn sprintf('.%d.raw', Level(k))];
   d = reprocess_one(rawDataPath, header, rejectThreshold);
   d.Level = Level(k);

   if k == 1
      data = d;
   else
      data(k) = d;
   end
end

end

%--------------------------------------------------------------------------
function data = reprocess_one(fn, header, rejectThreshold)

data = [];
y = cfts.abr.read_raw(fn);
y = y - mean(y);

fs = header.Params.Response.Fs_Hz;
rate = header.Params.Stimulus.Rep_rate_sec;
% y = epl.signals.filter_abr(y, fs, 4, 100, 5000);

nptsPerTrial = ceil(fs / rate);

y = reshape(y, nptsPerTrial, []);

A = zeros(nptsPerTrial, 1);
B = A;
na = 0;
nb = 0;

for k = 1:size(y, 2)
   if range(y(:, k)) < rejectThreshold
      if mod(k,2) == 1
         A = A + y(:,k);
         na = na + 1;
      else
         B = B + y(:, k);
         nb = nb + 1;
      end
   end
end

data.time = (0:nptsPerTrial-1)' * 1000 / fs;
data.crit = rejectThreshold;
data.A = A / na;
data.B = B / nb;
data.neural = (A + B) / (na + nb);

end

%--------------------------------------------------------------------------
% END OF CFTS.ABR.REPROCESS2.M
%--------------------------------------------------------------------------