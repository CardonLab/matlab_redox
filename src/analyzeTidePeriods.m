% Tidal period analysis for the major and minor high waters
%   Plum Island predictions are mixed semidiurnal: each tidal day carries two
%   high waters of unequal height. The taller is the higher high water (major)
%   and the shorter the lower high water (minor). This script extracts both,
%   measures the intervals within and between the two classes, and confirms
%   those intervals against a periodogram of the raw series.
%
%   Writes results\tidePeriods.mat and results\tidePeriods.png

scriptFile = mfilename("fullpath");
if isempty(scriptFile) % e.g. code pasted into the command window
    projectRoot = pwd;
else
    projectRoot = fileparts(fileparts(scriptFile)); % src\..
end
resultsFolder = fullfile(projectRoot,"results");

load(fullfile(resultsFolder,"TidesTimetable.mat"),"TidesTimetable");
t = TidesTimetable.Properties.RowTimes;
y = TidesTimetable.Prediction;
dt = median(diff(t));

%-------------------------------------------------------------------------------%
% Extract high waters and low waters
%-------------------------------------------------------------------------------%
% Successive high waters are ~12.4 h apart, so a 4 h exclusion is safely below
% the true spacing while still rejecting any shoulder on a flat crest.
minSep = round(hours(4)/dt);
[highVal,highIdx] = findpeaks(y,"MinPeakDistance",minSep);
[lowVal ,lowIdx ] = findpeaks(-y,"MinPeakDistance",minSep);
lowVal = -lowVal;
highTime = t(highIdx);
lowTime  = t(lowIdx);

%-------------------------------------------------------------------------------%
% Split the high waters into major (higher high) and minor (lower high)
%-------------------------------------------------------------------------------%
% Comparing a high water against its two immediate neighbours directly fails
% wherever the spring-neap trend outruns the diurnal inequality, giving a
% monotone run of three. Differencing against the MEAN of the neighbours
% removes that local linear trend and leaves only the tidal-day alternation,
% which is the quantity that actually separates the two classes.
n = numel(highVal);
alt = zeros(n,1);
alt(2:n-1) = highVal(2:n-1) - (highVal(1:n-2) + highVal(3:n))/2;
alt(1) = highVal(1) - highVal(2);   % endpoints have one neighbour only
alt(n) = highVal(n) - highVal(n-1);
isMajor = alt > 0;

majorTime = highTime(isMajor);   majorVal = highVal(isMajor);
minorTime = highTime(~isMajor);  minorVal = highVal(~isMajor);

% The inequality reverses when lunar declination crosses the equator, so which
% of the two daily highs is the taller genuinely swaps every ~13.7 days. Those
% reversals are real, not misclassification, and they are what puts the long
% and short tails on the same-class intervals below.
nReversal = sum(diff(isMajor) == 0);

%-------------------------------------------------------------------------------%
% Intervals within and between the two classes
%-------------------------------------------------------------------------------%
% major->minor and minor->major are measured on consecutive high waters only,
% so a class flip does not fabricate a doubled interval.
nextIsMinor = [isMajor(1:end-1) & ~isMajor(2:end); false];
nextIsMajor = [~isMajor(1:end-1) & isMajor(2:end); false];
stepToNext  = diff(highTime);

% A same-class interval is a true tidal day only when exactly one high water of
% the other class sits inside it. At a reversal that spacing breaks, splitting
% one 24.8 h step into a ~12.4 h and a ~37.2 h pair; those are reported apart
% so the tidal-day figure is not smeared by them.
majorIdx = find(isMajor);   minorIdx = find(~isMajor);
majorClean = diff(majorIdx) == 2;
minorClean = diff(minorIdx) == 2;
majorSteps = diff(majorTime);
minorSteps = diff(minorTime);

