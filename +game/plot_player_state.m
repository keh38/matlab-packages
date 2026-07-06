function plot_player_state(data)

t = data.player.Time - data.player.Time(1);

[tev, lab] = game.parse_player_events(data.player.events, data.player.Time(1));

imiddle = strcmpi(lab, 'locked') | startsWith(lab, 'attack');

figure;
plot(t, data.player.X, t, data.player.Z);
xline(tev(~imiddle), ':', lab(~imiddle), 'LabelHorizontalAlignment', 'center');
xline(tev(imiddle), ':', lab(imiddle), 'LabelHorizontalAlignment', 'center', 'LabelVerticalAlignment', 'middle')

xlabel('Time (s)');

