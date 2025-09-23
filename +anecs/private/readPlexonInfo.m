function plex = readPlexonInfo(plexonFile)

[OpenedFileName, Version, Freq, Comment, Trodalness, NPW, PreThresh, SpikePeakV, SpikeADResBits, SlowPeakV, SlowADResBits, Duration, DateTime] = plx_information(plexonFile);
plex.OpenedFileName = OpenedFileName;
plex.Version = Version;
plex.Duration = Duration;
plex.DateTime = DateTime;
plex.Freq = Freq;
plex.Comment = Comment;
plex.Trodalness = Trodalness;
plex.NumPtsPerWave = NPW;
plex.PreThresh = PreThresh;
plex.SpikePeakV = SpikePeakV;
plex.SpikeADResBits = SpikeADResBits;
plex.SlowPeakV = SlowPeakV;
plex.SlowADResBits = SlowADResBits;
