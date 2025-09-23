function [S, data] = parse_ini(text, varargin)
% PARSE_INI -- reconstruct data from INI format.
% Usage: S = parse_ini(FN)
% Usage: S = parse_ini(text)
%

indicator = '';
collapseSingle = true;

epl.file.parse_propval_pairs(varargin{:});
if exist(text, 'file')
   text = fileread(text);
end

data = extractAfter(text, ['[DATA]' newline]);
if isempty(data)
   data = extractAfter(text, ['[DATA]' char(13) newline]);
end

lines = splitlines(text);

S = [];
kln = 1;
while kln < length(lines)
   if isempty(lines{kln}) || strcmpi(lines{kln}, '[data]')
      break;
   end

   if lines{kln}(1) == '['
      Section = lines{kln}(2:end-1);
      if isequal(Section, indicator)
         Section = 'Info';
      elseif isempty(S) && contains(Section, 'data file', 'IgnoreCase', true)
         dataType = Section;
         Section = 'Info';
      else
         Section = epl.file.create_valid_varname(Section);
      end
      kln = kln + 1;
      [S.(Section), kln] = parse_section(lines, kln, collapseSingle);
   else
      kln = kln + 1;
   end
   
end

%--------------------------------------------------------------------------
function [P, index] = parse_section(lines, index, collapseSingle)
% PARSE_SECTION
%
P = [];
IsStructArray = false;
while index <= length(lines)
%    if ~IsStructArray
      line = lines{index};
      index = index + 1;
%    end
   IsStructArray = false;
   if ~isempty(line) && isequal(line(1), '[')
      index = index - 1;
      break;
   end

   idx = find(line == '=');
   if isempty(idx), continue; end
   
   curKey = epl.file.create_valid_varname(line(1:idx-1));
   
   [val, IsStructArray] = parse_value(line(idx+1:end));
   if IsStructArray
      [val, index] = parse_struct_array(lines, index, line(1:idx-1), val);  
   end
   
   if ischar(val)
      eval(['P.' curKey '=''' val ''';']);
   else
      eval(['P.' curKey '=val;']);
   end
end

if ~isempty(P)
   names = fields(P);
   if length(names) == 1 && collapseSingle
      P = P.(names{1});
   end
end

%--------------------------------------------------------------------------
function [Val, IsStructArray] = parse_value(valStr)

IsStructArray = false;

% Parse value
valStr = strtrim(valStr);
if isempty(valStr)
   Val = '';
   
elseif isequal(lower(valStr), 'true')
   Val = true;
elseif isequal(lower(valStr), 'false')
   Val = false;
elseif isequal(valStr(1), '<')
   idx = find(valStr == '>');
   dim = sscanf(valStr(2:idx-1), '%d');
   if isempty(dim)
      Val = valStr;
   else
      dim = dim(:)';
      if length(dim) == 1
         dim = [1 dim];
      end
      valStr = valStr(idx+1:end);
      Val = sscanf(valStr, '%g,');
      if ~isempty(Val)
         Val = reshape(Val, fliplr(dim));
      elseif prod(dim) > 0
         Val = dim;
         IsStructArray = true;
      end
   end
   
elseif valStr(1)=='-' || (valStr(1)>='0' && valStr(1)<='9')
   Val = str2double(valStr);
   if isnan(Val)
      Val = valStr;
   end
   
else
   Val = valStr;
   Val = strrep(Val, 'line*~|.feed', '\n');
end

%--------------------------------------------------------------------------
function [S, lineNum] = parse_struct_array(lines, lineNum, name, dim)

while true
   line = lines{lineNum};
   if isequal(line, -1), break; end
   
   line = strrep(line, '..', '.');
   idx = strfind(line, name);
   ieq = find(line == '=');
   if isempty(idx) || idx(1) > ieq(1), break; end

   line = line(idx:end);
   
   idot = find(line == '.');
   idot = idot(idot > length(name));

   lineNum = lineNum + 1;
  
   ieq = find(line == '=');
   if isempty(idot) || idot(1)>ieq
      index = 1 + sscanf(line(length(name)+1:ieq(1)-1), '%d');
      val = parse_value(line(ieq(1)+1:end));
      if isscalar(index)
         S{index} = val;
      elseif length(index) == 2
         S(index(1), index(2)) = val;
      else
         error('Error parsing array.');
      end
      continue;
   end

   index = 1 + sscanf(line(length(name)+1:idot(1)-1), '%d');

   curKey = epl.file.create_valid_varname(line(idot(1)+1:ieq(1)-1));
   
   parentVars = strtrim(strsplit(name, '.'));
   curVars = strsplit(curKey, '.');
   if strcmp(parentVars{end}, curVars{1}) || strcmp(parentVars{end}, [curVars{1} 's']) ...
         || (strcmp(parentVars{end}, 'StimChans') && strcmp(curVars{1}, 'Stimulus')) ...
         || (strcmp(parentVars{end}, 'Families') && strcmp(curVars{1}, 'Family')) ...
         || (strcmp(parentVars{end}, 'Vars') && strcmp(curVars{1}, 'Element')) ...
         || (strcmp(parentVars{end}, 'Flowchart') && strcmp(curVars{1}, 'Flow_Element')) 
      curKey = '';
      for k = 2:length(curVars)
         curKey = [curKey '.' curVars{k}];
      end
   else
      curKey = ['.' curKey];
   end

   [val, IsStructArray] = parse_value(line(ieq(1)+1:end));
   if IsStructArray
      [val, lineNum] = parse_struct_array(lines, lineNum, line(idot(end)+1:ieq(1)-1));
   end
   
   if ischar(val)
      eval(['S(index)' curKey '=''' val ''';']);
   else
      eval(['S(index)' curKey '=val;']);
   end   
end

%--------------------------------------------------------------------------
% END OF PARSE_INI.M
%--------------------------------------------------------------------------
