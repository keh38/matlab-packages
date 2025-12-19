function [Data, Params] = read_series(filestem)

flist = dir([filestem '-*.tsv']);

freq = NaN*ones(size(flist));

for kf = 1:length(flist)
   [data, header] = cfts.fabr.read(fullfile(flist(kf).folder, flist(kf).name));

   freq(kf) = header.Info.Frequency_kHz;
end
level = data.level;

amplitude = NaN*ones(length(data.level), length(freq));

[freq, isort] = sort(freq);

for k = 1:length(flist)
   kf = isort(k);
   data = cfts.fabr.read(fullfile(flist(kf).folder, flist(kf).name));
   
   amplitude(:, kf) = range(data.neural);
end

Data.freq = freq;
Data.level = level;
Data.amplitude = amplitude;

Params = header.Params;