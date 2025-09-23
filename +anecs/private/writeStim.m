function writeStim(fp, S)

writeLenAndString(fp, 'Stimulus Info');

fwrite(fp, S.samplingRate, 'float32');
fwrite(fp, S.totalDuration, 'float32');
fwrite(fp, S.numRepetitions, 'int32');
fwrite(fp, S.refreshInterval, 'float32');

writeLenAndString(fp, S.measTag);

for k = 1:length(S.Chan)
   writeStimChan(fp, S.Chan(k), k-1);
end

%--------------------------------------------------------------------------
function S = writeStimChan(fp, S, kc)

writeLenAndString(fp, ['Channel ' num2str(kc)]);

writeLenAndString(fp, S.name);
writeLenAndString(fp, S.destination);
writeLenAndString(fp, S.waveform);

writeKParam(fp, S.param);

writeGate(fp, S.gate);

writeLenAndString(fp, S.modType);

fwrite(fp, S.modActive, 'int8');
writeKParam(fp, S.modParam);
writeLevel(fp, S.Level);

%--------------------------------------------------------------------------
function G = writeGate(fp, G)

fwrite(fp, G.isActive, 'char');
fwrite(fp, G.delay, 'float32');
fwrite(fp, G.width, 'float32');
fwrite(fp, G.risefall, 'float32');

%--------------------------------------------------------------------------
function writeLevel(fp, L)

fwrite(fp, L.mode, 'int32');
fwrite(fp, L.value, 'float32');
writeLenAndString(fp, L.expr);
fwrite(fp, L.atten, 'float32');
fwrite(fp, L.reference, 'float32');

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
