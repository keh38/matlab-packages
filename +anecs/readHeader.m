function H = readHeader(filePath)
% READ_HEADER -- read ANECS metadata from file into structure.
% Usage: H = read_header(filePath)
%

fp = fopen(filePath, 'rb', 'ieee-le');
if fp == -1
   error('read_header: Cannot open file for reading.');
end

blockLabel = readLenAndString(fp);
if ~isequal(blockLabel, 'This is an ANECS data file!')
   error('Invalid ANECS data file.');
end

H.Info = readInfo(fp);
H.Info.fileName = filePath;
fileFormat = get_file_format(H.Info);

H.Equip = readEquip(fp);
H.Stim = readStim(fp, 2, fileFormat);
H.Inner = readSequence(fp, fileFormat);
H.Outer = readSequence(fp, fileFormat);
H.SCL = readStimConList(fp);
H.Resp = readResp(fp);
H.AWin = readAnalysisWindow(fp);

% if ~headerOnly && H.Resp.saveSpikeTimes
   H.Events = readEvents(fp);
   H.SCL = append_times_to_SCL(H.SCL, H.Events);
% else
%    H.Events = [];
% end
% 
% if ~headerOnly && H.Resp.saveAvgWaveform
%    H.WF = readAverageWaveforms(fp, H.Resp);
% else
%    H.WF = [];
% end

fclose(fp);

%--------------------------------------------------------------------------
function format = get_file_format(I)

A = sscanf(I.version, 'Version %d.%d.%d.%d');
major = A(1);
minor = A(2);
fix = A(3);
build = A(4); %#ok<NASGU> 

if (major < 2)
   format = 1;
elseif major==2 && minor<5
   format = 1;
elseif major==2 && minor==5 && fix<1
   format = 1;
elseif build < 40
   format = 2;
elseif build < 50
   format = 3;
else
   format = 4;
end

%--------------------------------------------------------------------------
function SCL = append_times_to_SCL(SCL, E)

if isempty(E)
   return;
end

idbl = find(E(1:end-1) == 0 & E(2:end)==0);
if ~isempty(idbl)
    E(idbl+1) = 0.01;
end

if E(end) ~= 0, E(end+1) = 0; end

itr = find(E == 0);

kblock = 1;
n = 1;
for k = 1:length(itr)-1
   SCL.block(kblock, n).times = E(itr(k)+1 : itr(k+1)-1);
   n = n + 1;
   if n > SCL.blockLength
      n = 1;
      kblock = kblock + 1;
      if kblock > SCL.numBlocks
         break;
      end
   end
end

%--------------------------------------------------------------------------
% END OF READ_ANECS.M
%--------------------------------------------------------------------------
