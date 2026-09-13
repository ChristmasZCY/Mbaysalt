function [result, products] = build_python_package(functionFiles, varargin)
    %       Build selected Mbaysalt functions as a Python package or shared library.
    % =================================================================================================================
    % Parameters:
    %       functionFiles:          Exported MATLAB function files || required: True  || type: text array/cellstr
    %       varargin: (name-value)
    %           Target:             Build target                    || required: False || default: 'ctf'
    %                               'ctf': Python package and CTF using MATLAB Compiler SDK
    %                               'so': Runtime-based C shared library using MATLAB Compiler SDK
    %                               'coder': Standalone native library using MATLAB Coder
    %           PackageName:        Package or library name         || required: False || default: 'mbaysalt'
    %           OutputDir:          Build output directory          || required: False || default: target-specific
    %           CoderArgs:          Per-entry Coder argument types  || required for Target='coder' || type: cell
    % =================================================================================================================
    % Returns:
    %       result:                 MATLAB Compiler SDK or MATLAB Coder build result.
    %       products:               Required MathWorks products reported by dependency analysis.
    % =================================================================================================================
    % Updates:
    %       2026-09-12: Created, by Codex;
    %       2026-09-13: Added api.json manifest and unified varargin parsing, by Codex;
    % =================================================================================================================
    % Examples:
    %       build_python_package({'calc_weather_front.m', 'calc_thermocline.m', 'calc_sound_speed.m'});
    %       build_python_package({'calc_sound_speed.m'}, 'Target', 'so');
    %       array4d = coder.typeof(0, [Inf Inf Inf Inf], [1 1 1 1]);
    %       depth = coder.typeof(0, [Inf 1], [1 0]);
    %       build_python_package({'calc_sound_speed.m'}, 'Target', 'coder', ...
    %           'CoderArgs', {{array4d, array4d, depth}});
    % =================================================================================================================
    % References:
    %       None
    % =================================================================================================================

    arguments (Input)
        functionFiles
    end

    arguments (Input, Repeating)
        varargin
    end

    repoRoot = fileparts(fileparts(mfilename('fullpath')));
    oldPath = path;
    pathCleanup = onCleanup(@() path(oldPath)); %#ok<NASGU>
    restoredefaultpath;
    remove_user_paths;
    add_build_paths(repoRoot);

    varargin = parse_varargin(varargin, ...
        {'Target', 'PackageName', 'OutputDir', 'CoderArgs'}, ...
        {'ctf', 'mbaysalt', '', {}});

    if ~isempty(varargin)
        error('build_python_package:InvalidOption', 'Unknown or incomplete name-value option.');
    end

    Target = lower(strtrim(char(Target)));

    if ~ismember(Target, {'ctf', 'so', 'coder'})
        error('build_python_package:InvalidTarget', ...
            'Target must be ''ctf'', ''so'', or ''coder''.');
    end

    if strlength(string(OutputDir)) == 0
        outputNames = struct('ctf', 'python', 'so', 'shared', 'coder', 'coder');
        OutputDir = fullfile(repoRoot, 'build', outputNames.(Target));
    end

    [allFiles, products, entryFiles] = makedepends(functionFiles, ...
        'depDir', '', 'sourceRoot', repoRoot);
    dependencyFiles = setdiff(string(allFiles), entryFiles, 'stable');

    if ~isfolder(OutputDir)
        mkdir(OutputDir);
    end

    commonArguments = { ...
        'OutputDir', char(OutputDir), ...
        'AutoDetectDataFiles', true, ...
        'Verbose', true};

    if ~isempty(dependencyFiles)
        commonArguments = [commonArguments, {'AdditionalFiles', cellstr(dependencyFiles')}]; %#ok<AGROW>
    end

    switch Target
        case 'ctf'
            require_function('compiler.build.pythonPackage', 'MATLAB Compiler SDK');
            buildOptions = compiler.build.PythonPackageOptions(cellstr(entryFiles'), ...
                'PackageName', char(PackageName), commonArguments{:});
            result = compiler.build.pythonPackage(buildOptions);

        case 'so'
            require_function('compiler.build.cSharedLibrary', 'MATLAB Compiler SDK');
            buildOptions = compiler.build.CSharedLibraryOptions(cellstr(entryFiles'), ...
                'LibraryName', native_library_name(PackageName), commonArguments{:});
            result = compiler.build.cSharedLibrary(buildOptions);

        case 'coder'
            require_function('codegen', 'MATLAB Coder');
            result = build_coder_library(entryFiles, native_library_name(PackageName), ...
                OutputDir, CoderArgs);
    end

    write_api_manifest(OutputDir, PackageName, Target, entryFiles, repoRoot);

end

function write_api_manifest(outputDir, packageName, target, entryFiles, repoRoot)
    api = struct;
    api.schemaVersion = '1.0.0';
    api.packageName = char(packageName);
    api.target = target;
    api.matlabRelease = ['R', version('-release')];
    api.architecture = computer('arch');
    api.runtimeRequired = ~strcmp(target, 'coder');
    api.pythonImportable = strcmp(target, 'ctf');
    api.bindingRequired = ~strcmp(target, 'ctf');

    if strcmp(target, 'ctf')
        api.artifact = fullfile(char(packageName), [char(packageName), '.ctf']);
    else
        api.artifact = [native_library_name(packageName), shared_library_extension()];
    end

    api.functions = load_entry_signatures(entryFiles, repoRoot);
    apiFile = fullfile(outputDir, 'api.json');
    fileId = fopen(apiFile, 'w');

    if fileId < 0
        error('build_python_package:ApiManifestWriteFailed', ...
            'Cannot write API manifest: %s', apiFile);
    end

    fileCleanup = onCleanup(@() fclose(fileId)); %#ok<NASGU>
    fprintf(fileId, '%s\n', jsonencode(api, 'PrettyPrint', true));
end

function functions = load_entry_signatures(entryFiles, repoRoot)
    functions = cell(numel(entryFiles), 1);

    for i = 1:numel(entryFiles)
        entryFile = entryFiles(i);
        [entryDir, functionName] = fileparts(entryFile);
        signatureFile = fullfile(entryDir, 'functionSignatures.json');
        entry = struct;
        entry.name = functionName;
        entry.source = relative_source_path(entryFile, repoRoot);
        entry.inputs = cell(0, 1);
        entry.outputs = cell(0, 1);

        if isfile(signatureFile)
            signatures = jsondecode(fileread(signatureFile));

            if isfield(signatures, functionName)
                signature = signatures.(functionName);

                if isfield(signature, 'inputs'); entry.inputs = num2cell(signature.inputs); end
                if isfield(signature, 'outputs'); entry.outputs = num2cell(signature.outputs); end
            else
                warning('build_python_package:SignatureMissing', ...
                    'No signature entry for %s in %s.', functionName, signatureFile);
            end

        else
            warning('build_python_package:SignatureFileMissing', ...
                'No functionSignatures.json next to %s.', entryFile);
        end

        functions{i} = entry;
    end
end

function relativePath = relative_source_path(sourceFile, repoRoot)
    sourceFile = string(sourceFile);
    rootPrefix = string(repoRoot) + filesep;

    if startsWith(sourceFile, rootPrefix)
        sourceFile = extractAfter(sourceFile, strlength(rootPrefix));
    end

    relativePath = char(replace(sourceFile, filesep, '/'));
end

function extension = shared_library_extension()
    if ispc
        extension = '.dll';
    elseif ismac
        extension = '.dylib';
    else
        extension = '.so';
    end
end

function remove_user_paths()
    userFolders = split(string(userpath), pathsep);

    for userFolder = userFolders(:)'

        if strlength(userFolder) > 0 && contains([pathsep, path, pathsep], ...
                [pathsep, char(userFolder), pathsep])
            rmpath(char(userFolder));
        end

    end
end

function libraryName = native_library_name(packageName)
    libraryName = char(packageName);

    if ~ispc && ~startsWith(libraryName, 'lib')
        libraryName = ['lib', libraryName];
    end
end

function result = build_coder_library(entryFiles, libraryName, outputDir, coderArgs)
    if ~iscell(coderArgs) || numel(coderArgs) ~= numel(entryFiles) || ...
            any(~cellfun(@iscell, coderArgs))
        error('build_python_package:InvalidCoderArgs', ...
            'CoderArgs must contain one cell array of argument types for each entry file.');
    end

    config = coder.config('dll');
    config.TargetLang = 'C';
    config.EnableOpenMP = false;
    codegenArguments = {'-config', config, '-d', char(outputDir), '-o', char(libraryName)};

    for i = 1:numel(entryFiles)
        codegenArguments = [codegenArguments, ...
            {char(entryFiles(i)), '-args', coderArgs{i}}]; %#ok<AGROW>
    end

    result = codegen(codegenArguments{:});

    if isstruct(result) && isfield(result, 'summary') && ...
            isfield(result.summary, 'passed') && ~result.summary.passed
        error('build_python_package:CoderBuildFailed', ...
            'MATLAB Coder failed. See the generated report in %s.', outputDir);
    end
end

function require_function(functionName, productName)
    if isempty(which(functionName))
        error('build_python_package:ProductMissing', ...
            '%s is required for this build target.', productName);
    end
end

function add_build_paths(repoRoot)
    configFile = fullfile(repoRoot, 'Configurefiles', 'INSTALL.json');
    config = jsondecode(fileread(configFile));

    addpath(repoRoot);
    add_existing_paths(repoRoot, string(config.packages.modules.PATH), false);
    add_existing_paths(repoRoot, string(config.packages.builtin.PATH), true);
    add_configured_paths(repoRoot, config.packages.gitclone);
    add_configured_paths(repoRoot, config.packages.download);
end

function add_configured_paths(repoRoot, packages)
    packageNames = fieldnames(packages);

    for i = 1:numel(packageNames)
        package = packages.(packageNames{i});

        if isfield(package, 'SETPATH') && package.SETPATH
            add_existing_paths(repoRoot, string(package.PATH), true);
        end

    end

end


function add_existing_paths(repoRoot, relativePaths, recursive)
    for relativePath = relativePaths(:)'
        packagePath = fullfile(repoRoot, relativePath);

        if isfolder(packagePath)
            if recursive
                addpath(genpath(packagePath));
            else
                addpath(packagePath);
            end

        end

    end

end
