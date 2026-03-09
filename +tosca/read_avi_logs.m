function [toscaTrials, videoLog] = read_avi_logs(folder, filestem)
%READ_AVI_LOGS Concatenates Tosca .avi logs, parses trial and video data
%
%   [TOSCATRIALS, VIDEOLOG] = READ_AVI_LOGS(FOLDER, FILESTEM)
%
%   Input Arguments:
%      FOLDER     - folder containing .avi files and .avi.txt logs
%      FILESTEM   - Tosca filestem, e.g.: '1129-Session3-Run2'
%
%   Output Arguments:
%      TOSCATRIALS - Structure containing the following fields:
%
%         number     - trial number
%         toscaTime  - corresponding timestamp on PC running Tosca 
%         videoTime  - corresponding timestamp on PC acquiring video
%
%      VIDEOLOG - Structure containing the following fields:
%
%         cumulativeFrameNum  - overall frame number (across entire run)
%         aviFrameNum         - frame number in .avi 
%         videoTime           - corresponding timestamp on PC acquiring video
%
%   Example:
%      [toscaTrials, videoLog] = read_avi_logs('C:\Users\kehan\OneDrive\Desktop\Anna', '1129-Session3-Run2');
%

fileNum = 0;

toscaTrials = [];
videoLog = [];

while true
   filePath = fullfile(folder, sprintf('%s.%03d.avi.txt', filestem, fileNum));

   if ~exist(filePath, 'file'), break; end

   [tosca, video] = read_one_avi_log(filePath);

   toscaTrials = concatenate_structures(toscaTrials, tosca);
   videoLog = concatenate_structures(videoLog, video);

   fileNum = fileNum + 1;
end

% The cumulative frame number is the frame number reported by the camera.
% There are always a couple frames at the beginning acquired by the camera
% but not processed. (I don't know why.)
%
% Let's re-index to avoid confusion
videoLog.cumulativeFrameNum = videoLog.cumulativeFrameNum - videoLog.cumulativeFrameNum(1) + 1;

% Quick sanity check: the cumulative frame numbers should increase by one.
allIncreaseByOne = all(diff(videoLog.cumulativeFrameNum) == 1);
if ~allIncreaseByOne
   error('frame numbers do not all increase by one. This data set requires further investigation');
end

end

%--------------------------------------------------------------------------
function [toscaTrials, videoLog] = read_one_avi_log(fn)

% read log into matrix
M = readmatrix(fn, 'Delimiter', '\t');

% the logs have different numbers of columns, depending on their age
numCols = size(M, 2);

if numCols == 5
   % EXAMPLE:
   % 551.000000	551.000000	3725455835.254924	NaN	548.000000
   % 552.000000	552.000000	3725455835.288262	NaN	549.000000
   % 1.000000	-1.000000	3725455835.316551	3725455835.739403	NaN
   % 553.000000	553.000000	3725455835.321536	NaN	550.000000
   % 554.000000	554.000000	3725455835.354931	NaN	551.000000

   % COLUMNS (video):
   % 1. Frame number reported by camera
   % 2. Same?
   % 3. Timestamp on PC recording video
   % 4. NaN
   % 5. Frame number in the .avi

   % COLUMNS (trial markers)
   % 1. == 1 indicates new Tosca trial
   % 2. absolute value = trial number
   % 3. Time stamp on PC recording device
   % 4. Time stamp on Tosca PC
   % 5. NaN

   % Extract the trial data
   itrial = M(:, 1) == 1;        % first column == 1 ==> trial
   trialNum = abs(M(itrial, 2)); % absolute value  = trial number
   trialVideoTime = M(itrial, 3);
   trialToscaTime = M(itrial, 4);

   % Extract the video data
   cumulativeFrameNum = M(~itrial, 1);
   videoTime = M(~itrial, 3);
   aviFrameNum = M(~itrial, 5);

   % Package and return
   toscaTrials.number = trialNum;
   toscaTrials.videoTime = trialVideoTime;
   toscaTrials.toscaTime = trialToscaTime;

   videoLog.cumulativeFrameNum = cumulativeFrameNum;
   videoLog.videoTime = videoTime;
   videoLog.aviFrameNum = aviFrameNum;

else
   error('Code not implemented to handle .avi logs with other than 5 columns');
end

end

%--------------------------------------------------------------------------
function structOut = concatenate_structures(structIn, structNew)

% Robust method for combining two structures into one while concatenating
% their (vector) fields.

if isempty(structIn)
   structOut = structNew;
else
   fields = fieldnames(structIn);
   structOut = struct();
   for i = 1:numel(fields)
      f = fields{i};
      structOut.(f) = [structIn.(f); structNew.(f)];
   end
end

end