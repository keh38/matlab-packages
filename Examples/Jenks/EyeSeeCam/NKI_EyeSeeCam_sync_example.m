folder = 'Test Data';
fnEyeSeeCam = fullfile(folder, 'EyeSeeCam-2025-09-03_1217.esci');
fnChair = fullfile(folder, 'XYZ-002.f64');

% Read NKI data log...
chairData = jenks.read_nki_log(fnChair);
% ... and the EyeSeeCam data...
eyeSeeCamData = jenks.read_eyeseecam_log(fnEyeSeeCam);
% ...then compute how to map one clock to the other
syncMap = jenks.create_sync_map(chairData, eyeSeeCamData);

% Plot the head rotation velocity and compare to the chair disturbance
% velocity command

% Map chair time stamps to PC system time...
chairSystemTime = chairData.time * syncMap.driftChairToSystem + syncMap.offsetChairToSystem;
% ...then map PC system time to EyeSeeCam time
chairEyeTime = chairSystemTime * syncMap.driftSystemToEyeSeeCam + syncMap.offsetSystemToEyeSeeCam;
% Now we have the chair time stamps mapped to the EyeSeeCam clock:
% everything is in a common time frame

% Parse out the portion of the EyeSeeCam data that coincides with the NKI
% data
ifilt = eyeSeeCamData.LeftTime >= min(chairEyeTime) & eyeSeeCamData.LeftTime <= max(chairEyeTime);
eyeTime = eyeSeeCamData.LeftTime(ifilt);
y = eyeSeeCamData.HeadInertialVelYCal(ifilt);

% Set time = 0 to the beginning of the chair data record
eyeTime = eyeTime - chairEyeTime(1);
chairEyeTime = chairEyeTime - chairEyeTime(1);

figure(1);
clf;
plot(eyeTime, y/max(abs(y)), chairEyeTime, chairData.disturbance / max(abs(chairData.disturbance)));
xlabel('Time (s)');
ylabel('Normalized amplitude');
legend('EyeSeeCam', 'Disturbance');
