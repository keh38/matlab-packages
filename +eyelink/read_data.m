function S = eyelink_read_data(fn)
% $Date: 2022-11-30 08:19:55 -0500 (Wed, 30 Nov 2022) $
% $Rev: 879 $

oldFolder = pwd;
[folder, fn] = fileparts(fn);
cd(folder);

edf = Edf2Mat([fn '.edf']);

cd(oldFolder);

S.sampleRate = edf.RawEdf.RECORDINGS(1).sample_rate;

S.time = edf.Samples.time;
S.pupilSize = edf.Samples.pupilSize;

if edf.Samples.gx(1,1) ~= edf.MISSING_DATA_VALUE
   S.gazeX = edf.Samples.gx(:,1);
   S.gazeY = edf.Samples.gy(:,1);
elseif edf.Samples.gx(1,2) ~= edf.MISSING_DATA_VALUE
   S.gazeX = edf.Samples.gx(:,2);
   S.gazeY = edf.Samples.gy(:,2);
else
   warning('No gaze data found.');
end

% hdata(3) = target distance * 10 mm => /10 => mm => /10 => cm
S.targetDistance_cm = edf.Samples.hdata(1, 3) / 100; 

S.events.info = edf.Events.Messages.info;
S.events.time = edf.Events.Messages.time;

S.Tmax = max(max(S.time), max(S.events.time));

itr = contains(S.events.info, 'Trial:');
S.ttrial = S.events.time(itr);
S.NumTrials = length(S.ttrial);
