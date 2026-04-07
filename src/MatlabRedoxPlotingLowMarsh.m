%[text] # Read saved MatLab files for tide, water tabel and redox.
%[text] The redox files, "highMarshTbl" and "lowMarshTbl\_Eh" have temperture correctedEh .
load("TidesTimetable.mat")
load("lowMarshWaterTable.mat")
load("lowMarshTbl_Eh.mat")
load("lowMarshminuteTbl_Eh.mat")
load("lowMarshWTPeaks.mat")

%%
%[text] ## Find start and end of battery peaks great than a threshold
% Some of the redox sensors were affected by the spiky logger voltage when
% the solar panel was charging the battery.  The function findpeaks, identifies the
% voltage spikes and given a maximum gap between the spike create a group.
% The group is use to build a logic array of times which can be used to
% delete the affected sensor data

% Pass the custom function findPeaksGroups a timetable with battery voltage
rowsToNaN = findPeakGroups(lowMarshTbl_Eh(:,"BattV"));
%%
%[text] ## Set up Colors, Linestyle, and Start Date for plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% VARIETY OF GRAPHS OF VARYING USEFULNESS!
%These startDate and endDate are used in various graphs, below
startDate = datetime("2025-08-15 14:00:00","TimeZone","-05:00");
% endDate = datetime("today");
endDate = datetime("2025-11-04 07:50:00","TimeZone","-05:00");
lowMarshWTx = lowMarshWaterTable(lowMarshWaterTable.Properties.RowTimes > startDate, :);

% Define colors and line styles for plots

customColors = [0 0 0;0 0 0;0 0 0;0 0 1;0 1 1;0 0 1];
customLineStyles = ["-";"--";":";"-.";"-";"--"];
set(groot, 'defaultAxesColorOrder', customColors);
set(groot, 'defaultAxesLineStyleOrder', customLineStyles);
set(groot,'defaultAxesLineStyleCyclingMethod',"withcolor");
% set(groot, "DefaultFigureWindowStyle", "docked");
%%
%[text] ## Plot Battery and Watertable and Save Figure
% Redox and water table plots


figure;
% plot battery and water table on secondary axis
%save as template
ax = gca;
yyaxis(ax,'right');
hold on
plot(lowMarshTbl_Eh,"TIMESTAMP","BattV")
ylabel('volts(battery) meter x 10 WaterTable Sref');
ylim([11 30]);
xlim(ax,[min(lowMarshTbl_Eh.TIMESTAMP) max(lowMarshTbl_Eh.TIMESTAMP)]);
plot(lowMarshWTx.Date,lowMarshWTx.Sref*10,'b-', 'DisplayName',"Watertable")
% Plot vertial lines at water table peaks
midgrey = [0.5 0.5 0.5] ;
h = xline(lowMarshWTPeaks.Date, ':', 'Color', midgrey,'LineWidth', .5);
% Give only the first xline a name; hide the rest from legend
h(1).DisplayName = 'Watertable High Peaks';
for k = 2:numel(h)
    h(k).HandleVisibility = 'off';
end
hold off
savefig(gcf,'results\lowWatertablebat.fig');
%%
%[text] ## Clean data
% mask out the eradic battery voltages
% TODO use a function to get the mask, rowsToNaN

% Mask to NaN the redoxes most affected
lowMarshTbl_Eh.L08_05cmEhclean = lowMarshTbl_Eh.L08_05cmEh;
lowMarshTbl_Eh.L08_05cmEhclean(rowsToNaN) = NaN;
lowMarshTbl_Eh.L10_05cmEhclean = lowMarshTbl_Eh.L10_05cmEh;
lowMarshTbl_Eh.L10_05cmEhclean(rowsToNaN) = NaN;
lowMarshTbl_Eh.L12_05cmEhclean = lowMarshTbl_Eh.L12_05cmEh;
lowMarshTbl_Eh.L12_05cmEhclean(rowsToNaN) = NaN;

lowMarshTbl_Eh.L10_10cmEhclean = lowMarshTbl_Eh.L10_10cmEh;
lowMarshTbl_Eh.L10_10cmEhclean(rowsToNaN) = NaN;
lowMarshTbl_Eh.L11_10cmEhclean = lowMarshTbl_Eh.L11_10cmEh;
lowMarshTbl_Eh.L11_10cmEhclean(rowsToNaN) = NaN;
lowMarshTbl_Eh.L12_10cmEhclean = lowMarshTbl_Eh.L12_10cmEh;
lowMarshTbl_Eh.L12_10cmEhclean(rowsToNaN) = NaN;

lowMarshTbl_Eh.L07_15cmEhclean = lowMarshTbl_Eh.L07_15cmEh;
lowMarshTbl_Eh.L07_15cmEhclean(rowsToNaN) = NaN;
lowMarshTbl_Eh.L08_15cmEhclean = lowMarshTbl_Eh.L08_15cmEh;
lowMarshTbl_Eh.L08_15cmEhclean(rowsToNaN) = NaN;
lowMarshTbl_Eh.L09_15cmEhclean = lowMarshTbl_Eh.L09_15cmEh;
lowMarshTbl_Eh.L09_15cmEhclean(rowsToNaN) = NaN;
lowMarshTbl_Eh.L10_15cmEhclean = lowMarshTbl_Eh.L10_15cmEh;
lowMarshTbl_Eh.L10_15cmEhclean(rowsToNaN) = NaN;

