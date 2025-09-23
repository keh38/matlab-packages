function [IDX, Value] = find_markers(header)
% BDF_FIND_MARKERS -- find indices of trial markers in Biosemi .bdf file.
% Usage: IDX = bdf_find_markers(header)
%

fprintf('Finding trials...\n');

IDX = [];
Value = [];

fp = bdf.open(header);

offset = 0;
for k = 1:header.NumberOfRecords

   if k > 1
      for kb = 1:nbytes, fprintf('\b'); end
   end
   
   nbytes = fprintf('Scanning record %d of %d...', k, header.NumberOfRecords);
   
   fseek(fp, 3*header.SamplesPerRecord(1)*(header.NumberOfChannels-1), 'cof');
   s = fread(fp, header.SamplesPerRecord(1) * 3, '*uint8');
   s = s(1:3:end);
   
   idx = find(diff(s)>0.5);
   IDX = [IDX; idx + offset];
   Value = [Value; s(idx+1)];
   
   offset = offset + header.SamplesPerRecord(1);
end

fclose(fp);

for kb = 1:nbytes, fprintf('\b'); end
fprintf('Done.\n');
