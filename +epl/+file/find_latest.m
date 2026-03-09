function fn = find_latest(folder, pattern)

if ~contains(pattern, '*')
   pattern = [pattern '*'];
end
fileList = dir(fullfile(folder, pattern));
if isempty(fileList)
   fn = [];
   return;
end

[~, kmax] = max([fileList.datenum]);
fn = fullfile(fileList(kmax).folder, fileList(kmax).name);