lowMarshTbl_Eh.L11_30cmEhclean = lowMarshTbl_Eh.L11_30cmEh;
lowMarshTbl_Eh.L11_30cmEhclean(rowsToNaN) = NaN;
%%
%[text] ## Plots for each probe with watertable peaks and battery.
startDate = datetime("2025-09-29 16:00:00","TimeZone","-05:00");
%lowMarshTbl_Eh = lowMarshTbl_Eh(lowMarshTbl_Eh.Properties.RowTimes > startDate,:);
probes = (["L12","L11","L10","L09","L08","L07"]);
allVars = lowMarshTbl_Eh.Properties.VariableNames;
EhVars = allVars(contains(allVars,"Eh"));figs()
EhVars_cleaned = EhVars(contains(EhVars,"clean"));
% used cleaned varables
EhVars = EhVars(~ismember(EhVars,strrep(EhVars_cleaned,"clean","")));
figName = strcat("Low Marsh probe ",probes);
customColors = [0 1 1;0 1 0;1 0 0;0 0 0;0 1 1;0 0 1];
customLineStyles = [":";":";"-.";"-";"--"];
widths = [1.5,2.0,2.5,2.75,2.0,2.0,2.0,2.0]; % Vary the line widths
% t = tiledlayout(3, 3); 
% t.TileSpacing = 'compact';   % Reduce spacing between tiles
% t.Padding = 'compact';       % Reduce padding around the layout
% title(t, 'Low marsh redox probe layout and data - north is up'); % Overall title for the layouttitle(t, 'Low marsh redox probe layout and data - north is up')
 figs = gobjects(1,numel(probes));  % preallocate
 for f = 1:numel(probes)
     
    vars = sort(EhVars(contains(EhVars, probes(f))));
    
    figs(f) = openfig('results\lowWatertablebat.fig');
    figs(f).Name = figName(f);
    figs(f).NumberTitle = "off";
    hold on;
    ax = gca;    
    yyaxis(ax, 'left');    
    ax.YColor = [0 0 0]; 
    ax.ColorOrder = customColors;
    ax.LineStyleOrder = customLineStyles;
    ax.LineStyleCyclingMethod ="withcolor";

    hProbe= plot(lowMarshTbl_Eh, "TIMESTAMP", vars);
    for k = 1:numel(hProbe)
        hProbe(k).DisplayName = string(vars(k));
    end
    for k = 1:numel(hProbe) 
        hProbe(k).LineWidth = widths(k); 
    end
    ylabel('Eh(mV)');
    xlabel('Date Time');
    legend(hProbe, 'Location', 'best');
    ax.Toolbar.Visible = 'on';
    xlim([startDate endDate]);
    % Plot references
    % vars = allVars(contains(allVars, "reference") & ~contains(allVars,"reference07"));  
    % fig_ref = plot(lowMarshTbl_Eh, "TIMESTAMP",vars,"Color","k");
    % for k = 1:numel(fig_ref)
    %     fig_ref(k).DisplayName = string(vars(k));
    % end
    hold off;
    savefig(gcf,strcat("results\LowMarshProbe",probes(f),".fig"));
 end
%%
 % create a tiled figure
figure;
tcl = tiledlayout(3,3);
for i =2:numel(figs)
ax = figs(i).CurrentAxes;
ax.Parent = tcl;
ax.Layout.Tile = i;
end
 
% figure(f);
% vars = allVars( contains(allVars,"L07") & contains(allVars,"Eh") );
% ax = gca;
% yyaxis(ax,'left');
% h1 = plot(lowMarshTbl_Eh,"TIMESTAMP",vars)
% hold on
% ylabel('Eh(mV)')
% xlabel('Date Time')
% legend
% ax.Toolbar.Visible = 'on';
% hold off
% 
% openfig("watertablebat.fig") ;
% % Redox and water table plots
% vars = allVars( contains(allVars,"L08") & contains(allVars,"Eh") );
% ax = gca;
% yyaxis(ax,'left');
% h2 = plot(lowMarshTbl_Eh,"TIMESTAMP",vars)
% ylabel('Eh(mV)')
% xlabel('Date Time')
% legend
% ax.Toolbar.Visible = 'on';
%%
%[text] ## Plot the depths together with the "cleaned"  values

% Redox low marsh 5 cm and water table plots
openfig("watertablebat.fig");
vars = allVars(contains(allVars,"05cmEh"));
ax = gca;
yyaxis(ax,'left');
ylim([-225 -20])
h05 = plot(lowMarshTbl_Eh,"TIMESTAMP",vars);
h05(2).Color =  "[0.8 0.8 0.8]";
h05(4).Color =  "[0.8 0.8 0.8]";
h05(6).Color =  "[0.8 0.8 0.8]";
h05(7).Color = "r";
h05(8).Color = "r";
h05(9).Color = "r";
ylabel('Eh(mV)')
xlabel('Date Time')
grid off
legend
ax.Toolbar.Visible = 'on';

