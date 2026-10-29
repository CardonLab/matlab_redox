function out = adjustRefBase(tblRedox,startDate,endDate, vars, refVars)
% Adjust all the redox values by means of the spare reference probes
%   When the base reference probe deviates from the extra probes
% This function will subtract the mean of the extra probe/s from the redox probes
% End date is when base reference probe was changed and is functioning properly
% Passing several spare references averages them, which partly cancels the
% drift of any one spare. The column baseCorrUncertainty is set to half the
% spread (max - min) of the spares in the adjusted period, an estimate of
% how far off the correction may be. It is 0 where no spare correction is
% applied or only one spare is used.
    mask = ismember(tblRedox.Properties.VariableNames,refVars); % exact names, not Ref_15Adjusted for Ref_15
    referenceMean = mean(tblRedox(:,mask),2,"omitmissing");
    referenceMean = renamevars(referenceMean,"mean","refMean");
    mask =(referenceMean.Properties.RowTimes <= startDate) | (referenceMean.Properties.RowTimes >= endDate) ;
    referenceMean.refMean(mask) = 0; % set to 0 before startDate and after endDate

    % Uncertainty of the correction: half the spread of the spare references
    refValues = tblRedox{:,ismember(tblRedox.Properties.VariableNames,refVars)};
    spread = (max(refValues,[],2) - min(refValues,[],2))/2;
    if ~ismember("baseCorrUncertainty", tblRedox.Properties.VariableNames)
        tblRedox.baseCorrUncertainty = zeros(height(tblRedox),1);
    end
    tblRedox.baseCorrUncertainty(~mask) = spread(~mask);

    % Subtract the mean of extra reference probes from redox values
    out = varfun(@(x) x - referenceMean.refMean,tblRedox,"InputVariables",vars);

   if ~any(contains(vars,"Adjusted"))
        newNames = out.Properties.VariableNames + "Adjusted";
   else
       newNames =  out.Properties.VariableNames;
   end
        newNames = replace(newNames,"Fun_","");
        out.Properties.VariableNames = cellstr(newNames);

    % Remove any columns that will be replaced by the adjusted ones
    varsToReplace = out.Properties.VariableNames;
    existingVars = varsToReplace(ismember(varsToReplace, tblRedox.Properties.VariableNames));

    if ~isempty(existingVars)
        tblRedox(:, existingVars) = [];
    end

    % Return the combined table without duplicate variable names
    out = [tblRedox, out];

end
