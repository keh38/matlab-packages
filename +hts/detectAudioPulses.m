function [ audioTimes ] = detectAudioPulses(pulse, options)
% DETECTAUDIOPULSES -- Find audio pulses data stream
%
%  Inputs:
%    pulse - loopback pulses
%
%  Output:
%    audioPulseTimes - recovered onset times (ADC clock)
%
%  Method: matched-filter the recording against the known single-cycle 1 kHz
%  template, refine each onset to sub-sample precision
%

%% ---- 0. Arguments block ------------------------------------------------
arguments
   pulse double {mustBeVector}
   options.Fs (1,1) {mustBeNumeric} = 48000
end

fs = options.Fs;

fprintf('Detecting audio pulses...');

%% ---- 1. Build matched-filter template ----------------------------------
n    = round(fs/1000);                  % one cycle of 1 kHz in samples
tmpl = sin(2*pi*1000*(0:n-1).'/fs);
tmpl = tmpl / norm(tmpl);               % unit energy (clean matched filter)

%% ---- 2. Matched filter ------------------------------------------------------
% filter() with the reversed template: output peaks at sample k when the pulse
% occupies samples [k-n+1, k], so pulse onset = k - n + 1.
mf = filter(flipud(tmpl), 1, pulse);

% If the pulse comes back inverted anywhere in the chain, the peak is negative.
% One global flip fixes every pulse (they're identical loopbacks).
if abs(min(mf)) > abs(max(mf))
    mf = -mf;
end

%% ---- 3. Detect pulses & refine onsets to sub-sample ------------------------
minDist = round(0.1*fs);                % pulses are ~1 s apart; this is safely below
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

fprintf('detected %d pulses.\n', length(audioTimes));
