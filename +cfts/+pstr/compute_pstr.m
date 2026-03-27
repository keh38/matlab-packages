function [pstr, t] = compute_pstr(Vrw, Fs, Nreps)

Flo = 300;
Fhi = 1200;
N = 2;

[b, a] = butter(N, [Flo Fhi] * 2 / Fs);
V = filtfilt(b, a, Vrw);

V = abs(V);

tsmooth = 0.001;
n = round(Fs * tsmooth);
a = 1;
b = 1/n * ones(n, 1);
V = filtfilt(b, a, V);

blockSize = numel(V) / Nreps;
V = reshape(V, blockSize, Nreps);

pstr = mean(V, 2);
t = (0:length(pstr)-1) * 1000 / Fs;