%plotRedox low marsh 10 cm, battery and watertable
openfig("watertablebat.fig");
hold on
vars = allVars(contains(allVars,"10cmEh"));
ax = gca;
yyaxis(ax,'left');
h10 = plot(lowMarshTbl_Eh,"TIMESTAMP",vars)
h10(4).Color = "[0.8 0.8 0.8]";
h10(5).Color = "[0.8 0.8 0.8]";
h10(6).Color = "[0.8 0.8 0.8]";
h10(7).Color = "r";
h10(8).Color = "r";
h10(9).Color = "r";
ylabel('Eh(mV)')
xlabel('Date Time')
hold off
legend
ax.Toolbar.Visible = 'on';

%plotRedox low marsh 15 cm, battery and watertable
openfig("watertablebat.fig");
hold on
vars = allVars(contains(allVars,"15cmEh"));
ax = gca;
yyaxis(ax,'left');
h15 = plot(lowMarshTbl_Eh,"TIMESTAMP",vars)
h15(1).Color = "[0.8 0.8 0.8]";
h15(2).Color = "[0.8 0.8 0.8]";
h15(3).Color = "[0.8 0.8 0.8]";
h15(7).Color = "r";
h15(8).Color = "r";
h15(9).Color = "r";
ylabel('Eh(mV)')
xlabel('Date Time')
hold off
legend
ax.Toolbar.Visible = 'on';

%plotRedox low marsh 30 cm, battery and watertable
openfig("watertablebat.fig");
hold on
vars = allVars(contains(allVars,"30cmEh"));
ax = gca;
yyaxis(ax,'left');
h30 = plot(lowMarshTbl_Eh,"TIMESTAMP",vars)
h30(5).Color = "[0.8 0.8 0.8]";
h30(7).Color = "r";
ylabel('Eh(mV)')
xlabel('Date Time')
hold off
legend
ax.Toolbar.Visible = 'on';
%%

%Plot low marsh redox 7 and high marsh redox 1
figure(1)
plot(datelowmarsh(:,1),((lowmarsh_ArrayDbl(:,3:6))-(0.718*lowmarshtemp(:,1)) + 224.41),'b');
xlim([startDate endDate]);
hold on;
plot(datehighmarsh(:,1),((highmarsh_ArrayDbl(:,3:6))-(0.718*highmarshtemp(:,1))+224.41),'g');
xlim([startDate endDate]);
legend('Low7 5cm', 'Low7 10cm', 'Low7 15cm', 'Low7 30cm', 'High1 5cm', 'High1 10cm', 'High1 15cm', 'High1 30cm');
legend('Location','eastoutside')
hold off;
ylim([-300 300]);
ax.Toolbar.Visible = 'on';

figure(2) %plot low marsh redox 7,8,9 and high marsh redox 1,2
plot(datelowmarsh(:,1),((lowmarsh_ArrayDbl(:,3:14))-(0.718*lowmarshtemp(:,1)) + 224.41),'b');
hold on;
plot(datehighmarsh(:,1),((highmarsh_ArrayDbl(:,3:10))-(0.718*highmarshtemp(:,1))+224.41),'g');
hold off;
ylim([-300 300]);
xlim([startDate endDate]);
ax.Toolbar.Visible = 'on';

figure(200) %plot low marsh redox 7,8,9 and high marsh redox 1,2
plot(datelowmarsh(:,1),((lowmarsh_ArrayDbl(:,3:14))-(0.718*lowmarshtemp(:,1)) + 224.41));
colororder([1 0 0; 0 1 0; 0 0 1; 0 0 0]);
hold on;
plot(datehighmarsh(:,1),((highmarsh_ArrayDbl(:,3:10))-(0.718*highmarshtemp(:,1))+224.41));
colororder([1 0 0; 0 1 0; 0 0 1; 0 0 0]);
hold off;
ylim([-300 300]);
xlim([startDate endDate]);
ax.Toolbar.Visible = 'on';

figure(20) %plot ref probes relative to the one being used as reference for the profiling probes
plot(datelowmarsh(:,1),lowmarsh_ArrayDbl(:,27:29),'b');
ylim([-10 10]);
xlim([startDate endDate]);
hold on;
plot(datehighmarsh(:,1),highmarsh_ArrayDbl(:,27:29),'g');
ylim([-10 10]);
xlim([startDate endDate]);
hold off;
title('ref probe comparisons');
ax.Toolbar.Visible = 'on';

figure(21) %plot  ref probes relative to the one being used as reference for the profiling probes. Leave out one noisy probe lowmarsh
plot(datelowmarsh(:,1),lowmarsh_ArrayDbl(:,[27 29 32]),'b');
ylim([-10 10]);
xlim([startDate endDate]);
hold on;
plot(datehighmarsh(:,1),highmarsh_ArrayDbl(:,[27 28 29 32]),'g');
ylim([-10 10]);
xlim([startDate endDate]);
hold off;
title('ref probe comparisons');


figure(3)%show it is probe 9 that is crazy -- this is the one that bubbled when inserted
plot(datelowmarsh(:,1),((lowmarsh_ArrayDbl(:,11:14))-(0.718*lowmarshtemp(:,1)) + 224.41),'b');
hold on;
plot(datehighmarsh(:,1),((highmarsh_ArrayDbl(:,3:10))-(0.718*highmarshtemp(:,1))+224.41),'g');
hold off;
ylim([-300 300]);
xlim([startDate endDate]);


