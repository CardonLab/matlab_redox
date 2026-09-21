%[text] ## Continuous wavelet analysis of Typha marsh redox
%[text] Analytic Morlet CWT of a single Eh channel, to resolve tidal (M2 ~12.42 h),
%[text] diurnal (~24 h) and spring-neap (Msf ~14.77 d) periodicity, and how their
%[text] strength varies over the record.
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
% P1 channel labels are NOT offset from installed depth (unlike P2, where
% plot_Typha_redox.m renames P2_10cm -> P2_05cm etc.), so P1_10cmEh is the 10 cm
% sensor while P2_10cmEh is at 5 cm, P2_20cmEh at 15 cm, and so on.
% These three may be pre-set by a caller - a driver that runs this script over
% several channels for comparison - in which case the defaults are not applied.
if ~exist("varName","var"),    varName    = "P1_10cmEh"; end
if ~exist("depthLabel","var"), depthLabel = "10 cm";     end
if ~exist("startDate","var")
    startDate = datetime("2026-07-15 00:00:00","TimeZone","-05:00");
end
% The end of the window is taken from the data, not hardcoded: the .mat is rebuilt
% as new logger data arrives, so the last timestamp moves. Set below, after the load.

% The upper limit reaches past the spring-neap period (Msf, 14.765 d) so that band
% can be tested. cwt caps the largest period at about T/(2*sqrt(2)) = 22.6 d for this
% record, and the Morlet cone of influence excludes roughly period*sqrt(2) from each
% end, so a 14.77 d period retains only ~35% of the record and 20 d about 11%. Treat
% everything near the top of the range as weakly supported (see springNeapCoverage).
periodLimits    = [minutes(30) days(20)]; % resolvable band of interest
voicesPerOctave = 12;                     % scale resolution
tidalBand       = [hours(11) hours(14)];  % M2 band for scale-averaged power
diurnalBand     = [hours(20) hours(28)];  % diurnal band for scale-averaged power
springNeapBand  = [days(13) days(17)];    % Msf band for scale-averaged power
msfPeriod       = days(14.765);           % spring-neap (Msf) period
nSurrogates     = 100;                   % AR(1) surrogates for the 95% significance level
                                         % set to 0 to skip the significance test
saveWaveletMat  = false;                 % the full CWT is ~75 MB; off by default

% Reference periods drawn on the scalogram. The diurnal line is labelled generically
% because K1 (23.9345 h) and S1 (24.0000 h) are inseparable over any record of this
% length, so a diurnal peak cannot be assigned a lunar or solar origin here.
refPeriods = [hours(12.4206) hours(24) hours(6.2103) msfPeriod];
refLabels  = ["M2 12.42 h" "diurnal ~24 h" "M4 6.21 h" "Msf 14.77 d"];

%% Load and extract the channel
load(fullfile(resultsFolder,"typhaMarshMinuteTbl_Eh.mat"),"typhaMarshMinuteTbl_Eh");
T = typhaMarshMinuteTbl_Eh;
if ~ismember(varName,string(T.Properties.VariableNames))
    error("waveletTyphaRedox:noSuchVariable", ...
        "%s is not a variable in typhaMarshMinuteTbl_Eh. Available: %s", ...
        varName, strjoin(string(T.Properties.VariableNames),", "));
end

