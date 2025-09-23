function H = open_raw(fn, nchan)
% ephys.open_raw -- initialize read of EPhys raw data.
% Usage: H = ephys_raw(fn)
%

fi = dir(fn);

H.fp = fopen(fn, 'rb', 'ieee-be');

H.version = fread(H.fp, 1, 'int32');
H.reps_per_frame = fread(H.fp, 1, 'int32');
% nchan not stored correctly in raw data: stores #electrodes, not #active
% electrodes.
H.nchan = fread(H.fp, 1, 'int32');
% fread(H.fp, 1, 'int32');
% H.nchan = nchan;
H.nchan = H.nchan + 1;
H.pts_per_rep = fread(H.fp, 1, 'int32');
H.sync = fread(H.fp, 1, 'int32');

% fprintf('pts / rep = %d\nreps / cycle = %d\n', pts_per_rep, reps_per_cycle);

% file size (less header) / (8 bytes/point) / nchan ==> number of points
H.npts = (fi.bytes - 20) / (8 * H.nchan);

H.doubles_per_read_per_chan = H.reps_per_frame * H.pts_per_rep;
H.doubles_per_read = H.doubles_per_read_per_chan * H.nchan;
H.npairs = floor(H.npts / (2*H.pts_per_rep));

H.data = [];
H.offset = 0;
H.repsRead = 0;
