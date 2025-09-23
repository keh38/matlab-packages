function S = readSequence(fp, fileFormat)

blockLabel = readLenAndString(fp);
if ~isequal(blockLabel, 'Sequence')
   error('Invalid sequence block.');
end

S.channels = readLenAndString(fp);
S.seqVar = readLenAndString(fp);
S.units = readLenAndString(fp);

S.stepMode = fread(fp, 1, 'int32');
S.seqOrder = fread(fp, 1, 'int32');

S.startExpr = readLenAndString(fp);

S.start = fread(fp, 1, 'float32');
S.end = fread(fp, 1, 'float32');
S.stepSize = fread(fp, 1, 'float32');
S.nsteps = fread(fp, 1, 'int32');
S.setWhich = fread(fp, 1, 'int32');

S.isOddball = fread(fp, 1, 'char');
S.oddballFract = fread(fp, 1, 'float32');
S.standardValue = fread(fp, 1, 'float32');

if fileFormat >= 3
   n = fread(fp, 1, 'int32');
   fread(fp, n, 'char');
end

npts = fread(fp, 1, 'int32');
S.vals = fread(fp, npts, 'float32');
