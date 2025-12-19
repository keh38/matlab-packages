function Sync = create_sync_map(fn)
% CREATE_SYNC_MAP -- compiles synchronization data from HTS measurement.
% Usage: create_sync_map(filename)
% 
% filename : path to main .json file 
%
% Outputs a .mat file containing a structure 'Sync' whose fields describe
% the transformations between various clocks.
%

% 1. Stream Sync log: map tablet time to PC time
fnStreamSync = strrep(fn, '.json', '-StreamSync.log');

opts = detectImportOptions(fnStreamSync);
opts.VariableTypes{2} = 'int64';
opts.VariableTypes{3} = 'int64';

data = readtable(fnStreamSync, opts);

ifilt = find(strcmp(data.DataStream, 'HEARING.TEST.SUITE.SYNC'));

% The time sync message is exchanged four times. The remote (i.e. tablet)
% timestamp corresponds to the message with the lowest round trip time
% (RTT). 
rtt = [data.RTT1(ifilt) data.RTT2(ifilt) data.RTT3(ifilt) data.RTT4(ifilt)];
rtt = min(rtt, [], 2);

% Important: system times are acquired using
% GetSystemTimePreciseAsFileTime() which stores the time using 64-bit
% integers. In order to do floating point math (linear regression) on these
% times without losing precision, we need to reference them to some recent
% time. Doesn't matter what it is, we just need to be consistent. We will
% use the first PC timestamp in the -StreamSync.log for this purpose.
Sync.T0 = data.LocalTime(1);

tlocal = double(data.LocalTime(ifilt) - Sync.T0) * 1e-7;
% Subtract off half the round-trip-time
tstream = double(data.StreamTime(ifilt) - Sync.T0) * 1e-7 - 1e-3 * rtt(:) / 2;

[m, b] = epl.stats.linefit(tstream, tlocal);

Sync.offsetTabletToPC = b;
Sync.driftTabletToPC = m;

% 1b. Stream Sync log: other data streams
streamNames = unique(data.DataStream);
for k = 1:length(streamNames)
   if strcmp(streamNames{k}, 'HEARING.TEST.SUITE.SYNC'), continue; end

   varName = convert_stream_name_to_var_name(streamNames{k});

   ifilt = find(strcmp(data.DataStream, streamNames{k}));

   % The time sync message is exchanged four times. The remote (i.e. tablet)
   % timestamp corresponds to the message with the lowest round trip time
   % (RTT).
   rtt = [data.RTT1(ifilt) data.RTT2(ifilt) data.RTT3(ifilt) data.RTT4(ifilt)];
   rtt = min(rtt, [], 2);

   tlocal = double(data.LocalTime(ifilt) - Sync.T0) * 1e-7;
   % Subtract off half the round-trip-time
   tstream = double(data.StreamTime(ifilt) - Sync.T0)* 1e-7 - 1e-3 * rtt(:) / 2;

   [m, b] = epl.stats.linefit(tlocal, tstream);

   Sync.(['offsetPCTo' varName]) = b;
   Sync.(['driftPCTo' varName]) = m;
end

% 2. Audio Sync log: map audio time to tablet system time
fnAudioSync = strrep(fn, '.json', '-AudioSync.log');

opts = detectImportOptions(fnAudioSync);
opts.VariableTypes{1} = 'int64';
opts.VariableTypes{5} = 'int64';

data = readtable(fnAudioSync, opts);

ifilt = strcmp(data.SyncPulseDetection, 'Detected');
syncDSPTime = data.SyncDSPTime(ifilt);

% The tablet sends a pulse to the Arduino, which detects and timestamps it.
% Shortly thereafter, the tablet generates a system time stamp
% (syncSystemTime) and immediately asks the Arduino when the last sync
% pulse was detected. The Arduino responds with a "syncOffset", i.e.: "the
% last pulse was detected so many milliseconds ago. We need to remove this
% offset from the system time stamp to get the system time when the pulse
% actually occurred. (We also subtract half the round-trip serial port
% communication time.)
syncOffset = data.SyncOffset(ifilt);
rtt = data.RTT(ifilt);
totalOffset = int64((syncOffset - rtt/2) * 1e4);

syncSystemTime = data.SyncSystemTime(ifilt) + totalOffset;
syncSystemTime = syncSystemTime - Sync.T0;
syncSystemTime = double(syncSystemTime) * 1e-7;

iout = find_outliers(syncSystemTime);
nout = sum(iout);
if nout > 0
   fprintf('Removed %d outlier(s) from DSP system times.\n', nout);
end

[m, b] = epl.stats.linefit(syncDSPTime(~iout), syncSystemTime(~iout));
Sync.offsetAudioToTablet = b;
Sync.driftAudioToTablet = m;
Sync.audioSyncTimes = data.SyncDSPTime(ifilt); % storing the sync pulse times is useful for ground truth testing

