%[text] ## Is the ~12 h redox cycle lunar (M2) or solar (S2)?
%[text] The CWT cannot separate M2 (12.4206 h) from S2 (12.0000 h): they differ by 3.5%
%[text] while one voice at 12 voices/octave spans 5.95%. Over a ~64-day record the two are
%[text] comfortably separable by least squares (df = 4.3 x the Rayleigh resolution 1/T), so
%[text] this script settles it three ways: a Lomb-Scargle periodogram on a dense grid, a
%[text] simultaneous harmonic fit, and a phase/amplitude comparison against the predicted tide.
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

% Constituents fitted simultaneously. Only mutually separable ones are included.
% Over this ~64-day window N2 (12.6583 h) is now 2.3x the Rayleigh limit from M2 and
% 6.6x from S2, so it is included here (it was dropped from the 28-day P2 fit at 1.02x).
% Only ONE diurnal term is fitted: K1 (23.9345 h) and S1 (24.0000 h) are separated by
% just 0.17x the Rayleigh limit, so any diurnal peak cannot be attributed to solar
% versus lunar origin from this record. The term is named "D1" to keep that explicit.
constit = struct( ...
    "name",   {"S2"    ,"M2"     ,"N2"     ,"D1"   ,"O1"     ,"S4"  ,"M4"    }, ...
    "period", { 12.0000, 12.4206 , 12.6583 ,24.0000, 25.8193 ,6.0000, 6.2103 }, ...
    "note",   {"solar semidiurnal","lunar semidiurnal","lunar elliptic semidiurnal", ...
               "diurnal (S1/K1 unresolved)","lunar diurnal", ...
               "solar quarter-diurnal","lunar quarter-diurnal"});

lfCutoffHours = 48;              % drift absorbed by a Fourier basis of periods > this
bandHours     = [11 13.5];       % Lomb-Scargle zoom window
nFreq         = 20000;           % dense frequency grid across that band

%% Load the redox channel
load(fullfile(resultsFolder,"typhaMarshMinuteTbl_Eh.mat"),"typhaMarshMinuteTbl_Eh");
T = typhaMarshMinuteTbl_Eh;

% timerange is half-open, so extend one sample past the last timestamp to include it
dataEnd = max(T.Properties.RowTimes);
endDate = dataEnd + minutes(1);

W = T(timerange(startDate,endDate), varName);
W = retime(W,"regular","linear","TimeStep",minutes(1));
tEh = W.Properties.RowTimes;
xEh = fillmissing(W.(varName),"linear");

%% Load the predicted tide over the same window
Std = load(fullfile(resultsFolder,"TidesTimetable.mat"),"TidesTimetable");
T2 = Std.TidesTimetable;
V = T2(timerange(startDate,endDate),:);
tTide = V.Properties.RowTimes;
xTide = V.Prediction;

fprintf("Window %s .. %s (last sample in the data)\n", ...
    string(startDate,"yyyy-MM-dd HH:mm"),string(dataEnd,"yyyy-MM-dd HH:mm"));
fprintf("  Eh   : %d samples (%s step)\n",numel(xEh),string(median(diff(tEh))));
fprintf("  Tide : %d samples (%s step)\n",numel(xTide),string(median(diff(tTide))));

spanHours = hours(max(tEh)-min(tEh));
rayleigh  = 1/spanHours;                                   % cycles per hour
sep = @(p1,p2) abs(1/p1 - 1/p2)/rayleigh;                  % separation in Rayleigh units
dfM2S2 = abs(1/constit(2).period - 1/constit(1).period);
fprintf("  span = %.2f days; Rayleigh = %.6f cyc/h\n",spanHours/24,rayleigh);
fprintf("  separability (x Rayleigh; >1 required to resolve a pair):\n");
fprintf("    M2 vs S2 = %.2fx    M2 vs N2 = %.2fx    N2 vs S2 = %.2fx\n", ...
    sep(12.4206,12.0000), sep(12.4206,12.6583), sep(12.6583,12.0000));
fprintf("    D1 vs O1 = %.2fx    K1 vs S1 = %.2fx (NOT resolvable - one diurnal term only)\n", ...
    sep(24.0000,25.8193), sep(23.9345,24.0000));
if dfM2S2 < rayleigh
    warning("M2 and S2 are NOT separable over this window; results below are unreliable.");
end

%% Harmonic fit of both series
fitEh   = harmonicFit(tEh,   xEh,   constit, lfCutoffHours);
fitTide = harmonicFit(tTide, xTide, constit, lfCutoffHours);

