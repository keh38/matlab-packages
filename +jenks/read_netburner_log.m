function Data = read_netburner_log(fn)

dataFormat = {
    'int64', [1 1], 'time';
    'int32', [1 1], 'magicVersion';
    'int32', [1 1], 'numCommands';
    'int32', [1 1], 'numFeedbacks';
    'int32', [1 1], 'numAux';
    'int32', [1 1], 'runnerState';
    'int32', [1 1], 'activeAbortBits';
    'int32', [1 1], 'stickyAbortBits';
    'int32', [1 1], 'brakeServoBits';
    'int32', [1 1], 'preSyncPauseState';
    'int32', [1 1], 'postSyncPauseState';
    'int32', [1 1], 'serialNumber';
    'int32', [1 1], 'digInputs';
    'int32', [1 1], 'digOutputs';
    'single', [1 1], 'joystickAngle';
    'single', [1 1], 'joyRawAngle';
    'int32', [1 1], 'joystickButton';
    'int32', [1 1], 'subjResponse';
    'int32', [1 1], 'subjConfidence';
    'int32', [1 1], 'subjRespTime';
    'single', [1 1], 'rollCmd';
    'single', [1 1], 'pitchCmd';
    'single', [1 1], 'zCmd';
    'single', [1 1], 'xCmd';
    'single', [1 1], 'yawCmd';
    'single', [1 1], 'yCmd';
    'single', [1 1], 'rollFeedback';
    'single', [1 1], 'pitchFeedback';
    'single', [1 1], 'zFeedback';
    'single', [1 1], 'xFeedback';
    'single', [1 1], 'yawFeedback';
    'single', [1 1], 'yFeedback';
    'single', [1 1], 'aux1';
    'single', [1 1], 'aux2';
    'single', [1 1], 'aux3';
    'single', [1 1], 'aux4';
};


recordSize = 148;
finfo = dir(fn);
numRecords = floor(finfo.bytes / recordSize);

m = memmapfile(fn, ...
               'Format', dataFormat, ...
               'Repeat', numRecords);

d = m.data;

t = [d.time];
Data.time = double(t - t(1)) * 1e-7;
Data.joystickAngle = [d.joystickAngle];

Data.pitchCmd = [d.pitchCmd];
Data.rollCmd = [d.rollCmd];
Data.yawCmd = [d.yawCmd];
Data.xCmd = [d.xCmd];
Data.yCmd = [d.yCmd];
Data.zCmd = [d.zCmd];

Data.pitchFeedback = [d.pitchFeedback];
Data.rollFeedback = [d.rollFeedback];
Data.yawFeedback = [d.yawFeedback];
Data.xFeedback = [d.xFeedback];
Data.yFeedback = [d.yFeedback];
Data.zFeedback = [d.zFeedback];
