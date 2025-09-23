function SyncLog = read_eyeseecam_sync_log(fn)

fp = fopen(fn, 'rb', 'b');

n = fread(fp, 1, 'int32');
SyncLog.date = fread(fp, n, '*char')';
SyncLog.T0 = fread(fp, 1, '*int64');
SyncLog.Tsync = fread(fp, Inf, '*int64');
fclose(fp);
