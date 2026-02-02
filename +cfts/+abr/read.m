function [Data, Header] = read(fn, varargin)
% cfts.abr.read -- read CFTS-format ABR data.
% Usage: [D, H] = cfts.abr.read(fn);
%
% ---Input---
%  fn : data file path
%
% ---Outputs---
% D: data structure, containing...
%     neural:  matrix of ABR data (in microvolts). Each column contains the ABR for
%              one sound level
%     cm:  matrix of CM data (in microvolts).
%     time  : time vector
%     level : sound levels
%
% H : full data header
%

text = fileread(fn);

if startsWith(text, ':RUN')
   [Data, Header] = read_old_format(text);
   return;
elseif ~startsWith(text, '[STANDARD ABR]')
   error('Unexpected ABR file format.');
end

% Read parameter sections
[Header, dataStr] = epl.file.parse_ini(text, 'indicator', 'STANDARD ABR');
Header.Info.Levels = eval([ '[' Header.Info.Levels ']' ]);
Header.Info.Avgs = eval([ '[' Header.Info.Avgs ']' ]);
Header.Info.Tries = eval([ '[' Header.Info.Tries ']' ]);

L = Header.Info.Levels;

a = textscan(dataStr, '%f', 'HeaderLines', 1, 'EndOfLine', '\r\n');
a = reshape(a{1}, 2*length(L)+1, [])';

Data.time = a(:, 1);
Data.neural = a(:, 1 + (1:length(L)));
Data.cm = a(:, 1 + length(L) + (1:length(L)));
Data.level = L;

%--------------------------------------------------------------------------
function [D, H] = read_old_format(text)

% Split text into data and header
[splitStart, splitEnd] = regexp(text, ':DATA[\n\r]');
if isempty(splitStart)
   error('Unexpected ABR file format: missing [DATA]');
end

header = text(1:splitStart-1);
data = text(splitEnd+1:end);

% Scan header for waveform
varargout = cell(size(varargin));

idx = find(strcmpi('stimulus', varargin));
if idx > 0
   wf = regexp(header, 'SW FREQ: ([\d\w.]+)', 'tokens');
   varargout{idx} = wf{1}{1};
end

idx = find(strcmpi('sample', varargin));
if idx > 0
   t = regexp(text, 'SAMPLE \(\w+\): (\d+)', 'tokens');
   dt = str2double(t{1});
   varargout{idx} = dt;
end

idx = find(strcmpi('iti', varargin));
if idx > 0
   t = regexp(text, 'ITI \(ms\):([\d.]+)', 'tokens');
   iti = str2double(t{1});
   varargout{idx} = iti;
end

% Scan header for vector of # avgs
idx = find(strcmpi('avgs', varargin));
if idx > 0
   t = regexp(header, ':Avgs: ([\d;]+)[\n\r]', 'tokens');
   if ~isempty(t)
      varargout{idx} = sscanf(t{1}{1},'%f;');
   end
end

% Scan header for vector of # tries
idx = find(strcmpi('tries', varargin));
if idx > 0
   t = regexp(header, ':Tries: ([\d;]+)[\n\r]', 'tokens');
   if ~isempty(t)
      varargout{idx} = sscanf(t{1}{1},'%f;');
   end
end

% Scan header for vector of stimulus levels
t = regexp(header, ':LEVELS:([\d.-;]+)[\n\r]', 'tokens');
L = sscanf(t{1}{1},'%f;');

% Parse data
c = textscan(data, '%f');
Y = reshape(c{1}, length(L), [])';
H = header;
%--------------------------------------------------------------------------
% END OF CFTS.ABR.READ.M
%--------------------------------------------------------------------------
