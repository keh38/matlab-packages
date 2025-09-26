function plot(fn)

h = epl.logger.open(fn);
dl = epl.logger.read(h);

figure;
hold on;

for k = 1:length(h.names)
   plot(dl.time, dl.(h.names{k}));
end

xlabel('Time (s)');
ylabel('Amplitude');
legend(h.names);
