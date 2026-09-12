function test_build_python_package()
    repoRoot = fileparts(fileparts(mfilename('fullpath')));
    addpath(fullfile(repoRoot, 'Scripts'));

    try
        build_python_package('calc_sound_speed.m', 'Target', 'invalid');
        error('test_build_python_package:ExpectedError', 'Invalid target was accepted.');
    catch exception
        assert(strcmp(exception.identifier, 'build_python_package:InvalidTarget'));
    end
end
