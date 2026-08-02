function t = newTrial()
%TAPPING.NEWTRIAL  Blank trial struct with every field defaulted.
%   Mirrors the C# TappingTrial constructor - add a field there, add it here,
%   in this one place. Enums are TEXT ("A", "AllElements"). Array fields are
%   left as plain numeric/empty; writeTrialList handles encode-time wrapping.
    t.Tag                  = "";
    t.Pacer                = "A";
    t.ResponseInstructions = "AllElements";
    t.LeadIn               = 0;
    t.Offset               = 0;
    t.PacerIntervals       = [];
    t.DistractorIntervals  = [];
    t.ParameterProfiles    = {};
end
