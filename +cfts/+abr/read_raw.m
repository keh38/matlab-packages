function [raw_uV, fs] = read_raw(filePath)

s = dir(filePath);         
filesize = s.bytes; 

fp = fopen(filePath, 'rb', 'ieee-be');

gain = fread(fp, 1, 'double');
fs = fread(fp, 1, 'double');
nread = fread(fp, 1, 'int32');

dataLength = filesize - 2 * 8;
numPerRead = 4 + nread * 8;
nbuf = dataLength / numPerRead;

Y = NaN*ones(nbuf * nread, 1);

fseek(fp, -4, 'cof');
offset = 0;
while true
   y = epl.file.read_prepended_1d_array(fp, 'double');
   if isempty(y), break; end
   
   Y(offset + (1:length(y))) = y;
   offset = offset + length(y);
end

fclose(fp);

raw_uV = Y / gain * 1e6;