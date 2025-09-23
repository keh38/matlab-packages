function writeSpecWin(fp, S)

writeLenAndString(fp, S.indicator);
for k = 1:length(S.entry)
   writeLenAndString(fp, S.entry(k).name);
   fwrite(fp, S.entry(k).val, 'float32');
   fwrite(fp, S.entry(k).byte, 'char');
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
