%[text] ## Low and high marsh redox 1 and 5 minute data
% Folder of logger data files
folder_path = "C:\Users\jl01596\OneDrive - Marine Biological Laboratory\Cmarsh\";
%-----------------------------------------------------------------------------------------
% low marsh redox data.
%-----------------------------------------------------------------------------------------
lowMarshMinuteFile = fullfile(folder_path,"cmarsh_lowmarsh_pheno_redox_1min.dat");
lowMarsh5MinuteFile = fullfile(folder_path,"cmarsh_lowmarsh_pheno_redox_5min.dat");

% Get 1 minute data
if exist(lowMarshMinuteFile, 'file') == 2
    % Load the low marsh minute data
    lowMarshMinuteTbl = importCSdata(lowMarshMinuteFile);
else
    % Prompt user to select the low marsh minute data file
    [dat_file, dat_path] = uigetfile('*.dat', 'Select low marsh minute .dat file');
    lowMarshMinuteTbl = importCSdata(fullfile(dat_path, dat_file));
end
lowMarshMinuteTbl = removevars(lowMarshMinuteTbl,"RECORD"); % Remove the record 
lowMarshMinuteTbl = unique(lowMarshMinuteTbl,"rows"); % Remove duplicates

% Get 5 minute data
if exist(lowMarsh5MinuteFile, 'file') == 2
    % Load the low marsh minute data
    lowMarsh5MinuteTbl = importCSdata(lowMarsh5MinuteFile);
else
    % Prompt user to select the low marsh minute data file
    [dat_file, dat_path] = uigetfile('*.dat', 'Select low marsh 5 minute .dat file');
    lowMarsh5MinuteTbl = importCSdata(fullfile(dat_path, dat_file));
end
lowMarsh5MinuteTbl = removevars(lowMarsh5MinuteTbl,["RECORD","PTemp_C_Avg"]); % Remove the record 
lowMarsh5MinuteTbl = unique(lowMarsh5MinuteTbl,"rows"); % Remove duplicates
%-------------------------------------------------------------------------------%
% Correct reference base using the spare references
%-------------------------------------------------------------------------------%
% Adjust reference base at the beginning before switching Ref_06 as base reference
adjustStartDate = datetime("2026-04-14 14:00:00","TimeZone","-05:00");
adjustEndDate = datetime("2026-05-13 11:00:00","TimeZone","-05:00");
% Use adjustBase.m function to adjust the probes. Passing the timetable,
% start data, end date, variables to adjust, and the spare references
vars = lowMarshMinuteTbl.Properties.VariableNames(contains(lowMarshMinuteTbl.Properties.VariableNames,"cm"));
% Using Ref_06, Ref_08.  Not Ref_15 which has an offset.
refVars = lowMarshMinuteTbl.Properties.VariableNames(contains(lowMarshMinuteTbl.Properties.VariableNames,"Ref_0"));
lowMarshMinuteTbl = adjustRefBase(lowMarshMinuteTbl,adjustStartDate,adjustEndDate,vars,refVars);
% 5 minute data
vars = lowMarsh5MinuteTbl.Properties.VariableNames(contains(lowMarsh5MinuteTbl.Properties.VariableNames,"cm"));
lowMarsh5MinuteTbl = adjustRefBase(lowMarsh5MinuteTbl,adjustStartDate,adjustEndDate,vars,refVars);

% Rename variable Ref_06 after switching it to base reference
switchTime = datetime("2026-04-14 14:00:00","TimeZone","-05:00"); % set the switch time you want
rt  = lowMarshMinuteTbl.Properties.RowTimes;
if ~ismember("Ref_05", lowMarshMinuteTbl.Properties.VariableNames)
    lowMarshMinuteTbl.Ref_05 = NaN(height(lowMarshMinuteTbl),1);
end
idx = rt >= switchTime;
lowMarshMinuteTbl.Ref_05(idx) = lowMarshMinuteTbl.Ref_06(idx);
lowMarshMinuteTbl.Ref_06(idx) = NaN;

% Repeat for 5-minute table
rt5 = lowMarsh5MinuteTbl.Properties.RowTimes;
if ~ismember("Ref_05_Avg", lowMarsh5MinuteTbl.Properties.VariableNames)
    lowMarsh5MinuteTbl.Ref_05_Avg = NaN(height(lowMarsh5MinuteTbl),1);   
