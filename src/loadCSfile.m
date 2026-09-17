function tbl = loadCSfile(filename,prompt)
% Load a Campbell logger file, asking for it only if it is not where expected
%   Returns the timetable from importCSdata. When FILENAME is missing the user
%   is prompted with PROMPT and the file filter is taken from FILENAME's own
%   extension, so .dat and .dat.backup both work. Cancelling the dialog raises
%   an error instead of passing uigetfile's 0 return on to fullfile.
    if isfile(filename)
        tbl = importCSdata(filename);
        return
    end
    [~,~,ext] = fileparts(filename);
    [datFile,datPath] = uigetfile(char("*" + ext),prompt);
    if isequal(datFile,0)
        error("loadCSfile:cancelled","No file selected: %s",prompt);
    end
    tbl = importCSdata(fullfile(datPath,datFile));
end
