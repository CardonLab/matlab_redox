%[text] ## Typha P2 5 cm: wavelet and Lomb-Scargle on raw mV versus Eh
%[text] Repeats the August 2026 Typha report analysis (P2_10cmEh, true depth 5 cm,
%[text] 1-28 Aug 2026) on the raw probe millivolts. Eh = mV - 0.718*T + 224.41 uses
%[text] P2_Soil_Temp_C, so any daily temperature wave enters Eh directly; comparing
%[text] the two shows how much of the Eh periodicity comes from the correction.
%[text] Kept flat (no wrapper function) because both analysis scripts define local
%[text] functions, which cannot be evaluated in a function's workspace via run().
%% Window and channels
twStart = datetime("2026-08-01 00:00:00","TimeZone","-05:00");
twEnd   = datetime("2026-08-29 00:00:00","TimeZone","-05:00"); % exclusive; the
% report stops here because Eh steps up ~200 mV from 29 Aug 12:36
twChans = ["P2_10cm" "P2_10cmEh"];
twLabels = ["5 cm, raw mV" "5 cm, Eh"];
twSrc   = fileparts(mfilename("fullpath"));

%% Run each channel through both analyses
for iTw = 1:numel(twChans)
    for twScript = ["waveletTyphaRedox.m" "lombScargleM2vsS2.m"]
        fprintf("\n\n################ %s (%s) - %s ################\n", ...
            twChans(iTw), twLabels(iTw), twScript);
        % The analysis scripts reuse generic names (k, T, x, ...), so clear between runs
        clearvars -except twStart twEnd twChans twLabels twSrc iTw twScript
        tblName    = "typhaMarshMinuteTbl_Eh";
        siteLabel  = "Typha marsh";
        varName    = twChans(iTw);
        depthLabel = twLabels(iTw);
        startDate  = twStart;
        windowEnd  = twEnd;
        run(fullfile(twSrc,twScript));
        close all
    end
end
fprintf("\n\nAll Typha raw-vs-Eh runs complete.\n");
