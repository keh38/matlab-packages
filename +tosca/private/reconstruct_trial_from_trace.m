function trialData = reconstruct_trial_from_trace(trialData, traceData)

istate = find(traceData.Event == 2);

trialData.start = traceData.Time(istate(1));
trialData.stop = traceData.Time(end);
trialData.duration = trialData.stop - trialData.start;

% individual state timing information
tState = traceData.Time(istate);
names = trialData.History(1:2:end);
if length(names) > length(tState)
   names = names(1:length(tState));
   warning('mismatch between state names and times');
end
   
tState(end+1) = trialData.stop;
for ks = 1:length(names)

   ifilt = traceData.Time >= tState(ks) & traceData.Time < tState(ks+1);
   nrep = sum(traceData.Event(ifilt) == 5 & traceData.Data(ifilt) == 0);
   
   stateData = struct(...
      'name', strtrim(names{ks}), ...
      'start', tState(ks), ...
      'stop', tState(ks+1), ...
      'duration', tState(ks+1) - tState(ks), ...
      'nrep', nrep);
   
   trialData.states(ks) = stateData;
end
