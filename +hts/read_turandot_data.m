function [Data, Header] = read_turandot_data(fn)

try
   s = loadjson(fn);
   Data = s.data;

   fieldnames = fields(s);
   for k = 1:length(fieldnames)
      if isequal(fieldnames{k}, 'data'), continue; end
      Header.(fieldnames{k}) = s.(fieldnames{k});
   end

catch

   text = fileread(fn);

   isplit = strfind(text, '{"block"');

   if ~isempty(isplit)
      headerText = text(1:isplit(1)-1);
      dataText = ['[{' strrep(text(isplit(1)+1:end), '{"block', ',{"block') ']'];
   else
      headerText = text;
      dataText = '';
   end

   Header = jsondecode(headerText);
   if isempty(dataText)
      Data = [];
   else
      Data = jsondecode(dataText);
   end
end

