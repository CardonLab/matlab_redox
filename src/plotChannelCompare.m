%[text] ## Eh series for the Typha marsh channels over a common window
%[text] Plots the raw series side by side so that data-quality problems are visible
%[text] before any spectral analysis is attempted. P2_10cmEh in particular carries
%[text] large positive excursions in this window that make it unusable: a transient
%[text] of a few hundred mV swamps the sub-mV oscillations the analysis is after.
%[text]
%[text] Depth labelling differs between probes: P1 labels are the installed depth,
%[text] while P2 labels sit 5 cm below the sensor.
%% Project paths, resolved from this file's location so the script runs from any folder
thisFile = mfilename("fullpath");
if isempty(thisFile) || contains(thisFile,"LiveEditorEvaluationHelper")
    try
        thisFile = matlab.desktop.editor.getActiveFilename; % Live Editor / Editor
    catch
        thisFile = '';
    end
end
projectRoot = "";
if ~isempty(thisFile)
    projectRoot = string(fileparts(fileparts(thisFile))); % src\..
end
if projectRoot == "" || ~isfolder(fullfile(projectRoot,"results"))
    try
        projectRoot = string(currentProject().RootFolder);
    catch
        projectRoot = string(pwd);
    end
end
resultsFolder = fullfile(projectRoot,"results");

%% Parameters
chans  = ["P1_10cmEh" "P2_10cmEh" "P2_20cmEh"];
depths = ["10 cm"     "5 cm"      "15 cm"    ];
cols   = [0 0.35 0.7; 0.75 0.1 0.1; 0.1 0.5 0.2];
startDate = datetime("2026-07-15 00:00:00","TimeZone","-05:00");

% Intervals to shade on a channel, as {channel, from, to} - the P2_10cmEh
% excursions, identified as the stretches where Eh rises far above its reducing
% baseline (see the excursion discussion in the report).
shadeSpans = { ...
    "P2_10cmEh", datetime("2026-07-26 17:50","TimeZone","-05:00"), datetime("2026-07-29 17:37","TimeZone","-05:00"); ...
    "P2_10cmEh", datetime("2026-08-30 06:18","TimeZone","-05:00"), datetime("2026-09-02 02:00","TimeZone","-05:00")};

%% Load
load(fullfile(resultsFolder,"typhaMarshMinuteTbl_Eh.mat"),"typhaMarshMinuteTbl_Eh");
T = typhaMarshMinuteTbl_Eh;
dataEnd = max(T.Properties.RowTimes);
endDate = dataEnd + minutes(1);   % timerange is half-open

%% Figure
fig = figure(Position=[80 80 1180 900], Color="w");
tl = tiledlayout(fig,numel(chans),1,TileSpacing="compact",Padding="compact");
ax = gobjects(numel(chans),1);
for k = 1:numel(chans)
    W = T(timerange(startDate,endDate),chans(k));
    t = W.Properties.RowTimes; x = W.(chans(k));
    ax(k) = nexttile(tl);
    plot(ax(k),t,x,LineWidth=0.75,Color=cols(k,:));
    ylabel(ax(k),"Eh (mV)"); grid(ax(k),"on"); box(ax(k),"on");
    title(ax(k),sprintf("%s - %s true depth   (range %.1f to %.1f mV, span %.1f; detrended sd %.2f mV)", ...
        chans(k),depths(k),min(x),max(x),range(x),std(detrend(x,1))),Interpreter="none");
    % Shade any flagged spans belonging to this channel
    isMine = strcmp(string(shadeSpans(:,1)),chans(k));
    if any(isMine)
        yline(ax(k),0,":",Color=[0.3 0.3 0.3],LineWidth=1);
        for j = find(isMine).'
            xregion(ax(k),shadeSpans{j,2},shadeSpans{j,3}, ...
                FaceColor=[0.9 0.6 0.1],FaceAlpha=0.25);
        end
        text(ax(k),shadeSpans{find(isMine,1),3}+days(1), 0.75*max(x), ...
            sprintf(" excursions (shaded): peak %+.0f mV",max(x)), ...
            FontWeight="bold",Color=[0.6 0.3 0]);
    end
end
xlabel(ax(end),"Date");
linkaxes(ax,"x"); xlim(ax(1),[startDate dataEnd]);
title(tl,sprintf("Typha marsh Eh, %s - %s", ...
    string(startDate,"d MMMM"),string(dataEnd,"d MMMM yyyy")), ...
    FontWeight="bold",FontSize=13);

stamp = sprintf("%s_%s",string(startDate,"yyyyMMdd"),string(dataEnd,"yyyyMMdd"));
exportgraphics(fig,fullfile(resultsFolder,"channelCompare_"+stamp+".png"),Resolution=150);
savefig(fig,fullfile(resultsFolder,"channelCompare_"+stamp+".fig"));
fprintf("Saved channelCompare_%s.png/.fig to %s\n",stamp,resultsFolder);
