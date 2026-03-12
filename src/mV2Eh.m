% Function to temperature correct the redox mVolt 
function out = mV2Eh(redoxmVtbl,vars,soilT)
% Takes a Timetable, variable array, and temperature varaible and returns a table of corrected values.
out = varfun(@(x) x - (0.718 * soilT)+224.41,redoxmVtbl,"InputVariables",vars);
newNames = out.Properties.VariableNames + "Eh";
newNames = replace(newNames,"Fun_","");
out.Properties.VariableNames = cellstr(newNames);
end