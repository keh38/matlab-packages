function t = read_stream_sync_log(fn, streamName)

opts = detectImportOptions(fn);
opts.VariableTypes{2} = 'int64';
opts.VariableTypes{3} = 'int64';

data = readtable(fn, opts);

ifilt = find(strcmp(data.DataStream, streamName));
t = data.LocalTime(ifilt);