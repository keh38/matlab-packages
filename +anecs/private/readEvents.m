function E = readEvents(fp)

blockLabel = readLenAndString(fp);
if isempty(blockLabel)
   E = [];
   return;
end

if ~isequal(blockLabel, 'Events')
   error('Invalid event block.');
end

E = fread(fp, Inf, 'float32');
% return;

% e1 = fread(fp, 302, 'float32');
% garbage = fread(fp, 6, 'uint8');
% disp(garbage');
% disp(char(garbage'));
% e2 = fread(fp, Inf, 'float32');
% E = [e1; e2];
% return;
% 
% E = [];
% for k = 1:109,
%    a = fread(fp, 1, 'float32');
% end
% fprintf('%d: %g\n', k, a);
% 
% fread(fp, 10, 'int8');
% 
% for k = 1:5,
%    a = fread(fp, 1, 'float32');
%    fprintf('%g\n',a);
% end
% 