intervals = { ...
    "High to high (all)",            diff(highTime); ...
    "Major to major (tidal day)",    majorSteps(majorClean); ...
    "Minor to minor (tidal day)",    minorSteps(minorClean); ...
    "Major to major (at reversal)",  majorSteps(~majorClean); ...
    "Minor to minor (at reversal)",  minorSteps(~minorClean); ...
    "Major to next minor",           stepToNext(nextIsMinor(1:end-1)); ...
    "Minor to next major",           stepToNext(nextIsMajor(1:end-1)); ...
    "Low to low (all)",              diff(lowTime)};

rows = strings(size(intervals,1),1);
meanH = zeros(size(rows)); medH = meanH; sdH = meanH; minH = meanH; maxH = meanH; cnt = meanH;
for k = 1:size(intervals,1)
    h = hours(intervals{k,2});
    rows(k) = intervals{k,1};
    cnt(k)  = numel(h);
    meanH(k)= mean(h);   medH(k) = median(h);  sdH(k) = std(h);
    minH(k) = min(h);    maxH(k) = max(h);
end
periodTable = table(rows,cnt,meanH,medH,sdH,minH,maxH, ...
    'VariableNames',{'Interval','N','Mean_h','Median_h','SD_h','Min_h','Max_h'});

heightTable = table( ...
    ["Major (higher high)";"Minor (lower high)";"Diurnal inequality";"Low waters"], ...
    [numel(majorVal);numel(minorVal);min(numel(majorVal),numel(minorVal));numel(lowVal)], ...
    [mean(majorVal);mean(minorVal);NaN;mean(lowVal)], ...
    [std(majorVal);std(minorVal);NaN;std(lowVal)], ...
    [min(majorVal);min(minorVal);NaN;min(lowVal)], ...
    [max(majorVal);max(minorVal);NaN;max(lowVal)], ...
    'VariableNames',{'Class','N','Mean_ft','SD_ft','Min_ft','Max_ft'});
% Pair each major with the high water actually adjacent to it, rather than by
% position in the two lists, which would drift out of step at every reversal.
adjPair = find(diff(isMajor) ~= 0);
inequality = abs(highVal(adjPair) - highVal(adjPair+1));
heightTable.N(3)       = numel(inequality);
heightTable.Mean_ft(3) = mean(inequality);
heightTable.SD_ft(3)   = std(inequality);
heightTable.Min_ft(3)  = min(inequality);
heightTable.Max_ft(3)  = max(inequality);

%-------------------------------------------------------------------------------%
% Independent check: periodogram of the raw series
%-------------------------------------------------------------------------------%
% The interval statistics above are time-domain. A periodogram of the whole
% record should place power at the constituents those intervals imply. Picking
% the largest peaks is no good here: zero-padding puts sidelobes within a few
% hundredths of an hour of M2, and they crowd out every other constituent. So
% look up power at the known constituent periods instead, taking the maximum
% within one Rayleigh width (1/record length) of each nominal frequency.
fs = 1/seconds(dt);
[pxx,f] = periodogram(y-mean(y),[],2^nextpow2(numel(y))*4,fs);
recordSec = seconds(t(end)-t(1));
rayleigh  = 1/recordSec; % frequency resolution set by record length

name   = ["M2";"S2";"N2";"K2";"K1";"O1";"P1";"Q1";"M4";"M6"];
nominal= [12.4206;12.0000;12.6583;11.9672;23.9345;25.8193;24.0659;26.8684;6.2103;4.1402];
power  = zeros(size(nominal));
for k = 1:numel(nominal)
    f0 = 1/(nominal(k)*3600);
    band = f >= f0-rayleigh & f <= f0+rayleigh;
    power(k) = max(pxx(band));
end
constituents = table(name,nominal,power/max(power), ...
    'VariableNames',{'Constituent','Period_h','RelativePower'});
constituents = sortrows(constituents,"RelativePower","descend");

