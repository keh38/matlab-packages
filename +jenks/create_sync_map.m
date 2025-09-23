function Map = create_sync_map(chairData, eyeSeeCamData)

% Important: system times are acquired using
% GetSystemTimePreciseAsFileTime() which stores the time using 64-bit
% integers. In order to do floating point math (linear regression) on these
% times without losing precision, we need to reference them to some recent
% time. Doesn't matter what it is, we just need to be consistent. We will
% use the first EyeSeeCam timestamp for this purpose.
SyncMap.T0 = eyeSeeCamData.HostTime(1);

systemTime = double(eyeSeeCamData.HostTime - SyncMap.T0) * 1e-7;
eyeSeeCamTime = eyeSeeCamData.LeftTime;

[m, b] = epl.stats.linefit(systemTime, eyeSeeCamTime);
Map.offsetSystemToEyeSeeCam = b;
Map.driftSystemToEyeSeeCam = m;

fprintf('EyeSeeCam clock drift = %.1f us/s\n', (1 - m)*1e6);

systemTime = double(chairData.tsystem - SyncMap.T0) * 1e-7;
[m, b] = epl.stats.linefit(chairData.time, systemTime);
Map.offsetChairToSystem = b;
Map.driftChairToSystem = m;

fprintf('Chair clock drift = %.1f us/s\n', (1 - 1/m)*1e6);
