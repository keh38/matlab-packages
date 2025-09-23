function extract_raw_traces(logPath)
% elektra.extract_raw_traces -- extract raw traces from .log.bin files
% Usage: elektra.extract_raw_traces(logPath)
%
% --- Inputs ---
% logPath : path to main Elektra .log file
%

% Read main data file
[data, header] = elektra.read_run(logPath);

% Identify sequence variables
xvar = [];
yvar = [];

seq = header.Config.Sequence;

for k = 1:length(seq.Variables)
   seqVar = struct(...
      'name', seq.Variables(k).SeqVar.Name, ...
      'values', eval(seq.Variables(k).SeqVar.Expr), ...
      'property', klib.file.create_valid_substruct([seq.Variables(k).SeqVar.Channel '.' seq.Variables(k).SeqVar.Property]) ...
      );

   if strcmpi(seq.Variables(k).SeqVar.Dim, 'x') && isempty(xvar)
      xvar = seqVar;
   elseif strcmpi(seq.Variables(k).SeqVar.Dim, 'y') && isempty(yvar)
      yvar = seqVar;
   end
end

% Find video folder (which contains .log.bin files)
[logFolder, filestem] = fileparts(logPath);
if isempty(logFolder)
   logFolder = pwd;
end
videoFolder = strrep(logFolder, 'Data', 'Video');

% Loop through data once to compute baseline mean and variance, and mean
% frame interval

sumFME = 0;
sumFME2 = 0;
nframes = 0;

tmin = Inf;
tmax = -Inf;
dt = NaN*ones(size(data));

fprintf('Computing statistics: ');
for k = 1:length(data)
   fprintf('%4d / %4d', k, length(data));

   binLogFile = fullfile(videoFolder, sprintf('%s.%03d.log.bin', filestem, k));
   [fme, t] = elektra.read_bin_log(binLogFile);

   nframes = nframes + length(fme);
   sumFME = sumFME + sum(fme);
   sumFME2 = sumFME2 + sum(fme.^2);

   tmin = min(tmin, t(1));
   tmax = max(tmax, t(end));

   dt(k) = mean(diff(t));
   fprintf(repmat('\b', 1, 11));
end
fprintf('done.\n');

fmeMean = sumFME / nframes;
fmeStdDev = sqrt(sumFME2/nframes - fmeMean^2);

dt = mean(dt);

t1 = ceil(tmin/dt) * dt;
t2 = floor(tmax/dt) * dt;
Time = t1:dt:t2;

% Loop through data again to z-score and interpolate
Nx = length(xvar.values);
Ny = 1;
if ~isempty(yvar)
   Ny = length(yvar.values);
end

if Ny == 1
   FME = NaN*ones(Nx, header.Config.Sequence.Repeats, length(Time));
else
   FME = NaN*ones(Ny, Nx, header.Config.Sequence.Repeats, length(Time));
end

Ntrials = zeros(Ny, Nx);

fprintf('Computing Z-scores: ');
for k = 1:length(data)
   fprintf('%4d / %4d', k, length(data));

   ix = find(xvar.values == subsref(data{k}, xvar.property));
   iy = 1;
   if Ny > 1
      iy = find(yvar.values == subsref(data{k}, yvar.property));
   end

   binLogFile = fullfile(videoFolder, sprintf('%s.%03d.log.bin', filestem, k));
   [fme, time] = elektra.read_bin_log(binLogFile);

   fme = (fme - fmeMean) / fmeStdDev;
   fme = interp1(time, fme, Time);

   Ntrials(iy, ix) = Ntrials(iy, ix) + 1;
   if Ny == 1
      FME(ix, Ntrials(iy, ix), :) = fme;
   else
      FME(iy, ix, Ntrials(iy, ix), :) = fme;
   end

   fprintf(repmat('\b', 1, 11));
end
fprintf('done.\n');

% Save data
fprintf('Saving data...');
matFile = fullfile(logFolder, sprintf('%s.mat', filestem));
save(matFile, 'Time', 'FME', 'xvar', 'yvar', 'Ntrials');
fprintf('finished.\n\n');