figure(4)%show probes 7,8 are like MI already
plot(datelowmarsh(:,1),((lowmarsh_ArrayDbl(:,3:10))-(0.718*lowmarshtemp(:,1)) + 224.41),'b');
hold on;
plot(datehighmarsh(:,1),((highmarsh_ArrayDbl(:,3:10))-(0.718*highmarshtemp(:,1))+224.41),'g');
hold off;
ylim([-300 300]);
xlim([startDate endDate]);


figure(5) %plot low marsh redox 10,11,12 and high marsh redox 3,4,5,6
plot(datelowmarsh(:,1),((lowmarsh_ArrayDbl(:,15:26))-(0.718*lowmarshtemp(:,1)) + 224.41),'b');
hold on;
plot(datehighmarsh(:,1),((highmarsh_ArrayDbl(:,11:18))-(0.718*highmarshtemp(:,1))+224.41),'c');
plot(datehighmarsh(:,1),((highmarsh_ArrayDbl(:,19:26))-(0.718*highmarshtemp(:,1))+224.41),'g');
hold off;
ylim([-300 300]);
xlim([startDate endDate]);


figure(6) %plot low marsh redox 10,11,12 and high marsh redox 5,6  5 cm only
plot(datelowmarsh(:,1),((lowmarsh_ArrayDbl(:,[15 19 23]))-(0.718*lowmarshtemp(:,1)) + 224.41),'b');
hold on;
plot(datehighmarsh(:,1),((highmarsh_ArrayDbl(:,[19 23]))-(0.718*highmarshtemp(:,1))+224.41),'g');
hold off;
ylim([-300 300]);
xlim([startDate endDate]);
title('5 cm depth only, low marsh MI probes 10,11,12; high marsh MI probes 5,6');

figure(7) %plot low marsh redox 10,11,12 and high marsh redox 5,6  10 cm only
plot(datelowmarsh(:,1),((lowmarsh_ArrayDbl(:,[16 20 24]))-(0.718*lowmarshtemp(:,1)) + 224.41),'b');
hold on;
plot(datehighmarsh(:,1),((highmarsh_ArrayDbl(:,[20 24]))-(0.718*highmarshtemp(:,1))+224.41),'g');
hold off;
ylim([-300 300]);
xlim([startDate endDate]);
title('10 cm depth only, low marsh MI probes 10,11,12; high marsh MI probes 5,6');

figure(8) %plot low marsh redox 10,11,12 and high marsh redox 5,6  15 cm only
plot(datelowmarsh(:,1),((lowmarsh_ArrayDbl(:,[17 21 25]))-(0.718*lowmarshtemp(:,1)) + 224.41),'b');
hold on;
plot(datehighmarsh(:,1),((highmarsh_ArrayDbl(:,[21 25]))-(0.718*highmarshtemp(:,1))+224.41),'g');
hold off;
ylim([-300 300]);
xlim([startDate endDate]);
title('15 cm depth only, low marsh MI probes 10,11,12; high marsh MI probes 5,6');

figure(9) %plot low marsh redox 10,11,12 and high marsh redox 5,6  30 cm only
plot(datelowmarsh(:,1),((lowmarsh_ArrayDbl(:,[18 22 26]))-(0.718*lowmarshtemp(:,1)) + 224.41),'b');
hold on;
plot(datehighmarsh(:,1),((highmarsh_ArrayDbl(:,[21 26]))-(0.718*highmarshtemp(:,1))+224.41),'g');
hold off;
ylim([-300 300]);
xlim([startDate endDate]);
title('30 cm depth only, low marsh MI probes 10,11,12; high marsh MI probes 5,6');

figure(10) %plot low marsh redox 10,11,12 and high marsh redox 3.4  30 cm only
plot(datelowmarsh(:,1),((lowmarsh_ArrayDbl(:,[18 22 26]))-(0.718*lowmarshtemp(:,1)) + 224.41),'b');
hold on;
plot(datehighmarsh(:,1),((highmarsh_ArrayDbl(:,[14 18]))-(0.718*highmarshtemp(:,1))+224.41),'g');
plot(datehighmarsh(:,1),((highmarsh_ArrayDbl(:,[21 26]))-(0.718*highmarshtemp(:,1))+224.41),'m');
hold off;
ylim([-300 300]);
xlim([startDate endDate]);
title('30 cm depth only, low marsh MI probes 10,11,12 blue; high marsh MI probes 3,4 green; high marsh MI 5,6 magenta');


figure(11) %plot the six redox probes from high marsh in their locations in space
t=tiledlayout(3,2,"TileSpacing","compact") 
title(t, 'High marsh redox probe layout and data - north is up')
nexttile
plot(datehighmarsh(:,1),((highmarsh_ArrayDbl(:,23:26))-(0.718*highmarshtemp(:,1))+224.41),'g');
title('probe6');
ylim([-300 300]);
xlim([startDate endDate]);

nexttile
plot(datehighmarsh(:,1),((highmarsh_ArrayDbl(:,19:22))-(0.718*highmarshtemp(:,1))+224.41),'g');
title('probe5');
ylim([-300 300]);
xlim([startDate endDate]);

