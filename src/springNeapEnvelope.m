%[text] ## Is the semidiurnal redox amplitude modulated at the spring-neap period?
%[text] A spring-neap cycle is the beat between M2 and S2, so a tidally forced signal
%[text] carries it as a ~14.77 d modulation of the SEMIDIURNAL AMPLITUDE, not as a
%[text] 14.77 d line in Eh itself. Broad fortnightly power in the Eh spectrum arises
%[text] just as readily from aperiodic drift or a single step, so this script works on
%[text] the envelope of the 11-14 h band written by waveletTyphaRedox.m, with the
%[text] predicted tide as a positive control.
%[text]
%[text] Two traps are handled here. The envelope is very smooth, so at 1-minute
%[text] sampling any parametric standard error is meaningless - tested that way the
%[text] tide's unmistakable spring-neap cycle comes out at 0.3 sigma. Envelopes are
%[text] therefore reduced to daily means and judged by RANK against the other
%[text] independent periods in the band. And the largest modulation in a 5-30 d band
%[text] need not be spring-neap: M2 also beats with N2 at 27.55 d (the anomalistic
%[text] month), which dominates the tide whenever N2 exceeds S2, as it does here. The
%[text] statistic is therefore power AT Msf and its rank, not the global maximum.
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
% Must match the stamp written by waveletTyphaRedox.m for the run being analysed
summaryStamp = "P1_10cmEh_20260715_20260916";
varLabel     = "P1\_10cmEh";     % for figure text (TeX-escaped)

msfPeriod   = 14.765;            % M2-S2 beat, spring-neap, days
monthPeriod = 27.555;            % M2-N2 beat, anomalistic month, days
searchBand  = [5 30];            % modulation-period search range, days
semiBand    = [hours(11) hours(14)];  % semidiurnal band whose envelope is tested
nFreq       = 4000;
burstThreshold = 0.15;           % mV; daily-mean envelope peaks above this count as
                                 % bursts, chosen from the envelope's own scale (its
                                 % median is ~0.05 mV and its maximum ~0.66 mV)

%% Eh semidiurnal envelope, from the saved wavelet summary
S = load(fullfile(resultsFolder,"waveletSummary_"+summaryStamp+".mat"),"waveletSummary");
w = S.waveletSummary;
[tE,aE] = dailyEnvelope(w.time, w.bandAmp);

%% Predicted tide, same pipeline as a positive control
Std = load(fullfile(resultsFolder,"TidesTimetable.mat"),"TidesTimetable");
V = Std.TidesTimetable(timerange(min(w.time),max(w.time)+minutes(1)),:);
tTraw = V.Properties.RowTimes;
% cwt requires the sampling period and the period limits to share a Format
dtT = median(diff(tTraw));              dtT.Format = 'h';
plT = [hours(4) days(8)];               plT.Format = 'h';
[wtT,pT,coiT] = cwt(detrend(V.Prediction,1),'amor',dtT, ...
    VoicesPerOctave=12, PeriodLimits=plT);
