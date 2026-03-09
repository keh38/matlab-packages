function Data = read_joystick_log(fn, T0)

if nargin < 2, T0 = []; end

dataFormat = {
    'int64', [1 1], 'time';
    'double', [1 1], 'gain';
    'double', [1 1], 'joystick';
    'double', [1 1], 'raw';
    'uint8', [1 1], 'locked';
    'uint8', [1 1], 'sent';
};

recordSize = 34;
finfo = dir(fn);
numRecords = floor(finfo.bytes / recordSize);

m = memmapfile(fn, ...
               'Format', dataFormat, ...
               'Repeat', numRecords);

d = m.data;

t = [d.time];
<<<<<<< HEAD
Data.itime = t;
Data.time = double(t - t(1)) * 1e-7;
=======
if isempty(T0)
   T0 = t(1);
end

Data.time = double(t - T0) * 1e-7;
>>>>>>> 858bde258415c2372d085b2586c6e564786c1118
Data.gain = [d.gain];
Data.joystick = [d.joystick];
Data.raw = [d.raw];
Data.locked = [d.locked] > 0;
Data.sent = [d.sent] > 0;

clear m;