nexttile
plot(datehighmarsh(:,1),((highmarsh_ArrayDbl(:,15:18))-(0.718*highmarshtemp(:,1))+224.41),'g');
title('probe4');
ylim([-300 300]);
xlim([startDate endDate]);

nexttile
plot(datehighmarsh(:,1),((highmarsh_ArrayDbl(:,11:14))-(0.718*highmarshtemp(:,1))+224.41),'g');
title('probe3');
ylim([-300 300]);
xlim([startDate endDate]);

nexttile
plot(datehighmarsh(:,1),((highmarsh_ArrayDbl(:,7:10))-(0.718*highmarshtemp(:,1))+224.41),'g');
title('probe2');
ylim([-300 300]);
xlim([startDate endDate]);

nexttile
plot(datehighmarsh(:,1),((highmarsh_ArrayDbl(:,3:6))-(0.718*highmarshtemp(:,1))+224.41),'g');
title('probe1');
ylim([-300 300]);
xlim([startDate endDate]);



figure(12) %plot the six redox probes from low marsh in their locations in space
t=tiledlayout(2,3,"TileSpacing","compact") 
title(t, 'Low marsh redox probe layout and data - north is up')
nexttile
plot(datelowmarsh(:,1),((lowmarsh_ArrayDbl(:,23:26))-(0.718*lowmarshtemp(:,1))+224.41),'b');
title('probe12');
ylim([-300 300]);
xlim([startDate endDate]);

nexttile
plot(datelowmarsh(:,1),((lowmarsh_ArrayDbl(:,19:22))-(0.718*lowmarshtemp(:,1))+224.41),'b');
title('probe11');
ylim([-300 300]);
xlim([startDate endDate]);

nexttile
plot(datelowmarsh(:,1),((lowmarsh_ArrayDbl(:,15:18))-(0.718*lowmarshtemp(:,1))+224.41),'b');
title('probe10');
ylim([-300 300]);
xlim([startDate endDate]);

nexttile
plot(datelowmarsh(:,1),((lowmarsh_ArrayDbl(:,11:14))-(0.718*lowmarshtemp(:,1))+224.41),'b');
title('probe9');
ylim([-300 300]);
xlim([startDate endDate]);

nexttile
plot(datelowmarsh(:,1),((lowmarsh_ArrayDbl(:,7:10))-(0.718*lowmarshtemp(:,1))+224.41),'b');
title('probe8');
ylim([-300 300]);
xlim([startDate endDate]);

nexttile
plot(datelowmarsh(:,1),((lowmarsh_ArrayDbl(:,3:6))-(0.718*lowmarshtemp(:,1))+224.41),'b');
title('probe7');
ylim([-300 300]);
xlim([startDate endDate]);

%________________________________________________________

figure(1200) %plot the six redox probes from low marsh and 5 from high marsh in their locations in space
t=tiledlayout(3,5,"TileSpacing","compact") 
title(t, 'Marsh redox probe layout and data - north is up')
nexttile
plot(datelowmarsh(:,1),((lowmarsh_ArrayDbl(:,23:26))-(0.718*lowmarshtemp(:,1))+224.41),'b');
title('probe12');
ylim([-300 300]);
xlim([startDate endDate]);

nexttile
plot(datelowmarsh(:,1),((lowmarsh_ArrayDbl(:,19:22))-(0.718*lowmarshtemp(:,1))+224.41),'b');
title('probe11');
ylim([-300 300]);
xlim([startDate endDate]);

nexttile
plot(datelowmarsh(:,1),((lowmarsh_ArrayDbl(:,15:18))-(0.718*lowmarshtemp(:,1))+224.41),'b');
title('probe10');
ylim([-300 300]);
xlim([startDate endDate]);

nexttile
plot(datehighmarsh(:,1),((highmarsh_ArrayDbl(:,23:26))-(0.718*highmarshtemp(:,1))+224.41),'g');
title('probe6');
ylim([-300 300]);
xlim([startDate endDate]);

nexttile
plot(datehighmarsh(:,1),((highmarsh_ArrayDbl(:,19:22))-(0.718*highmarshtemp(:,1))+224.41),'g');
title('probe5');
ylim([-300 300]);
xlim([startDate endDate]);

nexttile

nexttile

nexttile

nexttile
plot(datehighmarsh(:,1),((highmarsh_ArrayDbl(:,15:18))-(0.718*highmarshtemp(:,1))+224.41),'g');
title('probe4');
ylim([-300 300]);
xlim([startDate endDate]);

nexttile
plot(datehighmarsh(:,1),((highmarsh_ArrayDbl(:,11:14))-(0.718*highmarshtemp(:,1))+224.41),'g');
title('probe3');
ylim([-300 300]);
xlim([startDate endDate]);

nexttile
plot(datelowmarsh(:,1),((lowmarsh_ArrayDbl(:,11:14))-(0.718*lowmarshtemp(:,1))+224.41),'b');
title('probe9');
ylim([-300 300]);
xlim([startDate endDate]);

nexttile
plot(datelowmarsh(:,1),((lowmarsh_ArrayDbl(:,7:10))-(0.718*lowmarshtemp(:,1))+224.41),'b');
title('probe8');
ylim([-300 300]);
xlim([startDate endDate]);

