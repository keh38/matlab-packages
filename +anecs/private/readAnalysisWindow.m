function S = readAnalysisWindow(fp)

blockLabel = readLenAndString(fp);
if ~isequal(blockLabel, 'Analysis Window')
   error('Invalid analysis window block.');
end

numWin = fread(fp, 1, 'int32');
for k = 1:numWin
   S(k) = read_one(fp); %#ok<AGROW> 
end

%--------------------------------------------------------------------------
function A = read_one(fp)

A.Name = readLenAndString(fp);
A.position = fread(fp, 4, 'int32');
A.Param = readKParam(fp);
A.Graph = read_graph_param(fp);

%--------------------------------------------------------------------------
function P = read_graph_param(fp)

P.Name = readLenAndString(fp);
P.titleFontColor = fread(fp, 1, 'int32');
P.brushColor = fread(fp, 1, 'int32');
P.axisColor = fread(fp, 1, 'int32');

P.showFrame = fread(fp, 1, 'char');
P.showBox = fread(fp, 1, 'char');
P.axisFontName = readLenAndString(fp);
P.axisFontSize = fread(fp, 1, 'int32');

for kax = 1:2
   ax.Label = readLenAndString(fp);
   ax.Min = fread(fp, 1, 'float32');
   ax.Step = fread(fp, 1, 'float32');
   ax.Max = fread(fp, 1, 'float32');
   ax.ShowGrid = fread(fp, 1, 'char');
   if kax == 1
      P.XAxis = ax;
   else
      P.YAxis = ax;
   end
end

