function S = readSpecWin(fp)

S.indicator = readLenAndString(fp);
for k = 1:5
   S.entry(k).name = readLenAndString(fp);
   S.entry(k).val = NaN*ones(1, 4);
   for j = 1:4
      S.entry(k).val(j) = fread(fp, 1, 'float32');
   end
   S.entry(k).byte = fread(fp, 1, 'char');
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
