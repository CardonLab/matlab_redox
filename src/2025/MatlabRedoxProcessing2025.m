%[text] # Read in the tide data from NOAA

% NOAA api tide data from Plum Island Sound
% Note: matlab article said a Web services token was needed.
%   n = noaa("yrteIwdviqvigwZeUrwYPuWFzsmlBhei");
% But I used an url instead.
startDateTide = "20250814"; % Set the start date for tide data retrieval
% Set the end date for tide data retrieval. Use "today" or a set data
endDateTide = "20251104"; % Or = string(endDate,'yyyyMMdd');

url_plumIsland = strcat('https://api.tidesandcurrents.noaa.gov/api/prod/datagetter?product=predictions&application=NOS.COOPS.TAC.WL&begin_date=',startDateTide,'&end_date=',endDateTide,'&datum=MLLW&station=8441241&time_zone=LST&units=english&interval=&format=csv');
Tides = webread(url_plumIsland);
TidesTimetable = table2timetable(Tides);
TidesTimetable.DateTime.TimeZone = '-05:00'; % Eastern Standard Time

% Save the tide data to a CSV file for future reference
writetable(Tides, 'results\2025\PlumIslandTides.csv');
%%
%[text] ## Get water table data
%[text] water table data from Sam.
 dataDir = '\data';
 % read in low marsh water table data
 lowMarshWaterTable = readtimetable(fullfile(dataDir,"MAR-RO-Wtable-Shad-2025.csv"));
 lowMarshWaterTable.Date.TimeZone = "-05:00";
 % Plot against predicted tides.
 varsLowMarshWaterTable = string(lowMarshWaterTable.Properties.VariableNames);
 vars = {[varsLowMarshWaterTable,"Prediction"]};
 stackedplot(TidesTimetable,lowMarshWaterTable,vars)
 % read in high marsh water table data
 highMarshWaterTable = readtimetable(fullfile(dataDir,"MAR-RO-Wtable-Nel-2025.csv"));
 highMarshWaterTable.Date.TimeZone =  "-05:00";
 varsHighMarshWaterTable = string(highMarshWaterTable.Properties.VariableNames);
 vars = {[varsHighMarshWaterTable,"Prediction"]};
 stackedplot(TidesTimetable,highMarshWaterTable,vars)
 % Save files
 save("results\2025\lowMarshWaterTable.mat","lowMarshWaterTable")
 save("results\2025\highMarshWaterTable.mat","highMarshWaterTable")
%%
%[text] ## Find maximum peaks of water table and tides.
% Predicted Tide peaks
y = TidesTimetable.Prediction;
[~, locs] = findpeaks(y);
Tidepeaks = TidesTimetable(locs, :);
% Low marsh water table peaks time
y = lowMarshWaterTable.Sref;
[~, locs] = findpeaks(y,MinPeakHeight=0.3);
lowMarshWTPeaks = lowMarshWaterTable(locs, :);
save("results\2025\lowMarshWTPeaks.mat","lowMarshWTPeaks");
% High marsh water table peak time
y = highMarshWaterTable.Nref;
[pks, locs] = findpeaks(y,MinPeakHeight=0.2);
highMarshWTPeaks = highMarshWaterTable(locs, :);
save("results\2025\highMarshWTPeaks.mat","highMarshWTPeaks");
% Battery peaks
y = lowMarshMinuteTbl.BattV_Min;
[~, locs] = findpeaks(y, MinPeakHeight=13);
lowMarshBattPeaks = lowMarshMinuteTbl(locs,:);

