function FN = pastefn()
fn = strrep(clipboard('paste'), '"', '');
if nargout == 0
   evalin('base', ['fn=''' fn '''']);
else
   FN = fn;
end

