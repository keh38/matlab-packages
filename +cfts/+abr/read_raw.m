function [raw_uV, fs] = read_raw(filePath)

fp = fopen(filePath, 'rb', 'ieee-be');

gain = fread(fp, 1, 'double');
fs = fread(fp, 1, 'double');

Y = [];
while true
   y = epl.file.read_prepended_1d_array(fp, 'double');
   if isempty(y), break; end
   
   Y = [Y; y];
end

fclose(fp);

raw_uV = Y / gain * 1e6;