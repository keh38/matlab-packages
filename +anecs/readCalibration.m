function S = readCalibration(FN)

fp = fopen(FN, 'rb', 'ieee-le');
if fp == -1, error('readCal: Cannot open file for reading.'); end


% Read calibration file header
nchar             = fread(fp, 1, 'int32');
filetypeLabel      = char(fread(fp, nchar, 'char')');
if ~isequal(filetypeLabel, 'This is an ANECS spectrum data file!'),
   error('Invalid ANECS calibration file.');
end

S.Info = readInfo(fp);
fileFormat = get_file_format(S.Info);

S.Equip = readEquip(fp);
S.Stim = readStim(fp, S.Equip.numStimChan, fileFormat);
S.Resp = readResp(fp);
S.A = readSpecWin(fp);
S.B = readSpecWin(fp);

S.Spec = readSpec(fp);

fclose(fp);

%--------------------------------------------------------------------------
function format = get_file_format(I)

A = sscanf(I.version, 'Version %d.%d.%d.%d');
major = A(1);
minor = A(2);
fix = A(3);
build = A(4);

if (major < 2),
   format = 1;
elseif major==2 && minor<5,
   format = 1;
elseif major==2 && minor==5 && fix<1,
   format = 1;
else
   format = 2;
end

