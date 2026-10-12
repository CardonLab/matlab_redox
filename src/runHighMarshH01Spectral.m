%[text] ## Wavelet and Lomb-Scargle analysis of high marsh probe H01
%[text] Runs waveletTyphaRedox.m and lombScargleM2vsS2.m on the H01 Eh channels from
%[text] highMarshMinuteTbl_Eh on one common window. Both scripts take tblName,
%[text] siteLabel, varName, depthLabel and startDate from this workspace.
%[text] Kept flat (no wrapper function) because both analysis scripts define local
%[text] functions, which cannot be evaluated in a function's workspace via run().
%% Channels to run, and the common window start
% h01Chans/h01Depths may be pre-set by a caller to run a subset.
if ~exist("h01Chans","var")
    h01Chans  = ["H01_05cmEh" "H01_10cmEh" "H01_15cmEh" "H01_30cmEh"];
    h01Depths = ["5 cm"       "10 cm"      "15 cm"      "30 cm"     ];
end
% The record starts 2026-04-14 08:11, but the probes settle from up to ~+400 mV to
% their working range over the first 3-6 days (longest at 5 cm); that transient
% inflates the red-noise level and creates edge artifacts in the band amplitudes,
% so start after every depth has equilibrated.
h01Start = datetime("2026-04-20 00:00:00","TimeZone","-05:00");
h01Src   = fileparts(mfilename("fullpath"));

%% Run each channel through both analyses
for iChan = 1:numel(h01Chans)
    for h01Script = ["waveletTyphaRedox.m" "lombScargleM2vsS2.m"]
        fprintf("\n\n################ %s (%s) - %s ################\n", ...
            h01Chans(iChan), h01Depths(iChan), h01Script);
        % The analysis scripts reuse generic names (k, T, x, ...), so clear between runs
        clearvars -except h01Chans h01Depths h01Start h01Src iChan h01Script
        tblName    = "highMarshMinuteTbl_Eh";
        siteLabel  = "high marsh (H01, tall Spartina, channel bank)";
        varName    = h01Chans(iChan);
        depthLabel = h01Depths(iChan);
        startDate  = h01Start;
        run(fullfile(h01Src,h01Script));
        close all
    end
end
fprintf("\n\nAll H01 runs complete.\n");
