function Y = read_record(header, startingFrom)
% BDF_READ_RECORD -- read one record from .bdf file at current position.
% Usage: Y = bdf_read_record(fp, header)
%

offset = header.HeaderSize + startingFrom * (header.SamplesPerRecord(1)*header.NumberOfChannels*3);
numwords = header.SamplesPerRecord(1) * header.NumberOfChannels;

buf = bdf_read_24bit(header.Path, offset, numwords);

Y = reshape(buf, header.SamplesPerRecord(1), header.NumberOfChannels);
Y = Y * (header.PhysicalMax(1) - header.PhysicalMin(1)) / (header.DigitalMax(1) - header.DigitalMin(1));  