% plot peak with water table data
% Plot predicted tide peaks with low and high marsh water table peaks
figure;
plot(Tidepeaks.DateTime, Tidepeaks.Prediction, 'ro', 'DisplayName', 'Tide Peaks');
hold on;
plot(lowMarshWaterTable.Date,lowMarshWaterTable.Sref,'b', 'DisplayName', 'Low Marsh Water');
plot(highMarshWaterTable.Date, highMarshWaterTable.Nref, 'g', 'DisplayName', 'High Marsh Water');
plot(lowMarshWTPeaks.Date, lowMarshWTPeaks.Sref, 'bo', 'DisplayName', 'Low Marsh Peaks');
plot(highMarshWTPeaks.Date, highMarshWTPeaks.Nref, 'go', 'DisplayName', 'High Marsh Peaks');
xlabel('Date and Time');
ylabel('Water Level (m)');
title('Tide Peaks vs Water Table Peaks');
legend('Location', 'best');
hold off;

%%
%[text] ## Get low marsh redox data
% low and high marsh redox data. lots of mismatches because of troubleshooting the voltage problems.
dataDir = uigetdir('Select logger .dat directory');
lowMarsh5MinuteTbl = importCSdata(fullfile(dataDir,'cmarsh_lowmarsh_pheno_redox_5minute.dat'));
oldVarnames = lowMarsh5MinuteTbl.Properties.VariableNames; 
lowMarsh5MinuteTbl.Properties.VariableNames = renameTblVar(oldVarnames,"low");
oldMinuteVarnames = lowMarsh5MinuteTbl.Properties.VariableNames;
% Rename replacing "Redox" with "low" and "Soil_C_1" and "Soil_C_2" with
% "soil1_c" and "soil2_c"
lowMarsh5MinuteTbl.Properties.VariableNames= renameTblVar(oldMinuteVarnames,"low");
lowMarsh5MinuteTbl = removevars(lowMarsh5MinuteTbl,["RECORD", "PTemp_C_Avg"]); % Remove the record and p_temp columns from low marsh data
% Start date after probes settled down
% Remove bad data
startDate = datetime('2025-08-25 00:00:00', TimeZone='America/New_York');
lowMarsh5MinuteTbl(lowMarsh5MinuteTbl.TIMESTAMP < startDate, :) =[];
mask = lowMarsh5MinuteTbl.L07_15cm > -300;
lowMarsh5MinuteTbl.L07_15cm(mask) = NaN;
% probes 10-12 were not in until 2025-08-24 14:00
% Remove bad data from high marsh table
startDatelowMarsh2ndPorbes = datetime('2025-08-25 00:00:00', TimeZone='America/New_York');
vars =lowMarsh5MinuteTbl.Properties.VariableNames(contains(lowMarsh5MinuteTbl.Properties.VariableNames,("L10"|"L11"|"L12")));
rows = lowMarsh5MinuteTbl.Properties.RowTimes < startDatelowMarsh2ndPorbes;
lowMarsh5MinuteTbl{rows,vars} = NaN;
% Average the two soil temperatures
lowMarsh5MinuteTbl.avgSoilTemp = (lowMarsh5MinuteTbl.soil1_c + lowMarsh5MinuteTbl.soil2_c)/2; 

