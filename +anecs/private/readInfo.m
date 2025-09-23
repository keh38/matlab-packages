function S = readInfo(fp)

blockLabel = readLenAndString(fp);
if ~isequal(blockLabel, 'Experiment Info')
   error('Invalid info block.');
end

S.name = readLenAndString(fp);
S.description = readLenAndString(fp);
S.paramFile = readLenAndString(fp);
S.fileName = readLenAndString(fp);
S.fileDate = readLenAndString(fp);
S.version = readLenAndString(fp);

S.trackNum = fread(fp, 1, 'int32');
S.unitNum = fread(fp, 1, 'int32');
S.measNum = fread(fp, 1, 'int32');
S.runNum = fread(fp, 1, 'int32');

S.Metrics = readKParam(fp);