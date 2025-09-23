function [y, t_ms, Fs] = read_avg(fn, header)
% ephys.read_avg -- read average response data from EPhys data file.
% Usage: [y, t_ms] = ephys.read_avg(fn)
%

if nargin < 2
   header = epl.file.parse_ini_config(strrep(fn, '.0.avg', '.header.txt')); 
end

fp = fopen(fn, 'rb', 'ieee-be');
if fp < 0
   error('Could not open EPhys file: %s', fn);
end

if ~isempty(header.Params.Sequences)
   y = cell(length(header.Params.Sequences.Values), 1);
else
   y = cell(1);
end

for k = 1:length(y)
   y_odd = epl.file.read_prepended_2d_array(fp);
   y_even = epl.file.read_prepended_2d_array(fp);
   y{k} = 0.5 * (y_odd + y_even);
   
   if feof(fp)
      break;
   end
end

fclose(fp);

Fs = header.Params.Response.Sampling_Rate_Hz;
t_ms = (0:length(y{1})-1) * 1000 / Fs;

%--------------------------------------------------------------------------
% END OF READ_AVG.M
%--------------------------------------------------------------------------

