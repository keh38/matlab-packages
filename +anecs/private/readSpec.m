function S = readSpec(fp)

S.measType = readLenAndString(fp);
S.samplingRate = fread(fp, 1, 'float32');
S.numPts = fread(fp, 1, 'int32');
S.numAvgs = fread(fp, 1, 'int32');
S.windowType = readLenAndString(fp);
S.stimWaveform = readLenAndString(fp);
S.stimChanNum = fread(fp, 1, 'int32');
S.attenuation = fread(fp, 1, 'float32');
S.numRespChan = fread(fp, 1, 'int32');

for k = 1:S.numRespChan
   S.Chan(k).name = readLenAndString(fp);
   npts = fread(fp, 1, 'int32');
   S.Chan(k).signal = fread(fp, npts, 'float32');
   npts = fread(fp, 1, 'int32');
   S.Chan(k).mag = fread(fp, npts, 'float32');
   npts = fread(fp, 1, 'int32');
   S.Chan(k).phase = fread(fp, npts, 'float32');
   S.Chan(k).units = readLenAndString(fp);
end


%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