fprintf("\n=== %s (%s) - harmonic fit ===\n",varName,depthLabel);
printFit(fitEh,constit,"mV");
fprintf("\n=== Predicted tide - harmonic fit ===\n");
printFit(fitTide,constit,"m");

%% Lomb-Scargle periodogram over the semidiurnal band
fGrid = linspace(1/bandHours(2), 1/bandHours(1), nFreq);   % cycles per hour
[pEh,  ~] = plomb(fitEh.residLF,   hours(tEh   - tEh(1)),   fGrid);
[pTide,~] = plomb(fitTide.residLF, hours(tTide - tTide(1)), fGrid);

[~,iEh]   = max(pEh);
[~,iTide] = max(pTide);
peakEh    = 1/fGrid(iEh);
peakTide  = 1/fGrid(iTide);
fprintf("\nLomb-Scargle peak in %g-%g h band:\n",bandHours(1),bandHours(2));
fprintf("  Eh   : %.4f h   (S2 = 12.0000, M2 = %.4f)\n",peakEh,constit(2).period);
fprintf("  Tide : %.4f h\n",peakTide);

% A single peak location only means something if the band holds one dominant line.
% Count the independent frequencies in the band and list the leading peaks: if several
% peaks of comparable height sit at periods with no tidal meaning, the band is
% noise-dominated and the winner of the M2-vs-S2 contest is decided by chance.
nIndep = (1/bandHours(1) - 1/bandHours(2))/rayleigh;
fprintf("  band holds %.0f independent frequencies (Rayleigh-spaced)\n",nIndep);
% Require peaks to be at least half a Rayleigh width apart so each is a distinct line
minSep = max(1,round(0.5*rayleigh/mean(diff(fGrid))));
[pkList,locList] = findpeaks(pEh/max(pEh),"SortStr","descend","MinPeakDistance",minSep);
fprintf("  leading Eh peaks (normalised power):\n");
for k = 1:min(4,numel(pkList))
    pd = 1/fGrid(locList(k));
    [~,jNear] = min(abs([constit.period] - pd));
    nearD = abs(1/pd - 1/constit(jNear).period)/rayleigh;
    if nearD <= 1
        tag = sprintf("= %s",constit(jNear).name);
    else
        tag = sprintf("no constituent within 1 Rayleigh (nearest %s at %.1fx)", ...
            constit(jNear).name,nearD);
    end
    fprintf("    %.4f h  power %.2f   %s\n",pd,pkList(k),tag);
end

%% Verdict
% The conclusion rests on where the spectral peak sits and on the M2/S2 and N2/M2
% amplitude ratios measured against the tide control - NOT on the significance of
% individual constituent amplitudes. Residual lag-1 autocorrelation at 1-minute
% sampling is ~0.998, so the AR(1) correction inflates parameter variances by ~1000x
% and every individual amplitude looks marginal regardless of how real it is.
iS2 = 1; iM2 = 2; iN2 = 3; iD1 = 4;
rEh   = fitEh.amp(iM2)  /fitEh.amp(iS2);
rTide = fitTide.amp(iM2)/fitTide.amp(iS2);
nEh   = fitEh.amp(iN2)  /fitEh.amp(iM2);
nTide = fitTide.amp(iN2)/fitTide.amp(iM2);

fprintf("\n=== Verdict ===\n");
fprintf("  M2/S2 amplitude ratio : Eh = %.2f   tide = %.2f\n",rEh,rTide);
snrS2 = fitEh.amp(iS2)/fitEh.ampSE(iS2);
snrM2 = fitEh.amp(iM2)/fitEh.ampSE(iM2);
snrN2 = fitEh.amp(iN2)/fitEh.ampSE(iN2);
snrD1 = fitEh.amp(iD1)/fitEh.ampSE(iD1);
fprintf("  Eh amplitudes: S2 = %.3f +/- %.3f mV (%.1f sigma)\n",fitEh.amp(iS2),fitEh.ampSE(iS2),snrS2);
fprintf("                 M2 = %.3f +/- %.3f mV (%.1f sigma)\n",fitEh.amp(iM2),fitEh.ampSE(iM2),snrM2);
fprintf("                 N2 = %.3f +/- %.3f mV (%.1f sigma)\n",fitEh.amp(iN2),fitEh.ampSE(iN2),snrN2);
fprintf("                 D1 = %.3f +/- %.3f mV (%.1f sigma)  [solar vs lunar NOT attributable]\n", ...
    fitEh.amp(iD1),fitEh.ampSE(iD1),snrD1);

