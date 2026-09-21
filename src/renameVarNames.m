function newVarNames = renameVarNames(varNames, replacePairs)
%RENAMEVARNAMES Rename variable names using old/new text pairs.
%   newVarNames = renameVarNames(varNames, replacePairs)
%   varNames      : string array or cell array of char vectors
%   replacePairs   : Nx2 string array or cell array, where each row is
%                    [oldText, newText]

isCellInput = iscell(varNames);
varNames = string(varNames);
replacePairs = string(replacePairs);

newVarNames = varNames;

for i = 1:numel(varNames)
    name = varNames(i);
    for k = 1:size(replacePairs, 1)
        oldText = replacePairs(k, 1);
        newText = replacePairs(k, 2);

        if contains(name, oldText)
            newVarNames(i) = replace(name, oldText, newText);
            break
        end
    end
end

if isCellInput
    newVarNames = cellstr(newVarNames);
end
end