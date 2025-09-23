function [FME, Time] = read_bin_log(fn)

fp = fopen(fn, 'rb', 'b');

n = fread(fp, 1, 'int32');

time = NaN*ones(n, 1);
fme = time;
code = time;

for k = 1:n
   frame = fread(fp, 1, 'int32'); %#ok<NASGU> 
   time(k) = fread(fp, 1, 'double');
   frameInFile = fread(fp, 1, 'int32'); %#ok<NASGU> 
   code(k) = double(fread(fp, 1, 'int32'));
   fme(k) = fread(fp, 1, 'double');

   slen = fread(fp, 1, 'int32');
   event = char(fread(fp, slen, 'char')'); %#ok<NASGU> 
end

fclose(fp);

FME = fme(code == 0);
Time = time(code == 0) - time(code == 2);