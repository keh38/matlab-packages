function plot_target_data(data)
% PLOT_TARGET_DATA -- summary of the target proximity cues from foraging.
% Usage: game.plot_target_data(data)
%
% --- INPUTS ---
% data : data log (see game.read_master_data_log)
%

% --- Initialize figure ---
figure();
% set(h, 'WindowStyle', 'docked');

clf;
tiledlayout('vertical');

ax1 = nexttile;
hold on;

t0 = []; % common time reference point

% Top panel: plot the onset times of each burst of electrical stimulation
% in the target stimulus. Sort them by target area.
for k = 1:length(data.targetClipTrack)
   t = data.targetClipTrack(k).dspTime;
   if isempty(t), continue; end % is empty: player never went there

   if isempty(t0)
      t0 = t(1); % set the time reference point if not set
   end

   t = t - t0; % henceforth, all times are relative to the reference point

   h = plot(t, k*ones(size(t)), '.');
   set(h, 'MarkerFaceColor', get(h, 'Color'));
end

ylim([0 length(data.targetClipTrack)+1]);
ylabel({'Stimulus', '(target number)'});

% --- Create the next two panels ---
ax2 = nexttile;
hold on;

ax3 = nexttile;
hold on;

% Middle panel: plot the instantaneous pulse rate (in beats per minute),
% as a function of time, again sorted by target area
%
% Bottom panel: plot the distance to the target as a function of time,
% sorted by target
%
for k = 1:length(data.targetCue)
   cue = data.targetCue(k);

   ifilt = diff(cue.dspTime) > 0.03;
   t = cue.dspTime - t0;
   t(ifilt) = NaN;

   plot(ax2, t, cue.synthBPM);
   plot(ax3, t, cue.distance); 
end
ylabel(ax2, 'BPM');

xlabel(ax3, 'Time (s)');
ylabel(ax3, 'Distance');
yline(ax3, data.arena.Radius);

linkaxes([ax1 ax2 ax3], 'x');

[~, name] = fileparts(data.header.FilePath);
title(ax1, sprintf('%s:Level%02d', name, data.level.levelNumber));



