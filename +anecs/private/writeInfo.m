function writeInfo(fp, S)

writeLenAndString(fp, 'Experiment Info');
writeLenAndString(fp, S.name);
writeLenAndString(fp, S.description);
writeLenAndString(fp, S.paramFile);
writeLenAndString(fp, S.fileName);
writeLenAndString(fp, S.fileDate);
writeLenAndString(fp, S.version);

fwrite(fp, S.trackNum, 'int32');
fwrite(fp, S.unitNum, 'int32');
fwrite(fp, S.measNum, 'int32');
fwrite(fp, S.runNum, 'int32');

fwrite(fp, 0, 'int32'); % S.Metrics = readKParam(fp);