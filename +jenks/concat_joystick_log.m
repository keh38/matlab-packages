function concat_joystick_log(folder)

matFile = fullfile(folder, 'MoogJoystickLog.mat');

% --- Netburner logs-------------------------------------------------------
fileList = dir(fullfile(folder, 'NetburnerPackets*.bin'));
T0 = [];
for k = 1:length(fileList)
   [nbData, t0] = jenks.read_netburner_log(fullfile(fileList(k).folder, fileList(k).name));

   if isempty(T0)
      T0 = t0;
   end

   nbData.time = double(nbData.itime - T0) * 1e-7;
   nbData.joystickAngle = nbData.joystickAngle * 180/pi;
   nbData.rollFeedback = nbData.rollFeedback * 180/pi;

   if k == 1
      netburner = nbData;
   else
      f = fieldnames(netburner);
      for kf = 1:length(f)
         netburner.(f{kf}) = [netburner.(f{kf}) NaN nbData.(f{kf})];
      end
   end

end

save(matFile, 'netburner');

% --- Joystick data -------------------------------------------------------
fileList = dir(fullfile(folder, 'JoystickLog*.bin'));
for k = 1:length(fileList)
   jdata = jenks.read_joystick_log(fullfile(fileList(k).folder, fileList(k).name));

   jdata.time = double(jdata.itime - T0) * 1e-7;
   if k == 1
      joystick = jdata;
   else
      f = fieldnames(joystick);
      for kf = 1:length(f)
         joystick.(f{kf}) = [joystick.(f{kf}) NaN jdata.(f{kf})];
      end
   end

end

save(matFile, 'joystick', '-append');
