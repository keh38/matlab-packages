function [Data, Header] = read_turandot_data(fn)

try
   s = loadjson(fn);
   Data = s.data;
   Header.info = s.info;
   Header.params = s.params;
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

