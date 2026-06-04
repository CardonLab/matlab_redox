% Combine multiple .mlx into one HTML report
mFiles = dir('src/*Marsh2026.m'); 
outDir = dir('report\*.html').folder;
% mkdir(outDir);

tmpHtmlFiles = strings(1,numel(mFiles));
for k = 1:numel(mFiles)
    mPath = fullfile(mFiles(k).folder, mFiles(k).name);
    % Export each .m to HTML with images embedded (data URIs)
    htmlName = fullfile(outDir, replace(mFiles(k).name, '.m', '.html'));
    export(mPath, htmlName, Format="html",Run=true,EmbedImages=true, HideCode=true,FigureResolution=1200);
    tmpHtmlFiles(k) = htmlName;
end

% Read and extract body content from each exported HTML
bodyParts = strings(1,numel(tmpHtmlFiles));
for k = 1:numel(tmpHtmlFiles)
    txt = fileread(tmpHtmlFiles(k));
    % extract contents between <body ...> and </body>
    tok = regexp(txt, '<body[^>]*>(.*)</body>', 'tokens', 'dotexceptnewline');
    if ~isempty(tok)
        bodyParts(k) = tok{1}{1};
    else
        bodyParts(k) = "";  % fallback empty
    end
end

% Build final HTML (simple wrapper). You can add CSS/TOC here.
finalHtml = ["<!doctype html>"
             "<html>"
             "<head>"
             "<meta charset='utf-8'>"
             "<title>Nelson and Shad Redox Figures</title>"
             "<style>/* optional global styles */ body{font-family:Arial,Helvetica,sans-serif;margin:20px;} .section{margin-bottom:40px;border-top:1px solid #ccc;padding-top:20px;}</style>"
             "</head>"
             "<body>"];

for k = 1:numel(bodyParts)
    sectionHeader = sprintf("<div class='section'><h2>%s</h2>", mFiles(k).name);
    finalHtml(end+1) = sectionHeader;                       %#ok<SAGROW>
    finalHtml(end+1) = bodyParts(k);
    finalHtml(end+1) = "</div>";
end

finalHtml(end+1) = "</body>";
finalHtml(end+1) = "</html>";

finalPath = fullfile(outDir, "combined_report.html");
fid = fopen(finalPath, 'w', 'n', 'utf-8');
fwrite(fid, join(finalHtml, newline));
fclose(fid);

fprintf('Combined report written to %s\n', finalPath);
