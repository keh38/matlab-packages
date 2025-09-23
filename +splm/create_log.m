function create_log(filestem)

flist = dir(sprintf('%s-*.splm', filestem));

log = '';
for k = 1:length(flist)
   log = [log sprintf('%s\n', flist(k).name)];
   
   d = splm.read_data(flist(k).name);
   
   log = [log sprintf('\t%s\n\n', strrep(d.Header.Notes, '\n', '\n\t'))];
end

fp = fopen(sprintf('%s.log', filestem), 'wt');
fprintf(fp, log);
fclose(fp);