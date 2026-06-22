function data = read_master_data_log(fn)

data = [];

fp = fopen(fn, 'rb');
if fp < 0
   error('Error opening file');
end

n = fread(fp, 1, 'uint8');
indicator = fread(fp, n, '*char')';
if ~strcmp(indicator, 'Master Log')
   fclose(fp);
   error('file does not contain a master data log');
end

while true
   [d, name] = read_one_log(fp);

   if isempty(d), break; end

   if ~isempty(data) && ismember(name, fieldnames(data))
      data.(name)(end+1) = d;
   else
      data.(name) = d;
   end
end

fclose(fp);
end

%--------------------------------------------------------------------------
function [data, name] = read_one_log(fp)

nbytes = fread(fp, 1, 'int');
if isempty(nbytes)
   data = [];
   name = '';
   return;
end

dataType = read_string(fp);

switch dataType
   case {'JSON', 'JsonLog'}
      [data, name] = read_one_json(fp);

   case 'DataLog'
      [data, name] = read_one_data_log(fp);

   case 'EventLog'
      [data, name] = read_one_event_log(fp, true);

   case 'TextLog'
      [data, name] = read_one_text_log(fp);

   otherwise
      warning('unknown log data type');
end
end

%--------------------------------------------------------------------------
function name = read_string(fp)

n = fread(fp, 1, 'int');
name = fread(fp, n, '*char')';

end

%--------------------------------------------------------------------------
function [data, name] = read_one_json(fp)

name = read_string(fp);

n = fread(fp, 1, 'int');
json = fread(fp, n, '*char')';
data = jsondecode(json);
end

%--------------------------------------------------------------------------
function [data, name] = read_one_data_log(fp)

name = read_string(fp);

n = fread(fp, 1, 'int');
delimitedVariableNames = fread(fp, n, '*char')';
variableNames = split(delimitedVariableNames, char(0));
variableNames = variableNames(1:end-1);

n = fread(fp, 1, 'int32');
itime = fread(fp, n, '*int64');

n = fread(fp, 1, 'int32');
d = fread(fp, n, 'float')';
d = reshape(d, length(variableNames), n / length(variableNames));

data.itime = itime;
for k = 1:length(variableNames)
   data.(variableNames{k}) = d(k,:);
end

n = fread(fp, 1, 'int32');
if n > 0
   d = read_one_event_log(fp);
   data.events = d;
   % flds = fieldnames(d);
   % for k = 1:length(flds)
   %    data.(flds{k}) = d.(flds{k});
   % end
end
end

%--------------------------------------------------------------------------
function [data, name] = read_one_event_log(fp, standalone)

name = [];

if nargin < 2
   standalone = false;
end

if standalone
   name = read_string(fp);
end

n = fread(fp, 1, 'int');
delimitedVariableNames = fread(fp, n, '*char')';
variableNames = split(delimitedVariableNames, char(0));
variableNames = variableNames(1:end-1);

n = fread(fp, 1, 'int32');
values = fread(fp, n, 'float');

n = fread(fp, 1, 'int32');
time = fread(fp, n, 'float');

n = fread(fp, 1, 'int32');
itime = fread(fp, n, '*int64');

data = [];

% uniqueNames = unique(variableNames);
% for k = 1:length(uniqueNames)
%    ifilt = strcmp(uniqueNames{k}, variableNames);
%    if all(itime(ifilt) < 0)
%       data.(uniqueNames{k}) = values(ifilt);
%    else
%       data.(uniqueNames{k}) = struct('time', time(ifilt), 'itime', itime(ifilt), 'value', values(ifilt));
%    end
% end
data = struct('time', {time}, 'itime', {itime}, 'description', {variableNames}, 'value', {values});

end

%--------------------------------------------------------------------------
function [data, name] = read_one_text_log(fp)

name = read_string(fp);

n = fread(fp, 1, 'int32');
time = fread(fp, n, 'float');

n = fread(fp, 1, 'int');
delimitedEntries = fread(fp, n, '*char')';
entries = split(delimitedEntries, char(0));
entries = entries(1:end-1);


data = struct('time', {time}, 'entry', {entries});

end

%--------------------------------------------------------------------------
