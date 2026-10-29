function [tbl, flag, blocks] = maskPowerLoss(tbl, battTbl, opts)
%MASKPOWERLOSS NaN out redox values affected by low battery / logger shutdowns.
%   [tbl, flag, blocks] = maskPowerLoss(tbl, battTbl) masks the redox
%   columns (names like L07_...) of TBL around periods when the logger
%   lost power. BATTTBL is the 5-minute table that holds BatteryVolt_Min
%   (it can be TBL itself). Works for both the 1-minute and 5-minute tables.
%
%   A power-loss event is either
%     - a logging gap longer than opts.minGap that starts with the battery
%       below opts.gapVolts (the logger shut down), or
%     - a 5-minute record with BatteryVolt_Min below opts.minVolts.
%   Each event is masked from opts.preBuffer before it to opts.settle after
%   logging resumes, because the probes take several hours to re-equilibrate
%   after a restart. Masked blocks closer than opts.mergeGap are joined, so a
%   run of nightly shutdowns (e.g. 25-31 May 2026) becomes one block.
%
%   Outputs: TBL with masked values set to NaN and a logical lowBattFlag
%   column, FLAG (same as the column), and BLOCKS, a table of masked
%   start/stop times.
%
%   Example:
%     lowMarsh5MinuteTbl = maskPowerLoss(lowMarsh5MinuteTbl, lowMarsh5MinuteTbl);
%     lowMarshMinuteTbl  = maskPowerLoss(lowMarshMinuteTbl,  lowMarsh5MinuteTbl);

arguments
    tbl timetable
    battTbl timetable
    opts.minVolts  (1,1) double   = 11.9
    opts.gapVolts  (1,1) double   = 12.2
    opts.minGap    (1,1) duration = minutes(30)
    opts.preBuffer (1,1) duration = minutes(30)
    opts.settle    (1,1) duration = hours(6)
    opts.mergeGap  (1,1) duration = hours(12)
    opts.vars      string         = string.empty
end

tb = battTbl.Properties.RowTimes;
v  = battTbl.BatteryVolt_Min;

% Shutdowns: gaps that begin with a low battery. Mask from the last record
% before the gap through the settling period after restart.
dt = diff(tb);
iGap = find(dt > opts.minGap & v(1:end-1) < opts.gapVolts);
evStart = tb(iGap) - opts.preBuffer;
evStop  = tb(iGap+1) + opts.settle;

% Low-voltage records without a shutdown. Each 5-min record covers the
% 5 minutes before its time stamp.
iLow = find(v < opts.minVolts);
evStart = [evStart; tb(iLow) - minutes(5) - opts.preBuffer];
evStop  = [evStop;  tb(iLow) + opts.settle];

% Merge overlapping or nearby events into blocks.
[evStart, o] = sort(evStart); evStop = evStop(o);
bStart = evStart([]); bStop = evStop([]);
for k = 1:numel(evStart)
    if ~isempty(bStop) && evStart(k) <= bStop(end) + opts.mergeGap
        bStop(end) = max(bStop(end), evStop(k));
    else
        bStart(end+1,1) = evStart(k); %#ok<AGROW>
        bStop(end+1,1)  = evStop(k);  %#ok<AGROW>
    end
end
blocks = timetable(bStart, bStop, hours(bStop - bStart), ...
    'VariableNames', ["stop", "hours"]);
blocks.Properties.DimensionNames{1} = 'start';

% Apply to tbl.
t = tbl.Properties.RowTimes;
flag = false(height(tbl), 1);
for k = 1:numel(bStart)
    flag = flag | (t > bStart(k) & t <= bStop(k));
end
if isempty(opts.vars)
    names = string(tbl.Properties.VariableNames);
    opts.vars = names(~cellfun(@isempty, regexp(names, '^L\d\d_')));
end
tbl{flag, opts.vars} = NaN;
tbl.lowBattFlag = flag;
end
