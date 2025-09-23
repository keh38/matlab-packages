function plot_saved_average(fn)
% 
% Shows how to load and plot the average data saved by the EPhys software.
% 

[y, t] = ephys.read_avg(fn);

figure;
hold on;
for k = 1:length(y)
   plot(t, y{k});
end

xlabel('Time (ms)');
ylabel('Amplitude (uV)');