nexttile
plot(datelowmarsh(:,1),((lowmarsh_ArrayDbl(:,3:6))-(0.718*lowmarshtemp(:,1))+224.41),'b');
title('probe7');
ylim([-300 300]);
xlim([startDate endDate]);

nexttile
plot(datehighmarsh(:,1),((highmarsh_ArrayDbl(:,7:10))-(0.718*highmarshtemp(:,1))+224.41),'g');
title('probe2');
ylim([-300 300]);
xlim([startDate endDate]);

nexttile
plot(datehighmarsh(:,1),((highmarsh_ArrayDbl(:,3:6))-(0.718*highmarshtemp(:,1))+224.41),'g');
title('probe1');
ylim([-300 300]);
xlim([startDate endDate]);

%_________________________________________

figure(13) %plot three redox probes from closest-to-wells transect, high marsh 
t=tiledlayout(3,1,"TileSpacing","compact") 
title(t, 'High marsh redox probe layout and data - north is up')

nexttile
plot(datehighmarsh(:,1),((highmarsh_ArrayDbl(:,23:26))-(0.718*highmarshtemp(:,1))+224.41));
title('probe6');
ylim([-300 300]);
xlim([startDate endDate]);

nexttile
plot(datehighmarsh(:,1),((highmarsh_ArrayDbl(:,15:18))-(0.718*highmarshtemp(:,1))+224.41));
title('probe4');
ylim([-300 300]);
xlim([startDate endDate]);

nexttile
plot(datehighmarsh(:,1),((highmarsh_ArrayDbl(:,7:10))-(0.718*highmarshtemp(:,1))+224.41));
title('probe2');
ylim([-300 300]);
xlim([startDate endDate]);



% get mean and standard deviation onto graph
% Use multidimensional arrays to get the mean and stdev of the three probes at each depth x location (low marsh) or two probes at each depth x location(high marsh), and standard deviation at each depth 


HMPrb1=((highmarsh_ArrayDbl(:,3:6))-(0.718*highmarshtemp(:,1))+224.41);
HMPrb2=((highmarsh_ArrayDbl(:,7:10))-(0.718*highmarshtemp(:,1))+224.41);
HMPrb12=cat(3,HMPrb1,HMPrb2);
HMPrb12mean=mean(HMPrb12,3);
HMPrb12stdev=std(HMPrb12,0,3);

HMPrb12mean(:,5)=mean(HMPrb12mean(:,1:4),2);
HMPrb12stdev(:,5)=std(HMPrb12mean(:,1:4),0,2);


HMPrb3=((highmarsh_ArrayDbl(:,11:14))-(0.718*highmarshtemp(:,1))+224.41);
HMPrb4=((highmarsh_ArrayDbl(:,15:18))-(0.718*highmarshtemp(:,1))+224.41);
HMPrb34=cat(3,HMPrb3,HMPrb4);
HMPrb34mean=mean(HMPrb34,3);
HMPrb34stdev=std(HMPrb34,0,3);

HMPrb34mean(:,5)=mean(HMPrb34mean(:,1:4),2);
HMPrb34stdev(:,5)=std(HMPrb34mean(:,1:4),0,2);


HMPrb5=((highmarsh_ArrayDbl(:,19:22))-(0.718*highmarshtemp(:,1))+224.41);
HMPrb6=((highmarsh_ArrayDbl(:,23:26))-(0.718*highmarshtemp(:,1))+224.41);
HMPrb56=cat(3,HMPrb5,HMPrb6);
HMPrb56mean=mean(HMPrb56,3);
HMPrb56stdev=std(HMPrb56,0,3);

HMPrb56mean(:,5)=mean(HMPrb56mean(:,1:4),2);
HMPrb56stdev(:,5)=std(HMPrb56mean(:,1:4),0,2);

HMProfileMeans(:,1)=HMPrb12mean(:,5);
HMProfileMeans(:,2)=HMPrb34mean(:,5);
HMProfileMeans(:,3)=HMPrb56mean(:,5);

HMProfileStdevs(:,1)=HMPrb12stdev(:,5);
HMProfileStdevs(:,2)=HMPrb34stdev(:,5);
HMProfileStdevs(:,3)=HMPrb56stdev(:,5);



LMPrb7=((lowmarsh_ArrayDbl(:,3:6))-(0.718*lowmarshtemp(:,1))+224.41);
     %But we have some obvious hugh peak outliers
     %HOW TO GET RID OF OUTLIERS  y_clean = filloutliers(y_raw, 'linear', 'movmedian', 11, 'SamplePoints', t);
	LMPrb7FillOutliers=filloutliers(LMPrb7,'linear','movmedian',minutes(15),'SamplePoints', datelowmarsh);
LMPrb8=((lowmarsh_ArrayDbl(:,7:10))-(0.718*lowmarshtemp(:,1))+224.41);
LMPrb9=((lowmarsh_ArrayDbl(:,11:14))-(0.718*lowmarshtemp(:,1))+224.41);
LMPrb789=cat(4,LMPrb7FillOutliers,LMPrb8, LMPrb9);
LMPrb789mean=mean(LMPrb789,4);
LMPrb789stdev=std(LMPrb789,0,4);

