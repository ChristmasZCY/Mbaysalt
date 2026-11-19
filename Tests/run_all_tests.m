function run_all_tests()
    % RUN_ALL_TESTS 依次运行 Tests 目录下全部 test_*.m 回归函数，供本机与 CI 共用。
    % Inputs: none. Outputs: none.
    % Throws: run_all_tests:Failed，列出失败的测试名。
    testDir = fileparts(mfilename('fullpath'));
    addpath(testDir);
    files = dir(fullfile(testDir, 'test_*.m'));
    failed = strings(0);
    for k = 1:numel(files)
        name = erase(files(k).name, '.m');
        try
            feval(name);
            fprintf('PASS %s\n', name);
        catch exception
            fprintf(2, 'FAIL %s: %s\n', name, exception.message);
            failed(end + 1) = name; %#ok<AGROW>
        end
    end
    assert(isempty(failed), 'run_all_tests:Failed', 'Failed: %s', strjoin(failed, ', '));
end
