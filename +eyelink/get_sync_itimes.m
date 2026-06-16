function syncTimes = get_sync_itimes(D)

if ischar(D)
   D = eyelink.read_data(D);
end

events = D.events.info;
syncIndex = find(startsWith(events, 'Sync'));

syncTimes = int64(-1 * ones(1, length(syncIndex)));
for k = 1:length(syncIndex)
   itime = sscanf(events{syncIndex(k)}, 'Sync:%ld');
   syncTimes(k) = itime;
end
