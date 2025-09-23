function names = get_state_names(p)

names = cell(length(p.Flowchart), 1);
for k = 1:length(names)
   names{k} = p.Flowchart(k).State.Name;
end