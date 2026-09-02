function out = adjustRefBase(tblRedox,startDate,endDate, vars, refVars)
% Adjust all the redox values by means of the spare reference probes
%   When the base reference probe deviates from the extra probes 
% This function will subtract the mean of the extra probes from the redox probes
    % Just use Ref_06 and Ref_08 since Ref_15 has an offset of about 1 mv
    % End date is when base reference probe was changed and is functioning properly 
    mask = contains(tblRedox.Properties.VariableNames,refVars);
    referenceMean = mean(tblRedox(:,mask),2,"omitmissing");
    referenceMean = renamevars(referenceMean,"mean","refMean");
    mask =(referenceMean.Properties.RowTimes <= startDate) | (referenceMean.Properties.RowTimes >= endDate) ;
    referenceMean.refMean(mask) = 0; % set to 0 before startDate and after endDate
    %tblRedox = [tblRedox,referenceMean];
    % Subtract the mean of extra reference probes from redox values
    out = varfun(@(x) x - referenceMean.refMean,tblRedox,"InputVariables",vars);
    newNames = out.Properties.VariableNames + "Adjusted";
    newNames = replace(newNames,"Fun_",""); 
    out.Properties.VariableNames = cellstr(newNames);
    % Return the adjusted table with the original redox values and the new adjusted values
    out = [tblRedox, out];
end