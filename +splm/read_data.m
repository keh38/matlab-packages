function D = read_data(fn)
% READ_SPL_METER_DATA -- does exactly that.
% Usage: [Freq, Mag, H] = read_spl_meter_data(FN)
% 
% Inputs:
% FN : filename
%
% Outputs:
% Freq : frequency, Hz
% Mag : magnitude spectrum, dB
% H : header structure
%

if ~endsWith(fn, '.splm')
   fn = [fn '.splm'];
end

text = fileread(fn);

[D, data] = epl.file.parse_ini(text);

lines = splitlines(data);

imag = find(startsWith(lines, 'Mag'));
if ~isempty(imag)
   D.mag = sscanf(lines{imag+1}, '%g\t', Inf);
   df = 1000 / D.Settings.Interval_ms;
   D.freq = (0:length(D.mag)-1) * df;
end
   
iphase = find(startsWith(lines, 'Phase'));
if ~isempty(iphase)
   D.phase = sscanf(lines{iphase+1}, '%g\t', Inf);
end
   
itime = find(startsWith(lines, 'Time'));
if ~isempty(itime)
   D.waveform = sscanf(lines{itime+1}, '%g\t', Inf);
   dt = 1000 / D.Settings.Sampling_Rate_Hz;
   D.time = (0:length(D.waveform)-1) * dt;
end
   
