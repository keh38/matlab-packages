function plot_target_data(data)

h = figure();
% set(h, 'WindowStyle', 'docked');

clf;
tiledlayout('vertical');

ax1 = nexttile;
hold on;

t0 = [];

for k = 1:length(data.targetClipTrack)
   t = data.targetClipTrack(k).dspTime;
   if isempty(t), continue; end

   if isempty(t0)
      t0 = t(1);
   end

   t = t - t0;

   h = plot(t, k*ones(size(t)), '.');
   set(h, 'MarkerFaceColor', get(h, 'Color'));
end

ylim([0 length(data.targetClipTrack)+1]);
ylabel('Target number');

ax2 = nexttile;
hold on;

ax3 = nexttile;
hold on;

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
title(ax1, name);



