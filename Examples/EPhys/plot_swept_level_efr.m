function plot_swept_level_efr(fn)

header = epl.file.parse_ini_config(fn);
rawfn = strrep(fn, '.header.txt', '.0.0.raw');

Fs_Hz = header.Params.Response.Sampling_Rate_Hz;
Lmax_dB = header.Params.StimChans.Level.Level;

DR_dB = 70;
SweepDur_s = 8;

ptsPerSweep = round(SweepDur_s * Fs_Hz);
framesPerSweep = round(SweepDur_s * header.Params.Stimulus.Rep_rate_Hz);
Ntrials = abs(header.Params.Response.NumAvgs);

y = zeros(1, ptsPerSweep);

hraw = ephys.open_raw(rawfn);

for k = 1:Ntrials
   [m, hraw] = ephys.read_raw(hraw, framesPerSweep);
   y = y + m(2, :);
end
y = y / Ntrials;

ephys.close_raw(hraw);


% FROM KELLY: calculate multiple short-time Fourier transforms on consecutive
%overlapping 1-second intervals

%First, duplicate the first half-second of each averaged sweep and tack it
%to the end; Also duplicate last half-second of each averaged sweep and
%tack it to the beginning (This forms a virtual sweep going from 0.5 sec
%before to 0.5 sec after the actual sweep)

%number of samples per half-second
npts = Fs_Hz/2;

%first and last 500 ms
first = y(1:npts);
last = y(length(y)-npts+1:length(y));

y_long = [last y first];


% choose same parameters as Picton et al (2007) - 1 second rectangular
% window, sliding in 80 ms steps


%% parameters for 1000 ms window
wlen = floor(Fs_Hz);                       % window length - one second (1 Hz frequency res)
n_overlap = floor(wlen*.92);             % number of overlapping samples for each window - slide in 80 ms seconds (temporal res = 80 ms)

%%
[s, Freq, Time] = spectrogram(y_long, rectwin(wlen), n_overlap, wlen, Fs_Hz, 'yaxis');
Amplitude = abs(s);

%extract values at 40 Hz
[~, i40] = min(abs(Freq - 40));
A40 = Amplitude(i40, :);

nhalf = floor(length(Time)/2);
if mod(length(Time), 2) == 0
   Wrapped = (A40(1:nhalf) + flip(A40(nhalf+1:nhalf)))/2;
else
   Wrapped = (A40(1:nhalf) + flip(A40((nhalf+2):end)))/2;
end

figure;
figsize('portrait', 0.6);
subplot(3,1,1)
imagesc(Time, Freq, Amplitude)
caxis([min(A40) max(A40)]);
colorbar
colormap('jet')
ylabel('Frequency (Hz)');
xlabel('Time (s)');
ylim([30 50]);
% title(sprintf('%g Hz Carrier, 40 Hz AM', Fc))
set(gca,'YDir','normal');

%% Plot amplitude over time
subplot(3,1,2)
plot(Time - 0.5, A40,'k')
xlabel('Time (s)')
ylabel('Amplitude (nV)')


dBmin = Lmax_dB - DR_dB;
dBSPL = dBmin:(DR_dB/(length(Wrapped)-1)):Lmax_dB;

subplot(3,1,3) 
plot(dBSPL, Wrapped) 
xlim([dBmin Lmax_dB])
xlabel('Intensity (dB SPL)')
ylabel('Amplitude (nV)')

