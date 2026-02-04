function Data = read_data(fn)

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

Data.deviceTime = [d.deviceTime];
Data.systemTime = [d.systemTime];
Data.leftPupil = [d.leftPupil];
Data.rightPupil = [d.rightPupil];

Data.leftX = [d.leftX];
Data.leftY = [d.leftY];
Data.leftGazeValid = logical([d.leftGazeValid]);

Data.rightX = [d.rightX];
Data.rightY = [d.rightY];
Data.rightGazeValid = logical([d.rightGazeValid]);
