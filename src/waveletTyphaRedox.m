%[text] ## Continuous wavelet analysis of Typha marsh redox
%[text] Analytic Morlet CWT of a single Eh channel, to resolve tidal (M2 ~12.42 h)
%[text] and diurnal (~24 h) periodicity and how their strength varies over the record.
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

%% Analysis parameters
varName   = "P2_10cmEh";   % logger label; true depth 5 cm (see plot_Typha_redox.m rename)
depthLabel = "5 cm";
startDate = datetime("2026-08-01 00:00:00","TimeZone","-05:00");
endDate   = datetime("2026-08-29 00:00:00","TimeZone","-05:00");

periodLimits    = [minutes(30) days(8)]; % resolvable band of interest
voicesPerOctave = 12;                    % scale resolution
tidalBand       = [hours(11) hours(14)]; % M2 band for scale-averaged power
nSurrogates     = 100;                   % AR(1) surrogates for the 95% significance level
                                         % set to 0 to skip the significance test
saveWaveletMat  = false;                 % the full CWT is ~75 MB; off by default

% Reference periods drawn on the scalogram
refPeriods = [hours(12.4206) hours(23.9345) hours(6.2103)];
refLabels  = ["M2 12.42 h" "K1 23.93 h" "M4 6.21 h"];

%% Load and extract the channel
load(fullfile(resultsFolder,"typhaMarshMinuteTbl_Eh.mat"),"typhaMarshMinuteTbl_Eh");
T = typhaMarshMinuteTbl_Eh;
if ~ismember(varName,string(T.Properties.VariableNames))
    error("waveletTyphaRedox:noSuchVariable", ...
        "%s is not a variable in typhaMarshMinuteTbl_Eh. Available: %s", ...
        varName, strjoin(string(T.Properties.VariableNames),", "));
end

W = T(timerange(startDate,endDate), varName);
if isempty(W)
    error("waveletTyphaRedox:emptyWindow","No data between %s and %s.",startDate,endDate);
end

% CWT needs a uniform grid. The logger is nominally 1-minute; retime is a
% safeguard that also exposes how much of the series had to be filled.
dtNominal = minutes(1);
W = retime(W,"regular","linear","TimeStep",dtNominal);
t = W.Properties.RowTimes;
xRaw = W.(varName);

nFilled = sum(isnan(T{timerange(startDate,endDate),varName})) + sum(isnan(xRaw));
if nFilled > 0
    xRaw = fillmissing(xRaw,"linear");
end
fprintf("%s: %d samples, %s .. %s (%.1f days)\n", varName, numel(xRaw), ...
    string(min(t)), string(max(t)), days(max(t)-min(t)));
fprintf("  interpolated samples: %d (%.2f%%)\n", nFilled, 100*nFilled/numel(xRaw));

% Remove mean and linear trend so slow drift does not smear across all scales
x = detrend(xRaw,1);

%% Continuous wavelet transform (analytic Morlet)
[wt,period,coi] = cwt(x,'amor',dtNominal, ...
    VoicesPerOctave=voicesPerOctave, PeriodLimits=periodLimits);
amp = abs(wt);                      % L1-normalised, so this is ~oscillation amplitude in mV
periodHours = hours(period);
coiHours    = hours(coi);

% Mask everything outside the cone of influence, where edge effects dominate
inCOI = periodHours(:) <= coiHours(:).';

%% Time-averaged (global) wavelet spectrum, COI-corrected
ampMasked = amp;
ampMasked(~inCOI) = NaN;
globalSpec = mean(ampMasked,2,"omitnan");
nValid     = sum(inCOI,2);
globalSpec(nValid < 0.1*numel(t)) = NaN;  % drop periods with too little COI-free support

%% AR(1) surrogate significance level
sigLevel = [];
if nSurrogates > 0
    r = corr(x(1:end-1),x(2:end));            % lag-1 autocorrelation
    sd = std(x);
    innov = sd*sqrt(1-r^2);
    surrSpec = nan(numel(period),nSurrogates);
    fprintf("  AR(1) surrogates (r = %.4f): ",r);
    for k = 1:nSurrogates
        xs = filter(1,[1 -r],innov*randn(numel(x),1));
        wts = cwt(xs,'amor',dtNominal, ...
            VoicesPerOctave=voicesPerOctave, PeriodLimits=periodLimits);
        as = abs(wts);
        as(~inCOI) = NaN;
        surrSpec(:,k) = mean(as,2,"omitnan");
        if mod(k,10)==0, fprintf("%d ",k); end
    end
    fprintf("done\n");
    sigLevel = prctile(surrSpec,95,2);        % 95% level against red noise
end

%% Scale-averaged amplitude in the tidal band
bandIdx   = period >= tidalBand(1) & period <= tidalBand(2);
bandAmp   = mean(ampMasked(bandIdx,:),1,"omitnan").';

%% Figure 1 - series, scalogram, tidal-band amplitude
fig1 = figure(Position=[80 80 1180 900], Color="w");
tl = tiledlayout(fig1,3,1,TileSpacing="compact",Padding="compact");

ax1 = nexttile(tl);
plot(ax1,t,xRaw,LineWidth=0.75,Color=[0 0.35 0.7]);
ylabel(ax1,"Eh (mV)");
title(ax1,sprintf("%s (%s depth) - Typha marsh",varName,depthLabel),Interpreter="none");
grid(ax1,"on"); box(ax1,"on");

