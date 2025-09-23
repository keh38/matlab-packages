function fp = open(header)
% BDF_OPEN -- open Biosemi .bdf file and advance to data records.
% Usage: fp = bdf_open(header)
%

fp = fopen(header.Path, 'rb');
if fp < 0, error('Could not open .bdf file for reading.'); end

status = fseek(fp, header.HeaderSize, 'bof');
if status < 0
   fclose(fp);
   error('Cannot find start of .bdf data records.');
end
