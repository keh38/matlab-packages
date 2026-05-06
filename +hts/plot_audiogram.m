function plot_audiogram(audiogram, ldlgram)

% Plotting options
markerSize = 8;
lineWidth = 2;
yInfValue = 115;

% Defaults
leftAudio = [];
rightAudio = [];

leftLDL = [];
rightLDL = [];

allFreq = [];

if ~isempty(audiogram)
   ileft = find(strcmpi({audiogram.ear}, 'left'));
   leftAudio = audiogram(ileft);
   rightAudio = audiogram(3 - ileft);

   allFreq = [leftAudio.Frequency_Hz(:); rightAudio.Frequency_Hz(:)];
end

if ~isempty(ldlgram)
   ileft = find(strcmpi({ldlgram.ear}, 'left'));
   leftLDL= ldlgram(ileft);
   rightLDL = ldlgram(3 - ileft);
   allFreq = [allFreq; leftLDL.Frequency_Hz(:); rightLDL.Frequency_Hz(:)];
end
fmin = min(allFreq) * 2^(-0.25);
fmax = max(allFreq) * 2^(0.25);

cla;
hold on;

xx = [0 0 1 1 0];
yy = [0 1 1 0 0];
h = patch(fmin + xx*(fmax - fmin), 25 * yy, 'g');
set(h, ...
   'EdgeColor', 'none', ...
   'FaceColor', [0.85 0.95 0.85], ...
   'FaceAlpha', 0.4);

if ~isempty(leftAudio)
   plot(leftAudio.Frequency_Hz, min(yInfValue, leftAudio.Threshold_dBHL), 'bx', ...
      'LineWidth', lineWidth, ...
      'MarkerSize', markerSize);
end

if ~isempty(rightAudio)
   plot(rightAudio.Frequency_Hz, min(yInfValue, rightAudio.Threshold_dBHL), 'rs', ...
      'LineWidth', lineWidth, ...
      'MarkerSize', markerSize);
end

if ~isempty(leftLDL)
   h = text(leftLDL.Frequency_Hz, min(yInfValue, leftLDL.Threshold_dBHL), 'U');
   set(h, ...
      'Color', 'b', ...
      'FontWeight', 'bold');
end

if ~isempty(rightLDL)
   h = text(rightLDL.Frequency_Hz, min(yInfValue, rightLDL.Threshold_dBHL), 'U');
   set(h, ...
      'Color', 'r', ...
      'FontWeight', 'bold');
end

xlabel('Frequency (Hz)');
ylabel('dB HL');

grid on;
set(gca, 'YLim', [-10 120]);
set(gca, 'XLim', [fmin fmax]);
set(gca, 'XScale', 'log');
set(gca, 'YDir', 'reverse');
