function writeCalibrationXML(filename, entries)
% WRITECALIBRATIONXML  Write a UserFileReferences calibration XML file.
%
%   writeCalibrationXML(filename, entries)
%
%   entries must be a struct array with required fields:
%       .Transducer   (char)
%       .Destination  (char)
%       .Units        (char)
%       .Value        (numeric scalar)
%
%   and optional fields (omit the field, or set to '', to skip):
%       .Frequencies  (char)  e.g. '[250 500 1000 2000 4000]'
%       .Weights      (char)  e.g. '[1.0 0.9 0.95 0.85 0.8]'
%       .Comment      (char)
%
%   All string fields are omitted from the output if their value is ''.
%
%   Example:
%       e.Transducer  = 'Insert';
%       e.Destination = 'Left';
%       e.Units       = 'dB_SPL';
%       e.Value       = 46.038388;
%       e.Frequencies = '[250 500 1000 2000 4000]';
%       e.Weights     = '[1.0 0.9 0.95 0.85 0.8]';
%       e.Comment     = 'Measured 2024-01-15';
%       writeCalibrationXML('Output.xml', e);

    validateEntries(entries);

    lines = {};
    lines{end+1} = '<?xml version="1.0" encoding="Windows-1252"?>';
    lines{end+1} = '<UserFileReferences xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">';
    lines{end+1} = sprintf('\t<Entries>');

    for i = 1 : numel(entries)
        e = entries(i);
        lines{end+1} = sprintf('\t\t<Entry>');

        lines = writeStr(lines, 'Transducer',  e.Transducer);
        lines = writeStr(lines, 'Destination', e.Destination);
        lines = writeStr(lines, 'Units',       e.Units);

        lines{end+1} = sprintf('\t\t\t<Value>%s</Value>', num2str(e.Value, '%.6f'));

        if isfield(e, 'Frequencies')
            lines = writeStr(lines, 'Frequencies', e.Frequencies);
        end
        if isfield(e, 'Weights')
            lines = writeStr(lines, 'Weights', e.Weights);
        end
        if isfield(e, 'Comment')
            lines = writeStr(lines, 'Comment', e.Comment);
        end

        lines{end+1} = sprintf('\t\t</Entry>');
    end

    lines{end+1} = sprintf('\t</Entries>');
    lines{end+1} = '</UserFileReferences>';

    xmlText = strjoin(lines, newline);

    fid = fopen(filename, 'w', 'n', 'windows-1252');
    if fid == -1
        error('writeCalibrationXML:fileError', ...
              'Cannot open file for writing: %s', filename);
    end
    cleanup = onCleanup(@() fclose(fid));
    fwrite(fid, xmlText, 'char');
end

% -------------------------------------------------------------------------
function lines = writeStr(lines, tag, value)
% Append a string element line only if value is non-empty.
    if ~isempty(value)
        lines{end+1} = sprintf('\t\t\t<%s>%s</%s>', tag, xmlEscape(value), tag);
    end
end

% -------------------------------------------------------------------------
function validateEntries(entries)
    required = {'Transducer', 'Destination', 'Units', 'Value'};
    for f = required
        if ~isfield(entries, f{1})
            error('writeCalibrationXML:missingField', ...
                  'entries struct is missing required field: %s', f{1});
        end
    end
    strFields = {'Transducer', 'Destination', 'Units', 'Frequencies', 'Weights', 'Comment'};
    for i = 1 : numel(entries)
        if ~isnumeric(entries(i).Value) || ~isscalar(entries(i).Value)
            error('writeCalibrationXML:badValue', ...
                  'entries(%d).Value must be a numeric scalar.', i);
        end
        for f = strFields
            if isfield(entries(i), f{1}) && ~ischar(entries(i).(f{1}))
                error('writeCalibrationXML:badField', ...
                      'entries(%d).%s must be a char.', i, f{1});
            end
        end
    end
end

% -------------------------------------------------------------------------
function s = xmlEscape(s)
    s = strrep(s, '&',  '&amp;');
    s = strrep(s, '<',  '&lt;');
    s = strrep(s, '>',  '&gt;');
    s = strrep(s, '"',  '&quot;');
    s = strrep(s, '''', '&apos;');
end
