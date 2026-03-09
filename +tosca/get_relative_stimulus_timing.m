function timing = get_relative_stimulus_timing(params)

fam = params.Schedule.Families;
for k = 1:length(fam)
   timing(k) = get_family_timing(fam(k), params.Output_States); %#ok<AGROW>
end

end

%--------------------------------------------------------------------------
function timing = get_family_timing(F, States)

V = F.Vars;

% Find the X-variable
ix  = find(strcmp({V.dim}, 'X'));

if isempty(ix)
   ix = 1; % use the first variable
end

if length(ix) > 1
   ix = ix(1);
end
v = V(ix);

% find state
istate = strcmp({States.Name}, v.state);
state = States(istate);

% find stimulus channel
ichan = strcmp({state.StimChans.Name}, v.chan);

timing.groupName = F.Name;
timing.state = v.state;

if any(ichan)
   chan = state.StimChans(ichan);
   timing.isVisual = false;
   timing.delay = chan.Burst.Delay_ms;
   timing.duration = chan.Burst.Duration_ms;
   return;
end

if strcmp(v.chan, 'Grating')
   timing.isVisual = true;
   timing.delay = 0;
   timing.duration = state.Grating.Duration_ms;
   return;
end

error('could not find suitable source to infer stimulus timing');

end
