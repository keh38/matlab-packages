function [tapTime, tapAmplitude, template] = analyzeTaps(tap, fs, options)
% ANALYZETAPS -- find taps in a single-channel tap trace
%
%   [tapTime, tapAmplitude, template] = analyzeTaps(tap, fs)
%   [...] = analyzeTaps(tap, fs, Name=Value)
%
%  1) Builds a matched filter empirically from the recorded biphasic tap shape.
%  2) Detects taps and recovers sub-sample onsets.
%
%  The tap template is not analytic (unlike the 1 kHz fiducial), so we build it
%  from the data: coarse-detect clean taps on the sharp leading (negative) phase,
%  align and average them into a template, then use that as the matched filter.
%
%  Inputs:
%    tap - vector, the tap sensor channel (leading phase is negative-going)
%    fs  - sample rate (Hz)
%
%  Name-Value options:
%    PreMs      - template window before the negative peak (ms)   [3]
%    PostMs     - template window after  the negative peak (ms)   [7]
%    MinITI_s   - minimum inter-tap interval (s), rejects doubles [0.15]
%    TaperRatio - Tukey taper on template edges                   [0.25]
%    ShowPlot   - draw the template summary in a new figure       [false]
%    ShowSummary- print an ITI/amplitude summary to the console   [false]
%
%  Outputs:
%    tapTime      - onset times (s, ADC clock)
%    tapAmplitude - negative-phase depth at each tap (signed negative)
%    template     - struct with everything needed to redraw the template summary:
%                     .fs .preS .postS .L .tpk .t_ms
%                     .segs     (L x nClean) baseline-removed per-tap windows
%                     .kernel   (unit-energy matched filter)
%                     .nClean   number of clean taps used
%                     .accepted (nClean x 1 logical) true where the coarse tap
%                               that built that segment is corroborated by the
%                               final matched-filter detection
%
%  Requires Signal Processing Toolbox (findpeaks, tukeywin).

%% ---- 0. Arguments ----------------------------------------------------------
arguments
    tap    double {mustBeVector}
    fs     (1,1) {mustBeNumeric}
    options.PreMs       (1,1) {mustBeNumeric} = 3
    options.PostMs      (1,1) {mustBeNumeric} = 7
    options.MinITI_s    (1,1) {mustBeNumeric} = 0.15
    options.TaperRatio  (1,1) {mustBeNumeric} = 0.25
    options.ShowPlot    (1,1) logical = false
    options.ShowSummary (1,1) logical = false
end

tap        = tap(:);
preMs      = options.PreMs;
postMs     = options.PostMs;
minITI_s   = options.MinITI_s;
taperRatio = options.TaperRatio;

N = numel(tap);

%% ---- 1. Noise floor --------------------------------------------------------
sigma = median(abs(tap - median(tap))) / 0.6745;        % robust (MAD) noise estimate
fprintf('Noise floor (MAD sigma): %.4g   (%.1f dBFS)\n', sigma, 20*log10(sigma));

preS   = round(preMs/1000*fs);
postS  = round(postMs/1000*fs);
minITI = round(minITI_s*fs);

%% ---- 2. Coarse-detect clean taps & build the template ----------------------
% Leading phase is negative-going, so peaks live in -tap.
coarseThr = max(8*sigma, 0.05*max(-tap));               % clearly above noise
[~, nlocs] = findpeaks(-tap, 'MinPeakHeight', coarseThr, 'MinPeakDistance', minITI);

% keep only taps with full windows
nlocs = nlocs(nlocs > preS & nlocs <= N - postS);

L   = preS + postS + 1;
tpk = preS + 1;                                         % negative-peak index within template
segs = zeros(L, numel(nlocs));
for i = 1:numel(nlocs)
    seg = tap(nlocs(i)-preS : nlocs(i)+postS);
    segs(:, i) = seg - median(seg);                     % remove per-tap baseline
end

