function [Y, H] = raw_to_mat(fn)

H = ephys_open_raw(fn);

Y = NaN(H.nchan, H.npts);

offset = 0;
for k = 1:H.npairs
   [y, H] = ephys_read_raw(H, 2);
   
   Y(:, offset + (1:size(y, 2))) = y;
   offset = offset + size(y,2);
end

ephys_close_raw(H);