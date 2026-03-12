function t = get_trial_times_from_trace(traceLog)

itrial = traceLog.code == 1;
t = traceLog.time(itrial);