templateRaw = mean(segs, 2);
w           = tukeywin(L, taperRatio);                  % smooth edges -> clean filter
kernel      = templateRaw .* w;
kernel      = kernel - mean(kernel);                    % reject DC
kernel      = kernel / norm(kernel);                    % unit energy

fprintf('Built template from %d clean taps (%.1f ms window).\n', ...
        numel(nlocs), (L-1)/fs*1e3);

%% ---- 3. Matched-filter detection of ALL taps -------------------------------
mf = filter(flipud(kernel), 1, tap);                    % positive peak at each tap

sigmaMf = median(abs(mf)) / 0.6745;
thrMf   = max(6*sigmaMf, 0.15*max(mf));
[~, mflocs] = findpeaks(mf, 'MinPeakHeight', thrMf, 'MinPeakDistance', minITI);

onsetSamp = zeros(numel(mflocs), 1);
amp       = zeros(numel(mflocs), 1);
for i = 1:numel(mflocs)
    k = mflocs(i);
    if k > 1 && k < numel(mf)
        y1 = mf(k-1); y2 = mf(k); y3 = mf(k+1);
        denom = (y1 - 2*y2 + y3);
        if denom ~= 0, delta = 0.5*(y1 - y3)/denom; else, delta = 0; end
    else
        delta = 0;
    end
    onsetSamp(i) = (k + delta) - L + tpk;               % map mf peak -> negative-peak landmark
    % amplitude = depth of the negative phase near this tap
    lo = max(1, round(onsetSamp(i))-2); hi = min(N, round(onsetSamp(i))+2);
    amp(i) = -min(tap(lo:hi));
end
tapTime      = (onsetSamp - 1)/fs;                      % seconds on the ADC clock
tapAmplitude = -amp;

%% ---- 3b. Mark which template segments survive to final detection -----------
% A coarse (template-building) tap is "accepted" if the matched-filter pass
% re-detects a tap at effectively the same landmark. Both nlocs and onsetSamp
% live in the negative-peak sample frame, so they coincide for a true match.
% Detected taps are >= minITI apart, so a half-ITI tolerance matches at most one
% and cannot collide with a neighbour.
matchTol = minITI / 2;
accepted = false(numel(nlocs), 1);
for i = 1:numel(nlocs)
    accepted(i) = any(abs(onsetSamp - nlocs(i)) <= matchTol);
end

%% ---- 4. Package template info ----------------------------------------------
template = struct( ...
    'fs',     fs, ...
    'preS',   preS, ...
    'postS',  postS, ...
    'L',      L, ...
    'tpk',    tpk, ...
    't_ms',   ((0:L-1)-preS)/fs*1e3, ...
    'segs',   segs, ...
    'kernel', kernel, ...
    'nClean', numel(nlocs), ...
    'accepted', accepted);

%% ---- 5. Optional console summary -------------------------------------------
if options.ShowSummary
    ITI = diff(tapTime);
    fprintf('\n==================== TAP SUMMARY ====================\n');
    fprintf('Taps detected     : %d over %.1f s\n', numel(tapTime), tapTime(end)-tapTime(1));
    if ~isempty(ITI)
        fprintf('ITI  median       : %.1f ms\n', median(ITI)*1e3);
        fprintf('ITI  mean +/- SD  : %.1f +/- %.1f ms  (CV = %.3f)\n', ...
            mean(ITI)*1e3, std(ITI)*1e3, std(ITI)/mean(ITI));
        fprintf('ITI  range        : %.1f - %.1f ms\n', min(ITI)*1e3, max(ITI)*1e3);
    end
    fprintf('Amplitude range   : %.4f - %.4f\n', min(amp), max(amp));
    fprintf('====================================================\n');
end

%% ---- 6. Optional standalone template plot ----------------------------------
if options.ShowPlot
    figure('Name', 'Tap template', 'Color', 'w');
    hts.plotTapTemplate(gca, template);
end
end
