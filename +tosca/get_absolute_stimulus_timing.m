function stimTime = get_absolute_stimulus_timing(data, timing, traceLog)

trialIndices = find(traceLog.code == 1);

stimTime = NaN(numel(data), 2);

for k = 1:numel(data)

   % Find the entry in 'timing' corresponding to the schedule group applied
   % during this trial
   igroup = strcmp({timing.groupName}, data{k}.Group);
   if ~any(igroup)
      error('Group not found');
   end

   % Get the state containing the X-variable for the group
   state = timing(igroup).state;

   % Find the occurrence of this state in the current trial
   trialIndex = trialIndices(k);
   offset = find(strcmp(traceLog.item(trialIndex:end), state), 1);
   istate = trialIndex + offset - 1;

   % Get the time the stimulus-containing state started
   tstate = traceLog.time(istate);

   % Get stimulus on and off times
   stimOnTime = tstate + timing(igroup).delay * 1e-3;
   stimOffTime = stimOnTime + timing(igroup).duration * 1e-3;

   % Visual stimuli have a small additional delay we should account for
   if timing(igroup).isVisual
      % Find the next "Draw" call after the start of the state
      offset = find(strcmp(traceLog.item(istate:end), "Draw"), 1);
      idraw = istate + offset - 1;

      % compute the delay
      visDelay = traceLog.time(idraw) - tstate;

      % adjust
      stimOnTime = stimOnTime + visDelay;
      stimOffTime = stimOffTime + visDelay;
   end

   stimTime(k, :) = [stimOnTime stimOffTime];
end
