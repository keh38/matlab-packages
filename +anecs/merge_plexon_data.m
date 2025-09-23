function merge_plexon_data(anecsFile, plexonFile)

anecs = readHeader(anecsFile);

plex = readPlexonInfo(plexonFile);

timeStamps = readPlexonTimeStamps(plexonFile);
trialMarkers = readPlexonEvents(plexonFile);

save(strrep(anecsFile ,'.anx', '.mat'), 'anecs', 'plex', 'timeStamps', 'trialMarkers');

% keyboard; 
itr = 1;

ta=[];
ya=[];
irow = 1;
for kb = 1:anecs.SCL.numBlocks
   for kt = 1:anecs.SCL.blockLength
      ta = [ta; anecs.SCL.block(kb, kt).times(:)];
      ya = [ya; irow*ones(length(anecs.SCL.block(kb, kt).times), 1)];
      irow = irow + 1;
   end
end

% figure
% plot(t, y, '.');


for kr = 2:size(timeStamps,1)
   for kc = 1:size(timeStamps,2)

      if ~isempty(timeStamps{kr, kc})
         t = timeStamps{kr, kc};

         tp = [];
         yp = [];
         irow = 0;

         for k = 1:length(trialMarkers)-1
            irow = irow + 1;
            ifilt = t>trialMarkers(k) & t<trialMarkers(k+1);

            if any(ifilt)
               tp = [tp; 1000*(t(ifilt) - trialMarkers(k))];
               yp = [yp; irow*ones(sum(ifilt),1)];
            end
         end

         figure;
         plot(ta, ya, '.', tp, yp, '.');
         title(sprintf('%d, %d', kr, kc));

      end
   end
end