ampT = abs(wtT);
ampT(~(hours(pT(:)) <= hours(coiT(:)).')) = NaN;
bT = pT >= semiBand(1) & pT <= semiBand(2);
[tT,aT] = dailyEnvelope(tTraw, mean(ampT(bT,:),1,"omitnan").');

spanDays = days(max(tE)-min(tE));
rayleigh = 1/spanDays;                                   % cycles per day
nIndep   = (1/searchBand(1) - 1/searchBand(2))/rayleigh;
fprintf("Eh   envelope: %d daily means, %s .. %s (%.2f d)\n",numel(aE), ...
    string(min(tE),"dd-MMM"),string(max(tE),"dd-MMM"),spanDays);
fprintf("Tide envelope: %d daily means, %s .. %s\n",numel(aT), ...
    string(min(tT),"dd-MMM"),string(max(tT),"dd-MMM"));
fprintf("Span covers %.2f spring-neap cycles; Rayleigh = %.4f cyc/d; " + ...
    "band holds %.1f independent periods\n",spanDays/msfPeriod,rayleigh,nIndep);

%% Lomb-Scargle of each envelope across the modulation-period search range
fGrid = linspace(1/searchBand(2), 1/searchBand(1), nFreq);
pE = plomb(detrend(aE,1), days(tE - tE(1)), fGrid);
pT2 = plomb(detrend(aT,1), days(tT - tT(1)), fGrid);

fprintf("\n--- Predicted tide (positive control) ---\n");
reportBand(fGrid,pT2,msfPeriod,monthPeriod,rayleigh,nIndep);
fprintf("\n--- %s ---\n",w.varName);
reportBand(fGrid,pE,msfPeriod,monthPeriod,rayleigh,nIndep);

%% Phase alignment
% Power at the spring-neap period is necessary but not sufficient. If the redox
% semidiurnal bursts are driven by spring tides then the phase of the 14.77 d
% component must align with the tide's own spring-neap phase.
t0  = min([min(tE) min(tT)]);
phE = msfPhase(tE,aE,msfPeriod,t0);
phT = msfPhase(tT,aT,msfPeriod,t0);
dPh = mod(phE - phT + 180,360) - 180;
fprintf("\n--- Spring-neap phase alignment ---\n");
fprintf("  Eh   envelope Msf phase: %6.1f deg\n",phE);
fprintf("  Tide envelope Msf phase: %6.1f deg\n",phT);
fprintf("  difference: %+.1f deg = %+.2f days out of %.2f\n", ...
    dPh, dPh/360*msfPeriod, msfPeriod);
if abs(dPh) <= 45
    fprintf("  => in phase: Eh semidiurnal bursts coincide with spring tides\n");
elseif abs(dPh) >= 135
    fprintf("  => anti-phase: Eh semidiurnal bursts coincide with NEAP tides\n");
else
    fprintf("  => neither in phase nor anti-phase; no simple spring-neap relationship\n");
end

%% Does the modulation persist, and do the bursts land on spring tides?
% A genuine spring-neap modulation continues for as long as the forcing does, so
% compare the first and second parts of the record, and time each Eh burst against
% the maxima of the tide's own semidiurnal envelope (the operational spring tides).
[~,lspring] = findpeaks(aT,"MinPeakDistance",7);
springDates = tT(lspring);
fprintf("\n--- Persistence and burst timing ---\n");
fprintf("  spring tides (tide envelope maxima): %s\n", ...
    strjoin(string(springDates,"dd-MMM"),", "));
[~,lburst] = findpeaks(aE,"MinPeakDistance",5,"MinPeakHeight",burstThreshold);
burstDates = tE(lburst);
fprintf("  Eh semidiurnal bursts: %s\n",strjoin(string(burstDates,"dd-MMM"),", "));
for k = 1:numel(burstDates)
    fprintf("    %s : %.1f d from the nearest spring tide\n", ...
        string(burstDates(k),"dd-MMM"), min(abs(days(burstDates(k)-springDates))));
end
% Split at the last burst so "after" covers the quiet tail
splitAt = max(burstDates) + days(2);
e1 = aE(tE <  splitAt); e2 = aE(tE >= splitAt);
if ~isempty(e2)
    fprintf("  envelope mean before %s: %.4f mV (n=%d); after: %.4f mV (n=%d); ratio %.1fx\n", ...
        string(splitAt,"dd-MMM"),mean(e1,"omitnan"),numel(e1), ...
        mean(e2,"omitnan"),numel(e2),mean(e1,"omitnan")/mean(e2,"omitnan"));
    fprintf("  largest value after %s: %.4f mV (mean before was %.4f mV)\n", ...
        string(splitAt,"dd-MMM"),max(e2),mean(e1,"omitnan"));
end

%% Figure
fig = figure(Position=[100 100 1100 800], Color="w");
tl = tiledlayout(fig,3,1,TileSpacing="compact",Padding="compact");

ax1 = nexttile(tl);
plot(ax1,tE,aE,"-o",LineWidth=1.3,MarkerSize=3,Color=[0.75 0.1 0.1]);
ylabel(ax1,sprintf("|CWT| %g-%g h (mV)",hours(semiBand(1)),hours(semiBand(2))));
grid(ax1,"on"); box(ax1,"on");
title(ax1,varLabel+" semidiurnal amplitude envelope, daily means (COI interior)");

ax2 = nexttile(tl);
plot(ax2,tT,aT,"-o",LineWidth=1.3,MarkerSize=3,Color=[0.3 0.3 0.3]);
ylabel(ax2,sprintf("|CWT| %g-%g h (m)",hours(semiBand(1)),hours(semiBand(2))));
grid(ax2,"on"); box(ax2,"on");
title(ax2,"Predicted tide semidiurnal envelope, daily means - positive control");
xlabel(ax2,"Date");
linkaxes([ax1 ax2],"x"); xlim(ax1,[min(tE) max(tE)]);

ax3 = nexttile(tl);
plot(ax3,1./fGrid,pE/max(pE),LineWidth=1.6,Color=[0.75 0.1 0.1],DisplayName=varLabel);
hold(ax3,"on");
plot(ax3,1./fGrid,pT2/max(pT2),LineWidth=1.3,Color=[0.3 0.3 0.3], ...
    DisplayName="Predicted tide");
xline(ax3,msfPeriod,"-",sprintf("Msf %.2f d",msfPeriod), ...
    Color=[0.1 0.45 0.75],LineWidth=1.5,HandleVisibility="off");
xline(ax3,monthPeriod,"--",sprintf("M2-N2 %.2f d",monthPeriod), ...
    Color=[0.45 0.25 0.6],LineWidth=1.3, ...
    LabelHorizontalAlignment="left",HandleVisibility="off");
hold(ax3,"off");
xlabel(ax3,"Modulation period (days)"); ylabel(ax3,"Normalised LS power");
title(ax3,"Spring-neap test: periodogram of the semidiurnal amplitude envelope");
legend(ax3,Location="north"); grid(ax3,"on"); box(ax3,"on"); xlim(ax3,searchBand);

exportgraphics(fig,fullfile(resultsFolder,"springNeap_"+summaryStamp+".png"),Resolution=150);
savefig(fig,fullfile(resultsFolder,"springNeap_"+summaryStamp+".fig"));
fprintf("\nSaved springNeap_%s.png/.fig to %s\n",summaryStamp,resultsFolder);

%% ---------------------------------------------------------------------------
function [td,ad] = dailyEnvelope(t,a)
% Trim to the cone-of-influence interior, then reduce to daily means so the degrees
% of freedom are honest rather than inflated by 1-minute sampling.
ok = ~isnan(a);
i1 = find(ok,1); i2 = find(ok,1,"last");
t = t(i1:i2); a = fillmissing(a(i1:i2),"linear");
TT = retime(timetable(t,a),"daily","mean");
td = TT.Properties.RowTimes; ad = TT.a;
keep = ~isnan(ad); td = td(keep); ad = ad(keep);
end

function ph = msfPhase(t,y,per,t0)
% Phase of the Msf component in degrees, referenced to a common origin t0, fitted on
% top of a linear trend. Phase 0 means the envelope peaks at t0.
th = days(t - t0); y = y(:);
X = [ones(numel(th),1), th(:), cos(2*pi*th/per), sin(2*pi*th/per)];
b = X\y;
ph = mod(atan2(b(4),b(3))*180/pi,360);
end

function reportBand(fGrid,p,msf,mnth,rayleigh,nIndep)
% Power at the two candidate beat periods and how Msf ranks among the band's
% independent periods. Rank is used instead of a parametric significance because the
% envelope's autocorrelation makes any variance model unusable.
pn = p/max(p);
[~,iM] = min(abs(fGrid - 1/msf));
[~,iN] = min(abs(fGrid - 1/mnth));
minSep = max(1,round(0.5*rayleigh/mean(diff(fGrid))));
[pk,lc] = findpeaks(pn,"SortStr","descend","MinPeakDistance",minSep);
fprintf("  global max at %.3f d (normalised power 1.00)\n",1/fGrid(lc(1)));
fprintf("  power at Msf   %.2f d: %.3f\n",1/fGrid(iM),pn(iM));
fprintf("  power at M2-N2 %.2f d: %.3f\n",1/fGrid(iN),pn(iN));
fInd = linspace(min(fGrid),max(fGrid),max(2,round(nIndep)));
nAbove = sum(interp1(fGrid,pn,fInd) >= pn(iM));
fprintf("  Msf rank %d of %d independent periods (%d exceed it; crude p ~ %.2f)\n", ...
    nAbove+1, round(nIndep)+1, nAbove, (nAbove+1)/(round(nIndep)+1));
fprintf("  nearest local peak to Msf: %.2f Rayleigh widths away\n", ...
    min(abs(fGrid(lc) - 1/msf))/rayleigh);
for k = 1:min(3,numel(pk))
    fprintf("    peak %d: %6.3f d  power %.2f\n",k,1/fGrid(lc(k)),pk(k));
end
end
