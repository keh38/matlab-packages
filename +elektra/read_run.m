function [Data, Header] = read_run(fn)
% elektra.read_run -- reads summary data for Elektra run.
% Usage: [Data, Header] = elektra.read_run(filepath)
% 
% Inputs:
%   filepath:      run data file, e.g. 'XYZ999-Session1-Run12.log'
%
% Outputs:
%   Data:    structure containing summary data
%   Header:  structure containing comprehensive description of Elektra setup
%

if ~exist(fn, 'file')
   error(['Cannot find data file: ' fn]);
end

% Read parameter sections
s = epl.file.parse_ini(fn, 'indicator', 'ELEKTRA DATA');
Header.Info = s.Info;
Header.Metadata = s.Metadata;
Header.Config = s.Config;
Header.UserStim = s.UserStim;

Header.Info.Filename = fn;

Data = {};

% Read data section
% Find trials
ktr = 1;
while true
   trialName = sprintf('Trial_%d', ktr);
   if ~isfield(s, trialName)
      break;
   end

   Data{ktr} = s.(trialName); %#ok<AGROW> 

   ktr = ktr + 1;
end


%--------------------------------------------------------------------------
% END OF elektra.read_run.m
%--------------------------------------------------------------------------
