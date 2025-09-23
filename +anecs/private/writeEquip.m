function writeEquip(fp, S)

writeLenAndString(fp, 'Hardware Configuration');
writeLenAndString(fp, S.DACname);
writeLenAndString(fp, S.ETname);

fwrite(fp, S.numStimChan, 'int32');
fwrite(fp, S.numAtten, 'int32');

for k = 1:S.numStimChan
   for j = 1:S.numAtten
      writeLenAndString(fp, S.AttenName{k, j});
   end
end
