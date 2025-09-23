function edf2f64(edfPath)

edf = Edf2Mat(edfPath);
Fs = edf.RawEdf.RECORDINGS(1).sample_rate;

fp = fopen(strrep(edfPath, '.edf', '.edf.f64'), 'wb');

fwrite(fp, Fs, 'double');
fwrite(fp, edf.Samples.pupilSize, 'double');

fclose(fp);