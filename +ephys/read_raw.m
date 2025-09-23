function [M, H] = read_raw(H, Nrep, E)

if nargin < 3
   E = 1:H.nchan;
end

M = NaN(length(E), Nrep*H.pts_per_rep);

coff = (E-1) * H.doubles_per_read_per_chan;

for kr = 1:Nrep
   if H.repsRead == H.reps_per_frame || isempty(H.data)
      H.data = fread(H.fp, H.doubles_per_read, 'double');
      H.offset = 0;
      H.repsRead = 0;
   end
   
   for kc = 1:length(E)
      M(kc, (kr-1)*H.pts_per_rep + (1:H.pts_per_rep)) = ...
         H.data(coff(kc) + H.offset + (1:H.pts_per_rep));
   end
   
   H.repsRead = H.repsRead + 1;
   H.offset = H.offset + H.pts_per_rep;
end

