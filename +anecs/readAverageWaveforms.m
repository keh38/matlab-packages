function [WF, T, Header] = readAverageWaveforms(varargin)

if ischar(varargin{1})
   Header = anecs.readHeader(varargin{1});
end

for k = 1:length(Header.Inner.vals)
   fn = strrep(Header.Info.fileName, '.anx', sprintf('.ch0avg0-%d.anx', k-1));
   y = readAverageWaveform(fn);

   if k == 1
      WF = NaN(length(Header.Inner.vals), length(y));
   end
   WF(k, :) = y;
end

