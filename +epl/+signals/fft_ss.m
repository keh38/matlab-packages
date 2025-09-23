function [s, f] = fft_ss(y, fs)

if nargin < 2, fs = 1; end

s = fft(y) / length(y);
s(2:end) = s(2:end) * sqrt(2);

f = (0:length(y)-1) * fs / length(y);

ikeep = f <= fs/2;
s = s(ikeep);
f = f(ikeep);