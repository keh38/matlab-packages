function AVI = read_avi_log(logPath, stimDur_s)
% elektra.read_avi_log -- parse .avi.log files into trial-based structure
% Usage: AVI = elektra.read_avi_log(logPath)
%
% --- Inputs ---
% logPath : path to .avi.log file
%

if nargin < 2, stimDur_s = 1; end

text = fileread(logPath);
data = textscan(text, '%f\t%d\t%d\t%d\t%f\t%s', 'HeaderLines', 1);

code = data{2};
overallFrameNum = data{3}; %#ok<NASGU> 

trialIndices = find(code == 1);
trialIndices(end+1) = length(code) + 1;

AVI = struct('aviFile', {}, 'frameRate', {}, 'baselineFrames', {}, 'stimFrames', {}, 'isiFrames', {});

for k = 1:length(trialIndices)-1
   AVI(k).aviFile = strrep(logPath, '.avi.log', sprintf('.%03d.avi', k));

   index = trialIndices(k) : trialIndices(k+1)-1;
   trialCodes = code(index);
   tframe = data{1}(index);
   frameInAVI = data{4}(index);

   AVI(k).frameRate = 1 / mean(diff(tframe(frameInAVI > 0)));
   nstimFrames = round(AVI(k).frameRate * stimDur_s);

   
   stimMarker = find(trialCodes == 2);
   AVI(k).baselineFrames = frameInAVI(1:stimMarker-1);
   AVI(k).stimFrames = frameInAVI(stimMarker + (0:nstimFrames-1));
   AVI(k).isiFrames = frameInAVI((stimMarker + nstimFrames):end);
end