ax2 = nexttile(tl);
% Decimate columns for display only; the transform itself used every sample
stride = max(1,floor(numel(t)/4000));
tD = t(1:stride:end);
ampD = amp(:,1:stride:end);
pcolor(ax2,tD,periodHours,ampD); shading(ax2,"interp");
set(ax2,YScale="log");
colormap(ax2,turbo);
cb = colorbar(ax2); cb.Label.String = "|CWT| (mV)";
clim(ax2,[0 prctile(amp(inCOI),99.5)]);   % ignore rare extremes when scaling colour
hold(ax2,"on");
% Cone of influence
plot(ax2,t,coiHours,"w-",LineWidth=1.4);
patch(ax2,[t; flipud(t)],[coiHours; repmat(max(periodHours),numel(t),1)], ...
    "w",FaceAlpha=0.45,EdgeColor="none");
% Reference tidal / diurnal periods
for k = 1:numel(refPeriods)
    yline(ax2,hours(refPeriods(k)),"--w",refLabels(k), ...
        LineWidth=1.1,LabelHorizontalAlignment="left",Color=[1 1 1],FontWeight="bold");
end
hold(ax2,"off");
ylabel(ax2,"Period (hours)");
ylim(ax2,[min(periodHours) max(periodHours)]);
title(ax2,"Morlet scalogram (shaded = outside cone of influence)");

ax3 = nexttile(tl);
plot(ax3,t,bandAmp,LineWidth=1.3,Color=[0.75 0.1 0.1]);
ylabel(ax3,sprintf("|CWT| %g-%g h (mV)",hours(tidalBand(1)),hours(tidalBand(2))));
title(ax3,"Scale-averaged amplitude in the M2 tidal band");
grid(ax3,"on"); box(ax3,"on");
xlabel(ax3,"Date");

linkaxes([ax1 ax2 ax3],"x");
xlim(ax1,[min(t) max(t)]);

%% Figure 2 - global wavelet spectrum
fig2 = figure(Position=[120 120 760 620], Color="w");
ax4 = axes(fig2);
plot(ax4,globalSpec,periodHours,LineWidth=1.6,Color=[0 0.35 0.7], ...
    DisplayName="Time-averaged |CWT|");
hold(ax4,"on");
if ~isempty(sigLevel)
    plot(ax4,sigLevel,periodHours,"--",LineWidth=1.3,Color=[0.6 0.6 0.6], ...
        DisplayName="95% vs AR(1) red noise");
end
for k = 1:numel(refPeriods)
    yline(ax4,hours(refPeriods(k)),":",refLabels(k), ...
        Color=[0.2 0.2 0.2],LabelHorizontalAlignment="right",HandleVisibility="off");
end
hold(ax4,"off");
set(ax4,YScale="log",XScale="log");
ylabel(ax4,"Period (hours)"); xlabel(ax4,"Time-averaged |CWT| (mV)");
ylim(ax4,[min(periodHours) max(periodHours)]);
title(ax4,sprintf("Global wavelet spectrum - %s (%s)",varName,depthLabel),Interpreter="none");
legend(ax4,Location="southeast"); grid(ax4,"on"); box(ax4,"on");

%% Report the dominant periods
valid = ~isnan(globalSpec);
if ~isempty(sigLevel)
    isPeak = valid & globalSpec > sigLevel;
else
    isPeak = valid;
end
[pk,loc] = findpeaks(globalSpec(valid),"SortStr","descend");
pv = periodHours(valid);
fprintf("\nStrongest periods in the global spectrum:\n");
for k = 1:min(5,numel(pk))
    flag = "";
    if ~isempty(sigLevel)
        idxFull = find(periodHours == pv(loc(k)),1);
        if globalSpec(idxFull) > sigLevel(idxFull), flag = "  *above 95% red-noise level"; end
    end
    fprintf("  %7.2f h   |CWT| = %6.2f mV%s\n",pv(loc(k)),pk(k),flag);
end

%% Save
if ~isfolder(resultsFolder), mkdir(resultsFolder); end
stamp = sprintf("%s_%s_%s",varName,string(startDate,"yyyyMMdd"),string(endDate,"yyyyMMdd"));
savefig(fig1,fullfile(resultsFolder,"wavelet_"+stamp+".fig"));
exportgraphics(fig1,fullfile(resultsFolder,"wavelet_"+stamp+".png"),Resolution=150);
exportgraphics(fig2,fullfile(resultsFolder,"waveletGlobal_"+stamp+".png"),Resolution=150);

waveletSummary = struct( ...
    "varName",varName,"depthLabel",depthLabel, ...
    "startDate",startDate,"endDate",endDate, ...
    "period",period,"globalSpec",globalSpec,"sigLevel",sigLevel, ...
    "tidalBand",tidalBand,"time",t,"bandAmp",bandAmp, ...
    "nSurrogates",nSurrogates,"nInterpolated",nFilled);
save(fullfile(resultsFolder,"waveletSummary_"+stamp+".mat"),"waveletSummary");
if saveWaveletMat
    save(fullfile(resultsFolder,"waveletCWT_"+stamp+".mat"),"wt","period","coi","t","-v7.3");
end
fprintf("\nSaved figures and waveletSummary_%s.mat to %s\n",stamp,resultsFolder);
