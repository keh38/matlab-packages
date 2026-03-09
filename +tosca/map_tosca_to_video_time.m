function time = map_tosca_to_video_time(time, tosca)

% tosca.toscaTime and tosca.videoTime are timestamps of the same event!!! 
% This is how we map one clock onto the other.

t0 = tosca.toscaTime(1);
% Because the timestamps are large in value, we need to subtract a constant
% to prevent the linear regression from balking. We'll just add it back on
% when we're done.
[m, b] = epl.stats.linefit(tosca.toscaTime - t0, tosca.videoTime - t0);

time = (time - t0) * m + b + t0;
