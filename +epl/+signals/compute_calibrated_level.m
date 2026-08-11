function maxLevel = compute_calibrated_level(Y, Fs, calPath, options)
% GET_SPEECH_REFERENCE - compute reference level of table audio.
% Usage: maxLevel = get_speech_reference(y, Fs, ...)

arguments
   Y (:, :) {mustBeVector}
   Fs (1, 1) double
   calPath (1, :) char
   options.units (1, :) char = 'SPL';
   options.computePeakLevel (1,1) logical = false
   options.windowSize (1,1) double = 50
   options.applyAWeighting (1, 1) logical = false;
end

cal = cfts.calib.read(calPath);

if strcmpi(options.units, 'HL')
   error('update this option');
end

if options.computePeakLevel
   windowPts = round(Fs * options.windowSize/1000);
else
   windowPts = length(Y);
end

nfft = floor(windowPts/2);
df = Fs/windowPts;
freq = (0:nfft-1) * df;

calMagLinear = 10.^(cal.Mag(:)/20);
calMagLinear = interp1(cal.Freq(:), calMagLinear, freq(:));

W = ones(size(calMagLinear));
if strcmpi(options.units, 'A') || options.applyAWeighting
   W = A_weighting(freq(:), 'linear');
end

if ~options.computePeakLevel
   m = sqrt(2)* fft(Y) / windowPts;
   magSpec = abs(m(1:nfft));
   
   magSPL = magSpec .* calMagLinear .* W;
   maxLevel = 20*log10(sqrt(sum(magSPL.^2, 'omitnan')));
else
   numWin = floor(length(Y) / windowPts);
   spl = NaN(numWin, 1);

   ifilt = 1:windowPts;
   for k = 1:numWin
      m = sqrt(2)* fft(Y(ifilt)) / windowPts;
      magSpec = abs(m(1:nfft));
      
      magSPL = magSpec .* calMagLinear .* W;
      spl(k) = 20*log10(sqrt(sum(magSPL.^2, 'omitnan')));

      ifilt = ifilt + windowPts;
   end
   maxLevel = max(spl);
end