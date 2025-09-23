function writeKParam(fp, P)

fwrite(fp, length(P), 'int32');
for k = 1:length(P)
   writeOneKParam(fp, P(k));
end

%--------------------------------------------------------------------------
function writeOneKParam(fp, P)

writeLenAndString(fp, P.name);
writeLenAndString(fp, P.units);
fwrite(fp, P.type, 'char');
writeLenAndString(fp, P.expr);
fwrite(fp, P.val, 'float32');

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
