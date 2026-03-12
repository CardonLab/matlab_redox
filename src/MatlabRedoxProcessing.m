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
writetable(Tides, 'results\PlumIslandTides.csv');
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
 save("results\lowMarshWaterTable.mat","lowMarshWaterTable")
 save("results\highMarshWaterTable.mat","highMarshWaterTable")
%%
%[text] ## Find maximum peaks of watertable and tides.
% Predicted Tide peaks
y = TidesTimetable.Prediction;
[~, locs] = findpeaks(y);
Tidepeaks = TidesTimetable(locs, :);
% Low marsh water table peaks time
y = lowMarshWaterTable.Sref;
[~, locs] = findpeaks(y,MinPeakHeight=0.3);
lowMarshWTPeaks = lowMarshWaterTable(locs, :);
save("results\lowMarshWTPeaks.mat","lowMarshWTPeaks");
% High marsh water table peak time
y = highMarshWaterTable.Nref;
[pks, locs] = findpeaks(y,MinPeakHeight=0.2);
highMarshWTPeaks = highMarshWaterTable(locs, :);
save("results\highMarshWTPeaks.mat","highMarshWTPeaks");
% Battery peaks
y = lowMarshTbl.BattV;
[~, locs] = findpeaks(y, MinPeakHeight=13);
lowMarshBattPeaks = lowMarshTbl(locs,:);

% plot peak with water table data
% Plot predicted tide peaks with low and high marsh water table peaks
figure;
plot(Tidepecks.DateTime, Tidepecks.Prediction, 'ro', 'DisplayName', 'Tide Peaks');
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
%[text] ## Get data low marsh redox data
% low and high marsh redox data. lots of mismatches because of troubleshooting the voltage problems.
dataDir = uigetdir('Select logger .dat directory');
lowMarshTbl = importCSdata(fullfile(dataDir,'cmarsh_lowmarsh_pheno_redox.dat'));
oldVarnames = lowMarshTbl.Properties.VariableNames; 
lowMarshTbl.Properties.VariableNames = renameTblVar(oldVarnames,"low");
oldMinuteVarnames = lowMarshminuteTbl.Properties.VariableNames;
lowMarshminuteTbl.Properties.VariableNames= renameTblVar(oldMinuteVarnames,"low");
lowMarshTbl = removevars(lowMarshTbl,["RECORD", "PTemp_C_Avg"]); % Remove the record and p_temp columns from low marsh data
% Start date after probes settled down
% Remove bad data
startDate = datetime('2025-08-25 00:00:00', TimeZone='America/New_York');
lowMarshTbl(lowMarshTbl.TIMESTAMP < startDate, :) =[];
mask = lowMarshTbl.L07_15cm > -300;
lowMarshTbl.L07_15cm(mask) = NaN;
% probes 10-12 were not in until 2025-08-24 14:00
% Remove bad data from high marsh table
startDatelowMarsh2ndPorbes = datetime('2025-08-25 00:00:00', TimeZone='America/New_York');
vars =lowMarshTbl.Properties.VariableNames(contains(lowMarshTbl.Properties.VariableNames,("L10"|"L11"|"L12")));
rows = lowMarshTbl.Properties.RowTimes < startDatelowMarsh2ndPorbes;
lowMarshTbl{rows,vars} = NaN;
% Average the two soil temeratures
lowMarshTbl.avgSoilTemp = (lowMarshTbl.soil1_c + lowMarshTbl.soil2_c)/2; 

