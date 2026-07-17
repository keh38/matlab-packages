function plot_player_state(data, T0)

if nargout < 2, T0 = data.player.Time(1); end

t = data.player.Time - T0;

[tev, lab] = game.parse_player_events(data.player.events, T0);

imiddle = strcmpi(lab, 'locked') | startsWith(lab, 'attack');
ibottom = strcmpi(lab, 'paused') | startsWith(lab, 'resume');
itop = ~imiddle & ~ibottom;

figure;
plot(t, data.player.X, t, data.player.Z);
xline(tev(itop), ':', lab(itop), 'LabelHorizontalAlignment', 'center');
xline(tev(imiddle), ':', lab(imiddle), 'LabelHorizontalAlignment', 'center', 'LabelVerticalAlignment', 'middle')
xline(tev(ibottom), ':', lab(ibottom), 'LabelHorizontalAlignment', 'center', 'LabelVerticalAlignment', 'bottom')

xlabel('Time (s)');

[~, name] = fileparts(data.header.FilePath);
title(name);

