function update_turandot_config_file(filePath)

wordsToReplace = {
    'channels',      'Channels';
    'waveform',      'Waveform';
    'gate',          'Gate';
    'level',         'Level';
    'modulation',    'Modulation';
    'Duration_ms',   'Width_ms';
};


fp = fopen(filePath, 'rb');
xml = fread(fp, '*char')';
fclose(fp);

for k = 1:size(wordsToReplace, 1)
    xml = strrep(xml, ['<' wordsToReplace{k,1}], ['<' wordsToReplace{k,2}]);
    xml = strrep(xml, [wordsToReplace{k,1} '>'], [wordsToReplace{k,2} '>']);
end

[folder, filename] = fileparts(filePath);

backupFolder = fullfile(folder, 'backups');
if ~exist(backupFolder, 'dir')
   mkdir(backupFolder);
end

copyfile(filePath, fullfile(backupFolder, [filename '.xml']));

fp = fopen(filePath, 'wb');
fprintf(fp, xml);
fclose(fp);

