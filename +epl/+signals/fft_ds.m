function [s, f] = fft_ds(y, fs)

if nargin < 2, fs = 1; end

n = length(y);
s = fftshift(fft(y) / n);

nh = floor(n/2);

if mod(n, 2) > 0 % n odd
   f = (-nh:nh) * (fs/n);
else % n even
   f = (-nh:nh-1) * (fs/n);
end



