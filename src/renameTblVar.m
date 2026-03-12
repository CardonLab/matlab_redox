% Function to rename the variables
function varNames = renameTblVar(varNames,site)
 % Validate site input
    validInputs = ["low", "high"];
    if ~ismember(site, validInputs)
        error('Invalid input. Please use "low" or "high".');
    end
% Define the replacement pattern

switch site
  case "low"
   varNames = replace(varNames,"Redox0","L");
   varNames = replace(varNames,"Redox","L");
   varNames = replace(varNames,regexpPattern("_1$"),"_05cm");
   varNames = replace(varNames,regexpPattern("_2$"),"_10cm");
   varNames = replace(varNames,regexpPattern("_3$"),"_15cm");
   varNames = replace(varNames,regexpPattern("_4$"),"_30cm");
    case "high"
   varNames = replace(varNames,"Redox0","H"); 
   varNames = replace(varNames,"Redox","H");
end

% Rename the temperature and reference probes
oldNames = {'Soil_C_1_Avg','Soil_C_2_Avg','_1_Avg','_2_Avg','_3_Avg','_4_Avg'};
newNames = {'soil1_c','soil2_c','_05cm','_10cm','_15cm','_30cm'};
varNames = replace(varNames,oldNames,newNames);

end