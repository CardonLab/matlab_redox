[dat_file, dat_path] = uigetfile('*.dat', 'Select logger .dat file');
full_dat_file = fullfile(dat_path, dat_file);

df_logger = importCSdata(full_dat_file);

% Assuming df_logger is a table with a datetime column 'timestamp' and several columns containing "batt" in their names

% Select timestamp and columns containing "batt"
battCols = contains(df_logger.Properties.VariableNames, 'batt', IgnoreCase=true);
selectedData = df_logger(:, [true, battCols(2:end)]); % keep timestamp and batt columns

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
