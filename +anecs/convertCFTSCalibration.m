function convertCFTSCalibration(fn)

c = cfts.calib.read(fn);

a = anecs.readCalibration(fullfile(fileparts(which('anecs.readCalibration')), 'dummy.cal'));

a.Info.description = 'converted from CFTS calibration';
a.Info.paramFile = '';
a.Info.fileDate = c.Header.Info.Date;

a.Spec.Chan.mag = [0 c.Mag-14];
a.Spec.Chan.phase = [0 c.Phase];
a.Spec.samplingRate = 195312.5 / 1000;
a.Spec.numPts = 2 * length(a.Spec.Chan.mag);

fp = fopen(strrep(fn, '.calib', '.cal'), 'wb', 'ieee-le');

% Read calibration file header
writeLenAndString(fp, 'This is an ANECS spectrum data file!')
writeInfo(fp, a.Info);
writeEquip(fp, a.Equip);
writeStim(fp, a.Stim);
writeResp(fp, a.Resp);
writeSpecWin(fp, a.A);
writeSpecWin(fp, a.B);
writeSpec(fp, a.Spec);

fclose(fp);