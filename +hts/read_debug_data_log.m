function data = read_debug_data_log(fn)

if exist(fn, 'dir')
   fn = epl.file.find_latest(fn, 'DebugDataLog');
end

fp = fopen(fn, 'rb');
if fp < 0
   error('Error opening file');
end

n = fread(fp, 1, 'uint8');
indicator = fread(fp, n, '*char')';
if ~strcmp(indicator, 'DebugDataLog')
   fclose(fp);
   error('file does not contain a debug data log');
end

while true
   [d, name] = read_one_entry(fp);

   if isempty(d), break; end

   data.(name) = d;
end


fclose(fp);

end

%--------------------------------------------------------------------------
function [data, name] = read_one_entry(fp)

dataType = read_string(fp);

if isempty(dataType)
   data = [];
   name = '';
   return;
end

name = read_string(fp);

switch dataType
   case 'JSON'
      json = read_string(fp);
      data = jsondecode(json);

   case 'FloatArray'
      data = epl.file.read_prepended_1d_array(fp, 'float');

   otherwise
      warning('unknown log data type');
end
end

%--------------------------------------------------------------------------
function value = read_string(fp)

n = fread(fp, 1, 'int');
if isempty(n)
   value = [];
   return;
end

value = fread(fp, n, '*char')';

end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------


