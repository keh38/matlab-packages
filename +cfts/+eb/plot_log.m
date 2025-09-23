function plot_log(fn)

t = readtable(fn);

figure
plot(t.Time_min_, t.SPL, 'LineWidth', 2);
xlabel('Time (min)');
ylabel('dB SPL');

ymin = floor(min(t.SPL) / 10) * 10;
ymax = ceil(max(t.SPL) / 10) * 10;
set(gca, 'YLim', [ymin ymax]);

set(gca, 'TickDir', 'out');
box off;

grid on;

