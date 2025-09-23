function [Y, Navg] = readAverageWaveform(FN)

fp = fopen(FN, 'rb');
if fp < 0
   error('Cannot open file for reading: %s', FN); 
end

Navg = fread(fp, 1, 'int32');
Y = fread(fp, Inf, 'float32');

fclose(fp);

