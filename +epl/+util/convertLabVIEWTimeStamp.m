function matlabDateTime = convertLabVIEWTimeStamp(lvTime)

labviewEpoch = datetime(1904, 1, 1, 0, 0, 0, 'TimeZone', 'UTC');
matlabDateTime = datetime(labviewEpoch + seconds(lvTime), 'TimeZone', 'America/New_York');