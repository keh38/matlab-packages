function create_audiogram_xml_files(fn, folder)

if nargin < 2, folder = fileparts(fn); end

data = hts.read_json_file(fn);
audiogram = hts.sanitize_audiogram(data.audiogram);
ldlgram = hts.sanitize_audiogram(data.LDLgram);

fprintf('Writing agram.xml...\n')
hts.audiogram2xml(audiogram, fullfile(folder, 'agram.xml'));
fprintf('Writing ldlgram.xml...\n')
hts.audiogram2xml(ldlgram, fullfile(folder, 'ldlgram.xml'));
