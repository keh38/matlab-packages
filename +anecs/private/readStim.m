function S = readStim(fp, numChans, format)

blockLabel = readLenAndString(fp);
if ~isequal(blockLabel, 'Stimulus Info')
   error('Invalid equipment block.');
end

S.samplingRate = fread(fp, 1, 'float32');
S.totalDuration = fread(fp, 1, 'float32');
S.numRepetitions = fread(fp, 1, 'int32');
S.refreshInterval = fread(fp, 1, 'float32');
S.measTag = readLenAndString(fp);

for k = 1:numChans
   S.Chan(k) = anecsReadStimChan(fp, k-1, format);
end

%--------------------------------------------------------------------------
function S = anecsReadStimChan(fp, kc, format)

subLabel = readLenAndString(fp);
if ~isequal(subLabel, ['Channel ' num2str(kc)])
   error('Invalid stim chan block.');
end

S.name = readLenAndString(fp);
S.destination = readLenAndString(fp);
S.waveform = readLenAndString(fp);
S.param = readKParam(fp);
S.gate = anecsReadGate(fp);
S.modType = readLenAndString(fp);
if format == 1
   S.modActive = false;
else
   S.modActive = logical(fread(fp, 1, 'int8'));
end
S.modParam = readKParam(fp);
S.Level = anecsReadLevel(fp);


%--------------------------------------------------------------------------
function G = anecsReadGate(fp)

G.isActive = fread(fp, 1, 'char');
G.delay = fread(fp, 1, 'float32');
G.width = fread(fp, 1, 'float32');
G.risefall = fread(fp, 1, 'float32');

%--------------------------------------------------------------------------
function L = anecsReadLevel(fp)

L.mode = fread(fp, 1, 'int32');
L.value = fread(fp, 1, 'float32');
L.expr = readLenAndString(fp);
L.atten = fread(fp, 1, 'float32');
L.reference = fread(fp, 1, 'float32');


%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
