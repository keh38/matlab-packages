function [Y, T] = recompute_average_from_raw_data(fn)
%
% Shows how to recompute the time-domain average from the raw data stream.
%

% Read the header file to extract useful parameters
header = epl.file.parse_ini_config(strrep(fn, '.0.3.raw', '.header.txt'));

Fs = header.Params.Response.Sampling_Rate_Hz;
nchan = sum([header.Params.Response.Electrodes.enabled]);

scaleFactor = 1e6 / header.Params.Response.Electrodes(1).Gain;

% Initialize raw file read
hraw = ephys.open_raw(fn, nchan);

ymat = NaN(hraw.npairs, hraw.pts_per_rep);

ielectrode = 2; % data have two channels, first is the sync pulse

nkeep = 0;
for k = 1:hraw.npairs
   
   [yframe, hraw] = ephys.read_raw(hraw, 2);
   yframe = yframe(ielectrode, :);
   
   if k == 1, continue; end % empty trial
    
   y = zeros(1, 2*hraw.pts_per_rep);

   y = y + yframe * scaleFactor;
   
   y = y - mean(y);
   yo = y(1:end/2);
   ye = y(end/2+1:end);

   nkeep = nkeep + 1;
   ymat(nkeep, :) = 0.5*(yo + ye);
end

ephys.close_raw(hraw);

Y = mean(ymat(1:nkeep, :));
T = (0:hraw.pts_per_rep-1) * 1000 / Fs;

