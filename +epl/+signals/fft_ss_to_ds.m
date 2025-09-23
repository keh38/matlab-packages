function ds = fft_ss_to_ds(ss, npts)

isCol = iscolumn(ss);
if isCol
   ss = ss';
end

ss(2:end) = ss(2:end) / sqrt(2);

% Make the spectrum double-sided again.
if mod(npts, 2) == 0
   ds = [ss conj(ss(end-1:-1:2))];
else
   ds = [ss conj(ss(end:-1:2))];
end

if isCol
   ds = ds';
end

ds = ds * length(ds);