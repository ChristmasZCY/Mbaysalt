function test_makedepends()
    repoRoot = fileparts(fileparts(mfilename('fullpath')));
    addpath(fullfile(repoRoot, 'Infunctions'));
    addpath(fullfile(repoRoot, 'Exfunctions', 'matFVCOM'));

    depDir = string(tempname);
    cleanup = onCleanup(@() cleanup_dir(depDir)); %#ok<NASGU>

    packageFile = fullfile(repoRoot, 'Exfunctions', 'funcsign', 'data', ...
        'testlib3', '+sch', 'myfun.m');
    classFile = fullfile(repoRoot, 'Exfunctions', 'funcsign', 'data', ...
        'testlib3', '+sch', '@Student', 'Student.m');

    [files, ~, entryFiles] = makedepends( ...
        {'calc_weather_front.m', 'calc_sound_speed.m', packageFile, classFile}, ...
        'depDir', depDir, 'sourceRoot', repoRoot);

    assert(numel(entryFiles) == 4);
    assert(any(endsWith(string(files), fullfile('Infunctions', 'calc_weather_front.m'))));
    assert(isfile(fullfile(depDir, 'Infunctions', 'calc_weather_front.m')));
    assert(isfile(fullfile(depDir, 'Exfunctions', 'funcsign', 'data', ...
        'testlib3', '+sch', 'myfun.m')));
    assert(isfile(fullfile(depDir, 'Exfunctions', 'funcsign', 'data', ...
        'testlib3', '+sch', '@Student', 'Student.m')));
end

function cleanup_dir(directory)
    if isfolder(directory)
        rmdir(directory, 's');
    end
end
