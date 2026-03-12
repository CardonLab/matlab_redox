% Given a timetable with battery voltage find groups of spiky logger voltage
% Returns the rows to set to NaN
% This function finds the rows the redox sensors that were affected by the 
% spiky logger voltage when the solar panel was charging the battery.  
% Logic of Function
% The MatLab function findpeaks, identifies voltage spikes above a threshold.
% A maximum gap between the spike is used to create a groups.
% The groups are use to build a logic array of times which can be used to
% delete the affected sensor data.

function rowsToNaN = findPeakGroups(tt) 

% --- Find Battery peaks ---
minPeakHeight = 13.8; % threshold to detect only large peaks
[peakVals, peakLocs] = findpeaks(tt{:,1}, 'MinPeakHeight',minPeakHeight);

% --- Group peaks that are close together ---
maxGap = 20; % max index gap between peaks to be considered in same group
peakGroups = {};
currentGroup = peakLocs(1);

for i = 2:length(peakLocs)
    if peakLocs(i) - peakLocs(i-1) <= maxGap
        currentGroup(end+1) = peakLocs(i);
    else
        peakGroups{end+1} = currentGroup; 
        currentGroup = peakLocs(i);
    end
end
peakGroups{end+1} = currentGroup; % add last group

% --- Find start and end indices of the group ---
rowsToNaN = false(height(tt),1); % Create a lodgic array same height as time table
% --- Find start and end indices of the group ---
for g = 1:length(peakGroups)
startIdx = cellfun(@(v) v(1), peakGroups(g)) -1;% 1 samples before first peak
endIdx = cellfun(@(v) v(end), peakGroups(g)) + 8; % 8 samples after last peak
rowsToNaN(startIdx:endIdx) = true;
end