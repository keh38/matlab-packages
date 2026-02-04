function data = read_mic_data(fn)

fp = fopen(fn, 'rb');
fread(fp, 1, 'int64');
frameSize = fread(fp, 1, 'int32');
fclose(fp);

dataFormat = {
    'int64', [1 1], 'deviceTime';
    'int32', [1 1], 'frameSize';
    'double', [1 frameSize/8], 'mic';
};

recordSize = 8 + 4 + frameSize;
finfo = dir(fn);
numRecords = floor(finfo.bytes / recordSize);

m = memmapfile(fn, ...
               'Format', dataFormat, ...
               'Repeat', numRecords);

d = m.Data;

deviceTime = [d.deviceTime];
mic = [d.mic];

T0 = deviceTime(1);
t = double(deviceTime - T0) * 1e-7;



x = (0:numRecords-1) * frameSize/8;
[m, b] = epl.stats.linefit(x, t);

ti = b + m * (1:length(mic));

data.time = int64(ti * 1e7) + T0;
data.mic = mic;

