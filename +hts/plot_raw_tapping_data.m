function R = plot_raw_tapping_data(jsonFile, options)
% ANALYZEPATTERNTAPPING -- folded (pattern-repeat) analysis of a tapping recording
%
%   R = analyzePatternTapping(jsonFile)
%   R = analyzePatternTapping(jsonFile, Window_s=...)
%
%  jsonFile is the path to a serialized TappingTrial (see TappingTrial.cs). The
%  matching TapStreamer recording is the same path with .json -> .wav:
%     channel 1 = tap sensor
%     channel 2 = pattern-element onset pulses (1 kHz loopback fiducials)
%
%  The trial's PacerPattern field is the sequence of intervals that is tiled to
%  build the repeating pacer pattern. Its LENGTH, N, is the number of stimulus
%  elements per repeat. The fiducial pulse train is wrapped every N pulses -- by
%  COUNT, not by interval value -- so that time = 0 is the first pulse of each
%  repeat. Reference lines drawn from the interval values mark where the pulses
%  sit within a repeat; a horizontal line marks the repeat at which the
%  distractor turns on (LeadIn / sum(PacerPattern) repeats).
%
%  Figure:
%     bottom    : full waveform, tap and pulse overplotted (both normalized to
%                 the peak tap amplitude), light vertical onset markers, ~half
%                 the previous height
%     top-left  : tap-template summary (unchanged)
%     top-right : folded tap raster, one row per repeat, time increasing upward
%
%  Name-Value options:
%    Window_s - per-pulse match half-width in seconds; 0 => IPI/2 (default 0)

%% ---- 0. Arguments ----------------------------------------------------------
arguments
    jsonFile {mustBeTextScalar}
    options.Window_s (1,1) {mustBeNumeric} = 0     % half-width (s); 0 => IPI/2
end
jsonFile = char(jsonFile);

%% ---- 1. Load trial, derive and check the wav path --------------------------
s = jsondecode(fileread(jsonFile));
trial = s.trial;

[pth, stem] = fileparts(jsonFile);
wavFile = fullfile(pth, [stem '.wav']);
if ~isfile(wavFile)
    error('analyzePatternTapping:wav', ...
        'No matching .wav found next to the .json: %s', wavFile);
end

%% ---- 2. Read wav, split channels ------------------------------------------
[X, fs] = audioread(wavFile);
if size(X, 2) < 2
    error('analyzePatternTapping:channels', ...
        'Expected a 2-channel wav (ch1 = tap, ch2 = pulse); got %d channel(s).', size(X,2));
end
tap   = X(:, 1);
pulse = X(:, 2);

%% ---- 3. Detect event trains (reuse existing analyzers) ---------------------
pulseTimes = hts.detectAudioPulses(pulse, 'Fs', fs, 'minInterval', min(trial.PacerIntervals));
pulseTimes = sort(pulseTimes(:));

[tapTime, tapAmplitude, template] = hts.analyzeTaps(tap, fs);
tapTime = sort(tapTime(:));

nP = numel(pulseTimes);

%% ---- 6. Package results ----------------------------------------------------
R = struct();
R.fs                = fs;
R.tap               = tap;
R.pulse             = pulse;
R.pulseTimes        = pulseTimes;
R.tapTime           = tapTime;
R.tapAmplitude      = tapAmplitude;
R.template          = template;

%% ---- 7. Figure -------------------------------------------------------------
buildFigure(R, sprintf('%s: %s', stem, trial.Tag));
end

% ============================================================================
function buildFigure(R, name)

fig = figure('Name', 'Pattern tapping analysis', 'Color', 'w');
try
    fig.Position(3:4) = [1100 800];
    movegui(fig, 'onscreen');   % nudge fully back onto the display
catch
end
% 4 rows: template | raster occupy rows 1-3; the waveform strip occupies row 4
% (~1/4 of the figure = about half its previous height).
tOuter = tiledlayout(fig, 4, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

axTL = nexttile(tOuter, 1, [3 1]);           % top-left: template (unchanged)
hts.plotTapTemplate(axTL, R.template);

axRas = nexttile(tOuter, 2, [3 1]);          % top-right: folded raster

axW = nexttile(tOuter, 7, [1 2]);            % bottom: half-height waveform strip
drawWaveform(axW, R);

title(tOuter, strrep(name, '_', '\_'), 'FontWeight', 'bold', 'Interpreter', 'tex');
end


% ============================================================================
function drawWaveform(ax, R)
% Tap and pulse overplotted on a single baseline, both normalized to the peak
% tap amplitude; light vertical lines mark detected onsets.

t = (0:numel(R.tap)-1).' / R.fs;
m = max(abs(R.tap)) + eps;                    % normalize BOTH channels to peak tap
tapN   = R.tap   / m;
pulseN = R.pulse / m;

ymax = max([1, max(abs(pulseN))]);
yl   = [-1.05*ymax, 1.05*ymax];

hold(ax, 'on');
hPO  = drawEventLines(ax, R.pulseTimes, yl, [0.70 0.80 1.00], '-');   % light blue
hTO  = drawEventLines(ax, R.tapTime,    yl, [1.00 0.80 0.70], '-');   % light orange
hTap = plot(ax, t, tapN,   'Color', [0.15 0.15 0.15]);
hPul = plot(ax, t, pulseN, 'Color', [0.35 0.35 0.55]);
hold(ax, 'off');

set([hPO hTO], 'LineWidth', 0.5);
ylim(ax, yl);
xlim(ax, [t(1) t(end)]);
xlabel(ax, 'time (s)');
ylabel(ax, 'norm. amplitude');
title(ax, 'Recording with detected pulses and taps');

hTap.DisplayName = 'tap';
hPul.DisplayName = 'pulse';
hPO.DisplayName  = 'pulse onset';
hTO.DisplayName  = 'tap onset';
legend(ax, [hTap hPul hPO hTO], 'Location', 'northeastoutside', 'Box', 'off');
end

% ============================================================================
function h = drawEventLines(ax, times, yspan, colr, style)
% Draw a set of vertical lines as a single line object (NaN-separated) so it
% carries one legend entry and does not rescale the axes.

times = times(:).';
if isempty(times)
    h = plot(ax, NaN, NaN, style, 'Color', colr);
    return;
end
x = reshape([times; times; nan(1, numel(times))], [], 1);
y = repmat([yspan(1); yspan(2); NaN], numel(times), 1);
h = plot(ax, x, y, style, 'Color', colr);
end


% ============================================================================
function out = ternary(cond, a, b)
if cond, out = a; else, out = b; end
end
