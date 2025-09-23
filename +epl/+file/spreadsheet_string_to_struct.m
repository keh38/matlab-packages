function Data = spreadsheet_string_to_struct(dataString, delim)

if nargin < 2, delim = '\t'; end

isplit = find(dataString == newline, 1);
varNames = strtrim(strsplit(dataString(1:isplit-2), delim));

fmt = repmat(['%f' delim], 1, length(varNames));
values = textscan(dataString(isplit+1:end), fmt);

Data = struct();
for k = 1:length(varNames)
   Data.(varNames{k}) = values{k};
end
