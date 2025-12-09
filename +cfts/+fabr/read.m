function [Data, Header] = read(filepath)
% cfts.fabr.read -- reads data for 
% Usage: [Data, Header] = elektra.read_run(filepath)
% 
% Inputs:
%   filepath:      run data file, e.g. 'XYZ999-Session1-Run12.log'
%
% Outputs:s
%   Data:    structure containing summary data
%   Header:  structure containing comprehensive description of Elektra setup
%

if ~exist(filepath, 'file')
   error(['Cannot find data file: ' filepath]);
end

% Read parameter sections
[Header, dataStr] = epl.file.parse_ini(filepath, 'indicator', 'FAST ABR');

L = eval([ '[' Header.Info.Levels ']' ]);

a = textscan(dataStr, '%f', 'HeaderLines', 1, 'EndOfLine', '\r\n');
a = reshape(a{1}, 2*length(L)+1, [])';

Data.time = a(:, 1);
Data.neural = a(:, 1 + (1:length(L)));
Data.cm = a(:, 1 + length(L) + (1:length(L)));
Data.level = L;
