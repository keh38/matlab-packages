function [tapTime, tapAmplitude, template] = analyzeTaps(wavFile)
% ANALYZETAPS -- find taps in a .wav file trace
%
%  1) Builds a matched filter empirically from the recorded biphasic tap shape.
%  2) Detects taps, recovers sub-sample onsets, and summarizes the tapping.
%
%  The tap template is not analytic (unlike the 1 kHz fiducial), so we build it
%  from the data: coarse-detect clean taps on the sharp leading (negative) phase,
%  align and average them into a template, then use that as the matched filter.
%
%  Requires Signal Processing Toolbox (findpeaks, tukeywin).

%% ---- 0. Parameters ---------------------------------------------------------
tapChannel = 1;          % which recorded channel holds the sensor (fiducial is the other)
preMs      = 3;          % template window before the negative peak (ms)
postMs     = 7;          % template window after  the negative peak (ms)
minITI_s   = 0.15;       % minimum inter-tap interval (rejects double-counting; tune to task)
taperRatio = 0.25;       % Tukey taper on template edges
showSummary= false;
showPlot   = true;

%% ---- 1. Load & noise floor -------------------------------------------------
[X, fs] = audioread(wavFile);
tap     = X(:, tapChannel);
N       = numel(tap);

sigma = median(abs(tap - median(tap))) / 0.6745;    % robust (MAD) noise estimate
fprintf('Noise floor (MAD sigma): %.4g   (%.1f dBFS)\n', sigma, 20*log10(sigma));

preS   = round(preMs/1000*fs);
postS  = round(postMs/1000*fs);
minITI = round(minITI_s*fs);

%% ---- 2. Coarse-detect clean taps & build the template ----------------------
% Leading phase is negative-going, so peaks live in -tap.
coarseThr = max(8*sigma, 0.05*max(-tap));           % clearly above noise
[~, nlocs] = findpeaks(-tap, 'MinPeakHeight', coarseThr, 'MinPeakDistance', minITI);

% keep only taps with full windows
nlocs = nlocs(nlocs > preS & nlocs <= N - postS);

L   = preS + postS + 1;
tpk = preS + 1;                                     % negative-peak index within template
segs = zeros(L, numel(nlocs));
for i = 1:numel(nlocs)
    seg = tap(nlocs(i)-preS : nlocs(i)+postS);
    segs(:, i) = seg - median(seg);                 % remove per-tap baseline
end

templateRaw = mean(segs, 2);
w           = tukeywin(L, taperRatio);              % smooth edges -> clean filter
template    = templateRaw .* w;
template    = template - mean(template);            % reject DC
template    = template / norm(template);            % unit energy

fprintf('Built template from %d clean taps (%.1f ms window).\n', ...
        numel(nlocs), (L-1)/fs*1e3);

%% ---- 3. Matched-filter detection of ALL taps -------------------------------
mf = filter(flipud(template), 1, tap);              % positive peak at each tap

sigmaMf = median(abs(mf)) / 0.6745;
thrMf   = max(6*sigmaMf, 0.15*max(mf));
[~, mflocs] = findpeaks(mf, 'MinPeakHeight', thrMf, 'MinPeakDistance', minITI);

onsetSamp = zeros(numel(mflocs),1);
amp       = zeros(numel(mflocs),1);
for i = 1:numel(mflocs)
    k = mflocs(i);
    if k > 1 && k < numel(mf)
        y1 = mf(k-1); y2 = mf(k); y3 = mf(k+1);
        denom = (y1 - 2*y2 + y3);
        if denom ~= 0, delta = 0.5*(y1 - y3)/denom; else, delta = 0; end
    else
        delta = 0;
    end
    onsetSamp(i) = (k + delta) - L + tpk;           % map mf peak -> negative-peak landmark
    % amplitude = depth of the negative phase near this tap
    lo = max(1, round(onsetSamp(i))-2); hi = min(N, round(onsetSamp(i))+2);
    amp(i) = -min(tap(lo:hi));
end
tapTime = (onsetSamp - 1)/fs;                       % seconds on the ADC clock
tapAmplitude = -amp;
ITI     = diff(tapTime);

%% ---- 4. Summary ------------------------------------------------------------
if showSummary
   fprintf('\n==================== TAP SUMMARY ====================\n'); %#ok<UNRCH>
   fprintf('Taps detected     : %d over %.1f s\n', numel(tapTime), tapTime(end)-tapTime(1));
   if ~isempty(ITI)
      fprintf('ITI  median       : %.1f ms\n', median(ITI)*1e3);
      fprintf('ITI  mean +/- SD  : %.1f +/- %.1f ms  (CV = %.3f)\n', ...
         mean(ITI)*1e3, std(ITI)*1e3, std(ITI)/mean(ITI));
      fprintf('ITI  range        : %.1f - %.1f ms\n', min(ITI)*1e3, max(ITI)*1e3);
   end
   fprintf('Amplitude range   : %.4f - %.4f  (%.1f:1 span)\n', min(amp), max(amp), max(amp)/min(amp));
   fprintf('====================================================\n');
end

%% ---- 5. Plots --------------------------------------------------------------
if showPlot
   figure('Name','Taps','Color','w');

   % Shape consistency: amplitude-normalized overlays + template
   t_ms = ((0:L-1)-preS)/fs*1e3;
   hold on;
   for i = 1:numel(nlocs)
      s = segs(:,i); s = s / max(-s);                 % normalize by negative-peak depth
      plot(t_ms, s, 'Color', [0.7 0.7 0.7]);
   end
   plot(t_ms, template/max(-template), 'k', 'LineWidth', 1.5);
   xlabel('time re: neg. peak (ms)'); ylabel('normalized');
   title('Tap shape across amplitudes (grey) + template (black)');
   grid on; hold off;
end

