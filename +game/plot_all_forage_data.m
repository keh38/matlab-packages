function fig = plot_all_forage_data(playerFolder, options)

arguments
   playerFolder char
   options.fileNames cell = {}
   options.title char = ''
   options.numberPlots logical = false
end

fileNames = options.fileNames;

%% plot_files_grid.m
% Read a set of files and plot each into its own tile of one full-screen
% figure, filled in typewriter order (left->right, then top->bottom).

%% ---- Configuration -------------------------------------------------------
[folder, player] = fileparts(playerFolder);
% player  = 'CyanOrangutan20';  % folder containing the files
pattern  = '*.bin';                 % glob for the files to plot

%% ---- Gather files --------------------------------------------------------
if isempty(fileNames)
   listing = dir(fullfile(folder, player, pattern));
   listing = listing(~[listing.isdir]);
   listing = listing(~contains({listing.name}, 'Yardstick'));
   [~, order] = sort({listing.name});  % deterministic order; swap for
   listing = listing(order);           %   natsortfiles() if you need 2 before 10
   fileNames = {listing.name};   
end

n = numel(fileNames);
assert(n > 0, 'No files matching %s in %s', pattern, player);

%% ---- Grid geometry: near-square, optimized for n ------------------------
nCols = ceil(sqrt(n));
nRows = ceil(n / nCols);            % rows <= cols, which suits a wide screen

%% ---- Full-screen figure + tight layout ----------------------------------
% fig = figure('WindowState', 'maximized', 'Color', 'w');
fig = figure('Color', 'w');
epl.graphics.figsize([9 6]);
t = tiledlayout(fig, nRows, nCols, ...
        'TileSpacing', 'tight', ... % 'none' packs tighter but may clip ticks
        'Padding',     'tight');

%% ---- One tile per file, typewriter order --------------------------------
for k = 1:n
    ax = nexttile(t);              % fills L->R, then top->bottom

    fpath = fullfile(folder, player, fileNames{k});
    d = readOneFile(fpath);        % <-- adapt reader below
    game.plot_forage_data(d, 'hax', ax);

    if options.numberPlots
       title(ax, sprintf('Run%d - Level%02d', k-1, d.level.levelNumber));
    else
       title(ax, sprintf('Level%02d', d.level.levelNumber));
    end
end

%% ---- Overall title (and optional shared labels) -------------------------
if isempty(options.title)
   options.title = d.header.PlayerName;
end
title(t, options.title, 'FontWeight', 'bold', 'FontSize', 16);
% xlabel(t, 'Time (s)');   % one shared x-label for the whole layout
% ylabel(t, 'Amplitude');
end

%% === HELPERS ============================================================

%% ---- File reader (swap the body for your format) ------------------------
function d = readOneFile(fpath)
   d = game.read_master_data_log(fpath);
end