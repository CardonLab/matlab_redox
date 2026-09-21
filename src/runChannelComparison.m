%[text] ## Run the wavelet and Lomb-Scargle analyses over several channels
%[text] waveletTyphaRedox.m and lombScargleM2vsS2.m take varName, depthLabel and
%[text] startDate from the caller's workspace when those are already set, so this
%[text] driver runs them over a list of channels on one common window.
%[text]
%[text] Depth labelling differs between the probes: P1 labels are the installed depth,
%[text] while P2 labels sit 5 cm below the sensor (plot_Typha_redox.m renames
%[text] P2_10cm -> P2_05cm and so on). There is therefore no P2 channel at a true
%[text] 10 cm, and P2_10cmEh (5 cm) and P2_20cmEh (15 cm) bracket P1_10cmEh.
%[text]
%[text] Kept deliberately flat, with no wrapper function: both analysis scripts define
%[text] local functions, which cannot be evaluated in a function's workspace via run().
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

%% Channels to run, and the common window start
comparisonRoot  = projectRoot;
comparisonStart = datetime("2026-07-15 00:00:00","TimeZone","-05:00");
% The end of the window is always the last timestamp in the data; the analysis
% scripts work that out for themselves.
comparisonChans  = ["P2_10cmEh" "P2_20cmEh"];
comparisonDepths = ["5 cm"      "15 cm"    ];

%% Run each channel through both analyses
for iChan = 1:numel(comparisonChans)
    fprintf("\n\n################ %s (%s) - wavelet ################\n", ...
        comparisonChans(iChan), comparisonDepths(iChan));
    clearvars -except comparisonRoot comparisonStart comparisonChans comparisonDepths iChan
    varName    = comparisonChans(iChan);
    depthLabel = comparisonDepths(iChan);
    startDate  = comparisonStart;
    run(fullfile(comparisonRoot,"src","waveletTyphaRedox.m"));
    close all

    fprintf("\n\n################ %s (%s) - Lomb-Scargle ################\n", ...
        comparisonChans(iChan), comparisonDepths(iChan));
    clearvars -except comparisonRoot comparisonStart comparisonChans comparisonDepths iChan
    varName    = comparisonChans(iChan);
    depthLabel = comparisonDepths(iChan);
    startDate  = comparisonStart;
    run(fullfile(comparisonRoot,"src","lombScargleM2vsS2.m"));
    close all
end
fprintf("\n\nAll comparison runs complete.\n");
