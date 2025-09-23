function S = readResp(fp)

blockLabel = readLenAndString(fp);
if ~isequal(blockLabel, 'Response Info')
   error('Invalid equipment block.');
end

S.saveSpikeTimes = fread(fp, 1, 'char');
S.saveRawWaveform = fread(fp, 1, 'char');
S.saveAvgWaveform = fread(fp, 1, 'char');

S.samplingRate = fread(fp, 1, 'float32');

numChans = fread(fp, 1, 'int32');
for k = 1:numChans
   S.Chan(k).isActive = fread(fp, 1, 'char');
   S.Chan(k).name = readLenAndString(fp);
   S.Chan(k).gain = fread(fp, 1, 'float32');
   S.Chan(k).useMic = fread(fp, 1, 'char');
   S.Chan(k).sens = fread(fp, 1, 'float32');   
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
