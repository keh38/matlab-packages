function data = read_moog_eng_data_v2(filepath)

n_words_header = 4;

fidMoog = fopen(filepath, 'r', 'ieee-be');
header = fread(fidMoog, n_words_header, 'uint32'); % header 4 words: magicVersion, numCommands, numFeedback, numAux

% fprintf('%s \n', fileMoog);
% fprintf('%x \n', header(1)); % deade1f5  
% fprintf('%x \n', header(2)); % 6 (for MOOG)
% fprintf('%x \n', header(3)); % 6 (for MOOG)
% fprintf('%x \n', header(4)); % 4 (for MOOG)

n_words_sample = 15 + sum(header(2:4)); % 31 for MOOG, 23 for XR

fseek(fidMoog, n_words_header * 4, 'bof'); % bypass header 4 words
dataMoog = fread(fidMoog, [n_words_sample, inf], 'float32');
fclose(fidMoog);

data.joystickAngle = dataMoog(10, :);
data.rollCmd  = dataMoog(16,:) * 180/pi;
data.pitchCmd = dataMoog(17,:) * 180/pi;
data.zCmd     = dataMoog(18,:);
data.xCmd     = dataMoog(19,:);
data.yawCmd   = dataMoog(20,:) * 180/pi;
data.yCmd     = dataMoog(21,:);
data.rollFeedback  = dataMoog(22,:) * 180/pi;
data.pitchFeedback = dataMoog(23,:) * 180/pi;
data.zFeedback     = dataMoog(24,:);
data.xFeedback     = dataMoog(25,:);
data.yawFeedback   = dataMoog(26,:) * 180/pi;
data.yFeedback     = dataMoog(27,:);

DataRateMoog = 60.24; % Hz, fixed
data.time = (0:size(data.rollCmd,2) -1 ) / DataRateMoog;
