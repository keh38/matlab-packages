function [time, labels] = parse_player_events(events, T0)

time = events.time - T0;

labels = cell(size(time));

for k = 1:length(events.description)
   if startsWith(events.description{k}, 'Attack')
      labels{k} = ['attack: ' attack_code_to_label(events.value(k))];
   elseif strcmpi(events.description{k}, 'state')
      labels{k} = status_code_to_label(events.value(k));
   else
      labels{k} = 'unknown';
   end
end

end

%% --- HELPERS ------------------------------------------------------------
function label = attack_code_to_label(code)

if code == 0
   label = 'none';
elseif code == 1
   label = 'dummy';
elseif code == 2
   label = 'target';
elseif code == -2
   label = 'fixed';
else
   label = 'unknown';
end

end

% -------------------------------------------------------------------------
function label = status_code_to_label(code)

if code == 0
   label = 'locked';
elseif code == 1
   label = 'move';
elseif code == 2
   label = 'fix';
elseif code == 3
   label = 'dance';
elseif code == 4
   label = 'no charge';
elseif code == 5
   label = 'finished';
else
   label = 'unknown';
end

end