% 2b. Map Unity time to tablet system time
tabletTime = data.SystemTime - Sync.T0;
tabletTime = double(tabletTime) * 1e-7;
unityTime = data.UnityTime;

[m, b] = epl.stats.linefit(unityTime, tabletTime);
Sync.offsetUnityToTablet = b;
Sync.driftUnityToTablet = m;

% 3. EDF file: map PC time to EyeLink time
fnEyeLink = strrep(fn, '.json', '.edf');
if exist(fnEyeLink, 'file')
   eyeData = hts.read_eyelink_data(fnEyeLink);
   
   isync = find(startsWith(eyeData.events.info, 'Sync:'));
   % The four-trial protocol is kind of annoying here. We really only need
   % every 4th sync message. 
   % The EyeLink Interface sends the EyeLink a message in the form
   % "Sync:<system time stamp>". 
   isync = isync(1:4:end);
   pcTime = int64(zeros(length(isync), 1));
   eyeTime = NaN(length(isync), 1);
   
   for k = 1:length(isync)
      pcTime(k) = sscanf(eyeData.events.info{isync(k)}, 'Sync:%lu');
      eyeTime(k) = eyeData.events.time(isync(k));
   end
   pcTime = double(pcTime - Sync.T0) * 1e-7;

   [m, b] = epl.stats.linefit(pcTime, eyeTime);
   Sync.offsetPCToEye = b;
   Sync.driftPCToEye = m;
end

% 4. BDF file: map PC time to Biosemi time
fnBDF = strrep(fn, '.json', '.bdf');
if exist(fnBDF, 'file')
   % read sync markers from BDF
   h = bdf.read_header(fnBDF);
   markers = bdf.find_markers(h);

   % It's not guaranteed that the Biosemi captures the first sync pulse 
   % from the tablet. We need to identify the first sync pulse in the BDF.
   % 
   % convert acquisition start time recorded in BDF header to 64-bit
   % precise time stamp
   bdfStartTime = datetime([h.Date '.' h.Time], 'InputFormat', 'dd.MM.yy.HH.mm.ss', 'TimeZone', 'local');
   bdfPreciseTime = convertTo(bdfStartTime, 'epochtime', 'Epoch', datetime(1601,1,1,'TimeZone','utc'), 'TicksPerSecond', 1e7);
   
   % compute BDF sync pulse times relative to the master reference
   markerTimes = double(bdfPreciseTime - Sync.T0) * 1e-7 + markers / h.SampleRate;

   % convert sync pulse times from audio DSP time to tablet time...
   syncTabletTime = Sync.offsetAudioToTablet + Sync.driftAudioToTablet * Sync.audioSyncTimes;
   % ... convert tablet time to PC time ...
   syncPCTime = Sync.offsetTabletToPC + Sync.driftTabletToPC * syncTabletTime;

   % find the closest sync pulse to the first recorded in the BDF
   [dt, kmn] = min(abs(markerTimes(1) - syncPCTime));
   
   % need some sanity checking: the closest sync pulse should really be
   % within one second but we'll be a bit lenient to start
   if dt > 2
      error('the math is not mathing when registering BDF sync pulse times');
   end

   syncPCTime = syncPCTime(kmn:end);
   % It's possible for there to be more marker times than sync pulse times.
   % This happens when the audio sync file is transferred to the PC while
   % it is still actively detecting the last pulse.
   if length(syncPCTime) < length(markerTimes)
      markerTimes = markerTimes(1:length(syncPCTime));
   end

   % for reasons yet to be sorted out, the Biosemi system sometimes misses
   % markers.
   while true
      ibig = find(abs(markerTimes - syncPCTime(1:length(markerTimes))) > 4, 1);
      if isempty(ibig), break; end

      syncPCTime = syncPCTime([1:ibig-1 ibig+1:end]);
   end

   [m, b] = epl.stats.linefit(syncPCTime(1:length(markerTimes)), markerTimes);
   Sync.offsetPCToBiosemiData = b;
   Sync.driftPCToBiosemiData = m;
end

% Save Sync structure to .mat file
fnMatfile = strrep(fn, '.json', '-Sync.mat');
save(fnMatfile, 'Sync');

end

%--------------------------------------------------------------------------
function varName = convert_stream_name_to_var_name(streamName)

varName = lower(streamName);
varName(1) = upper(varName(1));

idot = find(varName == '.');
varName(idot+1) = upper(varName(idot+1));

varName = strrep(varName, '.', '');

end

%--------------------------------------------------------------------------
function iout = find_outliers(Y)

x = 1:length(Y);
y = Y(:)';

iout = zeros(size(Y));

dy = median(diff(Y));
iout(2:end) = diff(Y) > 10*dy;
% 
% [m, b] = epl.stats.linefit(x, y);
% residuals = y - (m*x + b);
% iout = isoutlier(residuals, 'percentiles', [0 95]);

end
