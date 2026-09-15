%[text] ## Is the ~12 h redox cycle lunar (M2) or solar (S2)?
%[text] The CWT cannot separate M2 (12.4206 h) from S2 (12.0000 h): they differ by 3.5%
%[text] while one voice at 12 voices/octave spans 5.95%. Over a 28-day record the two are
%[text] separable by least squares (df = 1.9 x the Rayleigh resolution 1/T), so this script
%[text] settles it three ways: a Lomb-Scargle periodogram on a dense grid, a simultaneous
%[text] harmonic fit, and a phase/amplitude comparison against the predicted tide.
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
varName    = "P2_10cmEh";   % logger label; true depth 5 cm
depthLabel = "5 cm";
startDate  = datetime("2026-08-01 00:00:00","TimeZone","-05:00");
endDate    = datetime("2026-08-29 00:00:00","TimeZone","-05:00");

% Constituents fitted simultaneously. Only mutually separable ones are included:
% N2 (12.6583 h) is dropped because it sits 1.02x the Rayleigh limit from M2, and
% K1 (23.9345 h) is dropped because it is inseparable from S1 over 28 days.
constit = struct( ...
    "name",   {"S2"    ,"M2"     ,"S1"   ,"O1"     ,"S4"  ,"M4"    }, ...
    "period", { 12.0000, 12.4206 ,24.0000, 25.8193 ,6.0000, 6.2103 }, ...
    "note",   {"solar semidiurnal","lunar semidiurnal","solar diurnal", ...
               "lunar diurnal","solar quarter-diurnal","lunar quarter-diurnal"});

lfCutoffHours = 48;              % drift absorbed by a Fourier basis of periods > this
bandHours     = [11 13.5];       % Lomb-Scargle zoom window
nFreq         = 20000;           % dense frequency grid across that band

%% Load the redox channel
load(fullfile(resultsFolder,"typhaMarshMinuteTbl_Eh.mat"),"typhaMarshMinuteTbl_Eh");
T = typhaMarshMinuteTbl_Eh;
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

fprintf("Window %s .. %s\n",string(startDate),string(endDate));
fprintf("  Eh   : %d samples (%s step)\n",numel(xEh),string(median(diff(tEh))));
fprintf("  Tide : %d samples (%s step)\n",numel(xTide),string(median(diff(tTide))));

spanHours = hours(max(tEh)-min(tEh));
rayleigh  = 1/spanHours;                                   % cycles per hour
dfM2S2    = abs(1/constit(2).period - 1/constit(1).period);
fprintf("  span = %.2f days; Rayleigh = %.6f cyc/h; M2-S2 separation = %.6f cyc/h (%.2fx)\n", ...
    spanHours/24, rayleigh, dfM2S2, dfM2S2/rayleigh);
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

%% Verdict
iS2 = 1; iM2 = 2;
rEh   = fitEh.amp(iM2)  /fitEh.amp(iS2);
rTide = fitTide.amp(iM2)/fitTide.amp(iS2);
dPhase = mod(fitEh.phase(iM2) - fitTide.phase(iM2) + 180, 360) - 180;

fprintf("\n=== Verdict ===\n");
fprintf("  Eh   M2/S2 amplitude ratio = %.2f\n",rEh);
fprintf("  Tide M2/S2 amplitude ratio = %.2f\n",rTide);
fprintf("  M2 phase difference (Eh - tide) = %+.1f deg (%.2f h lag)\n", ...
    dPhase, dPhase/360*constit(iM2).period);
snrS2 = fitEh.amp(iS2)/fitEh.ampSE(iS2);
snrM2 = fitEh.amp(iM2)/fitEh.ampSE(iM2);
fprintf("  Eh S2 = %.3f +/- %.3f mV (%.1f sigma); M2 = %.3f +/- %.3f mV (%.1f sigma)\n", ...
    fitEh.amp(iS2),fitEh.ampSE(iS2),snrS2, fitEh.amp(iM2),fitEh.ampSE(iM2),snrM2);
if rEh < 1 && rTide > 1
    fprintf("  => SOLAR. The redox cycle is S2-dominated while the tide is M2-dominated.\n");
elseif rEh > 1 && rTide > 1
    fprintf("  => LUNAR/TIDAL. Both series are M2-dominated.\n");
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

exportgraphics(fig,fullfile(resultsFolder,"lombScargle_M2vsS2_"+varName+".png"),Resolution=150);
savefig(fig,fullfile(resultsFolder,"lombScargle_M2vsS2_"+varName+".fig"));
fprintf("\nSaved lombScargle_M2vsS2_%s.png/.fig to %s\n",varName,resultsFolder);

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
