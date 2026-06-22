function plot_forage_data(data)

targetColor = [0.5 0.75 0];
dummyColor = [0.85 0.7 0.7];
playerColor = [0 0 1];

symbolmap = dictionary(["KCNQ2", "GABAA", "AMPA"], ["o", "s", "^"]);

h = figure();
set(h, 'WindowStyle', 'docked');
clf;
hold on;

xx = [-1 -1 1 1 -1];
zz = [-1 1 1 -1 -1];

x = data.arena.Width/2 * xx;
z = data.arena.Length/2 * zz;

plot(x, z, 'k-', 'LineWidth', 3);

r = 2;
for k = 1:length(data.arena.Targets)
   target = data.arena.Targets(k);

   pos = [target.Position.x-r target.Position.z-r 2*r 2*r];
   rectangle('Position', pos, 'Curvature', [1 1], 'EdgeColor', targetColor);

   symbol = symbolmap(target.Shape);
   plot(target.Position.x, target.Position.z, symbol, ...
      'Color', targetColor, ...
      'MarkerSize', 8, ...
      'MarkerFaceColor', targetColor);

   pos = [target.DecoyPosition.x-r target.DecoyPosition.z-r 2*r 2*r];
   rectangle('Position', pos, 'Curvature', [1 1], 'EdgeColor', dummyColor);

   plot(target.DecoyPosition.x, target.DecoyPosition.z, 'o', ...
      'Color', dummyColor, ...
      'MarkerSize', 4);%, ...
      % 'MarkerFaceColor', dummyColor);
end

for k = 1:length(data.arena.Randos)
   if data.arena.Randos(k).Stratum > 6, continue; end

   pos = [data.arena.Randos(k).Position.x-r data.arena.Randos(k).Position.z-r 2*r 2*r];
   rectangle('Position', pos, 'Curvature', [1 1], 'EdgeColor', dummyColor);

   pos = data.arena.Randos(k).Position;
   plot(pos.x, pos.z, 'o', ...
      'Color', dummyColor, ...
      'MarkerSize', 4, ...
      'MarkerFaceColor', dummyColor);
end

player = data.player;
plot(player.X(1), player.Z(1), 's', 'Color', playerColor, 'MarkerFaceColor', playerColor);

plot(player.X, player.Z, '-', 'Color', playerColor);

attackLog = get_attack_log(player.events);

for k = 1:length(attackLog)
   [~, idx] = min(abs(attackLog(k).time - player.Time));
   h = plot(player.X(idx), player.Z(idx), '^', 'Color', playerColor);
   if attackLog(k).type == 1
      set(h, 'MarkerFaceColor', 'r');
   elseif attackLog(k).type == 2
      set(h, 'MarkerFaceColor', 'g');
   end
end

axis tight;
axis square;
axis off;

[~, name] = fileparts(data.header.FilePath);
title(name);

end

%% --- HELPERS ------------------------------------------------------------
function attackLog = get_attack_log(playerEvents)
   iattack = find(strcmpi(playerEvents.description, 'attack'));
   
   coe = cell(length(iattack), 1);
   attackLog = struct(...
      'time', coe, ...
      'type', coe, ...
      'channelType', coe, ...
      'channelIndex', coe);

   for k = 1:length(iattack)
      attackLog(k).time = playerEvents.time(iattack(k));
      attackLog(k).type = playerEvents.value(iattack(k));
      attackLog(k).channelType = 0;
      attackLog(k).channelIndex = 0;
   end

end
