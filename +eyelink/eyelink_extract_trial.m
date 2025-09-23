function TR =  eyelink_extract_trial(S, trialNum, startEvent, endEvent)

if nargin < 3, startEvent = ''; end
if nargin < 4, endEvent = ''; end

if trialNum < 1 || trialNum > S.NumTrials
   error('invalid trial number');
end

time1 = S.ttrial(trialNum);

if trialNum < S.NumTrials
   time2 = S.ttrial(trialNum + 1);
else
   time2 = S.Tmax;
end

ikeep = S.time >= time1 & S.time < time2;
TR.time = S.time(ikeep) - time1;
TR.pupilSize = S.pupilSize(ikeep);

ikeep = S.events.time >= time1 & S.events.time < time2;
TR.events.info = S.events.info(ikeep);
TR.events.time = S.events.time(ikeep) - time1;

if ~isempty(startEvent) && ~isempty(endEvent)
   
   idx = find(strcmp(TR.events.info, startEvent));
   if isempty(idx)
      error('event ''%s'' not found', startEvent);
   end
   time1 = TR.events.time(idx(1));
   
   idx = find(strcmp(TR.events.info, endEvent));
   if isempty(idx)
      error('event ''%s'' not found', endEvent);
   end
   time2 = TR.events.time(idx(1));
   
   ikeep = TR.time >= time1 & TR.time < time2;
   TR.time = TR.time(ikeep);
   TR.pupilSize = TR.pupilSize(ikeep);
   
   ikeep = TR.events.time >= time1 & TR.events.time < time2;
   TR.events.info = TR.events.info(ikeep);
   TR.events.time = TR.events.time(ikeep) - time1;
end