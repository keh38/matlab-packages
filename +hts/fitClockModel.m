function [syncMap, syncStats] = fitClockModel(syncPulse, dspTimes, options)
% FITCLOCKMODEL -- Clock drift / jitter analysis tap data stream.
%
%  Inputs (set below / present in workspace):
%    syncPulse - loopback pulses
%    dspTimes  - vector of Unity DSP onset times (seconds), one per pulse
%
%  Output structure:
%    drift  (ppm and ms accumulated over the run)  <- slope - 1
%    C      (ms, the fixed latency of the chain)   <- intercept
%    jitter (us, the device's timing noise floor)  <- residual SD
%
%  Method: matched-filter the recording against the known single-cycle 1 kHz
%  template, refine each onset to sub-sample precision, then regress the
%  recovered onset times (ADC clock) against the logged DSP times (output clock).

%% ---- 0. Arguments block ------------------------------------------------
arguments
   syncPulse double {mustBeVector}
   dspTimes double {mustBeVector}
   options.Fs (1,1) {mustBeNumeric} = 48000
end

fs = options.Fs;

dspTimes = dspTimes(:);

%% ---- 1. Build matched-filter template ----------------------------------
n    = round(fs/1000);                  % one cycle of 1 kHz in samples
tmpl = sin(2*pi*1000*(0:n-1).'/fs);
tmpl = tmpl / norm(tmpl);               % unit energy (clean matched filter)

%% ---- 2. Matched filter ------------------------------------------------------
% filter() with the reversed template: output peaks at sample k when the pulse
% occupies samples [k-n+1, k], so pulse onset = k - n + 1.
mf = filter(flipud(tmpl), 1, syncPulse);

% If the pulse comes back inverted anywhere in the chain, the peak is negative.
% One global flip fixes every pulse (they're identical loopbacks).
if abs(min(mf)) > abs(max(mf))
    mf = -mf;
end

%% ---- 3. Detect pulses & refine onsets to sub-sample ------------------------
minDist = round(0.5*fs);                % pulses are ~1 s apart; this is safely below
thresh  = 0.3*max(mf);                  % clean loopback -> generous threshold is fine
[~, locs] = findpeaks(mf, 'MinPeakDistance', minDist, 'MinPeakHeight', thresh);

onsetSamp = zeros(numel(locs),1);
for i = 1:numel(locs)
    k = locs(i);
    if k > 1 && k < numel(mf)
        y1 = mf(k-1); y2 = mf(k); y3 = mf(k+1);
        denom = (y1 - 2*y2 + y3);
        if denom ~= 0
            delta = 0.5*(y1 - y3)/denom;        % parabolic sub-sample peak
        else
            delta = 0;
        end
    else
        delta = 0;
    end
    onsetSamp(i) = (k + delta) - n + 1;         % matched-filter peak -> onset
end
audioTimes = (onsetSamp - 1)/fs;                % seconds on the ADC clock

%% ---- 4. Align detected onsets to DSP times ---------------------------------
nA = numel(audioTimes);
nD = numel(dspTimes);
fprintf('Detected %d audio pulses; %d DSP times logged.\n', nA, nD);

if nA == nD
    d = dspTimes;  a = audioTimes;
else
    % Counts differ (recording clipped a pulse at one end). Slide the shorter
    % sequence along the longer and pick the offset giving the smallest |C|:
    % the correct pairing yields C = a few ms, while a 1-pulse mispairing shifts
    % the intercept by ~1 s, so |intercept| cleanly identifies the alignment.
    warning('Pulse counts differ - searching for best alignment.');
    if nA < nD
        short = audioTimes; long = dspTimes; audioIsShort = true;
    else
        short = dspTimes;   long = audioTimes; audioIsShort = false;
    end
    m = numel(short); bestOff = 0; bestAbsC = inf;
    for off = 0:(numel(long)-m)
        seg = long(off+1:off+m);
        if audioIsShort, pp = polyfit(seg, short, 1);
        else,            pp = polyfit(short, seg, 1); end
        if abs(pp(2)) < bestAbsC, bestAbsC = abs(pp(2)); bestOff = off; end
    end
    seg = long(bestOff+1:bestOff+m);
    if audioIsShort, a = short; d = seg; else, a = seg; d = short; end
    fprintf('Best alignment offset = %d pulse(s). Verify C below is small.\n', bestOff);
end

%% ---- 5. Regression: audio onset (y) vs DSP time (x) ------------------------
p         = polyfit(d, a, 1);
slope     = p(1);
intercept = p(2);
resid     = a - polyval(p, d);

driftPPM   = (slope - 1)*1e6;
runSpan    = d(end) - d(1);
driftMsRun = (slope - 1)*runSpan*1e3;   % accumulated drift over the whole run
jitterUs   = std(resid)*1e6;
C_ms       = intercept*1e3;

syncMap.offsetDspToAudio = intercept;
syncMap.slopeDspToAudio = slope;

syncStats.driftPPM = driftPPM;
syncStats.jitterUs = jitterUs;
