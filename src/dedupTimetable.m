function tbl = dedupTimetable(tbl,name)
% Remove duplicate rows and guarantee unique, ascending row times
%   Logger files are appended to on every download, so the same records are
%   often written more than once. Rows that are duplicated exactly are simply
%   dropped. Rows that share a timestamp but disagree on values cannot both be
%   kept: the last one (from the most recent download) wins and a warning
%   reports how many were collapsed. Without this, repeated row times survive
%   into synchronize/retime, which fail there instead of here.
    if nargin < 2
        name = "timetable";
    end
    tbl = unique(tbl,"rows"); % Drop rows that are duplicated exactly
    tbl = sortrows(tbl);      % Ascending row times

    rowTimes = tbl.Properties.RowTimes;
    [~,lastIdx] = unique(rowTimes,"last");
    nCollapsed = height(tbl) - numel(lastIdx);
    if nCollapsed > 0
        warning("dedupTimetable:conflictingRows", ...
            "%s: %d row(s) share a timestamp with conflicting values; keeping the last of each. First at %s.", ...
            name, nCollapsed, string(rowTimes(find(diff(rowTimes) == seconds(0),1))));
        tbl = tbl(sort(lastIdx),:);
    end
end
