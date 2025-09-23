% fn = 'C:\Users\hancock\OneDrive\Engineering\Polley\HTS\Sync\_Yu-TENS-Run033.json';

% Create sync map
hts.create_sync_map(fn);

% Read main data file
Data = hts.read_turandot_data(fn);
% Data is a cell array where each cell describes a single trial, including
% the stimulus conditions, behavioral result (if applicable), and the
% stimulus timing.

% Extract stimulus times (in tablet audio DSP time)
% Note: this example is specific to the 3-min stimulus paradigm comprising
% a single trial in which the stimulus is repeated many times. For
% multi-trial runs, the logic of extracting the key times will necessarily
% be a bit more complicated.
stimAudioTime = Data{1}.Events.time;

% Load the sync map
load(strrep(fn, '.json', '-Sync.mat'), 'Sync');

% Convert stimulus time from audio DSP time to EyeLink time:
% convert audio time to tablet time...
stimTabletTime = Sync.offsetAudioToTablet + Sync.driftAudioToTablet * stimAudioTime;
% ... convert tablet time to PC time ...
stimPCTime = Sync.offsetTabletToPC + Sync.driftTabletToPC * stimTabletTime;
% ... convert PC time to EyeLink time
stimEyeTime = Sync.offsetPCToEye + Sync.driftPCToEye * stimPCTime;

eyeData = hts.read_eyelink_data(strrep(fn, '.json', '.edf'));
stimEyeTime = stimEyeTime - eyeData.time(1);
eyeData.time = eyeData.time - eyeData.time(1);

figure
subplot(211);
plot(eyeData.time/1000, eyeData.pupilSize);
xline(stimEyeTime/1000);
xlabel('Time (s)');
ylabel('Pupil Size');

Fs = 1000;
T = 2;
npts = round(Fs * T);
tpupil = (0:npts-1) * 1000/Fs;
y = zeros(npts, 2);

navg = 0;
for k = 1:length(stimEyeTime)
   [~, ioffset] = min(abs(eyeData.time - stimEyeTime(k)));
   
   ysample = eyeData.pupilSize(ioffset + (0:npts-1), :);
   
   if all(ysample(:) > 1000)
      y = y + ysample;
      navg = navg + 1;
   end

end

y = y / navg;

subplot(212);
plot(tpupil/1000, y);
xlabel('Time (s)');
ylabel('Mean pupil size');
