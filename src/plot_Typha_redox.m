

% Use imported file 
% Load files if not processed in in current session of matlab
load("TidesTimetable.mat")
load("Tidespeaks.mat")

df_logger = typhaMarshMinuteTbl_Eh;

% df_logger is a table imported from Campbell Sci logger with a datetime column 'timestamp' 

% Set LaTeX interpreter off so _ are not interpreted as subscript
set(groot,'DefaultLegendInterpreter','none')
% Start date for plotting P1
startDateP1 = datetime("2026-06-29 00:00:00","TimeZone","-05:00");
% Remove high redox values before probe 2 was installed
startDateP2 = datetime("2026-07-12 14:00:00","TimeZone","-05:00");
rowsBefore = df_logger.Properties.RowTimes < startDateP2;
p2Cols = contains(df_logger.Properties.VariableNames, "P2", 'IgnoreCase', true);
if ~any(p2Cols)
    warning('No P2 columns found.');
else
    % For each P2 column, set values before startDate to NaN if numeric
    varNames = df_logger.Properties.VariableNames(p2Cols);
    for k = 1:numel(varNames)
        v = df_logger.(varNames{k});
        if isnumeric(v) || islogical(v)
            v(rowsBefore) = NaN;
            df_logger.(varNames{k}) = v;
        end
    end
end
% Select timestamp and columns"
redoxCols = contains(df_logger.Properties.VariableNames, {'cmEh'}, IgnoreCase=true);
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
   fig_1 = plot(longTimestamp(idx), longValue(idx), 'DisplayName', keys{i});
end

ax = gca;
ax.YColor = [0 0 0]; 
customColors = [0 1 1;0 1 0;1 0 0;0 0 0]; % cyan,green,red,black,cyan,blue
customLineStyles = ["-";"-";"-";"-";"-.";"-.";"-.";"-."];
ax.ColorOrder = customColors;
ax.LineStyleOrder = customLineStyles;
ax.LineStyleCyclingMethod ="withcolor"; 
xlim([min(longTimestamp) max(longTimestamp)]);
widths = [1.5,2.0,2.5,2.75]; % Vary the line widths
for k = 1:numel(fig_1) 
    fig_1(k).LineWidth = widths(k);        
end
xlabel('Date');
ylabel('mV');
legend('Location', 'best');
set(gca, "XGrid", "off", "YGrid", "on")
title("Typha Redox")
hold off;
resultDir = strcat(currentProject().RootFolder,"\results\");
savefig(gcf,strcat(resultDir,"\TyphaMarshProbe.fig"));

%  Plot probes 

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
    customLineStyles = ["-";":";"-.";"-";"--"];
    customColors = [0 0 1;0 1 0;1 0 0;0 0 0]; % blue,green,red,black
    widths = [1.5,2.0,2.5,2.75]; % Vary the line widths


    for i = 1:length(keys)    
        idx = strcmp(longKey, keys{i});
        plot(longTimestamp(idx), longValue(idx), 'DisplayName', keys{i});
    end
    ax = gca;
    ax.ColorOrder = customColors;
    ax.LineStyleOrder = customLineStyles;
    ax.LineStyleCyclingMethod ="withcolor"; 

    xlim([startDateP1 max(longTimestamp)]);
    
    xlabel('Date');
    ylabel('mV');
    legend('Orientation','horizontal','Location','southoutside');
    hold off;
end
%  Plot each probes 
probes = (["P1","P2"]);
for f = 1:numel(probes) 
    names = df_logger.Properties.VariableNames;
    redoxCols = contains(names, probes(f), 'IgnoreCase', true) & contains(names, "Eh", 'IgnoreCase', true);
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
        customLineStyles = ["-";":";"-.";"-";"--"];
        customColors = [0 0 1;0 1 0;1 0 0;0 0 0]; % blue,green,red,black
        
        for i = 1:length(keys)
            idx = strcmp(longKey, keys{i});
            plot(longTimestamp(idx), longValue(idx), 'DisplayName', keys{i});
        end
        ax = gca;
        ax.ColorOrder = customColors;
        ax.LineStyleOrder = customLineStyles;
        ax.LineStyleCyclingMethod ="withcolor"; 

        xlim([min(longTimestamp) max(longTimestamp)]);
        title("Probe Number " + f);
        xlabel('Date');
        ylabel('Eh');
        legend({'10cm','20cm','30cm','40cm'},'Orientation','horizontal','Location','southoutside'); 
        if f ==2
            legend({'05cm','15cm','25cm','35cm'},'Orientation','horizontal','Location','southoutside');
        end
        % == Plot water table on right axis ==== 
        yyaxis(ax,'right');
        ax.YColor = [0 0 0]; 
        ax.XColor = [0 0 0];
        midgrey = [0.5 0.5 0.5];   
        ylabel('meter(Predicted Tide)',Color="k");
        ylim([8 18]);
        hold on

        fig_water = plot(TidesTimetable.DateTime,TidesTimetable.Prediction,'DisplayName',"Predicted Tide",Color = midgrey,LineStyle="-");

        % Plot vertical lines at water table peaks
        h = xline(Tidepeaks.DateTime, ':b', 'LineWidth', .5);
        % Give only the first xline a name; hide the rest from legend
        h(1).DisplayName = 'Tide High Peaks';
        for k = 2:numel(h)
            h(k).HandleVisibility = 'off';
        end
        lines = findall(ax, 'Type', 'line');  % returns handles
        legend('Interpreter', 'none'); % Don't interpret "_" as subscripts
        ax.Toolbar.Visible = 'on';
        hold off;

    end
end

% Plot soil Temperatures Celsius

figure; 
allVars = df_logger.Properties.VariableNames;
mask =df_logger.P2_Soil_Temp_C < 0 ;
df_logger.P2_Soil_Temp_C(mask) = NaN;
vars = allVars(contains(allVars, "Temp"));  
fig_soil = plot(df_logger, "TIMESTAMP",vars);
title("Typha Marsh Soil Temperature");
ylabel('Celsius');
legend