% The N2/M2 ratio is only informative if N2 is actually resolved. Quoting it when
% both terms are consistent with zero would manufacture agreement out of noise.
if snrN2 >= 2 && snrM2 >= 2
    fprintf("  N2/M2 amplitude ratio : Eh = %.2f   tide = %.2f", nEh,nTide);
    fprintf("   (tidal forcing should track the tide's ratio)\n");
else
    fprintf("  N2/M2 ratio not reported: N2 (%.1f sigma) and/or M2 (%.1f sigma) unresolved,\n", ...
        snrN2,snrM2);
    fprintf("    so the ratio (Eh %.2f vs tide %.2f) is noise over noise and carries no weight.\n", ...
        nEh,nTide);
end

% Only interpret a phase if the corresponding amplitude is actually resolved
if snrM2 >= 2
    dPhase = mod(fitEh.phase(iM2) - fitTide.phase(iM2) + 180, 360) - 180;
    fprintf("  M2 phase difference (Eh - tide) = %+.1f deg (%.2f h lag)\n", ...
        dPhase, dPhase/360*constit(iM2).period);
else
    fprintf("  M2 phase not reported: amplitude is only %.1f sigma, so its phase is meaningless.\n",snrM2);
end

% Primary evidence: does the semidiurnal peak land on M2 or on S2?
dPeakM2 = abs(1/peakEh - 1/constit(iM2).period)/rayleigh;
dPeakS2 = abs(1/peakEh - 1/constit(iS2).period)/rayleigh;
fprintf("  LS peak at %.4f h is %.2f Rayleigh widths from M2 and %.2f from S2\n", ...
    peakEh, dPeakM2, dPeakS2);
% An M2-vs-S2 attribution is only meaningful if there is a semidiurnal signal to
% attribute. If neither term is resolved, the peak location is merely picking the
% tallest of the band's independent noise peaks and must not be read as a result.
if max(snrS2,snrM2) < 2
    fprintf("  => SEMIDIURNAL BAND UNRESOLVED. S2 (%.1f sigma) and M2 (%.1f sigma) are both\n", ...
        snrS2,snrM2);
    fprintf("     consistent with zero, so M2 vs S2 cannot be decided for this channel.\n");
    fprintf("     What IS robust: tidal forcing is NOT supported. The predicted tide is\n");
    fprintf("     strongly M2-dominated (M2/S2 = %.2f), and a tidally driven redox signal\n",rTide);
    fprintf("     would inherit that. This record gives M2/S2 = %.2f with no N2 sideband.\n",rEh);
elseif rEh < 1 && rTide > 1
    fprintf("  => SOLAR. The redox cycle is S2-dominated while the tide is M2-dominated.\n");
    fprintf("     Carried by the peak location (%.2f vs %.2f Rayleigh widths from S2/M2)\n",dPeakS2,dPeakM2);
    fprintf("     and the M2/S2 ratio against the tide control, not by per-constituent SNR.\n");
elseif rEh > 1 && rTide > 1
    fprintf("  => LUNAR/TIDAL. Both series are M2-dominated.\n");
    fprintf("     Carried by the peak location (%.2f vs %.2f Rayleigh widths from S2/M2)\n",dPeakS2,dPeakM2);
    fprintf("     and the M2/S2 ratio against the tide control, not by per-constituent SNR.\n");
else
    fprintf("  => Ambiguous; inspect the amplitudes and phases above.\n");
end

%% Figure
fig = figure(Position=[100 100 1150 820], Color="w");
tl = tiledlayout(fig,2,2,TileSpacing="compact",Padding="compact");

ax1 = nexttile(tl,[1 2]);
plot(ax1,1./fGrid,pEh/max(pEh),LineWidth=1.5,Color=[0 0.35 0.7],DisplayName=varName);
hold(ax1,"on");
plot(ax1,1./fGrid,pTide/max(pTide),LineWidth=1.2,Color=[0.45 0.45 0.45], ...
    DisplayName="Predicted tide");
xline(ax1,constit(iS2).period,"-",  "S2 12.0000 h",Color=[0.85 0.33 0.10], ...
    LineWidth=1.4,HandleVisibility="off");
xline(ax1,constit(iM2).period,"-",  "M2 12.4206 h",Color=[0.10 0.55 0.20], ...
    LineWidth=1.4,LabelHorizontalAlignment="left",HandleVisibility="off");
