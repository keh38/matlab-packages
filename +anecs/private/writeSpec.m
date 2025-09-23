function writeSpec(fp, S)

writeLenAndString(fp, S.measType);
fwrite(fp, S.samplingRate, 'float32');
fwrite(fp, S.numPts, 'int32');
fwrite(fp, S.numAvgs, 'int32');
writeLenAndString(fp, S.windowType);
writeLenAndString(fp, S.stimWaveform);
fwrite(fp, S.stimChanNum, 'int32');
fwrite(fp, S.attenuation, 'float32');
fwrite(fp, S.numRespChan, 'int32');

for k = 1:S.numRespChan
   writeLenAndString(fp, S.Chan(k).name);
   fwrite(fp, length(S.Chan(k).signal), 'int32');
   fwrite(fp, S.Chan(k).signal, 'float32');
   fwrite(fp, length(S.Chan(k).mag), 'int32');
   fwrite(fp, S.Chan(k).mag, 'float32');
   fwrite(fp, length(S.Chan(k).phase), 'int32');
   fwrite(fp, S.Chan(k).phase, 'float32');
   writeLenAndString(fp, S.Chan(k).units);
end


%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
