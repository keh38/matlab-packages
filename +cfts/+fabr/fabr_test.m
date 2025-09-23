fn = 'C:\Users\kehan\OneDrive\Desktop\XYZ999-CAP-14.raw';

fp = fopen(fn, 'rb', 'b');

indicator = epl.file.read_prepended_string(fp);
if ~strcmp(indicator, 'FAST_ABR_RAW_DATA')
   error('not a valid Fast ABR raw data file');
end

fs = fread(fp, 1, 'double');
npts = fread(fp, 1, 'int32');

freq = epl.file.read_prepended_1d_array(fp);
level = epl.file.read_prepended_1d_array(fp);

numAcq = zeros(length(freq), length(level));
ABR = zeros(length(freq), length(level), npts);

while true
   if feof(fp), break; end
   
   nstim = fread(fp, 1, 'uint32');

   coe = cell(nstim, 1);
   scl = struct('freqIndex', coe, 'levelIndex', coe, 'polarity', coe);
   
   for k = 1:nstim
      a = fread(fp, 4, 'uint32');
      atten = fread(fp, 1, 'double');

      scl(k).freqIndex = a(2) + 1;
      scl(k).levelIndex = a(3) + 1;
      scl(k).polarity = a(4);
   end

   y = epl.file.read_prepended_1d_array(fp);

   offset = 0;
   for k = 1:nstim
      fidx = scl(k).freqIndex;
      lidx = scl(k).levelIndex;

      numAcq(fidx, lidx) = numAcq(fidx, lidx) + 1;
      ABR(fidx, lidx, :) = squeeze(ABR(fidx, lidx, :)) + y(offset + (1:npts));

      offset = offset + npts;
   end
end
fclose(fp);

figure(1);
tiledlayout(length(level), length(freq), 'TileSpacing', 'compact', 'Padding', 'compact');

ymax = max(abs(ABR(:)));

for kl = length(level):-1:1
   for kf = 1:length(freq)
      nexttile;
      plot(squeeze(ABR(kf, kl, :)) / numAcq(kf, kl));
      axis off;
      xlim([0 200]);
      ylim(ymax * [-1 1]);
   end
end