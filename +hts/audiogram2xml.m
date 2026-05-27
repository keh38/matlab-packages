function audiogram2xml(audiogram, filename)
% AUDIOGRAM2XML  Save a 2x1 audiogram struct array to the target XML format.
%
%   audiogram2xml(audiogram, 'output.xml')

    doc  = com.mathworks.xml.XMLUtils.createDocument('AudiogramData');
    root = doc.getDocumentElement();

    % Add the two schema attributes on the root element
    root.setAttribute('xmlns:xsd', 'http://www.w3.org/2001/XMLSchema');
    root.setAttribute('xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');

    % <audiograms> wrapper
    audiogramsNode = doc.createElement('audiograms');
    root.appendChild(audiogramsNode);

    for i = 1:numel(audiogram)
        ag = audiogram(i);

        % <Audiogram>
        agNode = doc.createElement('Audiogram');
        audiogramsNode.appendChild(agNode);

        % <ear>
        earNode = doc.createElement('ear');
        earNode.appendChild(doc.createTextNode(ag.ear));
        agNode.appendChild(earNode);

        % Numeric vector fields — each value wrapped in <float>
        vectorFields = {'Frequency_Hz', 'Threshold_dBHL', 'Threshold_dBSPL'};
        for f = vectorFields
            fieldNode = doc.createElement(f{1});
            agNode.appendChild(fieldNode);
            vals = ag.(f{1});
            for v = vals(:)'
                floatNode = doc.createElement('float');
                if isnan(v)
                    floatNode.appendChild(doc.createTextNode('NaN'));
                elseif isinf(v)
                    floatNode.appendChild(doc.createTextNode('Infinity'));                   
                else
                   floatNode.appendChild(doc.createTextNode(sprintf('%g', v)));
                end
                fieldNode.appendChild(floatNode);
            end
        end
    end

    xmlwrite(filename, doc);
    fprintf('Saved to %s\n', filename);
end