function S = readLenAndString(fp)

nc = fread(fp, 1, 'int32');
if isempty(nc)
   S = '';
else
   S = char(fread(fp, nc, 'char')');
end