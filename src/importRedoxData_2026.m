%[text] ## Low and high marsh redox 1 and 5 minute data
% Folder of logger data files
folder_path = "C:\Users\jl01596\OneDrive - Marine Biological Laboratory\Cmarsh\";
% low marsh redox data.
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

% Save files
save("results\lowMarshMinuteTbl.mat","lowMarshMinuteTbl")
save("results\lowMarsh5MinuteTbl.mat","lowMarsh5MinuteTbl")

% Get high marsh redox 1 and 5 mniute data 

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
% Adjust reference base if necessary
adjustStartDate = datetime("2026-04-14 14:00:00","TimeZone","-05:00");
adjustEndDate = datetime("2026-05-13 11:00:00","TimeZone","-05:00");
vars = lowMarshMinuteTbl.Properties.VariableNames(contains(lowMarshMinuteTbl.Properties.VariableNames,"cm"));
lowMarshMinuteTbl = adjustRefBase(lowMarshMinuteTbl,adjustStartDate,adjustEndDate,vars);
vars = lowMarsh5MinuteTbl.Properties.VariableNames(contains(lowMarsh5MinuteTbl.Properties.VariableNames,"cm"));
lowMarsh5MinuteTbl = adjustRefBase(lowMarsh5MinuteTbl,adjustStartDate,adjustEndDate,vars);

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

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":21.2}
%---
