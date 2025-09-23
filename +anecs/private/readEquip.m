function S = readEquip(fp)

blockLabel = readLenAndString(fp);
if ~isequal(blockLabel, 'Hardware Configuration')
   error('Invalid equipment block.');
end

S.DACname = readLenAndString(fp);
S.ETname = readLenAndString(fp);

S.numStimChan = fread(fp, 1, 'int32');
S.numAtten = fread(fp, 1, 'int32');

for k = 1:S.numStimChan
   for j = 1:S.numAtten
      S.AttenName{k, j} = readLenAndString(fp);
   end
end
