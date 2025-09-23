function P = readKParam(fp)

np = fread(fp, 1, 'int32');
if np == 0
   P = [];
else
   for k = 1:np
      P(k) = readOneKParam(fp); %#ok<AGROW> 
   end
end

%--------------------------------------------------------------------------
function P = readOneKParam(fp)

P.name = readLenAndString(fp);
P.units = readLenAndString(fp);
P.type = fread(fp, 1, 'char');
P.expr = readLenAndString(fp);
P.val = fread(fp, 1, 'float32');

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