% timerange is half-open, so extend one sample past the last timestamp to include it
dataEnd = max(T.Properties.RowTimes);
endDate = dataEnd + minutes(1);

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
    % innov is set so the AR(1) has stationary variance sd^2 - the standard
    % normalisation. At 1-minute sampling r is ~0.99997, so the decorrelation time
    % (~500 h) is only ~1/3 of the record and each surrogate is close to a random walk.
    % Its *sample* sd therefore comes out well below sd (the series wanders coherently,
    % so the sample mean absorbs the low-frequency power). That is a property of the
    % null, not a calibration error: the data are a length-n realization too, so
    % comparing them with surrogates generated identically is the correct test. Do NOT
    % rescale the surrogates to the data's sample sd - that forces the null to absorb
    % the record's genuine excess low-frequency variance and then spreads it to all
    % periods, inflating the level where no red noise should reach.
    % The surrogates ARE detrended like the data, so the two pipelines match.
    rng(0,"twister");   % fixed seed so the reported 95% level is reproducible
    surrSpec = nan(numel(period),nSurrogates);
    surrSd   = nan(nSurrogates,1);
    fprintf("  AR(1) surrogates (r = %.6f, decorrelation %.0f h): ",r,(1/(1-r))/60);
    for k = 1:nSurrogates
        xs = detrend(filter(1,[1 -r],innov*randn(numel(x),1)),1);
        surrSd(k) = std(xs);
        wts = cwt(xs,'amor',dtNominal, ...
            VoicesPerOctave=voicesPerOctave, PeriodLimits=periodLimits);
        as = abs(wts);
        as(~inCOI) = NaN;
        surrSpec(:,k) = mean(as,2,"omitnan");
        if mod(k,10)==0, fprintf("%d ",k); end
    end
    fprintf("done\n");
    fprintf("    data sample sd = %.3f mV; surrogate sample sd = %.3f mV\n",sd,mean(surrSd));
    fprintf("    (surrogates run lower by construction; the excess is the record's own\n");
    fprintf("     low-frequency variance, which an AR(1) with this r cannot reproduce)\n");
    sigLevel = prctile(surrSpec,95,2);        % 95% level against red noise
end

%% Scale-averaged amplitude in the tidal band
bandIdx   = period >= tidalBand(1) & period <= tidalBand(2);
bandAmp   = mean(ampMasked(bandIdx,:),1,"omitnan").';

%% Scale-averaged amplitude in the diurnal band
% Plotted alongside the tidal band because the contrast between the two is the
% clearest result in this record: the diurnal oscillation is present continuously,
% while the semidiurnal band is quiet with isolated bursts. mean/median and the
% fraction of time well above the median quantify that difference in character.
% Note that "continuous" is not "stationary": the diurnal amplitude can still trend
% over a record, so read the panel as well as these summary numbers.
diurnalIdx = period >= diurnalBand(1) & period <= diurnalBand(2);
diurnalAmp = mean(ampMasked(diurnalIdx,:),1,"omitnan").';
fprintf("\nScale-averaged amplitude by band (within the cone of influence):\n");
for bb = ["diurnal" "semidiurnal"]
    if bb == "diurnal"
        aB = diurnalAmp; lo = hours(diurnalBand(1)); hi = hours(diurnalBand(2));
    else
        aB = bandAmp;    lo = hours(tidalBand(1));   hi = hours(tidalBand(2));
    end
    med = median(aB,"omitnan");
    fprintf("  %-12s %4.4g-%.4g h: mean %.3f, median %.3f, max %.3f mV; " + ...
        "max/median %.1f; %.1f%% of the record above 2x median\n", ...
        bb, lo, hi, mean(aB,"omitnan"), med, max(aB), max(aB)/med, ...
        100*sum(aB > 2*med)/sum(~isnan(aB)));
end

%% Spring-neap band
% A spring-neap signal would appear as a ~14.77 d modulation. Report how much of the
% record actually supports that period once the cone of influence is applied, because
% only ~1/3 of it does and a band-averaged amplitude computed over so little of the
% record is easy to over-read.
snIdx     = period >= springNeapBand(1) & period <= springNeapBand(2);
snAmp     = mean(ampMasked(snIdx,:),1,"omitnan").';
[~,iMsf]  = min(abs(period - msfPeriod));
springNeapCoverage = nValid(iMsf)/numel(t);
fprintf("\nSpring-neap band (%.3g-%.3g d, Msf = %.3f d):\n", ...
    days(springNeapBand(1)),days(springNeapBand(2)),days(msfPeriod));
supportedDays  = springNeapCoverage*days(max(t)-min(t));
msfCyclesKnown = supportedDays/days(msfPeriod);
fprintf("  COI-free support at Msf: %.1f%% of the record (%.1f of %.1f days)\n", ...
    100*springNeapCoverage, supportedDays, days(max(t)-min(t)));
fprintf("  that supports only %.1f spring-neap cycles, so a significant value here is\n", ...
    msfCyclesKnown);
