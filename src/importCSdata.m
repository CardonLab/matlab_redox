
function stn_data = importCSdata(filename)
    % Import CSV data with specific formatting and timezone adjustment
    % Returns a time table    
    % Read data starting from line 5 (skip 4 lines)
    % Force it to accept unknow extentions like .backup
    time_zone = "-05:00"; % Eastern standard time
    opts = detectImportOptions(filename, 'NumHeaderLines', 4,"FileType", "text", "Delimiter", ",");
    opts = setvaropts(opts, 'TreatAsMissing', 'NAN');
    opts.VariableNamesLine = 2; % to ensure variable names are from header line
    % Read the table
    stn_data = readtimetable(filename, opts);
    stn_data.TIMESTAMP.TimeZone = time_zone;
    % Clean variable names
    
    stn_data.Properties.VariableNames = matlab.lang.makeValidName(stn_data.Properties.VariableNames);
    
%     % Convert timestamp to datetime with specified timezone
% 
%     % Assuming TIMESTAMP is a string column named 'TIMESTAMP'
%     if any(strcmp(stn_data.Properties.VariableNames, 'TIMESTAMP'))
%         stn_data.TIMESTAMP = datetime(stn_data.TIMESTAMP, 'InputFormat', 'yyyy-MM-dd HH:mm:ss', 'TimeZone', time_zone);
%     end
% end
