function header = read_header(fn)
% bdf.READ_HEADER -- read Biosemi .bdf file header.
% Usage: header = bdf.read_header(fn)
%

fp = fopen(fn, 'rb', 'n', 'UTF-8');
if fp < 0, error('Could not open .bdf file for reading.'); end

% Check indicator
bytes = fread(fp, 8, 'uint8');

if bytes(1) ~= 255 || ~strcmp(char(bytes(2:end)'), 'BIOSEMI')
   fclose(fp);
   error('Not a valid Biosemi .bdf file.');
end

header.Path = fn;
header.LocalSubjectID = strtrim(char(fread(fp, 80, 'char')'));
header.LocalRecordID = strtrim(char(fread(fp, 80, 'char')'));
header.Date = char(fread(fp, 8, 'char')');
header.Time = char(fread(fp, 8, 'char')');

header.HeaderSize = str2double(char(fread(fp, 8, 'char')'));
header.Format = strtrim(char(fread(fp, 44, 'char')'));
header.NumberOfRecords = str2double(char(fread(fp, 8, 'char')'));
header.RecordDuration_s = str2double(char(fread(fp, 8, 'char')'));
header.NumberOfChannels = str2double(char(fread(fp, 4, 'char')'));

header.Labels = read_strings(fp, header.NumberOfChannels, 16);
header.Transducers = read_strings(fp, header.NumberOfChannels, 80);
header.Dimensions = read_strings(fp, header.NumberOfChannels, 8);

header.PhysicalMin = read_array(fp, header.NumberOfChannels, 8);
header.PhysicalMax = read_array(fp, header.NumberOfChannels, 8);
header.DigitalMin = read_array(fp, header.NumberOfChannels, 8);
header.DigitalMax = read_array(fp, header.NumberOfChannels, 8);

header.Prefilter = read_strings(fp, header.NumberOfChannels, 80);
header.SamplesPerRecord = read_array(fp, header.NumberOfChannels, 8);
header.SampleRate = header.SamplesPerRecord(1) / header.RecordDuration_s;

fclose(fp);

%--------------------------------------------------------------------------
function S = read_strings(fp, numChan, numBytesPerChan)

nb = numChan * numBytesPerChan;

bytes = fread(fp, nb, 'char');
S = cell(numChan, 1);
for k = 1:numChan
   S{k} = strtrim(char(bytes((k-1)*numBytesPerChan + (1:numBytesPerChan))'));
end

%--------------------------------------------------------------------------
function A = read_array(fp, numChan, numBytesPerChan)

nb = numChan * numBytesPerChan;

bytes = fread(fp, nb, 'char');
A = NaN(numChan, 1);
for k = 1:numChan
   A(k) = str2double(char(bytes((k-1)*numBytesPerChan + (1:numBytesPerChan))'));
end

%--------------------------------------------------------------------------
% END OF bdf.READ_HEADER.M
%--------------------------------------------------------------------------