% one minute data
lowMarshminuteTbl = importCSdata(fullfile(dataDir,'cmarsh_lowmarsh_pheno_redox_1minute.dat'));  
oldMinuteVarnames = lowMarshminuteTbl.Properties.VariableNames;
lowMarshminuteTbl.Properties.VariableNames= renameTblVar(oldMinuteVarnames,"low");
lowMarshminuteTbl = removevars(lowMarshminuteTbl,["RECORD"]); % Remove the record and p_temp columns from low marsh data
% Start date after probes settled down
% Remove bad data
startDate = datetime('2025-08-25 00:00:00', TimeZone='America/New_York');
lowMarshminuteTbl(lowMarshminuteTbl.TIMESTAMP < startDate, :) =[];
mask = lowMarshminuteTbl.L07_15cm > -300;
lowMarshminuteTbl.L07_15cm(mask) = NaN;
% probes 10-12 were not in until 2025-08-24 14:00
% Remove bad data from high marsh table
startDatelowMarsh2ndPorbes = datetime('2025-08-25 00:00:00', TimeZone='America/New_York');
vars =lowMarshminuteTbl.Properties.VariableNames(contains(lowMarshminuteTbl.Properties.VariableNames,("L10"|"L11"|"L12")));
rows = lowMarshminuteTbl.Properties.RowTimes < startDatelowMarsh2ndPorbes;
lowMarshminuteTbl{rows,vars} = NaN;
lowMarshminuteTbl = unique(lowMarshminuteTbl);
% Add soil  temperature by snychronize from 5 minute data
lowMarshSoil = lowMarshTbl(:,contains(lowMarshTbl.Properties.VariableNames,"soil"));
lowMarshminuteTbl = synchronize(lowMarshminuteTbl,lowMarshSoil,"union","linear");
% Average the two soil temeratures
lowMarshminuteTbl.avgSoilTemp = (lowMarshminuteTbl.soil1_c + lowMarshminuteTbl.soil2_c)/2; 

%%
%[text] ## Get high marsh data
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
highMarshTbl = importCSdata(fullfile(dataDir,'cmarshhigh_redox.dat'));  %%Note - there is an extra column here ..last one. Don't need. 
oldVarnames = highMarshTbl.Properties.VariableNames;
highMarshTbl.Properties.VariableNames = renameVar(oldVarnames,"high");
highMarshTbl = removevars(highMarshTbl,["batteryVolt_Min","PTemp_C_Avg","RECORD"]);

highMarshTblbackup = importCSdata(fullfile(dataDir,'cmarshhigh_redox.dat.backup')); %There are earlier time frame data.  Time interval for some of it is 15 min instead of 5 until 8/26, and then it's 5 min again.  BUT!!! FOUND A PROBLEM> There are repeated data in there in the .backup file. lines 3183-467- are repeats. Need to remove those lines. So....
oldVarnames = highMarshTblbackup.Properties.VariableNames;
highMarshTblbackup.Properties.VariableNames = renameVar(oldVarnames,"high"); 
highMarshTblbackup = removevars(highMarshTblbackup,["PTemp_C_Avg","RECORD"]);
highMarshTblbackup = renamevars(highMarshTblbackup,"BattV","loggerBattV");


highMarshTbl = [highMarshTblbackup;highMarshTbl];
highMarshTbl = sortrows(highMarshTbl);           

%%
%[text] ## Eh Temperature correction: it's miniscule compared to the variations we see. Eh (mV) = ORP (mV) - 0.718\*T + 224.41
%[text] Using custom function mV2Eh, which takes a table, variable array, and temperature varible, and returns a table of corrected values.
% Average the two soil temeratures
lowMarshTbl.avgSoilTemp = (lowMarshTbl.soil1_c + lowMarshTbl.soil2_c)/2; %(lowmarsh_ArrayDbl(:,30)+lowmarsh_ArrayDbl(:,31))/2;
highMarshTbl.avgSoilTemp= (highMarshTbl.soil1_c + highMarshTbl.soil2_c)/2;

vars = highMarshTbl.Properties.VariableNames(contains(highMarshTbl.Properties.VariableNames,"cm"));
highMarshEh = mV2Eh(highMarshTbl,vars,highMarshTbl.avgSoilTemp);
highMarshTbl = [highMarshTbl,highMarshEh];

vars = lowMarshTbl.Properties.VariableNames(contains(lowMarshTbl.Properties.VariableNames,"cm"));
lowMarshEh = mV2Eh(lowMarshTbl,vars,lowMarshTbl.avgSoilTemp);
lowMarshTbl = [lowMarshTbl,lowMarshEh];

vars = lowMarshminuteTbl.Properties.VariableNames(contains(lowMarshminuteTbl.Properties.VariableNames,"cm"));
lowMarshEh = mV2Eh(lowMarshminuteTbl,vars,lowMarshminuteTbl.avgSoilTemp);
lowMarshminuteTbl = [lowMarshminuteTbl,lowMarshEh];
 % Save files
 save("results\lowMarshTbl_eH.mat","lowMarshTbl")
 save("results\lowMarshminuteTbl_eH.mat","lowMarshminuteTbl")

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":18.3}
%---
