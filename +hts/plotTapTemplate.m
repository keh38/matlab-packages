function plotTapTemplate(ax, T)
%PLOTTAPTEMPLATE  Draw the tap-template summary into axes AX.
%
%  plotTapTemplate(ax, T)
%
%  T is the template struct returned by analyzeTaps, containing:
%     .t_ms     - time axis (ms) re: negative peak
%     .segs     - (L x nClean) baseline-removed per-tap windows used to build the template
%     .kernel   - unit-energy matched filter
%     .nClean   - number of clean taps averaged into the template
%     .accepted - (nClean x 1 logical) true where the segment is corroborated by
%                 the final detection (optional; treated as all-false if absent)
%
%  Each individual tap is amplitude-normalized by its negative-peak depth.
%  Accepted segments are drawn in light green, the rest in grey, and the
%  template kernel is overlaid in black.

nSeg = size(T.segs, 2);
if isfield(T, 'accepted') && numel(T.accepted) == nSeg
    acc = logical(T.accepted(:));
else
    acc = false(nSeg, 1);                              % old struct: nothing marked
end

grey  = [0.70 0.70 0.70];
green = [0.50 0.80 0.50];                              % light green = accepted

hold(ax, 'on');
% rejected first, accepted on top so the green reads at a glance
for i = find(~acc).'
    s = T.segs(:, i);  s = s / max(-s);
    plot(ax, T.t_ms, s, 'Color', grey);
end
for i = find(acc).'
    s = T.segs(:, i);  s = s / max(-s);
    plot(ax, T.t_ms, s, 'Color', green);
end
plot(ax, T.t_ms, T.kernel / max(-T.kernel), 'k', 'LineWidth', 1.5);
hold(ax, 'off');

xlabel(ax, 'time re: neg. peak (ms)');
ylabel(ax, 'normalized');
title(ax, sprintf('Tap template (n = %d)', T.nClean));
grid(ax, 'on');
end