% ====one minute data======================
lowMarshMinuteTbl = importCSdata(fullfile(dataDir,'cmarsh_lowmarsh_pheno_redox_1minute.dat'));  
oldMinuteVarnames = lowMarshMinuteTbl.Properties.VariableNames;
lowMarshMinuteTbl.Properties.VariableNames= renameTblVar(oldMinuteVarnames,"low");
lowMarshMinuteTbl = removevars(lowMarshMinuteTbl,"RECORD"); % Remove the record and p_temp columns from low marsh data
% Start date after probes settled down
% Remove bad data
startDate = datetime('2025-08-25 00:00:00', TimeZone='America/New_York');
lowMarshMinuteTbl(lowMarshMinuteTbl.TIMESTAMP < startDate, :) =[];
mask = lowMarshMinuteTbl.L07_15cm > -300;
lowMarshMinuteTbl.L07_15cm(mask) = NaN;
% probes 10-12 were not in until 2025-08-24 14:00
% Remove bad data from high marsh table
startDatelowMarsh2ndPorbes = datetime('2025-08-25 00:00:00', TimeZone='America/New_York');
vars =lowMarshMinuteTbl.Properties.VariableNames(contains(lowMarshMinuteTbl.Properties.VariableNames,("L10"|"L11"|"L12")));
rows = lowMarshMinuteTbl.Properties.RowTimes < startDatelowMarsh2ndPorbes;
lowMarshMinuteTbl{rows,vars} = NaN;
lowMarshMinuteTbl = unique(lowMarshMinuteTbl);
% Add soil  temperature by synchronize from 5 minute data
lowMarshSoil = lowMarsh5MinuteTbl(:,contains(lowMarsh5MinuteTbl.Properties.VariableNames,"soil"));
lowMarshMinuteTbl = synchronize(lowMarshMinuteTbl,lowMarshSoil,"union","linear");
% Now average the two soil temperatures
lowMarshMinuteTbl.avgSoilTemp = (lowMarshMinuteTbl.soil1_c + lowMarshMinuteTbl.soil2_c)/2; 

%%
%[text] ## Get high marsh redox data
% ensure dataDir contains a valid folder path
if exist('dataDir','var') ~= 1 || isempty(dataDir) || ~ischar(dataDir) && ~isstring(dataDir) || ~isfolder(dataDir)
    % Prompt user to pick a directory (returns 0 if Cancel)
    chosen = uigetdir(pwd,'Select data directory');
    if isequal(chosen,0)
        error('No directory selected. Aborting.');
    else
        dataDir = char(chosen);   % ensure char row vector
    end
end

%dataDir = uigetdir('Select logger .dat directory');
highMarsh5MinuteTbl = importCSdata(fullfile(dataDir,'cmarshhigh_redox_5minute.dat'));  %%Note - there is an extra column here ..last one. Don't need. 
oldVarnames = highMarsh5MinuteTbl.Properties.VariableNames;
highMarsh5MinuteTbl.Properties.VariableNames = renameTblVar(oldVarnames,"high");
highMarsh5MinuteTbl = removevars(highMarsh5MinuteTbl,["batteryVolt_Min","PTemp_C_Avg","RECORD"]);
%There are earlier time frame data.  Time interval for some of it is 15 min instead of 5 until 8/26, and then it's 5 min again.  
% BUT!!! FOUND A PROBLEM> There are repeated data in there in the .backup file. lines 3183-467- are repeats. Need to remove those lines. So..
highMarsh5MinuteTblbackup = importCSdata(fullfile(dataDir,'cmarshhigh_redox_5minute.dat.backup')); 
oldVarnames = highMarsh5MinuteTblbackup.Properties.VariableNames;
highMarsh5MinuteTblbackup.Properties.VariableNames = renameTblVar(oldVarnames,"high"); 
highMarsh5MinuteTblbackup = removevars(highMarsh5MinuteTblbackup,["PTemp_C_Avg","RECORD"]);
highMarsh5MinuteTblbackup = renamevars(highMarsh5MinuteTblbackup,"BattV","loggerBattV");
highMarsh5MinuteTbl = [highMarsh5MinuteTblbackup;highMarsh5MinuteTbl];
highMarsh5MinuteTbl = sortrows(highMarsh5MinuteTbl); 

% ====one minute data======================

highMarshMinuteTbl = importCSdata(fullfile(dataDir,'cmarshhigh_redox_1minute.dat'));  
highMarshMinuteTblbackup = importCSdata(fullfile(dataDir,'cmarshhigh_redox_1minute.dat.backup')); 
highMarshMinuteTbl = [highMarshMinuteTblbackup;highMarshMinuteTbl];
highMarshMinuteTbl = unique(highMarshMinuteTbl);
oldMinuteVarnames = highMarshMinuteTbl.Properties.VariableNames;
highMarshMinuteTbl.Properties.VariableNames= renameTblVar(oldMinuteVarnames,"high");
highMarshMinuteTbl = removevars(highMarshMinuteTbl,"RECORD"); % Remove the record columns from high marsh data

