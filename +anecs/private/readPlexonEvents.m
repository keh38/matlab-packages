function trialMarkers = readPlexonEvents(plexonFile)

% get some counts
[~, ~, evcounts] = plx_info(plexonFile,1);

% and finally the events
[~, nevchannels] = size( evcounts );  
if ( nevchannels > 0 ) 
    % need the event chanmap to make any sense of these
    [~, evchans] = plx_event_chanmap(plexonFile);
	for iev = 1:nevchannels
		if ( evcounts(iev) > 0 )
            evch = evchans(iev);
            if ( evch == 257 )
				[nevs{iev}, tsevs{iev}] = plx_event_ts(plexonFile, evch); 
			else
				[nevs{iev}, tsevs{iev}] = plx_event_ts(plexonFile, evch);
            end
		end
	end
end

% [nev, evnames] = plx_event_names(plexonFile);

trialMarkers = tsevs{1};
