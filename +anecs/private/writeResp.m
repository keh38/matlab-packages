function writeResp(fp, S)

writeLenAndString(fp, 'Response Info');

fwrite(fp, S.saveSpikeTimes, 'char');
fwrite(fp, S.saveRawWaveform, 'char');
fwrite(fp, S.saveAvgWaveform, 'char');

fwrite(fp, S.samplingRate, 'float32');

fwrite(fp, length(S.Chan), 'int32');
for k = 1:length(S.Chan)

   fwrite(fp, S.Chan(k).isActive, 'char');
   writeLenAndString(fp, S.Chan(k).name);
   fwrite(fp, S.Chan(k).gain, 'float32');
   fwrite(fp, S.Chan(k).useMic, 'char');
   fwrite(fp, S.Chan(k).sens, 'float32');
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