end
idx5 = rt5 >= switchTime;
lowMarsh5MinuteTbl.Ref_05_Avg(idx5) = lowMarsh5MinuteTbl.Ref_06_Avg(idx5);
lowMarsh5MinuteTbl.Ref_06_Avg(idx5) = NaN;

%-------------------------------------------------------------------------------%
% Base reference started to be unstable 10 Aug) Using Ref_08 as base
%-------------------------------------------------------------------------------%
adjustStartDate = datetime("2026-08-10 19:24:00","TimeZone","-05:00");
adjustEndDate = datetime("2026-11-01 00:00:00","TimeZone","-05:00");
newBaseRef = lowMarshMinuteTbl.Properties.VariableNames(contains(lowMarshMinuteTbl.Properties.VariableNames,"Ref_08"));
vars = lowMarshMinuteTbl.Properties.VariableNames( ...
    contains(lowMarshMinuteTbl.Properties.VariableNames,"cmAdjusted") | ...
    contains(lowMarshMinuteTbl.Properties.VariableNames,"Ref"));
% Exclude new Base Ref
vars = vars(~contains(vars,newBaseRef));
% Adjust the value with the new base reference
lowMarshMinuteTbl = adjustRefBase(lowMarshMinuteTbl,adjustStartDate,adjustEndDate,vars,newBaseRef);
% Adjust the 5 minute values
newBaseRef = lowMarsh5MinuteTbl.Properties.VariableNames(contains(lowMarsh5MinuteTbl.Properties.VariableNames,"Ref_08"));
vars = lowMarsh5MinuteTbl.Properties.VariableNames( ...
    contains(lowMarsh5MinuteTbl.Properties.VariableNames,"cm_AvgAdjusted") | ...
    contains(lowMarsh5MinuteTbl.Properties.VariableNames,"Ref"));
% Exclude new Base Ref
vars = vars(~contains(vars,newBaseRef));
lowMarsh5MinuteTbl = adjustRefBase(lowMarsh5MinuteTbl,adjustStartDate,adjustEndDate,vars,newBaseRef);

% Save files
save("results\lowMarshMinuteTbl.mat","lowMarshMinuteTbl")
save("results\lowMarsh5MinuteTbl.mat","lowMarsh5MinuteTbl")

%---------------------------------------------------------------------------------
% Get high marsh redox 1 and 5 minute data 
%----------------------------------------------------------------------------------
highMarshMinuteFile = fullfile(folder_path,"cmarsh_highmarsh_redox_1min.dat");
highMarsh5MinuteFile = fullfile(folder_path,"cmarsh_highmarsh_redox_5min.dat");

% Get 1 minute data
if exist(highMarshMinuteFile, 'file') == 2
    % Load the high marsh minute data
    highMarshMinuteTbl = importCSdata(highMarshMinuteFile);
else
    % Prompt user to select the high marsh minute data file
    [dat_file, dat_path] = uigetfile('*.dat', 'Select high marsh minute .dat file');
    highMarshMinuteTbl = importCSdata(fullfile(dat_path, dat_file));
end
highMarshMinuteTbl = removevars(highMarshMinuteTbl,"RECORD"); % Remove the record 
highMarshMinuteTbl = unique(highMarshMinuteTbl,"rows"); % Remove duplicates

% Get 5 minute data
if exist(highMarsh5MinuteFile, 'file') == 2
    % Load the high marsh minute data
    highMarsh5MinuteTbl = importCSdata(highMarsh5MinuteFile);
else
    % Prompt user to select the high marsh minute data file
    [dat_file, dat_path] = uigetfile('*.dat', 'Select high marsh 5 minute .dat file');
    highMarsh5MinuteTbl = importCSdata(fullfile(dat_path, dat_file));
end
highMarsh5MinuteTbl = removevars(highMarsh5MinuteTbl,["RECORD","PTemp_C_Avg"]); % Remove the record 
highMarsh5MinuteTbl = unique(highMarsh5MinuteTbl,"rows"); % Remove duplicates

% Save files
save("results\highMarshMinuteTbl.mat","highMarshMinuteTbl")
save("results\highMarsh5MinuteTbl.mat","highMarsh5MinuteTbl")

