%% Relationship between tidal cycle and groundwater redox potential (Eh)
% Author: [Your Name]
% Date: 2026-03-05

clear; clc; close all;

%% 1. Load or simulate data
% Replace this section with your real data import
% Example: data = readtable('tidal_redox_data.csv');

% Simulated time vector (hourly for 30 days)
t = datetime(2023,1,1,0,0,0) + hours(0:1:(30*24-1));

% Simulated tidal cycle (semi-diurnal ~12.42h period)
tide_height = 1.5 * sin(2*pi*(1/12.42) * hours(t - t(1))) + ...
              0.3 * randn(size(t)); % add noise

% Simulated redox potential (Eh) with lag and noise
lag_hours = 6; % groundwater response delay
Eh = 200 + 50 * sin(2*pi*(1/12.42) * hours(t - t(1) - hours(lag_hours))) + ...
     10 * randn(size(t));

%% 2. Preprocessing
% Remove NaNs if present
valid_idx = ~isnan(tide_height) & ~isnan(Eh);
t = t(valid_idx);
tide_height = tide_height(valid_idx);
Eh = Eh(valid_idx);

% Detrend to focus on cyclic variations
tide_detr = detrend(tide_height);
Eh_detr = detrend(Eh);

%% 3. Cross-correlation analysis
[cc,lags] = xcorr(tide_detr, Eh_detr, 'coeff');
lag_hours_vec = lags; % since data is hourly

figure;
plot(lag_hours_vec, cc, 'LineWidth', 1.5);
xlabel('Lag (hours)');
ylabel('Cross-correlation coefficient');
title('Tide–Eh Cross-Correlation');
grid on;

% Find lag with maximum correlation
[~,maxIdx] = max(abs(cc));
fprintf('Max correlation at lag = %d hours, r = %.2f\n', ...
        lag_hours_vec(maxIdx), cc(maxIdx));

%% 4. Wavelet coherence analysis
% Requires MATLAB Wavelet Toolbox
figure;
wcoherence(tide_detr, Eh_detr, hours(1), 'PhaseDisplayThreshold', 0.7);
title('Wavelet Coherence: Tide vs. Eh');

%% 5. Interpretation
% - Cross-correlation shows the dominant lag between tide and Eh.
% - Wavelet coherence shows how the relationship changes over time and frequency.


%% Preprocess Eh and Tide Time Series From Copilot
% Inputs needed in workspace:
%   t_eh   - datetime vector for Eh measurements
%   Eh_raw - numeric vector (mV) same length as t_eh
%   t_tide - datetime vector for tide/water-level measurements
%   tide   - numeric vector (m) same length as t_tide
%
% Example: load your variables or replace above names.

% Parameters (tune these)
dt_minutes = 10;           % target regular sampling interval
smoothing_window = 5;      % window in samples for median smoothing
hp_cutoff_hours = 48;      % high-pass cutoff to remove long-term trend (hours)
lp_cutoff_hours = 6;       % low-pass cutoff to isolate tidal band (hours)
fs = 60/dt_minutes;        % samples per hour

%% 1. Create timetables and merge
tt_eh   = timetable(t_eh(:), Eh_raw(:), 'VariableNames', {'Eh'});
tt_tide = timetable(t_tide(:), tide(:), 'VariableNames', {'Tide'});

% Combine into one timetable (outerjoin keeps all times)
tt = synchronize(tt_eh, tt_tide, 'union');

%% 2. Regularize to fixed time grid
t0 = min(tt.Properties.RowTimes);
tend = max(tt.Properties.RowTimes);
newTime = (t0:minutes(dt_minutes):tend)';
tt_reg = retime(tt, newTime, 'linear');  % linear interp for initial alignment

%% 3. Remove obvious outliers (pointwise) and spikes
% Mark outliers using median rule (or 'movmedian' residuals)
eh = tt_reg.Eh;
tideV = tt_reg.Tide;

% Use isoutlier with median absolute deviation or threshold
eh_out = isoutlier(eh, 'median', 'ThresholdFactor', 3); 
tide_out = isoutlier(tideV, 'median', 'ThresholdFactor', 3);

% Replace outliers with NaN for later filling
eh(eh_out) = NaN;
tideV(tide_out) = NaN;

