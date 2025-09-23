function allts = readPlexonTimeStamps(plexonFile)

% get some counts
tscounts = plx_info(plexonFile, 1);

% tscounts, wfcounts are indexed by (unit+1,channel+1)
% tscounts(:,ch+1) is the per-unit counts for channel ch
% sum( tscounts(:,ch+1) ) is the total wfs for channel ch (all units)
% [nunits, nchannels] = size( tscounts )
% To get number of nonzero units/channels, use nnz() function

% gives actual number of units (including unsorted) and actual number of
% channels plus 1
[nunits1, nchannels1] = size( tscounts );   

% we will read in the timestamps of all units,channels into a two-dim cell
% array named allts, with each cell containing the timestamps for a unit,channel.
% Note that allts second dim is indexed by the 1-based channel number.
% preallocate for speed
allts = cell(nunits1, nchannels1);
for iunit = 0:nunits1-1   % starting with unit 0 (unsorted) 
    for ich = 1:nchannels1-1
        if ( tscounts( iunit+1 , ich+1 ) > 0 )
            % get the timestamps for this channel and unit 
            [~, allts{iunit+1,ich}] = plx_ts(plexonFile, ich , iunit );
         end
    end
end
