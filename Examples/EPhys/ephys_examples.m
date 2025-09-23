%% Plot EFR data
fn = 'D:\Data\Joanne\CJL0012\CJL0012-EFR-2.header.txt';

% Read header
header = epl.file.parse_ini_config(fn);

% Read time-domain average
[y, t] = ephys.read_avg(strrep(fn, '.header.txt', '.0.avg'));

% Compute FFT
tdur = header.Params.StimChans.Burst.Duration_ms;
ifilt = t <= tdur;
[s, f] = epl.signals.fft_ss(y{1}(ifilt), header.Params.Response.Sampling_Rate_Hz);

% Recompute time-domain average from raw data
[y_from_raw] = recompute_average_from_raw_data(strrep(fn, '.header.txt', '.0.0.raw'));

% Plot the results
figure;

tlo = tiledlayout(2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');

nexttile;
hold on;
for k = 1:length(y)
   plot(t, y{k});
end
plot(t, y_from_raw);

xlabel('Time (ms)');
ylabel('Amplitude (uV)');

nexttile;
plot(f, abs(s));
set(gca, 'XLim', [0 200]);
xlabel('Frequency (Hz)');
ylabel('Amplitude (uV)');
xline(header.Params.StimChans.SAM.Frequency_Hz, 'r');


