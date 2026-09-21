[dat_file, dat_path] = uigetfile('*.dat', 'Select logger .dat file');
full_dat_file = fullfile(dat_path, dat_file);

df_logger = importCSdata(full_dat_file);

% df_logger is a table imported from Campbell Sci logger with a datetime column 'timestamp' 
% rename columns
% Define the replacement pattern
varNames = df_logger.Properties.VariableNames;
if contains(dat_file, "low")
   varNames = replace(varNames,"Redox0","L");
   varNames = replace(varNames,"Redox","L");
else
   varNames = replace(varNames,"Redox0","H"); 
   varNames = replace(varNames,"Redox","H");
end

oldNames = {'Soil_C_1_Avg','Soil_C_2_Avg','_1_Avg','_2_Avg','_3_Avg','_4_Avg'};
newNames = {'soil1_c','soil2_c','_05cm','_10cm','_15cm','_30cm'};
df_logger.Properties.VariableNames = replace(varNames,oldNames,newNames);
vars = df_logger.Properties.VariableNames;

% Set LaTeX interpreter off so _ are not interpreted as subscript
set(groot,'DefaultLegendInterpreter','none')

% Remove high redox values
redox_vars = contains(vars, {'cm','Ref','Diff'});
for i = 1:length(vars)
    if redox_vars(i)
        col = df_logger.(vars{i});
        col(col > 250) = NaN;
        df_logger.(vars{i}) = col;
    end
end
% Select timestamp and columns containing "Redox"
redoxCols = contains(df_logger.Properties.VariableNames, {'cm','Ref'}, IgnoreCase=true);
selectedData = df_logger(:, [true, redoxCols(2:end)]); % keep timestamp and redox columns

% Convert from wide to long format
timestamp = selectedData.TIMESTAMP;
varNames = selectedData.Properties.VariableNames(2:end);
values = table2array(selectedData(:, 2:end));

% Remove NaN values and create long format arrays
longTimestamp = [];
longKey = {};
longValue = [];

for i = 1:length(varNames)
    colValues = values(:, i);
    validIdx = ~isnan(colValues);
    longTimestamp = [longTimestamp; timestamp(validIdx)];
    longKey = [longKey; repmat(varNames(i), sum(validIdx), 1)];
    longValue = [longValue; colValues(validIdx)];
end

% Plot
figure;
hold on;
keys = unique(longKey);
clear lines
colors = lines(length(keys));

for i = 1:length(keys)
    idx = strcmp(longKey, keys{i});
    plot(longTimestamp(idx), longValue(idx), 'Color', colors(i,:), 'DisplayName', keys{i});
end

xlim([min(longTimestamp) max(longTimestamp)]);

xlabel('Date');
ylabel('mV');
legend('Location', 'best');
set(gca, "XGrid", "off", "YGrid", "on")
title(strrep(dat_file,"_","\_"))
hold off;
resultDir = strcat(currentProject().RootFolder,"\results\");
savefig(gcf,strcat(resultDir,"\TyphaMarshProbe.fig"));
%  Plot5 cm probes 

redoxCols = contains(df_logger.Properties.VariableNames, {'05cm'}, IgnoreCase=true);
selectedData = df_logger(:, [true, redoxCols(2:end)]); % keep timestamp and redox columns

% Convert from wide to long format
timestamp = selectedData.TIMESTAMP;
varNames = selectedData.Properties.VariableNames(2:end);
values = table2array(selectedData(:, 2:end));

% Remove NaN values and create long format arrays
longTimestamp = [];
longKey = {};
longValue = [];

for i = 1:length(varNames)
    colValues = values(:, i);
    validIdx = ~isnan(colValues);
    longTimestamp = [longTimestamp; timestamp(validIdx)];
    longKey = [longKey; repmat(varNames(i), sum(validIdx), 1)];
    longValue = [longValue; colValues(validIdx)];
end

% Plot
if ~isempty(longKey)
    figure;
    hold on;
    keys = unique(longKey);
    colors = lines(length(keys));


    for i = 1:length(keys)    
        idx = strcmp(longKey, keys{i});
        plot(longTimestamp(idx), longValue(idx), 'Color', colors(i,:), 'DisplayName', keys{i});
    end


    xlim([min(longTimestamp) max(longTimestamp)]);
    
    xlabel('Date');
    ylabel('mV');
    legend('Location', 'best');
    hold off;
end
%  Plot 10 cm probes 

redoxCols = contains(df_logger.Properties.VariableNames, {'10cm'}, IgnoreCase=true);
selectedData = df_logger(:, [true, redoxCols(2:end)]); % keep timestamp and redox columns

% Convert from wide to long format
timestamp = selectedData.TIMESTAMP;
varNames = selectedData.Properties.VariableNames(2:end);
values = table2array(selectedData(:, 2:end));

% Remove NaN values and create long format arrays
longTimestamp = [];
longKey = {};
longValue = [];

for i = 1:length(varNames)
    colValues = values(:, i);
    validIdx = ~isnan(colValues);
    longTimestamp = [longTimestamp; timestamp(validIdx)];
    longKey = [longKey; repmat(varNames(i), sum(validIdx), 1)];
    longValue = [longValue; colValues(validIdx)];
end

% Plot
if ~isempty(longKey)
    figure;
    hold on;
    keys = unique(longKey);
    colors = lines(length(keys));


    for i = 1:length(keys)
        idx = strcmp(longKey, keys{i});
        plot(longTimestamp(idx), longValue(idx), 'Color', colors(i,:), 'DisplayName', keys{i});
    end

    xlim([min(longTimestamp) max(longTimestamp)]);
    
    xlabel('Date');
    ylabel('mV');
    legend('Location', 'best');
    hold off;
end