%---------------------------------------------------------------------------------
% Get Typha marsh redox 1 and 5 minute data 
%----------------------------------------------------------------------------------
typhaMarshMinuteFile = fullfile(folder_path,"cmarsh_typha_redox_1minute.dat");
typhaMarsh5MinuteFile = fullfile(folder_path,"cmarsh_typha_redox_5minute.dat");
typhaMarshMinuteFileBkup = fullfile(folder_path,"cmarsh_typha_redox_1minute.dat.backup");
typhaMarsh5MinuteFileBkup = fullfile(folder_path,"cmarsh_typha_redox_5minute.dat.backup");
% Get 1 minute data
if exist(typhaMarshMinuteFile, 'file') == 2
    % Load the Typha marsh minute data
    typhaMarshMinuteTbl = importCSdata(typhaMarshMinuteFile);    
else
    % Prompt user to select the typha marsh minute data file
    [dat_file, dat_path] = uigetfile('*.dat', 'Select typha marsh minute .dat file');
    typhaMarshMinuteTbl = importCSdata(fullfile(dat_path, dat_file));
end
% Get 1 minute backup data
if exist(typhaMarshMinuteFileBkup, 'file') == 2
    % Load the Typha marsh minute data
    typhaMarshMinuteTblBkup = importCSdata(typhaMarshMinuteFileBkup);    
else
    % Prompt user to select the typha marsh minute data file
    [dat_file, dat_path] = uigetfile('*.dat.backup', 'Select typha marsh minute .dat file');
    typhaMarshMinuteTblBkup = importCSdata(fullfile(dat_path, dat_file));
end

% Rename variables in the earlier .backup file.
varNames = typhaMarshMinuteTblBkup.Properties.VariableNames;

% Mapping: _10cm -> _40cm, _20cm -> _30cm, _30cm -> _20cm, _40cm -> _10cm
newVarNames = varNames; % preallocate
for i = 1:numel(varNames)
    name = varNames{i};
    if contains(name,'_10cm')
        newVarNames{i} = replace(name,'_10cm','_40cm');
    elseif contains(name,'_20cm')
        newVarNames{i} = replace(name,'_20cm','_30cm');
    elseif contains(name,'_30cm')
        newVarNames{i} = replace(name,'_30cm','_20cm');
    elseif contains(name,'_40cm')
        newVarNames{i} = replace(name,'_40cm','_10cm');
    elseif contains(name,'Temp')
        newVarNames{i} = replace(name,'Temp','Soil_Temp');    
    end
end

typhaMarshMinuteTblBkup.Properties.VariableNames = newVarNames;

% Merge the backup with the current file
typhaMarshMinuteTbl = [typhaMarshMinuteTblBkup; typhaMarshMinuteTbl];

typhaMarshMinuteTbl = removevars(typhaMarshMinuteTbl,"RECORD"); % Remove the record variable
typhaMarshMinuteTbl = unique(typhaMarshMinuteTbl,"rows"); % Remove duplicates

% Get 5 minute data

if exist(typhaMarsh5MinuteFile, 'file') == 2
    % Load the typha marsh minute data
    typhaMarsh5MinuteTbl = importCSdata(typhaMarsh5MinuteFile);
else
    % Prompt user to select the typha marsh minute data file
    [dat_file, dat_path] = uigetfile('*.dat', 'Select typha marsh 5 minute .dat file');
    typhaMarsh5MinuteTbl = importCSdata(fullfile(dat_path, dat_file));
end

% Get 5 minute backup data

if exist(typhaMarsh5MinuteFileBkup, 'file') == 2
    % Load the Typha marsh minute data
    typhaMarsh5MinuteTblBkup = importCSdata(typhaMarsh5MinuteFileBkup);    
else
    % Prompt user to select the typha marsh minute data file
    [dat_file, dat_path] = uigetfile('*.dat.backup', 'Select typha marsh minute .dat file');
    typhaMarsh5MinuteTblBkup = importCSdata(fullfile(dat_path, dat_file));
end

% Rename variables in the earlier .backup file.
varNames = typhaMarsh5MinuteTblBkup.Properties.VariableNames;