fprintf("    NOT evidence of periodicity - an aperiodic step or drift produces broad\n");
fprintf("    fortnightly power too. Test the semidiurnal envelope instead.\n");
fprintf("  band-averaged |CWT|: mean %.3f, max %.3f mV\n",mean(snAmp,"omitnan"),max(snAmp));
if isnan(globalSpec(iMsf))
    fprintf("  global spectrum at Msf: dropped (below the 10%% COI-support threshold)\n");
elseif ~isempty(sigLevel)
    msfRatio = globalSpec(iMsf)/sigLevel(iMsf);
    if msfRatio > 1, msfVerdict = "SIGNIFICANT"; else, msfVerdict = "not significant"; end
    fprintf("  global spectrum at Msf: %.3f mV = %.2fx the 95%% red-noise level -> %s\n", ...
        globalSpec(iMsf), msfRatio, msfVerdict);
else
    fprintf("  global spectrum at Msf: %.3f mV (no significance test run)\n",globalSpec(iMsf));
end

%% Figure 1 - series, scalogram, diurnal-band and tidal-band amplitude
fig1 = figure(Position=[80 80 1180 1080], Color="w");
tl = tiledlayout(fig1,4,1,TileSpacing="compact",Padding="compact");

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
% Scale the colour axis on periods up to 8 days only. The multi-day scales carry much
% larger |CWT| than the diurnal and semidiurnal bands, so including them in the
% percentile pushes the limit up and washes out the features of interest; this also
% keeps the colour scale comparable with runs made before the range was extended.
climIdx = period <= days(8);
ampClim = amp(climIdx,:);
coiClim = inCOI(climIdx,:);
clim(ax2,[0 prctile(ampClim(coiClim),99.5)]);
hold(ax2,"on");
% Cone of influence
plot(ax2,t,coiHours,"w-",LineWidth=1.4);
patch(ax2,[t; flipud(t)],[coiHours; repmat(max(periodHours),numel(t),1)], ...
    "w",FaceAlpha=0.45,EdgeColor="none");
% Reference tidal / diurnal periods
for k = 1:numel(refPeriods)
    % Labels sit above their line by default, which clips the topmost one against the
    % axes edge; drop those below the line instead.
    if hours(refPeriods(k)) > 0.5*max(periodHours), vAlign = "bottom"; else, vAlign = "top"; end
    yline(ax2,hours(refPeriods(k)),"--w",refLabels(k), ...
        LineWidth=1.1,LabelHorizontalAlignment="left",LabelVerticalAlignment=vAlign, ...
        Color=[1 1 1],FontWeight="bold");
end
hold(ax2,"off");
ylabel(ax2,"Period (hours)");
ylim(ax2,[min(periodHours) max(periodHours)]);
title(ax2,"Morlet scalogram (shaded = outside cone of influence)");

% Diurnal and tidal bands share the panel style but NOT the y-axis: the diurnal
% amplitude is several times the semidiurnal one, so a common scale would flatten the
% tidal panel. The titles carry mean and median so the difference in character -
% continuous versus bursty - is readable without comparing axis heights.
ax3 = nexttile(tl);
plot(ax3,t,diurnalAmp,LineWidth=1.3,Color=[0.85 0.5 0.05]);
ylabel(ax3,sprintf("|CWT| %g-%g h (mV)",hours(diurnalBand(1)),hours(diurnalBand(2))));
title(ax3,sprintf("Scale-averaged amplitude in the diurnal band (mean %.3f, median %.3f mV)", ...
    mean(diurnalAmp,"omitnan"),median(diurnalAmp,"omitnan")));
grid(ax3,"on"); box(ax3,"on");

ax4 = nexttile(tl);
plot(ax4,t,bandAmp,LineWidth=1.3,Color=[0.75 0.1 0.1]);
ylabel(ax4,sprintf("|CWT| %g-%g h (mV)",hours(tidalBand(1)),hours(tidalBand(2))));
title(ax4,sprintf("Scale-averaged amplitude in the M2 tidal band (mean %.3f, median %.3f mV)", ...
    mean(bandAmp,"omitnan"),median(bandAmp,"omitnan")));
