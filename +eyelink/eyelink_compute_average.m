function [A, time] = eyelink_compute_average(S, npts, startEvent, endEvent)

if nargin < 3, startEvent = ''; end
if nargin < 4, endEvent = ''; end

thr = 500;
S.pupilSize(S.pupilSize <= thr) = NaN;

y = NaN(S.NumTrials, npts);
for k = 1:S.NumTrials
   TR = eyelink_extract_trial(S, k, startEvent, endEvent);
   if length(TR.pupilSize) >= npts
      y(k,:) = TR.pupilSize(1:npts);
   end
end

A = nanmean(y);
time = (0:npts-1) / S.sampleRate;