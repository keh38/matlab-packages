function openfolderof(mfile)

if nargin == 0
   target = pwd;
else
   target = fileparts(which(mfile));
end
   
system(['explorer "' target '" .']);