% These startDate and endDate remove the setting-down time and time after take-out.
startDate = datetime("2025-08-14 14:00:00", "TimeZone", "-05:00");
endDate = datetime("2025-11-04 09:20:00", "TimeZone", "-05:00");
highMarshMinuteTbl = highMarshMinuteTbl(timerange(startDate,endDate),:);
highMarshMinuteTbl = highMarshMinuteTbl(timerange(startDate,endDate),:);
% Save table
save("results\2025\highMarsh5MinuteTbl.mat","highMarsh5MinuteTbl")
save("results\2025\highMarshMinuteTbl.mat","highMarshMinuteTbl")
%%
%[text] ## Eh Temperature correction: it's minuscule compared to the variations we see. Eh (mV) = ORP (mV) - 0.718\*T + 224.41
%[text] Using custom function mV2Eh, which takes a table, variable array, and temperature variable, and returns a table of corrected values.
% Average the two soil temperatures
lowMarsh5MinuteTbl.avgSoilTemp = (lowMarsh5MinuteTbl.soil1_c + lowMarsh5MinuteTbl.soil2_c)/2; 
highMarsh5MinuteTbl.avgSoilTemp= (highMarsh5MinuteTbl.soil1_c + highMarsh5MinuteTbl.soil2_c)/2;
highMarshMinuteTbl.avgSoilTemp= (highMarshMinuteTbl.Soil_C_1 + highMarshMinuteTbl.Soil_C_2)/2;
% High Marsh
% 5 Minute data
vars = highMarsh5MinuteTbl.Properties.VariableNames(contains(highMarsh5MinuteTbl.Properties.VariableNames,"cm"));
highMarsh5MinuteEh = mV2Eh(highMarsh5MinuteTbl,vars,highMarsh5MinuteTbl.avgSoilTemp);
highMarsh5MinuteTbl_Eh = [highMarsh5MinuteTbl,highMarsh5MinuteEh];
% Minute data
vars = highMarshMinuteTbl.Properties.VariableNames(contains(highMarshMinuteTbl.Properties.VariableNames,"cm"));
highMarshMinuteTblEh = mV2Eh(highMarshMinuteTbl,vars,highMarshMinuteTbl.avgSoilTemp);
highMarshMinuteTbl_Eh = [highMarshMinuteTbl,highMarshMinuteTblEh];

% Save files
save("results\2025\highMarsh5MinuteTbl_eH.mat","highMarsh5MinuteTbl_Eh")
save("results\2025\highMarshMinuteTbl_eH.mat","highMarshMinuteTbl_Eh")

% Low Marsh
% 5 Minute data
vars = lowMarsh5MinuteTbl.Properties.VariableNames(contains(lowMarsh5MinuteTbl.Properties.VariableNames,"cm"));
lowMarsh5MinuteEh = mV2Eh(lowMarsh5MinuteTbl,vars,lowMarsh5MinuteTbl.avgSoilTemp);
lowMarsh5MinuteTbl_Eh = [lowMarsh5MinuteTbl,lowMarsh5MinuteEh];
% Minute data
vars = lowMarshMinuteTbl.Properties.VariableNames(contains(lowMarshMinuteTbl.Properties.VariableNames,"cm"));
lowMarshMinuteEh = mV2Eh(lowMarshMinuteTbl,vars,lowMarshMinuteTbl.avgSoilTemp);
lowMarshMinuteTbl_Eh = [lowMarshMinuteTbl,lowMarshMinuteEh];
 % Save files
 save("results\2025\lowMarsh5MinuteTbl_eH.mat","lowMarsh5MinuteTbl_Eh")
 save("results\2025\lowMarshMinuteTbl_eH.mat","lowMarshMinuteTbl_Eh")

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":18.3}
%---
