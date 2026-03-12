%[text] # Read saved MatLab files for tide, water tabel and redox.
%[text] The redox files, "highMarshTbl" and "lowMarshTbl\_Eh" have temperture correctedEh .
load("TidesTimetable.mat")
load("highMarshWaterTable.mat")
load("highMarshTbl_Eh.mat")
load("highMarshWTPeaks.mat")

%%
%[text] ## Find start and end of battery peaks great than a threshold
% Some of the redox sensors were affected by the spiky logger voltage when
% the solar panel was charging the battery.  The function findpeaks, identifies the
% voltage spikes and given a maximum gap between the spike create a group.
% The group is use to build a logic array of times which can be used to
% delete the affected sensor data

% Pass the custom function findPeaksGroups a timetable with battery voltage
rowsToNaN = findPeakGroups(highMarshTbl_Eh(:,"loggerBattV"));
%%
%[text] ## Set up Colors, Linestyle, and Start Date for plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% VARIETY OF GRAPHS OF VARYING USEFULNESS!
%These startDate and endDate are used in various graphs, below
startDate = datetime("2025-08-14 14:00:00", "TimeZone", "-05:00");
endDate = datetime("2025-11-04 09:20:00", "TimeZone", "-05:00");

highMarshWTx = highMarshWaterTable(highMarshWaterTable.Properties.RowTimes > startDate, :);

% Define colors and line styles for plots

customColors = [0 1 1;0 1 0;1 0 0;0 0 0;0 1 1;0 0 1];
customLineStyles = [":";"--";"-.";"-";"--"];
% set(groot, 'defaultAxesColorOrder', customColors);
% set(groot, 'defaultAxesLineStyleOrder', customLineStyles);
% set(groot,'defaultAxesLineStyleCyclingMethod',"withcolor");
%%
%[text] ## Plot Battery and Watertable and Save Figure
% Redox and water table plots

figure(NumberTitle="off");
% plot battery and water table on secondary axis
%save as template
ax = gca;
yyaxis(ax,'right');
ax.YColor = [0 0 0]; 
ax.XColor = [0 0 0];
plot(highMarshTbl_Eh,"TIMESTAMP","loggerBattV",Color="k")
ylabel('volts(battery) meter x 10 WaterTable Nref',Color="k");
ylim([11 20]);
xlim(ax,[min(highMarshTbl_Eh.TIMESTAMP) max(highMarshTbl_Eh.TIMESTAMP)]);
hold on
plot(highMarshWTx.Date,highMarshWTx.Nref*10,'b-', 'DisplayName',"Watertable")
% Plot vertial lines at water table peaks
midgrey = [0.5 0.5 0.5] ;
h = xline(highMarshWTPeaks.Date, ':b', 'LineWidth', .5);
% Give only the first xline a name; hide the rest from legend
h(1).DisplayName = 'Watertable High Peaks';
for k = 2:numel(h)
    h(k).HandleVisibility = 'off';
end
hold off
savefig(gcf,'results\highMarshwatertablebat.fig');
%[text] ## 
%%
%[text] ## Plots for each probe with watertable peaks and battery.
%[text] Use a saved watertable figure.

probes = (["H06","H05","H04","H03","H02","H01"]);
allVars = highMarshTbl_Eh.Properties.VariableNames;
figName = strcat("High Marsh probe ",probes);
customColors = [0 1 1;0 1 0;1 0 0;0 0 0;0 1 1;0 0 1];
customLineStyles = [":";":";"-.";"-";"--"];
 for f = 1:numel(probes)
    vars = allVars(contains(allVars, probes(f)) & contains(allVars, "Eh"));
    openfig("highMarshwatertablebat.fig");
    fig = gcf;
    fig.Name = figName(f);
    title(strcat("High Marsh Probe ",probes(f)));   
    hold on;
    yyaxis('left');
    ax = gca;
    ax.YColor = [0 0 0]; 
    ax.ColorOrder = customColors;
    ax.LineStyleOrder = customLineStyles;
    ax.LineStyleCyclingMethod ="withcolor";
   
    hProbe= plot(highMarshTbl_Eh, "TIMESTAMP", vars);
    ylabel('Eh(mV)');
    xlabel('Date Time');
    widths = [1.5,2.0,2.5,2.75]; 
    for k = 1:numel(hProbe) 
        hProbe(k).LineWidth = widths(k); 
    end
    legend(hProbe, 'Location',"northeast");
    ax.Toolbar.Visible = 'on';
    hold off;
 end
%%
%[text] ## Plots for each probe with watertable peaks and battery.
%[text] #### This code plots the watertable and battery everytime a figure is generated.
% Recreate the water table graph for each figure
probes = (["H06","H05","H04","H03","H02","H01"]);
allVars = highMarshTbl_Eh.Properties.VariableNames;
figName = strcat("High Marsh probe ",probes);
customColors = [0 1 1;0 1 0;1 0 0;0 0 0;0 1 1;0 0 1];
customLineStyles = [":";":";"-.";"-";"--"];
 for f = 1:numel(probes)     
    fig = figure(NumberTitle="off");
    vars = allVars(contains(allVars, probes(f)) & contains(allVars, "Eh"));   
    fig.Name = figName(f);
    title(strcat("High Marsh Probe ",probes(f)));   
    hold on;
    yyaxis('left');
    ax = gca;
    ax.YColor = [0 0 0]; 
    ax.ColorOrder = customColors;
    ax.LineStyleOrder = customLineStyles;
    ax.LineStyleCyclingMethod ="withcolor";   
    hProbe= plot(highMarshTbl_Eh, "TIMESTAMP", vars);
    ylabel('Eh(mV)');
    xlabel('Date Time');    
    widths = [1.5,2.0,2.5,2.75]; % Vary the line widths
    for k = 1:numel(hProbe) 
        hProbe(k).LineWidth = widths(k); 
    end

    % == Plot watertable on right axis ==== 
    yyaxis(ax,'right');
    % ax.YColor = [0 0 0]; 
    % ax.XColor = [0 0 0];
    midgrey = [0.5 0.5 0.5] ;
    plot(highMarshTbl_Eh,"TIMESTAMP","loggerBattV",Color=midgrey)
    ylabel('volts(battery) meter x 10 WaterTable Nref',Color="k");
    ylim([11.5 20]);
    xlim(ax,[min(highMarshTbl_Eh.TIMESTAMP) max(highMarshTbl_Eh.TIMESTAMP)]);
    hold on
    plot(highMarshWTx.Date,highMarshWTx.Nref*10,'b-', 'DisplayName',"Watertable")
    % Plot vertial lines at water table peaks
   
    h = xline(highMarshWTPeaks.Date, ':b', 'LineWidth', .5);
    % Give only the first xline a name; hide the rest from legend
    h(1).DisplayName = 'Watertable High Peaks';
    for k = 2:numel(h)
        h(k).HandleVisibility = 'off';
    end
    
    legend(hProbe, 'Location',"northeast");
    ax.Toolbar.Visible = 'on';
    
    hold off;
 end
%[text] ## 

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":11.7}
%---
