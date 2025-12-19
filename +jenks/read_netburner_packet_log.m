function S = read_netburner_packet_log(fn)

packetSize = 140;

finfo = dir(fn);
npackets = floor(finfo.bytes / packetSize);

fp = fopen(fn, 'rb', 'ieee-be');



fclose(fp);