LMPrb789mean(:,5)=mean(LMPrb789mean(:,1:4),2);
LMPrb789stdev(:,5)=std(LMPrb789mean(:,1:4),0,2);


LMPrb10=((lowmarsh_ArrayDbl(:,15:18))-(0.718*lowmarshtemp(:,1))+224.41);
LMPrb11=((lowmarsh_ArrayDbl(:,19:22))-(0.718*lowmarshtemp(:,1))+224.41);
LMPrb12=((lowmarsh_ArrayDbl(:,23:26))-(0.718*lowmarshtemp(:,1))+224.41);
LMPrb101112=cat(4,LMPrb10,LMPrb11, LMPrb12);
LMPrb101112mean=mean(LMPrb101112,4);
LMPrb101112stdev=std(LMPrb101112,0,4);

LMPrb101112mean(:,5)=mean(LMPrb101112mean(:,1:4),2);
LMPrb101112stdev(:,5)=std(LMPrb101112mean(:,1:4),0,2);

x_datenum=datenum(datehighmarsh(:,1));
x_datenumLM=datenum(datelowmarsh(:,1));

%colors=jet(4);  jet didn't work well. So, I defined this as 
colors=([1 0 0; 0 1 0; 0 0 1; 0 0 0]);



figure(14) %%THIS WORKS!!!!
hold on;
for i=1:4
h=shadedErrorBar(x_datenum(:,1), HMPrb12mean(:,i), HMPrb12stdev(:,i), 'lineprops',{'Color', colors(i,:)} , 'patchSaturation', 0.05);
set(h.patch, 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'LineStyle','none');
if isfield(h,'edge') && all(ishandle(h.edge))
    set(h.edge, 'Visible','off');
end
datetick('x', 'mmm-dd-YYYY', 'keeplimits'); 
end
xlabel('Time');
ylabel('Eh (mV)');
ylim([-300 300])
title('Mean ± 1 Std Dev, High Marsh CB, Probes 1&2');
grid on;
legend({'5cm','10cm','15cm','30cm'});
hold off;

figure(15) %%THIS WORKS!!!!
hold on;
for i=1:4
h=shadedErrorBar(x_datenum(:,1), HMPrb34mean(:,i), HMPrb34stdev(:,i), 'lineprops',{'Color', colors(i,:)} , 'patchSaturation', 0.05);
set(h.patch, 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'LineStyle','none');
if isfield(h,'edge') && all(ishandle(h.edge))
    set(h.edge, 'Visible','off');
end
datetick('x', 'mmm-dd-YYYY', 'keeplimits'); 
end;
xlabel('Time');
ylabel('Eh (mV)');
ylim([-300 300])
title('Mean ± 1 Std Dev, High Marsh 5m into MI, Probes 3&4');
grid on;
legend({'5cm','10cm','15cm','30cm'});
hold off;


figure(16) %%THIS WORKS!!!!
hold on;
for i=1:4
h=shadedErrorBar(x_datenum(:,1), HMPrb56mean(:,i), HMPrb56stdev(:,i), 'lineprops',{'Color', colors(i,:)} , 'patchSaturation', 0.05);
set(h.patch, 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'LineStyle','none');
if isfield(h,'edge') && all(ishandle(h.edge))
    set(h.edge, 'Visible','off');
end
datetick('x', 'mmm-dd-YYYY', 'keeplimits'); 
end;
xlabel('Time');
ylabel('Eh (mV)');
ylim([-300 300])
title('Mean ± 1 Std Dev, High Marsh 9m into MI, Probes 5&6');
grid on;
legend({'5cm','10cm','15cm','30cm'});
hold off;


figure(160) %%THIS WORKs BUT IS NOT AT ALL HELPFUL!
hold on;
for i=1:3
h=shadedErrorBar(x_datenum(:,1), HMProfileMeans(:,i), HMProfileStdevs(:,i), 'lineprops',{'Color', colors(i,:)} , 'patchSaturation', 0.05);
set(h.patch, 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'LineStyle','none');
if isfield(h,'edge') && all(ishandle(h.edge))
    set(h.edge, 'Visible','off');
end
datetick('x', 'mmm-dd-YYYY', 'keeplimits'); 
end;
xlabel('Time');
ylabel('Eh (mV)');
ylim([-300 300])
title('High marsh 9mMI 5mMI CB probes');
grid on;
legend({'CB','5','9m'});
hold off;


figure(17) %%THIS WORKS!!!!
hold on;
for i=1:4
h=shadedErrorBar(x_datenumLM(:,1), LMPrb789mean(:,i), LMPrb789stdev(:,i), 'lineprops',{'Color', colors(i,:)} , 'patchSaturation', 0.05);
set(h.patch, 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'LineStyle','none');
if isfield(h,'edge') && all(ishandle(h.edge))
    set(h.edge, 'Visible','off');
end
datetick('x', 'mmm-dd-YYYY', 'keeplimits'); 
end;
xlabel('Time');
ylabel('Eh (mV)');
ylim([-300 300])
title('Mean ± 1 Std Dev, Low Marsh CB Probes7,8,9');
grid on;
legend({'5cm','10cm','15cm','30cm'});
hold off;


