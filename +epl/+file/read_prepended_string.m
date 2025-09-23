function A = read_prepended_string(fp)
% READ_PREPENDED_ARRAY -- read array saved by LV with prepended size.
% Usage: A = read_prepended_array(fp)
%
sz = fread(fp, 1, 'uint32');
if sz == 0
    A = [];
    return;
end

A = fread(fp, prod(sz), 'char');
A = char(A');