hold(ax1,"off");
xlabel(ax1,"Period (hours)"); ylabel(ax1,"Normalised Lomb-Scargle power");
title(ax1,sprintf("Semidiurnal band - %s (%s) vs predicted tide",varName,depthLabel), ...
    Interpreter="none");
legend(ax1,Location="northwest",Interpreter="none"); grid(ax1,"on"); box(ax1,"on");
xlim(ax1,bandHours);

ax2 = nexttile(tl);
cNames = cellstr(string({constit.name}));
cNames = categorical(cNames,cNames);   % keep the declared order
bar(ax2,cNames,fitEh.amp,FaceColor=[0 0.35 0.7]);
hold(ax2,"on");
errorbar(ax2,1:numel(constit),fitEh.amp,fitEh.ampSE,"k",LineStyle="none",LineWidth=1.1);
hold(ax2,"off");
ylabel(ax2,"Amplitude (mV)"); title(ax2,"Redox constituents (+/- 1 SE)");
grid(ax2,"on"); box(ax2,"on");

ax3 = nexttile(tl);
bar(ax3,cNames,fitTide.amp,FaceColor=[0.45 0.45 0.45]);
ylabel(ax3,"Amplitude (m)"); title(ax3,"Predicted tide constituents");
grid(ax3,"on"); box(ax3,"on");

stamp = sprintf("%s_%s_%s",varName,string(startDate,"yyyyMMdd"),string(dataEnd,"yyyyMMdd"));
exportgraphics(fig,fullfile(resultsFolder,"lombScargle_M2vsS2_"+stamp+".png"),Resolution=150);
savefig(fig,fullfile(resultsFolder,"lombScargle_M2vsS2_"+stamp+".fig"));
fprintf("\nSaved lombScargle_M2vsS2_%s.png/.fig to %s\n",stamp,resultsFolder);

%% ---------------------------------------------------------------------------
function out = harmonicFit(t,x,constit,lfCutoffHours)
% Least-squares fit of tidal constituents on top of a low-frequency Fourier basis.
% Fitting the drift simultaneously keeps multi-day variability from leaking into
% the semidiurnal amplitudes.
th   = hours(t - t(1));
span = th(end);
x    = x(:);

% Constant + linear + Fourier terms for every period longer than the cutoff
X = [ones(numel(th),1), th(:)];
kMax = floor(span/lfCutoffHours);
for k = 1:kMax
    X = [X, cos(2*pi*k*th(:)/span), sin(2*pi*k*th(:)/span)]; %#ok<AGROW>
end
nLF = size(X,2);

for j = 1:numel(constit)
    w = 2*pi/constit(j).period;
    X = [X, cos(w*th(:)), sin(w*th(:))]; %#ok<AGROW>
end

beta  = X\x;
resid = x - X*beta;

% Residuals are strongly autocorrelated, so inflate the covariance by the AR(1)
% factor (1+r)/(1-r). This is an approximation, not an exact GLS solution.
r      = corr(resid(1:end-1),resid(2:end));
inflate = (1+r)/(1-r);
sigma2 = (resid'*resid)/(numel(x)-size(X,2)) * inflate;
C      = sigma2 * inv(X'*X); %#ok<MINV>

amp   = zeros(numel(constit),1);
ampSE = zeros(numel(constit),1);
phase = zeros(numel(constit),1);
for j = 1:numel(constit)
    ia = nLF + 2*j - 1; ib = ia + 1;
    a = beta(ia); b = beta(ib);
    amp(j)   = hypot(a,b);
    phase(j) = mod(atan2(b,a)*180/pi,360);
    g = [a b]/amp(j);                       % gradient of hypot
    ampSE(j) = sqrt(g * C([ia ib],[ia ib]) * g.');
end

out = struct("amp",amp,"ampSE",ampSE,"phase",phase,"resid",resid, ...
    "residLF",x - X(:,1:nLF)*beta(1:nLF), ...   % drift removed, constituents kept
    "lag1",r,"inflate",inflate);
end

function printFit(f,constit,unit)
fprintf("  %-4s %-24s %10s %10s %10s\n","name","description","amp","+/-SE","phase");
for j = 1:numel(constit)
    fprintf("  %-4s %-24s %8.3f %s %8.3f %s %8.1f deg\n", ...
        constit(j).name,constit(j).note,f.amp(j),unit,f.ampSE(j),unit,f.phase(j));
end
fprintf("  residual lag-1 autocorr = %.4f (variance inflated %.1fx)\n",f.lag1,f.inflate);
end