figure(18) %%THIS WORKS!!!!
hold on;
for i=1:4
h=shadedErrorBar(x_datenumLM(:,1), LMPrb101112mean(:,i), LMPrb101112stdev(:,i), 'lineprops',{'Color', colors(i,:)} , 'patchSaturation', 0.05);
set(h.patch, 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'LineStyle','none');
if isfield(h,'edge') && all(ishandle(h.edge))
    set(h.edge, 'Visible','off');
end
datetick('x', 'mmm-dd-YYYY', 'keeplimits'); 
end;
xlabel('Time');
ylabel('Eh (mV)');
ylim([-300 300])
title('Mean ± 1 Std Dev, Low Marsh 9m into MI, Probes 10,11,12');
grid on;
legend({'5cm','10cm','15cm','30cm'});
hold off;



%%((((((((((((((((((((((((((((((((((((((((((
figure(300) %plot low and high marsh probe means and stdevs, day by day, from CB to MI. This is the graph I used in the presentation.

t=tiledlayout(3,2,"TileSpacing","compact") 
title(t, 'Marsh redox probe layout and data - north is up')

nexttile
hold on;
for i=1:4
h=shadedErrorBar(x_datenumLM(:,1), LMPrb101112mean(:,i), LMPrb101112stdev(:,i), 'lineprops',{'Color', colors(i,:)} , 'patchSaturation', 0.05);
set(h.patch, 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'LineStyle','none');
if isfield(h,'edge') && all(ishandle(h.edge))
    set(h.edge, 'Visible','off');
end;
xlim([datenum('2025-08-14 14:00:00') datenum('2025-10-13 13:00:00')]);
datetick('x', 'mmm-dd-YYYY', 'keeplimits'); 
end;
xlabel('Time');
ylabel('Eh (mV)');
ylim([-300 300])
title('Low Marsh 9m into MI');
grid on;
%legend({'5cm','10cm','15cm','30cm'});
hold off;

nexttile
hold on;
for i=1:4
h=shadedErrorBar(x_datenum(:,1), HMPrb56mean(:,i), HMPrb56stdev(:,i), 'lineprops',{'Color', colors(i,:)} , 'patchSaturation', 0.05);
set(h.patch, 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'LineStyle','none');
if isfield(h,'edge') && all(ishandle(h.edge))
    set(h.edge, 'Visible','off');
end;
xlim([datenum('2025-08-14 14:00:00') datenum('2025-10-13 13:00:00')]);
datetick('x', 'mmm-dd-YYYY', 'keeplimits'); 
end;
xlabel('Time');
ylabel('Eh (mV)');
ylim([-300 300])
title('High Marsh 9m into MI');
grid on;
legend({'5cm','10cm','15cm','30cm'});
legend('Location', 'eastoutside');
hold off;

nexttile

nexttile
hold on;
for i=1:4
h=shadedErrorBar(x_datenum(:,1), HMPrb34mean(:,i), HMPrb34stdev(:,i), 'lineprops',{'Color', colors(i,:)} , 'patchSaturation', 0.05);
set(h.patch, 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'LineStyle','none');
if isfield(h,'edge') && all(ishandle(h.edge))
    set(h.edge, 'Visible','off');
end;
xlim([datenum('2025-08-14 14:00:00') datenum('2025-10-13 13:00:00')]);
datetick('x', 'mmm-dd-YYYY', 'keeplimits'); 
end;
xlabel('Time');
ylabel('Eh (mV)');
ylim([-300 300])
title('High Marsh 5m into MI');
grid on;
legend({'5cm','10cm','15cm','30cm'},'Location','eastoutside');
hold off;

nexttile
hold on;
for i=1:4
h=shadedErrorBar(x_datenumLM(:,1), LMPrb789mean(:,i), LMPrb789stdev(:,i), 'lineprops',{'Color', colors(i,:)} , 'patchSaturation', 0.05);
set(h.patch, 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'LineStyle','none');
if isfield(h,'edge') && all(ishandle(h.edge))
    set(h.edge, 'Visible','off');
end;
xlim([datenum('2025-08-14 14:00:00') datenum('2025-10-13 13:00:00')]);
datetick('x', 'mmm-dd-YYYY', 'keeplimits'); 
end;
xlabel('Time');
ylabel('Eh (mV)');
ylim([-300 300])
title('Low Marsh CB');
grid on;
%legend({'5cm','10cm','15cm','30cm'});
hold off;

nexttile
hold on;
for i=1:4
h=shadedErrorBar(x_datenum(:,1), HMPrb12mean(:,i), HMPrb12stdev(:,i), 'lineprops',{'Color', colors(i,:)} , 'patchSaturation', 0.05);
set(h.patch, 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'LineStyle','none');
if isfield(h,'edge') && all(ishandle(h.edge))
    set(h.edge, 'Visible','off');
end;
xlim([datenum('2025-08-14 14:00:00') datenum('2025-10-13 13:00:00')]);
datetick('x', 'mmm-dd-YYYY', 'keeplimits'); 
end;
xlabel('Time');
ylabel('Eh (mV)');
ylim([-300 300])
title('High Marsh CB');
grid on;
legend({'5cm','10cm','15cm','30cm'});
legend('Location', 'eastoutside');
hold off;

%%%(((((((((((((((((((((((((((((((((((((((((((((((

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":29.2}
%---
