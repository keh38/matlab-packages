function EL = create_log(filePath, varargin)
% elektra.create_log -- parse Elektra data for re-analysis
% Usage: EL = elektra.create_log(filePath)
% Usage: EL = elektra.create_log(filePath, 'aviFolder', aviFolder)
%
% --- Inputs ---
% FN        : main Elektra data file
% aviFolder : if specified, adds video frame information
%

[aviFolder, fn] = fileparts(filePath);

klib.file.parse_propval_pairs(varargin{:});

[data, header] = elektra.read_run(filePath);
avi = elektra.read_avi_log(fullfile(aviFolder, [fn '.avi.log']));

EL.filename = header.Info.Filename;
EL.version = header.Info.Version;
EL.params = header;

if length(avi) ~= length(data)
   error('Elektra log does not match number of .avi''s');
end

for k = 1:length(data)
   data{k}.avi = avi(k);
end

EL.trials = data;

% save to .mat file
save(strrep(EL.filename, '.log', '.log.mat'), 'EL');

