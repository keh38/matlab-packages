function refSPL = compute_reference(carrier, fs, calFile)
% compute_reference: compute SPL of signal
%
% *** INPUTS ***
% signal : signal (if scalar, pure-tone frequency)
% fs     : sampling rate, Hz
% calFile: path to calibation file
%
% *** OUTPUTS ***
% refSPL : SPL of 1Vp signal
%

%%% MUST CREATE WAV FILES USING SAME OUTPUT SAMPLING RATE AS EPHYS SOFTWARE
[cal.Freq, cal.Mag, cal.Phase] = cfts.calib.read(calFile);

% Compute carrier reference level
if length(carrier) == 1
   refSPL = interp1(cal.Freq, cal.Mag, carrier) - 20*log10(sqrt(2));
else
   calMag = [-Inf cal.Mag -Inf];
   calPhase = [0 cal.Phase 0];
   calFreq = [0 cal.Freq cal.Freq(end)+cal.Freq(1)];
   spec = 10.^(calMag/20) .* exp(-1j*2*pi*calPhase/360);

   sigspec = fft(carrier);
   freq = (0:length(carrier)-1) / length(carrier) * fs;

   sigspec = sigspec(1:end/2);
   freq = freq(1:end/2);

   calspec = interp1(calFreq, spec, freq);

   s = sigspec/(length(carrier)) .* calspec;

   refSPL = 20*log10(sqrt(sum(2*abs(s).^2, 'omitnan')));
end
