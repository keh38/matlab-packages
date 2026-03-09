function TR = read_trace_data(FN, options)
% tosca.read_trace_data -- read trace data
%
% Usage: TR = tosca.read_trace_data(fn)
% 
% Inputs:
%   FN : filename, e.g. 'XYZ999-Session1-Run12.trace.txt'
%
% Output:
%   TR : structure array containing trace data (by trial).
%

arguments
   FN (1,:) char = ''
   options.flatten (1,:) logical = true
   options.concise (1,:) logical = false
end

if ~contains(FN, '.trace')
   FN = strrep(FN, '.txt', '.trace.txt');
end

fp = fopen(FN, 'rt');
if fp < 0
   error('Could not find file: %s', FN);
end

c = textscan(fp, '%f %d %s %f %s', 'Delimiter', '\t', 'HeaderLines', 1);
fclose(fp);

t = c{1};
e = c{2};
m = c{3};
d = c{4};
s = c{5};

TR = struct( ...
   'Time', [], ...
   'Event', [], ...
   'Message', {}, ...
   'Data', [], ...
   'Source', {} ...
);

if options.flatten

   ifilt = true(size(t));
   if options.concise
      ifilt = e < 3;
   end

   traceData.time = t(ifilt);
   traceData.code = e(ifilt);
   traceData.item = m(ifilt);

   if ~options.concise
      traceData.Data = d;
      traceData.Source = s;
   end
   TR = traceData;
   return;
end

itrial = [find(e == 1); length(e)+1];

for kt = 1:length(itrial)-1
   idx = itrial(kt) : min(itrial(kt+1), length(e));
   TR(kt).Time = t(idx);
   TR(kt).Event = e(idx);
   TR(kt).Message = m(idx);
   TR(kt).Data = d(idx);
   TR(kt).Source = s{idx};
end