% Long-period modulation of high-water height. Rectifying the series would
% fold the major/minor alternation into spurious harmonics, so instead average
% the two high waters of each day: that cancels the alternation and leaves the
% envelope. M2 beating against S2 gives the 14.77 d spring-neap; against N2 it
% gives the 27.55 d anomalistic cycle, which at this site is the stronger of
% the two because N2 carries more power than S2.
daily = retime(timetable(highTime,highVal),"daily","mean");
env = fillmissing(daily.highVal,"linear");
[pxx2,f2] = periodogram(env-mean(env),[],2^16,1); % 1 sample per day
per2 = 1./f2;
band = per2 >= 5 & per2 <= 60;
perBand = per2(band); powBand = pxx2(band);
[~,mIdx] = findpeaks(powBand,"SortStr","descend","NPeaks",3, ...
    "MinPeakDistance",sum(perBand>13 & perBand<16));
modulation = sortrows(table(perBand(mIdx),powBand(mIdx)/max(powBand), ...
    'VariableNames',{'Period_days','RelativePower'}),"Period_days");

%-------------------------------------------------------------------------------%
% Report
%-------------------------------------------------------------------------------%
fprintf('\nRecord: %s to %s (%.1f days, %s sampling)\n', ...
    string(t(1)), string(t(end)), days(t(end)-t(1)), string(dt));
fprintf('High waters found: %d  (major %d, minor %d)\n', ...
    n, numel(majorVal), numel(minorVal));
fprintf('Inequality reversals (class repeats): %d, about one per %.1f days\n\n', ...
    nReversal, days(t(end)-t(1))/max(nReversal,1));
disp('--- Intervals (hours) ---'); disp(periodTable);
disp('--- Heights (feet, MLLW) ---'); disp(heightTable);
disp('--- Power at known constituents (relative to M2) ---'); disp(constituents);
disp('--- Long-period modulation of high-water height ---'); disp(modulation);

%-------------------------------------------------------------------------------%
% Figure
%-------------------------------------------------------------------------------%
fig = figure('Position',[100 100 1100 800],'Visible','off');

subplot(3,1,1)
show = t >= t(1) & t < t(1)+days(15);
plot(t(show),y(show),'-','Color',[0.6 0.6 0.6]); hold on
plot(majorTime(majorTime<t(1)+days(15)),majorVal(majorTime<t(1)+days(15)),'v', ...
    'MarkerFaceColor',[0.85 0.33 0.10],'MarkerEdgeColor','none','MarkerSize',7)
plot(minorTime(minorTime<t(1)+days(15)),minorVal(minorTime<t(1)+days(15)),'v', ...
    'MarkerFaceColor',[0 0.45 0.74],'MarkerEdgeColor','none','MarkerSize',7)
ylabel('Height (ft)'); title('High waters, first 15 days (spring-neap cycle visible)')
legend('Prediction','Major (higher high)','Minor (lower high)','Location','best')
grid on; hold off

subplot(3,1,2)
plot(majorTime,majorVal,'.-','Color',[0.85 0.33 0.10],'MarkerSize',8); hold on
plot(minorTime,minorVal,'.-','Color',[0 0.45 0.74],'MarkerSize',8)
ylabel('Height (ft)'); title('Major and minor high-water heights, full record')
legend('Major','Minor','Location','best'); grid on; hold off

subplot(3,1,3)
histogram(hours(diff(majorTime)),40,'FaceColor',[0.85 0.33 0.10],'FaceAlpha',0.6); hold on
histogram(hours(diff(minorTime)),40,'FaceColor',[0 0.45 0.74],'FaceAlpha',0.6)
xline(24.84,'k--','24.84 h (tidal day)','LineWidth',1.2)
xlabel('Interval (hours)'); ylabel('Count')
title('Same-class intervals'); legend('Major to major','Minor to minor','Location','best')
grid on; hold off

exportgraphics(fig,fullfile(resultsFolder,"tidePeriods.png"),'Resolution',150);
close(fig)

save(fullfile(resultsFolder,"tidePeriods.mat"), ...
    "periodTable","heightTable","constituents","modulation", ...
    "majorTime","majorVal","minorTime","minorVal","lowTime","lowVal");