% Mapping: _10cm -> _40cm, _20cm -> _30cm, _30cm -> _20cm, _40cm -> _10cm
newVarNames = varNames; % preallocate
for i = 1:numel(varNames)
    name = varNames{i};
    if contains(name,'_10cm')
        newVarNames{i} = replace(name,'_10cm','_40cm_Avg');
    elseif contains(name,'_20cm')
        newVarNames{i} = replace(name,'_20cm','_30cm_Avg');
    elseif contains(name,'_30cm')
        newVarNames{i} = replace(name,'_30cm','_20cm_Avg');
    elseif contains(name,'_40cm')
        newVarNames{i} = replace(name,'_40cm','_10cm_Avg');
    elseif contains(name,'Temp')
        newVarNames{i} = replace(name,'_Temp','_Soil_Temp');    
    end
end

typhaMarsh5MinuteTblBkup.Properties.VariableNames = newVarNames;

% Merge the backup with the current file
typhaMarsh5MinuteTbl = [typhaMarsh5MinuteTblBkup; typhaMarsh5MinuteTbl];

typhaMarsh5MinuteTbl = removevars(typhaMarsh5MinuteTbl,"RECORD"); % Remove the record 
typhaMarsh5MinuteTbl = unique(typhaMarsh5MinuteTbl,"rows"); % Remove duplicates

% Save files
save("results\typhaMarshMinuteTbl.mat","typhaMarshMinuteTbl")
save("results\typhaMarsh5MinuteTbl.mat","typhaMarsh5MinuteTbl")

%%
%[text] ## Eh Temperature correction: it's miniscule compared to the variations we see. Eh (mV) = ORP (mV) - 0.718\*T + 224.41
%[text] Using custom function mV2Eh, which takes a table, variable array, and temperature variable, and returns a table of corrected values.
% Average the two soil temperatures
highMarshMinuteTbl.avgSoilTemp= (highMarshMinuteTbl.Soil_C_1 + highMarshMinuteTbl.Soil_C_2)/2;
highMarsh5MinuteTbl.avgSoilTemp= (highMarsh5MinuteTbl.Soil_C_1_Avg + highMarsh5MinuteTbl.Soil_C_2_Avg)/2;

vars = highMarshMinuteTbl.Properties.VariableNames(contains(highMarshMinuteTbl.Properties.VariableNames,"cm"));
highMarshMinuteEh = mV2Eh(highMarshMinuteTbl,vars,highMarshMinuteTbl.avgSoilTemp);
highMarshMinuteTbl_Eh = [highMarshMinuteTbl,highMarshMinuteEh];

vars = highMarsh5MinuteTbl.Properties.VariableNames(contains(highMarsh5MinuteTbl.Properties.VariableNames,"cm"));
highMarsh5MinuteTblEh = mV2Eh(highMarsh5MinuteTbl,vars,highMarsh5MinuteTbl.avgSoilTemp);
highMarsh5MinuteTbl_Eh = [highMarsh5MinuteTbl,highMarsh5MinuteTblEh];

% Save files
save("results\highMarshMinuteTbl_Eh.mat","highMarshMinuteTbl_Eh")
save("results\highMarsh5MinuteTbl_Eh.mat","highMarsh5MinuteTbl_Eh")

% Low Marsh
% % Adjust reference base if necessary
% adjustStartDate = datetime("2026-04-14 14:00:00","TimeZone","-05:00");
% adjustEndDate = datetime("2026-05-13 11:00:00","TimeZone","-05:00");
% vars = lowMarshMinuteTbl.Properties.VariableNames(contains(lowMarshMinuteTbl.Properties.VariableNames,"cm"));
% refVars = lowMarshMinuteTbl.Properties.VariableNames(contains(lowMarshMinuteTbl.Properties.VariableNames,"Ref_0"));
% lowMarshMinuteTbl = adjustRefBase(lowMarshMinuteTbl,adjustStartDate,adjustEndDate,vars,refVars);
% 
% vars = lowMarsh5MinuteTbl.Properties.VariableNames(contains(lowMarsh5MinuteTbl.Properties.VariableNames,"cm"));
% lowMarsh5MinuteTbl = adjustRefBase(lowMarsh5MinuteTbl,adjustStartDate,adjustEndDate,vars);
% 
% adjustStartDate = datetime("2026-08-10 19:24:00","TimeZone","-05:00");
% adjustEndDate = datetime("2026-11-01 00:00:00","TimeZone","-05:00");
% refVars = lowMarshMinuteTbl.Properties.VariableNames(contains(lowMarshMinuteTbl.Properties.VariableNames,"Ref_08"));
% vars = lowMarshMinuteTbl.Properties.VariableNames(contains(lowMarshMinuteTbl.Properties.VariableNames,"cmAdjusted"));
% lowMarshMinuteTbl = adjustRefBase(lowMarshMinuteTbl,adjustStartDate,adjustEndDate,vars,refVars);
% 
% lowMarsh5MinuteTbl = adjustRefBase(lowMarsh5MinuteTbl,adjustStartDate,adjustEndDate,vars,refVars);

