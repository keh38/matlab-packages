function resave(fn, freq, mag, phase, fnOut)

if nargin < 5
   [~, fnOut] = fileparts(fn);
   fnOut = [fnOut '_resave'];
end

text = fileread(fn);
isplit = strfind(text, 'Freq(Hz)');

fpOut = fopen(fnOut, 'w');
fprintf(fpOut, '%s', text(1:isplit-1));

fprintf(fpOut, 'Freq(Hz)\tMag(dB)\tPhase(deg)\n');
for k = 1:length(freq)
   fprintf(fpOut, '%.5f\t%.5f\t%.5f\n', freq(k), mag(k), phase(k));
end

fclose(fpOut);