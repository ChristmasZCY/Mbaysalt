function [fList, pList, entryFiles] = makedepends(funName, varargin)
    %       Analyze or copy the dependencies of one or more MATLAB functions.
    % =================================================================================================================
    % Parameters:
    %       funName:               Function files or function names || required: True  || type: text array/cellstr
    %       varargin: (name-value)
    %           depDir:            Dependency output directory      || required: False || default: './depends'
    %                              Set to "" to analyze without copying files.
    %           sourceRoot:        Root preserved below depDir      || required: False || default: Mbaysalt root
    %           overwrite:         Overwrite matching output files  || required: False || default: false
    % =================================================================================================================
    % Returns:
    %       fList:      Full paths of entry files and required user MATLAB files.
    %       pList:      MathWorks products required by the entry files.
    %       entryFiles: Resolved full paths of the requested entry files.
    % =================================================================================================================
    % Updates:
    %       2024-12-13: Created, by Christmas;
    %       2026-09-12: Added multiple entries, noninteractive analysis and structure-preserving copy, by Codex;
    % =================================================================================================================
    % Examples:
    %       makedepends('calc_weather_front.m');
    %       makedepends({'calc_weather_front.m', 'calc_thermocline.m'}, 'depDir', './depends');
    %       [fList, pList] = makedepends('calc_sound_speed.m', 'depDir', '');
    % =================================================================================================================

    arguments (Input)
        funName
    end

    arguments (Input, Repeating)
        varargin
    end

    depDir = './depends';
    sourceRoot = '';
    overwrite = false;
    varargin = read_varargin(varargin, ...
        {'depDir', 'sourceRoot', 'overwrite'}, {depDir, sourceRoot, overwrite});

    if ~isempty(varargin)
        error('makedepends:InvalidOption', 'Unknown or incomplete name-value option.');
    end

    requestedFiles = normalize_text_list(funName, 'funName');
    entryFiles = strings(size(requestedFiles));

    for i = 1:numel(requestedFiles)
        entryFiles(i) = resolve_file(requestedFiles(i));
    end

    [dependencyFiles, pList] = matlab.codetools.requiredFilesAndProducts(cellstr(entryFiles'));
    fList = cellstr(unique([entryFiles; string(dependencyFiles(:))], 'stable'));

    depDir = string(depDir);

    if strlength(strip(depDir)) == 0
        return
    end

    if strlength(string(sourceRoot)) == 0
        sourceRoot = fileparts(fileparts(mfilename('fullpath')));
    end

    sourceRoot = canonical_path(sourceRoot);

    if ~isfolder(depDir)
        mkdir(depDir);
    elseif ~overwrite
        contents = dir(depDir);
        contents = contents(~ismember({contents.name}, {'.', '..'}));

        if ~isempty(contents)
            error('makedepends:OutputNotEmpty', ...
                'Dependency directory is not empty: %s. Use overwrite=true or another directory.', depDir);
        end

    end

    depDir = canonical_path(depDir);

    if depDir == sourceRoot
        error('makedepends:InvalidOutput', 'depDir must not be the source root.');
    end

    sourcePrefix = sourceRoot + filesep;

    for i = 1:numel(fList)
        sourceFile = canonical_path(fList{i});

        if ~startsWith(sourceFile, sourcePrefix)
            error('makedepends:OutsideSourceRoot', ...
                'Dependency is outside sourceRoot: %s. Choose a sourceRoot containing every dependency.', sourceFile);
        end

        relativeFile = extractAfter(sourceFile, strlength(sourcePrefix));
        destinationFile = fullfile(depDir, relativeFile);
        destinationParent = fileparts(destinationFile);

        if ~isfolder(destinationParent)
            mkdir(destinationParent);
        end

        if isfile(destinationFile) && ~overwrite
            error('makedepends:OutputExists', 'Dependency already exists: %s', destinationFile);
        end

        [status, message] = copyfile(sourceFile, destinationFile, 'f');

        if ~status
            error('makedepends:CopyFailed', 'Failed to copy %s: %s', sourceFile, message);
        end

    end

end

function values = normalize_text_list(value, argumentName)
    if ~(ischar(value) || isstring(value) || iscellstr(value)) %#ok<ISCLSTR>
        error('makedepends:InvalidInput', '%s must be text or a cell array of character vectors.', argumentName);
    end

    values = strip(string(value(:)));

    if isempty(values) || any(strlength(values) == 0)
        error('makedepends:InvalidInput', '%s must contain at least one nonempty value.', argumentName);
    end

end

function filePath = resolve_file(requestedFile)
    filePath = requestedFile;

    if ~isfile(filePath)
        filePath = string(which(char(requestedFile)));
    end

    if strlength(filePath) == 0 || ~isfile(filePath)
        error('makedepends:FileNotFound', 'Cannot find MATLAB function file: %s', requestedFile);
    end

    filePath = canonical_path(filePath);
end

function pathValue = canonical_path(pathValue)
    pathValue = string(java.io.File(char(pathValue)).getCanonicalPath());
end