% Average the two soil temperatures
lowMarsh5MinuteTbl.avgSoilTemp = (lowMarsh5MinuteTbl.Soil_C_1_Avg + lowMarsh5MinuteTbl.Soil_C_2_Avg)/2;
% Low marsh minute data did not have the soil values
lowMarshMinuteTbl = synchronize(lowMarshMinuteTbl,lowMarsh5MinuteTbl(:,"avgSoilTemp"), 'union', 'linear');

vars = lowMarshMinuteTbl.Properties.VariableNames(contains(lowMarshMinuteTbl.Properties.VariableNames,"cm"));
lowMarshEh = mV2Eh(lowMarshMinuteTbl,vars,lowMarshMinuteTbl.avgSoilTemp);
lowMarshMinuteTbl_Eh = [lowMarshMinuteTbl,lowMarshEh];

vars = lowMarsh5MinuteTbl.Properties.VariableNames(contains(lowMarsh5MinuteTbl.Properties.VariableNames,"cm"));
lowMarsh5MinuteEh = mV2Eh(lowMarsh5MinuteTbl,vars,lowMarsh5MinuteTbl.avgSoilTemp);
lowMarsh5MinuteTbl_Eh = [lowMarsh5MinuteTbl,lowMarsh5MinuteEh];

 % Save files
 save("results\lowMarshMinuteTbl_Eh.mat","lowMarshMinuteTbl_Eh")
 save("results\lowMarsh5MinuteTbl_Eh.mat","lowMarsh5MinuteTbl_Eh")

 % Typha Marsh Redox

 %Use the two soil temperatures
 % Probe 2 temperature sensor was not wired until later.
 mask =typhaMarshMinuteTbl.P2_Soil_Temp_C < 0 ;
 typhaMarshMinuteTbl.P2_Soil_Temp_C(mask) = NaN;
 mask =typhaMarsh5MinuteTbl.P2_Soil_Temp_C < 0 ;
 typhaMarsh5MinuteTbl.P2_Soil_Temp_C(mask) = NaN;

 % Apply each probe's temperature to the correction 
 varNames = typhaMarshMinuteTbl.Properties.VariableNames;
 vars = varNames( contains(varNames,'P1') & contains(varNames,'cm') ); 
 typhaMarsh1Eh = mV2Eh(typhaMarshMinuteTbl,vars,typhaMarshMinuteTbl.P1_Soil_Temp_C);
 % Probe 2
 vars = varNames( contains(varNames,'P2') & contains(varNames,'cm') ); 
 typhaMarsh5Eh = mV2Eh(typhaMarshMinuteTbl,vars,typhaMarshMinuteTbl.P2_Soil_Temp_C);
 typhaMarshMinuteTbl_Eh = [typhaMarshMinuteTbl,[typhaMarsh1Eh, typhaMarsh5Eh]];
 % 5 minute data
 varNames = typhaMarsh5MinuteTbl.Properties.VariableNames;
 vars = varNames( contains(varNames,'P1') & contains(varNames,'cm') ); 
 typhaMarshEh = mV2Eh(typhaMarsh5MinuteTbl,vars,typhaMarsh5MinuteTbl.P1_Soil_Temp_C);
 typhaMarsh5MinuteTbl_Eh = [typhaMarsh5MinuteTbl,typhaMarshEh];
 vars = varNames( contains(varNames,'P2') & contains(varNames,'cm') ); 
 typhaMarshEh = mV2Eh(typhaMarsh5MinuteTbl,vars,typhaMarsh5MinuteTbl.P2_Soil_Temp_C);
 typhaMarsh5MinuteTbl_Eh = [typhaMarsh5MinuteTbl,typhaMarshEh];

 % Save files
 save("results\typhaMarshMinuteTbl_Eh.mat","typhaMarshMinuteTbl_Eh")
 save("results\typhaMarsh5MinuteTbl_Eh.mat","typhaMarsh5MinuteTbl_Eh")


%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":19}
%---
