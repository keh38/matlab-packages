function Data = read_tobii_data(fn)

dataFormat = {
    'int64', [1 1], 'deviceTime';
    'int64', [1 1], 'systemTime';
    'uint8', [1 1], 'leftGazeValid';
    'single', [1 1], 'leftX';
    'single', [1 1], 'leftY';
    'single', [1 1], 'leftPupil';
    'uint8', [1 1], 'rightGazeValid';
    'single', [1 1], 'rightX';
    'single', [1 1], 'rightY';
    'single', [1 1], 'rightPupil';
};

recordSize = 42;
finfo = dir(fn);
numRecords = floor(finfo.bytes / recordSize);

m = memmapfile(fn, ...
               'Format', dataFormat, ...
               'Repeat', numRecords);

d = m.Data;

Data.deviceTime = double([d.deviceTime]) * 1e-6;
Data.systemTime = double([d.systemTime]) * 1e-6;

Data.leftPupil = [d.leftPupil];
Data.rightPupil = [d.rightPupil];

isValid = logical([d.leftGazeValid]);
Data.leftX = [d.leftX];
Data.leftX(~isValid) = NaN;

Data.leftY = [d.leftY];
Data.leftY(~isValid) = NaN;

isValid = logical([d.rightGazeValid]);
Data.rightX = [d.rightX];
Data.rightX(~isValid) = NaN;

Data.rightY = [d.rightY];
Data.rightY(~isValid) = NaN;
