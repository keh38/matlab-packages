function [Y, T] = eyelink_extract_data(S, npts, startEvent, endEvent)

Y = [];
if npts > 0
   Y = NaN(S.NumTrials, npts);
end

for k = 1:S.NumTrials
   tr = eyelink_extract_trial(S, k, startEvent, endEvent);
   y = tr.pupilSize(:)';
   
   if isempty(Y)
      Y = y;
   elseif npts > 0
      Y(k, :) = y(1:npts);
   elseif length(y) < size(Y, 2)
      Y = Y(:, 1:length(y));
      Y(k, :) = y;
   else
      Y(k, :) = y(1:size(Y,2));
   end
end

T = (0:size(Y,2)-1) / S.sampleRate;

