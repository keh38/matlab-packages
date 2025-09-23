function Y = read(header, startingFrom, numRecords)
% BDF_READ -- read multiple records from current position in .bdf file.
% Usage: Y = bdf_read(fp, header, numRecords)
%

Y = NaN(header.NumberOfChannels, header.SamplesPerRecord(1)*numRecords);

ioff = 0;
for k = 1:numRecords
   y = bdf_read_record(header, startingFrom + k - 1);
   Y(:, ioff + (1:header.SamplesPerRecord(1))) = y';
   
   ioff = ioff + header.SamplesPerRecord(1);
end