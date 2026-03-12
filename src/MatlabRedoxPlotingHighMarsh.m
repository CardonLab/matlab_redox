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
startDate = datetime('2025-08-14 14:00:00');
startDate.TimeZone = "-05:00";
% endDate = datetime("today");
endDate = datetime("2025-11-04 09:20:00");
endDate.TimeZone = "-05:00";
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
savefig(gcf,'highMarshwatertablebat.fig');
%[text] ## 
%%
%[text] ## Plot each probe's depths together

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

% Test of recreating the water table graph for each figure
probes = (["H06","H05","H04","H03","H02","H01"]);
allVars = highMarshTbl_Eh.Properties.VariableNames;
figName = strcat("High Marsh probe ",probes);
customColors = [0 1 1;0 1 0;1 0 0;0 0 0;0 1 1;0 0 1];
customLineStyles = [":";":";"-.";"-";"--"];
 for f = 1:numel(probes)      %[output:group:5e2028c9]
    figure(NumberTitle="off"); %[output:5b5f4454] %[output:24771cc8] %[output:8e5584f7] %[output:645e8c43] %[output:41634218] %[output:92853225]
    vars = allVars(contains(allVars, probes(f)) & contains(allVars, "Eh"));   
    fig = gcf;
    fig.Name = figName(f); %[output:5b5f4454] %[output:24771cc8] %[output:8e5584f7] %[output:645e8c43] %[output:41634218] %[output:92853225]
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

    % Plot watertable on right axis    
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
    
    legend(hProbe, 'Location',"northeast");
    ax.Toolbar.Visible = 'on';
    
    hold off;
 end %[output:group:5e2028c9]
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
%   data: {"layout":"onright","rightPanelPercent":14.5}
%---
%[output:5b5f4454]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAH8AAABMCAYAAABEU2gQAAAAAXNSR0IArs4c6QAADclJREFUeF7tXWloVdcWXjc+FHlPnlacfQ6FqlAnVFAcMBEHBLVSEOfZ4g9FcLYOjfM8oKgotrSpA4ooioh1VlTUHy0VHzwnNIoaUSsWSoymyX18O66Tdfc9wz45J7k35pw\/yb1nj+tba+2111p731g8Ho9T9FR6CqxYsYK+++67hHlMnTqVtmzZQjVr1rSdXywCv9LjTn\/88QeNHj1aTWT\/\/v1Ut25do0lF4BuR6dMspMA\/dOgQffvtt7RmzRoaPny40UyD1EEHHTp0oB9++IE+++wz1d+NGzdo1KhR6v\/GjRvTjz\/+SF988YXRWPwWun\/\/Pk2cOJE6d+5Ma9eudVSLsl2u8\/z586TuoF7nz5\/vdxhJ5detW0e7d++mAwcOULdu3QK3hwac2nzz5g2lDHwMTE6Smakygo8xh8EAKQG\/LCwWRPJ79epFV65csTTNu3fvaMGCBXTixIm0l3xdW7DG0jVZWWiaEvB1IGE0TJ48WalfPG\/fvqX8\/Hz1GcDl5OSQrIMyWDa8JIDrQL1funTJUrtPnz5VapjVPFQsq325HDBBWWNI9V2rVi2lSQYPHqxU+bZt25QK5Ye\/h+Ur602aNImmTZtGUOduADotFVCfoNWrV6\/UmH\/77TdFi1mzZtH58+fp1q1bFpPrS4feH4O\/fft22rNnj6qLRy7HuqB4MZ2x2q9fvz7dvHmTli9friYiH5ZW\/P3555+pTZs29P79e8UMkGL5ONkODP6SJUvo999\/pydPnqh1\/969e2q95+9\/\/fVXq38whb7O8oRh5ervoX7xSOB5bKyaGYR69eop0GT7kkns1nwvyT979qwlCJJZ8T\/bNLJdad8wUHZaA4yNeUsNyeWYHti1w+o\/ffq01USdOnWodu3atopIrfkAYNWqVbRo0SLFxTwIJpbkNv6O60jOY3Cd1j+pLXJzcy3j5vLly+r\/77\/\/no4fP04Mvm7w6VKGGTH40n7wUp9SAnUtAoaQhihTzc3gkxqP5yjpYkc\/1NHpzJ8lA3J7+O7rr79W87V7\/9VXX9HFixeVRm7durUFthtDJRl8Q4YMUdylA8Dql4G1A1ovo7ObBL958+YJ0g4tAHW3fv36pL4ZdFaDLC0Mvg6Y21KBOlLyGWjuA+\/9gi81nR1dnNrWxwFVr1v7sgxAX7lypa0UQ8Kx1PXo0SPhvRSEoqIigjMIy3osFku29v2CLyfuB\/xOnTolqGxMLDs7m5YtW2aBz+CyqoUEyfVVf697snQmYIlhG0OqcFPwvbaHdoZwWoPPKvzly5dqv1q9enXFgW5q326SfsBnJmMLH0ykM97Ro0fVOJjBWAoAOtskJvt1p+WiosAvT7XPYg5p3rBhg6PahwbA0j537lxlFyTt87t3765UQo0aNSxLnxtnw05X+2WVfDiT5HokDRpecthy1vWcrvYliLo1LOumSvIxBrulCN+HYfChHdAPNpKTwdekSRM6duyY5fp1dPLAih46dCg9e\/ZM0a5du3bKgoW1Gib4+h4ZalvaG02bNk2wbsFoeNgbyUuHnSrWDR1pgNlt28pT7TsZjaZbPWnM2jG3m0fQc6unS5a0OrHGjhs3Tm3LsGUYNmyYklivB4OcOXOm2gpy0AF1ZPTp6tWrCQYKtM6YMWNU0\/v27Uuo59VfZX0v54w5VCRNbAM7TioKg9PVhxPReVISxGvXrlnW5p07d6z\/EYW6e\/cuzZgxQ1msePh\/uW2prAA7jVvSAzTAZziceLtW3jRxjOpJXzsPHs4QeK307YQ+OSwb06dPV0YFtAZLPqQeD5w5rBnGjh2r2gOzwFnE8WeU\/fzzz6uE9DP9ODQL+lQETWzBZ2DYS+aVFKCDD+AQlTpy5Iil9vVlQP8sGYOXB2aUT03ineajg29KE64nPXtOfQwYMMCK+SeAr2eD6OuPCQhQVdg6YssIjyGv+bqkM8As3bqkQxM8fPhQaYmq8mDOe\/futcDxSxO9vhfdFPiSc\/xKuewAAMNRAyOxWbNmCQZfUPDhDkZAafz48dSiRQuveaXle7c5YL3v2bNngsHnF3wWKOzS3NK3mDgW+GCAVq1aqe8hvdiHsztVUlKqDZ3CmMCFCxcS1nRd8p0+e6k4RAGzMrNUl3GqnGmHag5ZWcoHn5mZaZHPDni7pU+nUVAOT1rzWUJh1ftVuXZJhBggooRoS3KyncEn1bzO9SBcv6ye9DdVo2rVYgnzLi4myshIJAW+wyO\/dyrnVpfr+Kmrt1dURFStGkZTTEVF1RLA1y18OQt96QvbCE4CXzc6\/HKXZABsX+C0mTNnjmoGE50wYQI9ePBAfe7atSudPHlSeZ2gbeBDuH37tnoHx9Lhw4etCBXAz8wqkfxl8aWUTdl+h5by8rrks4bdsWOH7Q6qwrd6dmuzKdXkdg11Bg0aRK9fv1ZLAe9jwwA\/Fq+cql8HX3fwMJ2lb6Q8HV+2Wz3d+WAKvl5Oci6cNUH2+VLy\/\/UX0V\/\/jNOlS0Q5OUTZ2UQVYQPm5pbMsKx9Oa35ZaVv0Hq24JfV4HMD38n6ZwPQxOBjtf\/lf4lOfvmIcpa1oKVLiR49KjsgfggI8Fu2JLp4sbSWsNs8m0o78K9fv55gOn\/48EElVbRv35769u3rOSG3AtizIk0K3j48aLd\/\/\/7Utm1b9RnvGzVqpPqR\/+PduXPnKC8vj+ABxPP48WOaPOE\/VEwZFMuIq2QEGFJ4YjFzgw\/lTYxALqcbfGy8cd8lhlzpg\/LFxU3p77+bWl+6GXyBCGxTGcs28i1NDm7EWrZsWTn3TWFTLcT23r\/vSm\/ebKDCwhIGMAEf2nbp0qVKQBg43dOKtnjn5DRcNtghNDKgxuWRLYR0MPQR0yU\/RBpUyaaQALt161bbgxdOap+X2YYNGyYct+IYCZjCT4CL\/QbSYWfXR3RcK2QW5YiobYwdeXMEm6HUycPWPCQaoMmzdnbawHS4rAFevHhBDRo0oDNnziRpjQh8U2oalrPAz8ujbgUFSbV08JHCDqlG1hInV7LaD7rrkoa7XX5EYPCdUoNlTt7IkSNDO3tmiEHKijH4r\/L20ruCriVrPrySVEQZFKdCqp7k3kUZO6B1P4Cba12fMDvboFH69Omj4gZ63CYU8NGx3UFFTjmqiuAfMJR8Bs0OfAAogzT6ZzsOl+pe5vDbHeNW4DslUnbs2FGFZ5HEAUnmgxYy94xTutzA19sxPQmcMvEN0LGVwZzXmuYX\/OKp9t3A1yvrTjMn8JH1\/M0339jOIsHaP3jwYBygAjwkNq5evVodDMDhCTw494boHpI3pSpHpi9n4HpJvmwHfv7yPH4dALdQqjL4NfLW0P8KRqg2Y\/E4va1dm\/79559JBp9f8PXtYJBBx2bMmBHX1TKrawaYmWLTpk3qPD2kHTF1Pf2aB8LpyJx9y+0grWv27Nm0cOHCcjt7H4QYYdRl8PPyDlBB4ccz9nBGwdL7BxEVxozWfKfMp7JEW53mFRs6dGgcUi8vA9DXai\/wvSSfmauqgV\/4EXz2BmZkxKm4OMMIfNA0aDqdFzO7Sj6DFoHvRcbS91LyFyzoRs2blwSfEIRCQCg3117yzXtwL+knKhtbu3atcu\/ymj9v3jzlDMCJ2Qh8\/5BI8EeMaEg\/\/VSaclYR4PvJx4jl5+fH5ZlveWzKFHyns\/DIvUfbVVXtFygnT2m6Vgkrla\/kowc9Dd5xzY+uYvMv3W41Egy+ArtLlcoXfK80bsfU7XDJUDVb8wI\/MzNLbXXTIQM5sIevakLsPGsGHz4RBFT0B6CnA\/Af\/Q\/R9athMrBrVC\/MjkJoK5L8EIgom0gX8GVQCCev4MWVZyEjyQ8ZeDSXDuBzAGjx4sU0ZcoUdWYCdxngyLz0EEaSHzIDpBp8uc\/HdXlI5eJTv3rkMDD4UTw\/kXsYfFzuiHvx\/J56CsqLFQ4+ewj1gVfleH6qwJdOHqn2WQvIxM4onh9U1LT6qZZ8Hg4nccrh6alcsSieHy76TuDLfDokw3CWjb4OO91lFO4oS1qL4vkhU9UOfLvrVvgSBnQvjTKTbB23IbsFdpIMviieHy76duDrRHe7fiXojSS+wHfL5DGN6pkafFUpmUMafHqUTQdI5ufv3LlTZdt6XXqls6zTiV+9nDzxE8XzwxV8y8nTu3dvdZsYtnpeks\/r\/MCBA+nUqVPqmlSTs3Z2Q4\/i+SED6qe50qhenspVBPhuaz6DbHdvoZ9+y1I2sJOnLJ1+ynUYfCSv9uvXz3LyOFn7TIughp7bMhD59iuI41Lt3sU0I99+BYGtd5Nq8CvUvZsiGqdttxH4aQtN+Q8s1eBjhry1NPLtlz9Jqk4P6QA+qG3k24+yd8NlzHQB32RWgbd6UTw\/kczpAL7pbWqhgG\/q3jXhxspeJtXg+7k+N4rnh8xt0sOHI29dunSxLrGWoVx0q0uo101bJkP15d6N4vkmJDUvw+DDtYsLEuRVKPJmDdzBI39SxY\/Euo3G10HN6Hy+ObAmJRn8Xbt20ebNm63kSbkFw134GzduTPoZmbBcvKYXOUXn800Q9VHGBHyc5sHPw9kdcNWXBh9dW0WNDb4onl8W8jrXMQEfkT78GonTLZlBRuQnDSyK5wehtE1dE\/BZ8sO8YoWH4svgi87nh4u+CfhY82Hw6b+p4\/cHkuxG7svgizx8qQEfPx2ru2D9XLLoNmrTa1sDO3nCJV3lby3VTp7ocoYU8lCqwfcz9Ujy\/VDLoGxlAv\/\/lo5487QoS\/kAAAAASUVORK5CYII=","height":61,"width":101}}
%---
%[output:24771cc8]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAH8AAABMCAYAAABEU2gQAAAAAXNSR0IArs4c6QAADcBJREFUeF7tXVlsTd0XX7cV4sELwfeZZxKCGPLvZ2yFIMaIxKzGeCAV8zxPNcUQhCAqaIghxEPNJeYHgifzV4KK+an6yb+9\/++3a92uu3vG3nN7b\/89Rxr3nnP2tH5rrb32WmvvGwgGg0Hyr3JPgTVr1tDy5cvDxjFt2jTatm0bVa1a1XB8AR\/8co87ff36lcaMGaMGcuzYMapRo4ajQfngOyLT\/+dLgcaNGwehHhYsWEAnTpygRYsW0YYNG2jEiBGORhxJGTTQrl07OnjwIFWvXl21d+\/ePRo9erT6XKdOHTp06BA1b97cUV\/cvvTixQuaOHEidezYkdLT003Vo6yXy3z48KFEc0xHt\/3Q39+4cSPt27ePMjMzKSkpKdLqVHmjOmMOPjomB8nMVB7BR5+9YICYgF8aFotE8rt37043b94MaZqfP3\/SwoUL6fz583Ev+bq2YI2la7LS0DQm4DOQQ4YMoe3bt6t+V6lSRalfXD9+\/KBZs2YpVWw0VeAdTBt2EsDtQL1fv349pHbfvXun1DCreahYVvtyOmCCssaQ6rtatWpKkwwaNEip8p07dyoVyhffhwUsy02aNImmT59OUOdWAJpNFd++faPJkyfT58+fVZ8fPnyoaDF79my6evUqPX78OMTk+tSht8fg79q1i\/bv36\/K4pLTsS4odkxnqfanTJlCAwYMoE+fPhHAxxLBiOBNmzalV69eUeXKlencuXP06NEjNUiWYsnpZrYDg79s2TJV\/u3bt2ref\/78uZrv+f6DBw8UIXGBKfR5lgcMa1d\/DubEJYHnvjHjMgg1a9ZUoMn6JZMYzfl2kn\/58uWQIEhmxWe2aWS90r5hoIy0Bhgb45Yakt9r3bo1gSnAbPrVoUMH+v79e9htNeePHz+ePn78SJ07d6Z169aFOIw7wcSS3MZlUlJS1CAl5zG4ZvOfnCpycnJCxs2NGzfU5wMHDijGYvB1g0+XMskc0n6wU59SAnUtAoaQhihTzcrgkxqPxyjpIuknaaPTmb9LBuT6cG\/YsGGK2eVzaGTQbObMmepPv2DQnzx5siT4Rip88ODBirt0AFgb6GXkYPR39I5I8Bs2bBgm7dACUHebNm0q0TaDzmqQpYXB1wGzmipQRko+A81t4Llb8KWmMxIAs7r1fkDV69a+fAegr1271kgxmBqczFB169als2fPKl+AqbXvFnw5cDfgQx1JlY2BrVixglatWhUCn8FlVQsJkvOr\/lz3aOlMwBLDNoZU4U7Bt1seGhnCcQk+VDgIdOvWLapVq5YjtW\/lG3ADPjMZW\/hgIp3xzpw5oySBGYylAKBLm8AOELPpoqzAj6bah2dv8+bNylfTsmVLU7UPQYNNhStM8seOHUt37txRRl+zZs1oyZIlyvkjLzbsvAIfziRp4EiDhqcctpz1EelqX4KoW8OybKwkH30wmopw3wuDD\/VArUOIzQw+aRMZqn2ADuPg4sWLYUs9AN6zZ081R3sJvr5GhtqW9ka9evXCrFtoAFzsjeSpw0jydctZGmBGy7Zoqn0zo9HpUk8CZ8TcVh5Bw6WeVWCHC1SqVIlevnxJbdu2pb59+yrG8MKTZWixVLCbUNfQuHxBart27Rr6Lp8fPXo0FMDxgkyWgR0zFYWGvfQ7ezGQ8ljH7du3CaFYjsThOxxNPG8\/e\/aM0tLSlKMKF382mtNLM37bqN6OHTsIf\/LygS8Nqe3LcGgWBhmkH0wB9zfH5MEoTZo08Uz6DcHHfAKnAXvH7JIC7IdFyvOEOmEwcuwZ5WQSQlmqPCd9Lut3dPBBG1xsnevfuX9cDjaa3YVpmzVNGPh6NogOhl3FVs957pLzllR7T58+DVOB0VZ5kYwlWmVBoyNHjoTA0SUdz1+\/fh1iBr0fenm7firwJed4IeV6o6h\/xowZBEsaPgWWfMnJrBnGjRvnSOXBLXz48GFKTU2lRo0a2Y0zLp5b9RmC0K1bN7VMY4PPLfisSd+\/f2+ZvsXECIEPgFq0aKHuQ+qw\/mY3qqScVBtOKYpBICnh9OnTIbWvTwP6dzuVh2hgSnIKJVMyZVO2067E9D3V55QUys7OpuTk5FBfjIBnIJ2o\/dIOqsSczyDAWcBzTWkrZ0aCjxzOIvgPeM7XJZ0HywaNHdcrQvbpRlSQSIkJASosJEpIINP\/CwqIEhPNn5uVR7lAoIgCRvXjvl3beF50BSkYTAgDX7fwJa11NR91g083OiIBHgDDTw8\/fIMGDcIMPk\/AT05R3fub\/qZGFP+qX5d81rC7d+8OW9szzaNt95hKPs+9kYAPrr527ZrSIHZqvrRqvzyDrzt4mNbSKC5zJ4\/ufCgtAxjlkqOu1atXK4bA8ydPntCpU6dUE0gimTdvXsjgQ+iRnw0fPpyGDh0aMhZ5zv+tTFX5jIyink6YUNoeOyuXk0NUGhvTbM531qr3bxmu870y+KSTAl0fOHAgffnyRWkDxJP37t2rmADBJGSf8Gckb1y4cEG5PSEFuPhzv3791HcJfiql0sqcDJo4sYhA2VG2\/xo3LmKwnj2L2hO2myVCcQf+3bt3w3bs\/Pr1SyVTwI\/fu3dvz9gN9SKn7s2bN7Ry5UqqX7++WtMijQtRO1xY4owcOZLatGlDV65coaysrNAzBJSwFOI+oZ4Jk+sTFSYQJRRSoDCBeO+RE8POzpCTRhwTgQ0+bgeGID7jf2kM\/vpVjwoL8Vd8v6iOkgafZwT+XRGmz7y8PEcbN1RUz+sOVPT68vP\/Q9+\/b6Z\/\/qkXYgo78KFtIRQQPN5xo3taUQdPmWY0ZoMdNpv0pPL7yBJCGpjK5NElv6IDF+n479+\/r2IhuRuqUP6Ip2HVZV\/PNlzn8zT7xx9\/hG23YucYmMJNMIf9BtJhZ9SGbWAnUmJUtPIcCTUCX9EiAJuk2MnD1jwkGqDJvXZG2sApPVkDIDG3du3adOnSpRJawwffKTUdvucWfNg8kGrYPTK8i+YiXXVJw90oFyBi8M1yzGUu3qhRozzbc+YQg5i9FgL\/01HKz\/uLKKGAqDDxd3+CRMHEEu5dM6B1P4Ab1zovs6FRevXqpYxlPW7jCfjovJ7rh3ucalQRwW\/ZMpMuZP2lQM+lXPqT\/ixiAE3tM5caSTkAlEEa\/bsRh0t1L5M5jbZxK\/DNEijbt2+vctexkwWSzBssZM4ZytqBr9fjdAdwzMQ3goZDkp+bSVlZSWE+gACQdwG+3g3p7jUzAAEysp2nTp1qOIowa\/\/48eNBgArJRULj+vXr1YYAbJrAhbU5ontI2pSqvEuXLiry5wR8Wc\/cuXOjuu06Atw8KSrBX7gwiVasKK7WysnjZH6PxAA0GlwgLS0tqKtlVtcMMDPF1q1b1T56AI4Yup52zQ1wGjJn3XI9iOfPmTOHFi9eHLU9954gGEElEnys9xOpgAqpEsGZEqBCCpKzOd8sFuJVtFXNQEOHDg1C6uUhAPpcbQe+ndpn5qp44CdRIv2XCggGH5R+kIIUHtK1mvOjkU4n+dpS8hk0H3znqiBc8pMom1LoMKVSBnG0KWBo7TtvwfpNo1C5WYlAenq6cu\/ynD9\/\/nzlDMBOWR9895Do4CfT9X\/\/FWftQAPomTzuWzEv4SYfI5CXlxeUe73ldimn4JvtgUeeOequyGqfKOffYLNMNIku+GALPeXbVPL9o9i8lLvivXi5uZmUn290mFJ0wbdL4zZN3faWDBWzNl3t61RITk5RS914yDiO2MNXMSE2HzWDD58IAir6BdDjAXi11PPVvrfsy+CXhy1tPvjeYh\/afx9r8GVQCBtB4MWV+\/58yfcYeFQXD5LPAaClS5cSTllDbiTOMMBeSekh9CXfYwaINfhynd+qVSuVysW7fvX4QcTg+\/H8cO5h8HGoI06z92LXkxv+LHPwnfr23QyivL4ba\/Clk0eqfdYCMrHTj+d7zGXxAD6GxEmccnh6KlfAj+d7i74Z+DKfDskwnGWjz8Nmh1h428ui2vx4vsdUNQLf6LgVPoQBzUujzEm2jlWXrQI7JQw+P57vLfpG4OtEtzp+xe70DbveugLfKpPHaVTPqcFXkZI5pLWvR9l0gGR61p49e1S2rTyOzQ5wNvLkkW5mZeSOHz+e74SyLt5hycfeQhw0gaWeneTzPN+\/f3+1PxEnnzv9kSS9a3483wVYXr9aHNXLVbmKAN9qzmeQjQ6s8rpven0RO3mi3cHyVj+Dj+TVPn36hJw8ZtY+jy9SQ0+nk+\/bjwHnxNq9iyH7vv0YAI8mYw1+mbp3Y0TjuG3WBz9uoYl+x2INPi\/7ELt35NuPPkkqTgvxAD6o7ci376dxecuY8QK+k1FFvNTz4\/nhZI4H8J2epuYJ+E7du064sby\/E2vw3Ryf68fzPeY2Br9Tp06hHzFEHB3f+TBrGdJF87qk2p24ZdVlV+5dP57vLfoMPly7SJ40OhlLnrCBs3jkT6u4kVyjnrvaqOnvz48O+BkZGdSjR48Sfn25FMPPp2zZsqXET6dE6up1ctAD+uHvz\/cW+xIePiM1zCFe7OrBz8MZbXTVpwY33XRs8PnxfDdktX9XN\/iswEfED8fRm52Wad9ayTfcpIH58fzSUNiijBvwWfK9PGrFlcHn78\/3Fn034GPOh8Gn\/7aO2x9KkiNwZfD5Hr7Ygo+fjtVdsW4OWzTqvdNTuyJ28nhLuvJfW6ydPP7hDDHkoViD72bovuS7oZaDd8sT+P8DGRs82WwmKVMAAAAASUVORK5CYII=","height":61,"width":101}}
%---
%[output:8e5584f7]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAH8AAABMCAYAAABEU2gQAAAAAXNSR0IArs4c6QAADZ9JREFUeF7tXXmMTFsTr0Ysf8hLiEfw2bdEgljyxDqEiF2EiH1s8QcZMcS+jHXGFksQgiCYEEsIiSAMsUsIkid2Q2whlvhjePLRn9+ZV6369L19z+2+Pd3zzT2JmO57z1a\/qjp1quqcDgSDwSD5pdhTYMmSJbRgwYKweUycOJHWrl1LFSpUsJxfwAe\/2ONOHz58oOHDh6uJ7Nu3jypXrmw0KR98IzL9f74UqFu3bhDqYebMmXTgwAGaPXs2ZWdn05AhQ4xmHE8ddNC8eXPasWMHVapUSfV37do1GjZsmPq7evXqtHPnTmrYsKHRWNy+9OjRIxozZgy1atWKcnJybNWjbJfrvH79OqI7pqPbcejvr1ixgrZu3Uq5ubnUtm3beJtT9a3aTDr4GJicJDNTcQQfY\/aCAZICfiwsFo\/kd+zYkS5evBjSNF+\/fqVZs2bR8ePHU17ydW3BGkvXZLHQNCngM5D9+\/endevWqXGXK1dOqV+Uz58\/09SpU5Uqtloq8A6WDScJ4H6g3s+fPx9Suy9fvlRqmNU8VCyrfbkcMEFZY0j1XbFiRaVJ+vbtq1T5hg0blArlwt\/DApb1xo4dS5MmTSKo82gA2i0VHz9+pHHjxtH79+\/VmG\/duqVokZmZSWfPnqU7d+6EmFxfOvT+GPyNGzfStm3bVF0UuRzrguLEdFHV\/vjx46l379707t07AvjYIlgRvH79+vTkyRMqW7YsHTt2jG7fvq0myVIsOd3OdmDw58+fr+q\/ePFCrfsPHz5U6z1\/f\/PmTUVIFDCFvs7yhGHt6s\/BnCgSeB4bMy6DUKVKFQWabF8yidWa7yT5Z86cCQmCZFb8zTaNbFfaNwyUldYAY2PeUkPye02bNiUwBZhNLy1btqRPnz6Ffa3W\/FGjRtHbt2+pTZs2tGzZshCH8SCYWJLbuE6XLl3UJCXnMbh2659cKvLz80PGzYULF9Tf27dvV4zF4OsGny5lkjmk\/eCkPqUE6loEDCENUaZaNINPajyeo6SLpJ+kjU5n\/iwZkNvDdwMHDlTMLp9DI4NmU6ZMUf\/0AoP+4MGDkeBbqfB+\/fop7tIBYG2g15GT0d\/RByLBr127dpi0QwtA3a1cuTKibwad1SBLC4OvAxZtqUAdKfkMNPeB527Bl5rOSgDs2tbHAVWvW\/vyHYC+dOlSK8Vga3AyQ9WoUYOOHj2qfAG21r5b8OXE3YAPdSRVNia2cOFCWrRoUQh8BpdVLSRIrq\/6c92jpTMBSwzbGFKFm4LvtD20MoRTEnyocBDo0qVL9Oeffxqp\/Wi+ATfgM5OxhQ8m0hnvyJEjShKYwVgKALq0CZwAsVsuigr8RKp9ePZWrVqlfDWNGze2VfsQNNhUKGGSP2LECLpy5Yoy+ho0aEBz585Vzh9Z2LDzCnw4k6SBIw0aXnLYctZnpKt9CaJuDcu6yZJ8jMFqKcL3Xhh8aAdqHUJsZ\/BJm8hS7QN0GAenTp0K2+oB8M6dO6s12kvw9T0y1La0N2rWrBlm3UIDoLA3kpcOK8nXLWdpgFlt2xKp9u2MRtOtngTOirmjeQQtt3rRAjtcoUyZMvT48WNq1qwZ9ejRQzGGF54sS4ulhH0JdQ2NywVS2759+9Bn+Xzv3r2hAI4XZIoa2LFTUejYS7+zFxMpjm1cvnyZEIrlSBw+w9HE6\/aDBw8oIyNDOapQ+G+rNT2W+TtG9davX0\/4J4sPfCykdq7DoVkYZJB+MAXc3xyTB6PUq1fPM+m3BB\/rCZwG7B1zSgpwnhYpzxPahMHIsWfUk0kIRanyTMZc1O\/o4IM2KGyd6595fFwPNppTwbLNmiYMfD0bRAfDqeFoz3ntkuuWVHv3798PU4GJVnnxzCVRdUGjPXv2hMDRJR3Pnz59GmIGfRx6fadxKvAl53gh5XqnaH\/y5MkESxo+BZZ8ycmsGUaOHGmk8uAW3r17N40ePZrq1KnjNM+UeB5tzBCEDh06qG0aG3xuwWdN+urVq6jpW0yMEPgAqFGjRup7SB323+xGlZSTasOUopgEkhIOHz4cUvv6MqB\/dlJ5iAYirpCXl0dpaWmmQ0nqe3ZjtgKegTRR+7FOKmLNZxDgLOC1JtbGmZHgI4ezCP4DXvN1SefJskHjxPUgZLcuHegnlaZSpQP08ydRqVJk+\/+PH0SlS9s\/t6uPeoFAIQWs2sf3Tn3jeWEJUjBYKoxhdQtf0lpX8wk3+HSjIx7gATD89PDD16pVK8zg8wJ8SL4i6bNnRMVA9euSzxp206ZNYXt7pnmi7R5byee1Nx7wwdVIJz537pxqBpEkeO6mT58esv7BbIcOHVLPkUcwePBgZROAy+\/evRt6NmjQIOVkYm3EhES9NdOmUebq1fEMtUjq6uDrDh4ehDSKi9zJozsfYqUMgGRgZRtgALhoJ0yYQDdu3FDMAfsiPT2dtmzZQr169aLVq1erreaJEydU1T59+iivIhgHRYKPNR9r\/65dhb2kp8c6YrN6+fmxKZpUs1Ms9\/leG3wgKdQ8Ikr37t1T7mF4qQA+CAJPohX4cC4B\/PLly0cFH9Z+Xt4zGjOmELy8PDMQY32rbt1CBuvcubAFU3sz5cC\/evVq2Imd79+\/q2QKqNhu3brFSp+IemgXOXXPnz+nrKwsqlq1qurny5cvhAweFGxxIMXoF\/tdpIvxMwSUkEKG5QgF7aSn\/wdmGEwuCgRKEZ89MjHsnAw5acTxZNjg435gCOJv\/C+Nwe\/fa9LPn\/j3+\/vCNiINPs8I\/G9DELKCggKjgxsqquf1AEp6e9++\/UWfPq2if\/6pGWIKJ\/ChbSEUEAg+caN7WtHG4sWLo+7C2GCHkEhPKmOCLCGkgalMHl3ySzpw8c7\/+vXrKhaSnZ1LQ4aEH7iwU\/u8zFarVi3suBU7x8AUboI57DeQDjurPhwDO\/ESo6TV50ioKfhszUOiAZo8a2elDUzpyRoAiblYYk+fPh2hNXzwTalp+J5b8JG6DqlGtpIM76K7eHdd0nC3ygWIG3y7HHOZizd06FDPzpwZYpC01xj8d+9yqaCgrfGabwW07gdw41rnIB00SteuXVXcQI\/beAI+KK3n+uE7TjUqieA3bpxLJ0+arfl2Ug4AZZBG\/2zF4VLdy2ROq2PcCny7BMoWLVqo3HWcZIEk8wELmXOGuk7g6+2YngBOmvjG0TFL\/ps3heArH8Aff9CizEz6OyuLcGzCKhhlouKlu9fOAATIyHaGD8WqhFn7+\/fvDwJUSC4SGpcvX64OBODQBAr25nDAIGlTqvJ27dqpyJ8J+LIdeOgSeew6Dtw8qSrB\/\/YNyRVZEe3GA76+HYxn0IGMjIygrpZZXTPAzBRr1qxR5+gBOLxqeto1D4TTkDnrlttBPH\/atGk0Z86chJ25j4cYXtQNB\/+vX3k4P37lK5VGlrxyRuFvE\/DtQt5eRVsx18CAAQOCkHp5CYC+VjuB76T2mblKHvhY8\/8rwIc\/LTykywxnpfYTkU4nGTyq5DNoPvjmOiFc8gE+ws6jEW76t5FAQhNQrELldqMP5OTkKPcur\/kzZsxQzgCclPXBNwed34wAP+38rxCkzDRKLPhu8jECBQUFQXnWWx6XMgXf7gw88szRdslW+\/lEJHMMEws+mFBP+baVfP8qNvfSHa1GpNrX304s+E5p3Lap296SoWS25gR+WloXtdVNhYzjuD18JRNi+1n\/9u1nq4CKXgB6KgCvtnq+2veWfRn84nCkzQffW+xD5++TDb4MCuEgCLy48tyfL\/keA4\/mUkHyOQA0b948wi1ryHjGHQY4Kyk9hL7ke8wAyQZf7vObNGmiUrn41K\/uRYwbfD+eH849DD4udcRt9l6cenLDn0UOvqlv380kiuu7yQZfOnmk2mctIBM7\/Xi+x1yWCuBjSpzEKaenp3IF\/Hi+t+jbgS\/z6ZAMw1k2+jpsd4mFt6MsbM2P53tMVSvwra5b4UsY0L00ykyydaINOVpgJ8Lg8+P53qJvBb5O9GjXrzjdvuE0WlfgR8vkMY3qmRp8JSmZQ1r7epRNB0jm52\/evFll28rr2JwAZyNPXulmV0ee+PHj+SaUdfEOSz7OFuKiCWz1nCSf1\/mePXvSyZMn1c3npj+SpA\/Nj+e7AMvrV39H9d6oXEWAH23NZ5CtLqzyemx6e3E7eRI9wOLWPoOP5NXu3buHnDx21j7PL15DT6eT79tPAuck272LKfu+\/SQAjy6TDX6RuneTROOU7dYHP2WhSfzAkg0+b\/sQuzfy7SeeJCWnh1QAH9Q28u37aVzeMmaqgG8yq7i3en48P5zMqQC+6W1qnoBv6t414cbi\/k6ywXdzfa4fz\/eY2xj81q1bh37EEHF0fObLrGVIF93rkup041a0Ibty7\/rxfG\/RZ\/Dh2kXypNXNWPKGDdzFI39axY3kWo3c1UFN\/3x+YsDftWsXderUKcKvL7di+PkUXDOr\/3RKvK5ek1s+MA7\/fL632Ed4+KzUMId4cdMJfh7O6qCrvjS4GaaxwefH892Q1fld3eCLBj4ifriO3u62TOfeIt9wkwbmx\/NjoXCUOm7AZ8n38qoVVwaffz7fW\/TdgI81Hwaf\/ts6bn8oSc7AlcHne\/iSCz5+OlZ3xbq5bNFq9KbXtsbt5PGWdMW\/tWQ7efzLGZLIQ8kG383Ufcl3Qy2Dd4sT+P8DNgA+2QbYbq0AAAAASUVORK5CYII=","height":61,"width":101}}
%---
%[output:645e8c43]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAH8AAABMCAYAAABEU2gQAAAAAXNSR0IArs4c6QAADZlJREFUeF7tXWdoVF0TnjWi+MM\/il3sDQQVC1+wJhbELoKIPTbsEQv23mLFrogdNSiCKDZUbNhBRf\/ZjaJGFMuv+L76Jft9z4mzzp69NXs3u0nufd\/g7t572jwzc+bMzDk3EAwGg+RfRZ4CK1asoMWLF4eNY\/z48bRp0yYqV66c4fgCPvhFHnf6+vUrDR06VA3k6NGjVLFiRUeD8sF3RKbi+VCgbt26QaiHOXPm0PHjx2nevHmUkZFBgwYNcjTiaMqggebNm9O+ffuoQoUKqr179+7RkCFD1Ofq1avTgQMHqGHDho764vahFy9e0KhRo6hVq1a0Zs0aU\/Uo6+UyHz9+jGiO6ei2H\/rza9eupd27d1NmZiYlJydHW50qb1Rn3MFHx+QgmZmKIvjosxcMEBfwC8Ji0Uh+hw4d6ObNmyFN8\/PnT5o7dy6dOXMm4SVf1xassXRNVhCaxgV8BrJfv360efNm1e+yZcsq9Yvrx48fNH36dKWKjaYKPINpw04CuB2o9+vXr4fU7vv375UaZjUPFctqX04HTFDWGFJ9ly9fXmmSPn36KFW+detWpUL54t9hActyo0ePpsmTJxPUuRWAZlPFt2\/faMyYMfTlyxfV50ePHilazJgxg65cuUJPnjwJMbk+dejtMfjbt2+nPXv2qLK45HSsC4od01mq\/bFjx1KvXr3o8+fPBPCxRDAieP369enVq1dUpkwZOn36ND1+\/FgNkqVYcrqZ7cDgL1q0SJV\/9+6dmvefP3+u5nv+\/eHDh4qQuMAU+jzLA4a1q98Hc+KSwHPfmHEZhEqVKinQZP2SSYzmfDvJv3z5ckgQJLPiM9s0sl5p3zBQRloDjI1xSw3JzzVt2pTAFGA2\/WrZsiV9\/\/497Gc1548YMYI+ffpEbdq0oVWrVoU4jDvBxJLcxmVSU1PVICXnMbhm85+cKrKyskLGzY0bN9TnvXv3KsZi8HWDT5cyyRzSfrBTn1ICdS0ChpCGKFPNyuCTGo\/HKOki6Sdpo9OZv0sG5Prw24ABAxSzy\/vQyKDZtGnT1J9+waA\/ceJEJPhGKrxv376Ku3QAWBvoZeRg9Gf0jkjwa9euHSbt0AJQd+vWrYtom0FnNcjSwuDrgFlNFSgjJZ+B5jZw3y34UtMZCYBZ3Xo\/oOp1a18+A9BXrlxppBhMDU5mqBo1atCpU6eUL8DU2ncLvhy4G\/ChjqTKxsCWLFlCy5YtC4HP4LKqhQTJ+VW\/r3u0dCZgiWEbQ6pwp+DbLQ+NDOGEBB8qHAS6desWVa5c2ZHat\/INuAGfmYwtfDCRzngnT55UksAMxlIA0KVNYAeI2XRRWODHUu3Ds7d+\/Xrlq2ncuLGp2oegwabCFSb5w4YNozt37iijr0GDBrRgwQLl\/JEXG3ZegQ9nkjRwpEHDUw5bzvqIdLUvQdStYVk2XpKPPhhNRfjdC4MP9UCtQ4jNDD5pExmqfYAO4+DixYthSz0A3qlTJzVHewm+vkaG2pb2Rs2aNcOsW2gAXOyN5KnDSPJ1y1kaYEbLtliqfTOj0elSTwJnxNxWHkHDpZ5VYIcLlC5dml6+fEnNmjWj7t27K8bwwpNlaLGUsB+hrqFx+YLUtmvXLvRd3j9y5EgogOMFmSwDO2YqCg176Xf2YiBFsY7bt28TQrEcicN3OJp43n727Bmlp6crRxUu\/mw0pxdk\/LZRvS1bthD+5OUDXxBS25fh0CwMMkg\/mALub47Jg1Hq1avnmfQbgo\/5BE4D9o7ZJQVYDUsmGWBu061Reb8wVZ49FIX\/hA4+aIOLrXP9O\/eQy8FGs7swbbOmCQNfzwbRwbCrWL+vcy6+Hz58OEzNsdp7+vRpmAqMtcpzO5bCeF6njy7puP\/69esQMxjRW9LXrs8KfMk50Ui5XWMSUMxbkpNZ2wwfPtyRyoNb+NChQzRy5EiqU6eOXdMJcd+qz5jv27dvr5ZpbPC5BR+DRJkPHz5Ypm8xMULggwEaNWqkfgdIWH+zG1VSTqoNtxSV4NeqVUtNLfAbIAWJwefvdioP0cDUlBTVhaKShKj6nJpK165do5Q\/fUf\/jYBnIJ2ofbc4hIEvCzMIcBbwXFPQyvVykitxD+CzpPNg2aCx43pFyG4pRLlESaWI8vKISln8m4vnkuyf0+tBuUAgfyRG9eN3u7ZxP\/8KUjBYKgx83cKXNNPVfMwNPt3o8Ap4+Ot37Nihwo0w\/JjJcnNzVRQPF8LKkAhoAgw0Ozubdu3ape5NnDiRqlWrFmLIfMlf9oek17zqZkzr0SWfNSzoItf23IlY2z0R1r4+93pBDQC\/fPlyNZXAFw8PHtoZPHgwvXnzhq5evaqmmLS0NOVSht2BsOT58+fp7Nmzqgu9e\/emnj17hpad+eCnsjx50c2Y16GDrzt4uAPSmVPoTh7d+RANVQYOHKjcxDDMfv\/+HWaIdOnSRSVuwmMItyrm+6lTp9KECRNo0qRJ9ODBA0KMH8yCZ2Ek7ty5U3VHgv+G3lCd\/\/938GB+T9PSoumxfdmsLKKC2Jhmc759i7F5wnCd75XBByaCNEN6AaR0WHgp+QCfsurQqFH5RLoW41mgbt18BuvUKb89YbtZopRw4N+9ezfMWP7165dKpoAfv2vXrlGxHNac+\/fvj6hj27ZtamWBdvLy8ujcuXPqGaSRtWjRQrWLsrA\/kJ2CC6llSECAgYjr7du3lDamNtEfQy+YR8R7j5wYdnaGnDTieABs8HE7MATxGf9KY\/DXr5qUl4e\/v7\/n1xFp8EVFYIPCEKqcnBxHGzdUVM\/rDpT0+v755z\/0\/ft6+vffmiGmsAMf2nbp0qVKIHjHje5pRR2wnaxWYWywQ0h4F4\/EA1lCSANTmTy65Jd04KId\/\/3795VRmpGRSYMGhW+4MFP7PM1WrVo1bLsVgJwyZYpiCjfBHPYbSIedURu2gZ1oiVHSynMk1Cn4bM1DogGa3GtnpA2c0pM1ABJzq1SpQpcuXYrQGj74Tqnp8Dm34CN1HVKNbCUZ3kVz0a66pOFulAsQNfhmOeYyFw\/rea\/2nDnEIG6PMfifP2dSTk6y4znfCGjdD+DGtc5BOmiUzp07q7iBHrfxBHxQWs\/1w2+calQSwW\/cOJMuXHA255tJuR6kcRK0kepehs+NtnEr8M0SKLHsQu46drJAknmDhcw5Q1k78PV6nO4Ajpv4RtEwS352dj740gdgtc53ouL1qKhRNwEysp3HjRtnOIowa\/\/YsWNBgArJRULj6tWr1YYAbJrAhf1ucL0iaVOq8rZt2yp3rRPwZT2zZs2K6bbrKHDzpKgEf+7cZFqy5G+1AQoQ\/tejek7n92gMQKPBBdLT04O6WmZ1zQAzU2zcuFG5YwE4Yuh62jU3wGnInHXL9cCFO3PmTJo\/f37M9tx7gmAUlUjwsd5PolzKoyQKEqDPoyAlOQJfD3HHItoa6N+\/fxBSLw0yfa62A99O7TNzlTzwkymJ\/ku5lIQtEhSAh4\/CQ7rMZ0Zq38t0OteSz6D54DtXBeGSD4MPkceRCDf9qSRgKPnOW7B+0k1UNrBmzRrl3uU5f\/bs2coZgBi7D757SCLBv47Qj6gotuC7yccI5OTkBOVeb7ldyin4ZnvgkWeOukuy2ifKIiKZYxhb8MFleuKsGQtHvc53LxvFu0Sk5OvjjS34dmncpqnbxRuWwhmdHfgpKalqqZsIGce+5HvME399+xkqoKJfAD0RgEe\/fPBjBH5R2NLmg19MwZdBIWwEgRdXptH5ku8x8KiO1X48JZ8DQAsXLlTp8Mj8wRkG2Cch92P4ku8xA8QbfLnOb9KkiUrl4l2\/uhcxavD9eH449zD4ONQRp9l7vevJjlcLHXynvn27jheH+\/EGXzp5pNpnLSATO\/14vscclwjgY0icxCmHp6dyBfx4vrfom4Ev8+nkIRX6PKyHcr3tXXhtfjzfY+oagW903AofooDmpVHmJFvHqstWgZ0Ig8+P53uLvhH4OtGtjl+xO33DrreuwLfK5HEa1XNq8JWkZA5p7etRNh0gmZ6FjajItjXasm0FvNmOX72M3PHjx\/PtRMnlfZZ8HFaJgyaw1LOTfJ7ne\/ToQRcuXFAnnzt9SZLePT+e7xIwLx\/\/G9XLVrmKAN9qzmeQWXK9PmjRamxRO3m8JFxxqIvBR\/Jqt27dQk4eM2ufxxytoafTzvftx4Gb4u3exZB9334cgEeT8Qa\/UN27caJxwjbrg5+w0MS+Y\/EGHyPkpaUj337sSVJyWkgE8EFtR759\/0XK3jJmooDvZFRRL\/X8eH44mRMBfKenqXkCvlP3rhNuLOrPxBt8Nxs6\/Xi+x9zG4Ldu3Tr0EkN47fCdD7PW3zugS6rdiVtWXXbl3vXj+d6iz+DDtYvkSaOTseQJGziLR75axY3kGvXc1UZNf39+bMA\/ePAgdezYMcKvL5dieH3Khg0bIl6dEq2r18kpH+iHvz\/fW+wjPHxGapjX4TjpBK+HM9roavRKGqdddWzw+fF8pyR19pxu8FmBj4gfXgtrdlqmsxbDn3KTBubH8wtCYYsybsBnyffyxRauDD5\/f7636LsBH3M+DD793Tr6i5bc9NCVwed7+NyQ1v5Zt+DjXQK6K9bNYYtGPXJ6alfUTh57cpSsJ+Lt5PEPZ4gjv8UbfDdD9yXfDbUcPFuUwP8foVU62Z6rS2AAAAAASUVORK5CYII=","height":61,"width":101}}
%---
%[output:41634218]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAH8AAABNCAYAAACPD7u1AAAAAXNSR0IArs4c6QAADYtJREFUeF7tXWmMTcsWrsOLGxGCG7NnSgwRQgyPGEKLIRJEJOKZ2xQ\/SCfmeZ49QwhCEDF1iCFERMwEwQ9C\/LhmbWwx\/RGNuK3f\/aqtbe3q2nvXPnuf7nO6dyWdPkNV7ar1rbVq1Vqr6sTy8vLyRFSKHQUePHggBg0aJO7evWvNbfz48WL9+vWibNmy8rNYBH7xwH3JkiVi\/vz5tsmoYKszjcAvBth\/\/PhRDB06VM5k\/\/794s8\/\/zSalQT\/4MGDYtasWWLFihVSVZiUIG3Qf4sWLcTOnTtF5cqV5eNu3LghhgwZIl\/XrFlT7Nq1SzRs2NBkKL7rPHr0SIwaNUq0bt1arFy50lKDbh1Rmzdv3hSoBgmbMWOG73GoDVatWiW2bdsmMjMzRfv27QP3hw6c+vz06VO+2g8CZDwMQ7Pik6QxpCL4GHMYDFAk4MfDYkEYpnPnzuLKlSuWpvn69auYOXOmOHHiRNJLvqotSGOpmiwemhYJ+DoguRoGV3fp0kWqZeJw3gYTxbLhJQHUBv1cunTJUruvXr2SapjUPFQsqX0+DlVjcPVdvnx5qS779u0rVfnGjRulCqVCn8PS5e1Gjx4tJkyYIKDO3QB0WiqgPseMGSPev38vx3z79m1Ji8mTJ4vz589La5u0o7p0qM8j8Ddt2iS2b99uWepcu6qC4sV0vtU+LEdMhJcvX76IcuXKCUjt7t27BQFJUszrOi0F1GbevHnizp074sWLF3Ldf\/jwoWQs+vzWrVvW88EU6jpLE4aho34P5kThwNPYiHEJhCpVqkjQeP+cSficnMBXJf\/s2bOWIHBmxWuyaXi\/3L4hoHRaA4yNeXMNSfXcGMCtT9uaX7VqVXHz5k0xYsQIqZaJWJzbAPaePXtEkyZNxPfv323SQuA6rX9cW2RlZVnGzeXLl+XrHTt2iOPHjwsCXzX4VCnD5Al8bj94qU8ugdSOMwQ3RInAbgYf13g0Rw4Ipx+nDY2TPqP3nAGpP3w2YMAAOV\/d9xC47t27S6v\/9OnTFv9UqlRJVKxYUbsKSfAx2WXLlok5c+ZI7gR3qQAQh9NAqQ2fjFpHfSIHv27dujZphxaAulu9enWBZxPo5LAgaSHwIcFOOwedcakDmp6B+n7B55pOJwBOfavjgKpXrX1eB6AvXbpUCySEEvTB8xs3bmzVIYbCf2A8bdo0ySBaa79fv35G4LvZCSaS36pVK5vKxsQWLFggFi1aZIFP4JKRBQni66v6PXmuaOaqvUASQzYGN95MwffaHuroUhjgQ8Jh53Ts2NHGHFwL5ubmCizp8AXEYjH9Vk9VRzq1FRR8YjKy8CE9KuMdPXpUSoJqMGF2ZJOY7NedlovCAj+Rah+0ICcPbCbf4JMKf\/funXRW9OjRo4BxQoadztonx5AftY823BjhBg0tOWQ5q3pOVfscRNUa5m2LSvIxBt2uBZ+HYfCRBjxy5Ej8ar9Dhw5SJaA0bdpUgJBkzLht9eIFX7WUoba5vVG7dm2bdQsNgELeSFo6dKpYtXK5Aaaz3BOp9p2MRtOtHjdmdcxN35MG0Bl8tWrVEseOHbNcv9aar0rWwoULpUX\/+fNnqVKwDpcpU0aqYFNPFgY5adIkuTUkvzOewwMQV69etakpMN6wYcPkcPbt22drp7VyisGHfM6YTmHSRBvYcVJRGBwkauDAgZ5kp0lxEK9du2YZHPfv37deIxCBEGRGRoY0WlDoNbdcPR+aYhU4PUADvIfDiSz2RNPEMarHfe1E09mzZ4vDhw97Ro6gLSZOnCi3E\/AZkORD6lFgmJBmGD58uJR+MAt8CxRvRt0GDRqUCOkn+qqGW6Jp4hnSVZMCVLWkEzYAh6gUDBBS++oyoL7njEHLAzFKigl03MNVwU80TbTgEzDkIvVKCuCzBbNg94BdA5xGKvgk6QQwSbcq6eD6p0+fSi1RUgrmvHfvXkuzmtJEZ+g50axXr15W\/zbw1WwQEynnDwHTwFEDR0ydOnVsBp+q5v2CD3cwYgojR44U9erVS0l+cJsD1vtOnTrZDD5T8IkYKvN4EUmCzznHj5SrnWMCFy5csK3pYal9RAHT0tLExYsXRdeuXb3mlZTfO81BB7xu6VOXAacl9\/Xr17ZcPSdiWOCDARo1aiTr6ZL\/qAOuNtROdXlkqLN48WLJEJyTdQYfV\/Mq1+cTrtM\/m8XS\/5iMuaJ06X9Zj\/\/5U4hSpeyjwWco\/HOnem5tqY2ftmp\/ublClMawxU+Rm1vaxsCqhc9noS59YRvBBdZ8AgVOgXjWW84A2L7AaTN16lQ5J0w0PT1dPH78WL5v166dOHnypHQ8gOGwhbx37578rnnz5uLQoUNWkKI4gk9Ctnnz5gJuWRLCRG5\/C4Dv5if20qV8a4K6ffr0ER8+fJBLAe1jg4GfZg0h79kzIVJs7VfVvurgoclx30giHV+Oks+tci\/Qnb7nTgo4a4Ls84lw9KxnePEsT1y6JER6erwjLNx2yWa3aLd6qucpXhJx8J2sfzIIvfa0OvCzLuaJtDQhCksJZGUheQQRxfiUTtKBf\/369QIndl6+fCn9+U+ePCmAe9u2bcXcuXNFhQoVPHkCe1akScHbh4JkjZ49e4pmzZrJ9\/i+Ro0aMgOFv8Z3586dE9nZ2QIaCOX58+ciPf3fMOGk4ZRf8q28WMzc4ENd\/FHxMhZVg4+MN\/xHyTfk7P39\/Flb\/P13betDN4PPk4gJrBCrX79+dFwrZAJ\/\/95OfPr0P\/HjRz4DmIAPLYmAGgSEDl2ozjb0RTsnpyGjTU5OjtHBjZhO8kOmRYnqDjmQGzZs0B68cFL7ZPVXr17dFjehGAmYwjTARQY7NCaPphIISBVDLiAYzNO3X6KQC2GyFBHVnbrRgU\/WPCQathY\/bqXTBiZDJKcRd9jpGCwC34SaPur4BR8p7JBqZC1Rfh2p\/SCGN2mAt2\/fimrVqokzZ84UWDIi8H0Aa1KVwH\/\/PlN8\/Zp\/3s5kzdcBrfoB3LyrurFxT60uOSYw+E6HAnhC5uDBg0M7eGgCQFHWCRN8aALup1ffu82TPK1YTrp16yaDRqGfzwf4KLpTqpRvVhLBN13zCUATFa86zXTgc3XPc\/h1x7il5Dtl0bZs2VLG5nGcCZJMp2x44qEJ+Go\/psfAi1KC4302Sf4ff2SKv\/76fcwaefJUdJFJU\/DV7aA6ToCMlPdx48Zpp2Cz9g8cOJAHUCG5yGpdvny5PBWCkzMoOPSIkyA4ycNVOTJ9Kf3aS\/J5PwjyJPLsfbyghdWOwM\/OXiG+ffvvr24RgsbfQvneBHynzKd4A266+cUyMjLyVLVM6poAJqZYu3atvEwB0o6ECjX3nh5AueiUek39IKdvypQpArmAibp4ISwQ4+3nN\/iZ4tu3Nr+6ofDzDyFEGSPw0TBIRpXJ+GP9+\/fPg9TzmyDUtdoLfC\/JJ+YqeeD\/55crmsCHM7VU0iSkuEo+gRaBbyJH+XXsko\/TsgtY4ywhRP2Egq9Ll3MafWzlypXSt09r\/vTp06UzAMelI\/DNQaea7uCjViyh4PvJx4jl5OTk8QP\/\/MycKfhOFyEgCwV9l1y1r7tUKbHgg73UfH9HyY\/u4fMv3W4t7JJf+OB7pXE7pm6HS4aS2ZsX+F27psmtbjKknwd275ZMiJ1nTeDDJ4KAiloAejIAL62PSO2Hy75uUb1wnxS8twj84DS09ZAs4POIIE5ewYvLD8JGkh8y8HyfH+YVqn6HSdE\/5FqOHTtWnr\/ARRa4L4G7hwNLfhTStUNDko\/LHXGbfTwHX\/yCzevzfT6uy0MqF93VowaPQgGfnETqoEtySDdlwI9CukFkLbkknzt5uNonLcATO2NRSDc84Pmar0o+T6lCPgQlWqiq2OkuI7+jpCRO3k5N5YpCun6p6lFft+brrluhSxjQHV+XTbJ1whpyFNINi5K\/+tGBr0q32\/UrQW8kcQvsFDD43JI5TAM7pgZfSYrnc7WvBlpUgHh+\/pYtW2TCpXqTpimP+gI\/CumaktWsHkk+Lq3EfUPYZnlJPq3zvXv3FqdOnZIXJJv+Tg6Nyum4tzpqftwrCumaYWpc63dgJ1umqwF8tzWfQNbdW2j8UFbRVzw\/8u3HQ2LnNgQ+8hdxhzE5eZysfeqpMA09emZgJ0+4pEv93iLffupjGPcMkgH8QvPtx02lYtqwqMEvVN9+McUw7mlF4MdNutRvWNTgg4LkV\/D07UfWfrgMlwzgY0ZGvv2g4EfxfDvzJAv4JiwdeKtncko3OqJtAkV4dUyvz42OaIdHc9kT9\/Dh1FObNm3kgVacdOahXNRVQfK6actkqH6uz43i+SYU9VGHwIdrF2fk+W0Y\/GYN3MHDf1LFD2huw\/Hl3o2OaPtA1qAqgb9161axbt06K3+OW+H4KZk1a9YU+BmZMFy8vg5qRke0DRD1UcUEfBzowM\/D6c44qkuDj0dbVU1u+UDl6Ih2PNR1aWMCPoI9+DUSp4sSgw7J2OCL4vlBSa3f6rmpfZL8MK9YoVH4yQGM4vnhYm9Z+15rPgw+9Td1\/P5Gjm7ovgy+oE6ekGmX8t2ZqH367UDVC+f3kkUdsXwZfBH44fJbMnj4TO\/sDezhC5d0qd9bUYMfXc5QhDxU1OD7mXok+X6oZVA3lcD\/PyAAo\/Cb0IseAAAAAElFTkSuQmCC","height":61,"width":101}}
%---
%[output:92853225]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAH8AAABMCAYAAABEU2gQAAAAAXNSR0IArs4c6QAADhlJREFUeF7tXVlsVMcSrbEjEB9ILCKsL2AkQj7YRHgKIqDYUSDwAbEQyws7BMQHYL2QhB0cwuawPhAgEJtYgkACRBSJfTFi\/wABXwlI2CGQiYJAfBkTbM\/jtKlLTc9d+nrueMb43g+Y8e21TlV1dVV1TyQWi8UofOo8BZYsWUKLFi2Km8fUqVNp3bp11KhRI9v5RULw6zzu9OTJExo9erSayE8\/\/UTNmzc3mlQIvhGZ3s5CCvyDBw\/S3LlzacWKFTRy5EijmSZTBx10796dduzYQc2aNVP9Xbt2jUaNGqU+t2nThnbt2kWdOnUyGovfQvfu3aOJEyfShx9+SEVFRY5qUbbLdf7888+E7qBeZ8+e7XcYCeV\/\/PFH2rp1K+3fv5969+6ddHtowKnNp0+fUtrAx8DkJJmZ6iL4GHMQDJAW8GvCYslIfr9+\/ejixYuWpnn+\/DnNmTOHfvnll4yXfF1bsMbSNVlNaJoW8HUgYTR89dVXSv3iefbsGZWVlanvAG737t0k66AMlg0vCeA6UO\/FxcWW2n348KFSw6zmoWJZ7cvlgAnKGkOq78aNGytNMnjwYKXKN2zYoFQoP\/x3WL6y3qRJk2jatGkEde4GoNNSAfUJWj1+\/FiN+ebNm4oWM2fOpLNnz9Lt27ctJteXDr0\/Bn\/jxo20bds2VRePXI51QfFiOmO1\/+6779L169fphx9+UBORD0sr\/t+zZw998MEH9OLFC8UMkGL5ONkODP7ChQvp1q1b9ODBA7Xu3717V633\/PcbN25Y\/YMp9HWWJwwrV38P9YtHAs9jY9XMILRo0UKBJtuXTGK35ntJ\/unTpy1BkMyKz2zTyHalfcNA2WkNMDbmLTUkl2N6YNcOq\/\/kyZNWE02bNqUmTZrYKiK15gOAZcuW0fz58xUX8yCYWJLb+G9cR3Ieg+u0\/kltUVpaahk3Fy5cUJ+3b99OP\/\/8MzH4usGnSxlmxOBL+8FLfUoJ1LUIGEIaokw1N4NPajyeo6SLHf1QR6czf5cMyO3hb0OHDlXztXv\/xRdf0Pnz55VG7ty5swW2G0MlGHxDhgxR3KUDwOqXgbUDWi+js5sEv3379nHSDi0Adbdy5cqEvhl0VoMsLQy+DpjbUoE6UvIZaO4D7\/2CLzWdHV2c2tbHAVWvW\/uyDEBfunSprRRDwrHUffzxx3HvpSBUVlYSnEFY1iORSKK17xd8OXE\/4Pfs2TNOZWNihYWFtHjxYgt8BpdVLSRIrq\/6e92TpTMBSwzbGFKFm4LvtT20M4QzGnxW4X\/\/\/bfarzZo0EBxoJvat5ukH\/CZydjCBxPpjHfkyBE1DmYwlgKAzjaJyX7dabmoLfBTqfZZzCHNq1atclT70ABY2r\/77jtlFyTs8\/v06aNUQsOGDS1Lnxtnw05X+zWVfDiT5HokDRpecthy1vWcrvYliLo1LOumS\/IxBrulCH8PwuBDO6AfbCQng69t27Z09OhRy\/Xr6OSBFZ2fn0+PHj1StOvatauyYGGtBgm+vkeG2pb2Rrt27eKsWzAaHvZG8tJhp4p1Q0caYHbbtlSqfSej0XSrJ41ZO+Z28wh6bvV0yZJWJ9bYcePGqW0ZtgzDhw9XEhs+wVAAmnbMmDFWY5cuXYoz2uT7ffv2WQGcIHq3Dew4qSh0qKsPfRAcYeK9pj4ZGXqszYkGQayg27h8+bJlfSMSh+9wOPF27bfffqOCggJlxePhz3Irl8yYHKN60tfOHcAZAq+Vvp3g91BJX3\/9tWIQOGzk4DFgOdlff\/01buKpnmgyRKqtuiw4oB1oDKmHA41j8hCcjh07Bib9tuAziOwl80oKYOIAwO+\/\/17t1+1iyhg8HkyO+xg7dmytTLS2AEymHx18SS+0q3\/nvnRt6zaGzz\/\/3Ir5x4GvZ4PoatlrYjqnyvIMNnYNsEj176YT9RpDXX4P+u3du9cCR5d0vL9\/\/74SHrtHr+9FCwW+5BxTKXfqHIPDwylFzEC6pDMnsxrzmijcwQgojR8\/njp06OA1r4x87zYHLIl9+\/YlKXBeNLGbJOpgl+aWvsX1LPDBAO+\/\/776O9Q39uHsTpWdSLWhd86WKU9AGjDvvfeesgdYzfsFH1HAvLw85b\/Ozc3NSHB5UKVElPNKAKqysuBCjRtrhChhDnbA26l5J7VfU2IkrPm60eanYV3tS9WOoATAr6narwa\/L0Ui71BWVvyoqqrI9m8oJcs6lbNrj+tyHT910V7lqzU6u7JCDbSSsimbKimLYvSSGsSBr1v4cma6mk+5wacbHX7Ax0SwZkHl4JkxYwaVlJSoEDGsVwz+zp07dOjQIfUekSi4G9myhQeK3w0bNkw5mjgxMZMlP4+IioloAtzOr6W+JAIZT3yk5LOG3bRpk+0OKtU7IEfJl+rZlAEk42B9g\/OiW7dudO7cOWX9b9myRRkrV65cUVtG\/gy35IkTJ1R5ODLw8OeBAweq7wD\/f3l59N8MVPsMMxaj80SE7zED8HUHD9NZOnNq3cmjOx9MwUc5MMCIESMU4MiugeH37bffqiYg+QAR7+wkf+fOndY7J8lHPT5qUFxMtHs3UWEhUW3YgKVYzCmxLynjWOE3TZ9O0zZt8pR8P3RNRVnbfX5NDT4eIEBG9unhw4cd13i\/Wz1W++ijYMYMWr9hAy1eTK\/8CkQlJbUHfk4ODLY3UMD2lODjVa6D1KOWncGXCmBN2oxcvXo1zhz9559\/lJMG6vqzzz4zaSOuzB9\/\/EHHjh2jL7\/8UmXmcDvc7oABA6hLly6qDuyD1q1bq37kZ7w7c+YMRaNRtTvA8\/vvv9OECf+CCQc7mrKzs6gSVhUIGjE3+FDexAjkcrrBhz6zs8nqm7Krx5BVVVVt3VcSVVW0oYqK6vxHPG4Gn28Ce1SAUCHf0uTgRiQnJyc8rhUwAi\/KP6Knj4voZUXbOPAjFKMKzdrnru28o7qnFWVhPDs5efCe7S4IDRvLcnrIFsLOC8yRIPkB06HeNYcE2PXr19P+aJR6l5cTDRpEdPx4NR06dKBIaWnCPp+X2VatWsUdtwKQ06dPVy5zP8Ec9htIh51dH+FxrYDZkyOiFvhw8ggbQF\/z2ZqHRAM0edbOK1biNnTWAH\/99Re1bNmSTp06laA1QvBTDH5EX1Qj8R4+pLBDqpG1xMmVvF4ns+vCtKThbpcLkDT4TqnBMicPxl9QZ88Cxirw5ljyH0f30vPyj6gSBiH+ya4kyooRvYz38PEA7IDW\/QBurnV9Ihykg0b59NNPVdxAj9sEAj46tjuoyClH9RF8Vvteku8Gvh6kMQnaSHUvc\/jtjnEr8J0SKXv06KFy2JHEAUnmgxYy94xTutzA19sxPQkcuFjWQoNWBnO0M80pP\/Gmx+odqnrsglMmKl5PjrGbDkBG1vOUKVNsZxtn7R84cCAGUAEeEhuXL1+uDgbg8AQenHtDdA\/Jm1KVI9OXM3C9JF+2A29fKo9f1wK+rl0w+NHoCiov\/49t2WTAd0uW8Tv3SEFBQUxXy6yuGWBmijVr1qjz9JB2xNT19GvunNOROfuW20GG7DfffEPz5s1L2dl7vwQIuvwb8PdTeXmv182\/A6c0ESHKZ7bmOyW\/cIpcEOOO5OfnxyD10iDT12ov8L0kn5mr\/oH\/79egA3w8cEm+Y6z2a5pOZ8oYrpLPoIXgm5LzzeGMaBSSj9OyiAaNh8f\/9eeclCak2GVMOY0+UlRUpHaivObPmjVLOQPglw\/BNwedS8arfYBfKBqpzvFJZTaSn3yMSFlZWUye+ZbHpkzBdzoLjzxztF1\/1X75a4mXTBRJKfjoyS2RNm4k4VVs\/qXbrUa85NtdqpRa8L3SuB1Tt4MlQ\/1szQv83Nw8tdXNhAzkpD189RNi51kz+PCJIKCiPwA9E4DHuELwA+ZeK6oX4F16AQ\/Rai4EP2DKZgr4MiiEcxTw4spzf6HkBww8mssE8DkAtGDBApo8ebLK\/MFdBvIQbQj+Wwi+3OfjujykcvGpXz14lLTaD+P58RzEko\/LHZFi7pZvlwLes3L40G+tgM8eQn0y9Tmeny7wpZNHqn1mBJnYGcbzAxa\/dEs+T4eTOOX09FSuSBjPDxZ9J\/BlPh2SYTjLRl+H9VBusKOLby2M5wdMXTvw7a5b4UsY0L00ykyyddyG7BbYSTD4wnh+sOjbga8T3e36Fa\/bN7xG6wt8t0we06ieqcFXn5I5pMGnR9l0gGR+\/ubNm1W2rdOlV07gO5341cvLEz9hPN9LlHy+Z8n\/5JNP1M1Z2HJ5ST6v84MGDaLjx4+ra1JNztrZDS2M5\/sELMjib6J6UZWrCPDd1nwGmSU36IsW3eaWtJMnSMK9DW0x+Ehe7d+\/v+XkcbL2ec7JGno67ULffhq4KfTtp4HomdJlusGvVd9+phA9U8YRgp8pSKRhHOkG37dvPw00emu7zATwQVwj336YvRssH2YK+CazSnqrF8bz48mcCeCb3qYWCPim7l0TbqzrZdINvp\/rc8N4fsDcJj18OPLWq1cv6xJrGcpFt7qEet20ZTJUX+7dMJ5vQlLzMgw+XLu4IEFehSJv1sAdPPInVfxIrNtofB3UDM\/nmwNrUpLBxz3Da9eutZIn5RYMF1OvXr064SdTgnLxmtzygfGE5\/NNEPVRxgR8nObBz8PZHXDVlwYfXVtFjQ2+MJ5fE\/I61zEBH5E+\/GSd0y2ZyYzITxpYGM9PhtI2dU3AZ8kP8ooVHoovgy88nx8s+ibgY82Hwaf\/po7fH0iyG7kvgy\/08KUHfPx0rO6C9XPJotuoTa9tTdrJEyzp6n5r6XbyhJczpJGH0g2+n6mHku+HWgZl6xL4\/wdBNnvzENBwHQAAAABJRU5ErkJggg==","height":61,"width":101}}
%---
