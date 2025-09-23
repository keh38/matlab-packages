function S = readStimConList(fp)

blockLabel = readLenAndString(fp);
if ~isequal(blockLabel, 'Stimulus List')
   error('Invalid stimulus condition list block.');
end

S.numBlocks = fread(fp, 1, 'int32');
S.blockLength = fread(fp, 1, 'int32');
S.numInner = fread(fp, 1, 'int32');
S.numOuter = fread(fp, 1, 'int32');

for k = 1:S.numBlocks
   for j = 1:S.blockLength
      e.outer = fread(fp, 1, 'int32');
      e.inner = fread(fp, 1, 'int32');
      e.rep = fread(fp, 1, 'int32');
      e.skip = fread(fp, 1, 'char');
      e.isOddball = fread(fp, 1, 'char');
      e.innerVal = fread(fp, 1, 'float32');
      e.outerVal = fread(fp, 1, 'float32');
      S.block(k,j) = e;
   end
end

inIdx = fread(fp, S.numInner, 'int32'); %#ok<*NASGU> 
outIdx = fread(fp, S.numOuter, 'int32');