grid(ax4,"on"); box(ax4,"on");
xlabel(ax4,"Date");

linkaxes([ax1 ax2 ax3 ax4],"x");
xlim(ax1,[min(t) max(t)]);

%% Figure 2 - global wavelet spectrum
fig2 = figure(Position=[120 120 760 620], Color="w");
ax5 = axes(fig2);
plot(ax5,globalSpec,periodHours,LineWidth=1.6,Color=[0 0.35 0.7], ...
    DisplayName="Time-averaged |CWT|");
hold(ax5,"on");
if ~isempty(sigLevel)
    plot(ax5,sigLevel,periodHours,"--",LineWidth=1.3,Color=[0.6 0.6 0.6], ...
        DisplayName="95% vs AR(1) red noise");
end
for k = 1:numel(refPeriods)
    yline(ax5,hours(refPeriods(k)),":",refLabels(k), ...
        Color=[0.2 0.2 0.2],LabelHorizontalAlignment="right",HandleVisibility="off");
end
hold(ax5,"off");
set(ax5,YScale="log",XScale="log");
ylabel(ax5,"Period (hours)"); xlabel(ax5,"Time-averaged |CWT| (mV)");
ylim(ax5,[min(periodHours) max(periodHours)]);
title(ax5,sprintf("Global wavelet spectrum - %s (%s)",varName,depthLabel),Interpreter="none");
legend(ax5,Location="southeast"); grid(ax5,"on"); box(ax5,"on");

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
        ratio = globalSpec(idxFull)/sigLevel(idxFull);
        % The 95% level is the 95th percentile of only nSurrogates draws, so it carries
        % sampling noise of its own; ratios close to 1 should not be read as verdicts.
        if ratio > 1.25
            flag = sprintf("  %.2fx the 95%% red-noise level  *significant",ratio);
        elseif ratio > 1
            flag = sprintf("  %.2fx the 95%% red-noise level  *borderline",ratio);
        else
            flag = sprintf("  %.2fx the 95%% red-noise level (not significant)",ratio);
        end
        % Long periods are averaged over little of the record once the COI is applied
        nCyc = (nValid(idxFull)/numel(t))*days(max(t)-min(t))/(pv(loc(k))/24);
        if nCyc < 3
            flag = flag + sprintf(" [only %.1f cycles supported]",nCyc);
        end
    end
    fprintf("  %7.2f h   |CWT| = %6.2f mV%s\n",pv(loc(k)),pk(k),flag);
end

%% Save
if ~isfolder(resultsFolder), mkdir(resultsFolder); end
stamp = sprintf("%s_%s_%s",varName,string(startDate,"yyyyMMdd"),string(dataEnd,"yyyyMMdd"));
savefig(fig1,fullfile(resultsFolder,"wavelet_"+stamp+".fig"));
exportgraphics(fig1,fullfile(resultsFolder,"wavelet_"+stamp+".png"),Resolution=150);
exportgraphics(fig2,fullfile(resultsFolder,"waveletGlobal_"+stamp+".png"),Resolution=150);

waveletSummary = struct( ...
    "varName",varName,"depthLabel",depthLabel, ...
    "startDate",startDate,"endDate",endDate, ...
    "period",period,"globalSpec",globalSpec,"sigLevel",sigLevel, ...
    "tidalBand",tidalBand,"time",t,"bandAmp",bandAmp, ...
    "diurnalBand",diurnalBand,"diurnalAmp",diurnalAmp, ...
    "springNeapBand",springNeapBand,"msfPeriod",msfPeriod,"snAmp",snAmp, ...
    "springNeapCoverage",springNeapCoverage, ...
    "nSurrogates",nSurrogates,"nInterpolated",nFilled);
save(fullfile(resultsFolder,"waveletSummary_"+stamp+".mat"),"waveletSummary");
if saveWaveletMat
    save(fullfile(resultsFolder,"waveletCWT_"+stamp+".mat"),"wt","period","coi","t","-v7.3");
end
fprintf("\nSaved figures and waveletSummary_%s.mat to %s\n",stamp,resultsFolder);
