function T = group_delay(freqHz, phaseDeg, fmax)
% GROUP_DELAY -- compute group delay
% Usage: T = group_delay(freqHz, phaseDeg, fmax)
%
% *** INPUTS ***
% freqHz    :
% phaseDeg  :
% fmax      : optional
%
% *** OUTPUTS ***
% T : group delay (seconds)
%

freqRad = 2 * pi * freqHz(:);
phaseRad = unwrap(phaseDeg(:) * pi/180);

if nargin > 2
   ifilt = freqHz < fmax;
   freqRad = freqRad(ifilt);
   phaseRad = phaseRad(ifilt);
end

T = -epl.stats.linefit(freqRad, phaseRad);