%% 4. Fill small gaps / missing values
% First-pass: fill short gaps by linear interpolation, longer by moving mean
maxGapSamples = round(6*60/dt_minutes); % e.g., up to 6 hours
eh = fillmissing(eh, 'linear', 'MaxGap', maxGapSamples);
eh = fillmissing(eh, 'movmean', smoothing_window); % remaining gaps
tideV = fillmissing(tideV, 'linear', 'MaxGap', maxGapSamples);
tideV = fillmissing(tideV, 'movmean', smoothing_window);

%% 5. Smooth to remove high-frequency noise (median then lowpass)
eh = medfilt1(eh, smoothing_window, [], 1);  % median filter
tideV = medfilt1(tideV, smoothing_window, [], 1);

% Design Butterworth bandpass around tidal frequencies (optional)
% Convert cutoff to normalized frequency (Hz). fs in samples/hour -> convert to Hz
fs_hz = fs / 3600; % samples per second
hp_cutoff_hz = 1/(hp_cutoff_hours*3600);
lp_cutoff_hz = 1/(lp_cutoff_hours*3600);

% If you want bandpass (hp + lp), make sure cutoffs valid
if hp_cutoff_hz < lp_cutoff_hz
    [b,a] = butter(2, [hp_cutoff_hz, lp_cutoff_hz] / (fs_hz/2), 'bandpass');
    eh_f = filtfilt(b, a, eh);
    tide_f = filtfilt(b, a, tideV);
else
    % fallback: simple lowpass to isolate tidal-band variability
    Wn = lp_cutoff_hz / (fs_hz/2);
    if Wn >= 1, Wn = 0.99; end
    [b,a] = butter(2, Wn, 'low');
    eh_f = filtfilt(b, a, eh);
    tide_f = filtfilt(b, a, tideV);
end

%% 6. Remove linear trend (detrend) if needed
eh_dt = detrend(eh_f);       % removes linear trend
tide_dt = detrend(tide_f);

%% 7. Save preprocessed timetable and quick QC plot
tt_proc = timetable(newTime, eh, tideV, eh_f, tide_f, eh_dt, tide_dt, ...
    'VariableNames', {'Eh_raw','Tide_raw','Eh_smoothed','Tide_smoothed','Eh_detrend','Tide_detrend'});

% Quick diagnostic plots
figure('Name','Preprocessed Eh and Tide','NumberTitle','off','Units','normalized','Position',[0.1 0.1 0.8 0.6]);
subplot(2,1,1);
plot(tt_proc.Time, tt_proc.Eh_raw, '.', 'DisplayName','raw'); hold on;
plot(tt_proc.Time, tt_proc.Eh_smoothed, '-', 'LineWidth',1.2, 'DisplayName','smoothed');
plot(tt_proc.Time, tt_proc.Eh_detrend, '--', 'LineWidth',1.2, 'DisplayName','detrended');
ylabel('Eh (mV)'); legend; grid on;

subplot(2,1,2);
plot(tt_proc.Time, tt_proc.Tide_raw, '.', 'DisplayName','raw'); hold on;
plot(tt_proc.Time, tt_proc.Tide_smoothed, '-', 'LineWidth',1.2, 'DisplayName','smoothed');
plot(tt_proc.Time, tt_proc.Tide_detrend, '--', 'LineWidth',1.2, 'DisplayName','detrended');
ylabel('Tide (m)'); xlabel('Time'); legend; grid on;

%% 8. Example: compute cross-correlation and lag (hours)
% Use detrended series to emphasize tidal signal
x = tt_proc.Eh_detrend;
y = tt_proc.Tide_detrend;
maxLagHours = 48;
maxLagSamples = round(maxLagHours * fs); 
[cc, lags] = xcorr(x, y, maxLagSamples, 'coeff');
[~, imax] = max(abs(cc));
lag_samples = lags(imax);
lag_hours = lag_samples / fs;
fprintf('Max abs cross-corr at lag = %.2f hours (positive means Eh leads Tide)\n', lag_hours);

% plot correlation vs lag
figure('Name','Cross-correlation','NumberTitle','off');
plot(lags/fs, cc); xlabel('Lag (hours)'); ylabel('Correlation'); grid on;

% Output: tt_proc contains processed time series for further analysis

