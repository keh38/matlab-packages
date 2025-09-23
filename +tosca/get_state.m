function state = get_state(p, name)

state = [];
for k = 1:length(p.Flowchart)
   if strcmp(p.Flowchart(k).State.Name, name)
      state = p.Flowchart(k).State;
      break;
   end
end

