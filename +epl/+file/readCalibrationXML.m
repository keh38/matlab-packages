function entries = readCalibrationXML(filename)
% READCALIBRATIONXML  Read a UserFileReferences calibration XML file.
%
%   entries = readCalibrationXML(filename)
%
%   Returns a struct array where each element corresponds to one <Entry>
%   in the file and has the fields:
%
%     Required:
%       .Transducer   (char)
%       .Destination  (char)
%       .Units        (char)
%       .Value        (double scalar)
%
%     Optional ('' if absent in file):
%       .Frequencies  (char)  e.g. '[250 500 1000 2000 4000]'
%       .Weights      (char)  e.g. '[1.0 0.9 0.95 0.85 0.8]'
%       .Comment      (char)
%
%   Parsing of Frequencies and Weights into numeric vectors is left to
%   the caller (e.g. via eval or a dedicated expression parser).
%
%   Example:
%       entries = readCalibrationXML('Example.xml');
%       freqs = eval(entries(1).Frequencies);

    doc        = xmlread(filename);
    entryNodes = doc.getElementsByTagName('Entry');
    n          = entryNodes.getLength();

    template = struct('Transducer',  '', ...
                      'Destination', '', ...
                      'Units',       '', ...
                      'Value',       0,  ...
                      'Frequencies', '', ...
                      'Weights',     '', ...
                      'Comment',     '');
    entries = repmat(template, 1, n);

    for i = 0 : n - 1
        node = entryNodes.item(i);

        % --- Required fields ---
        entries(i+1).Transducer  =            getChildText(node, 'Transducer');
        entries(i+1).Destination =            getChildText(node, 'Destination');
        entries(i+1).Units       =            getChildText(node, 'Units');
        entries(i+1).Value       = str2double(getChildText(node, 'Value'));

        % --- Optional fields ---
        entries(i+1).Frequencies = getChildTextOpt(node, 'Frequencies');
        entries(i+1).Weights     = getChildTextOpt(node, 'Weights');
        entries(i+1).Comment     = getChildTextOpt(node, 'Comment');
    end
end

% -------------------------------------------------------------------------
function text = getChildText(parentNode, tagName)
% Return text of a required child element; error if missing.
    nodes = parentNode.getElementsByTagName(tagName);
    if nodes.getLength() == 0
        error('readCalibrationXML:missingTag', ...
              'Required element <%s> not found.', tagName);
    end
    child = nodes.item(0).getFirstChild();
    if isempty(child)
        text = '';
    else
        text = strtrim(char(child.getNodeValue()));
    end
end

% -------------------------------------------------------------------------
function text = getChildTextOpt(parentNode, tagName)
% Return text of an optional child element; return '' if absent.
    nodes = parentNode.getElementsByTagName(tagName);
    if nodes.getLength() == 0
        text = '';
        return
    end
    child = nodes.item(0).getFirstChild();
    if isempty(child)
        text = '';
    else
        text = strtrim(char(child.getNodeValue()));
    end
end
