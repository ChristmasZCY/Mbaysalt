function run_all_tests()
    % RUN_ALL_TESTS 在干净的 MATLAB 路径下用 ST_Mbaysalt 安装测试依赖，再依次运行 Tests/test_*.m。
    % 本机与 GitHub Actions 共用；结束后恢复调用前的路径。
    % Inputs: none. Outputs: none.
    % Throws: run_all_tests:Failed，列出失败的测试名（含 ST_Mbaysalt 安装检查）。
    testDir = fileparts(mfilename('fullpath'));
    originalPath = path;
    pathCleanup = onCleanup(@() path(originalPath)); %#ok<NASGU>
    restoredefaultpath;
    addpath(testDir);

    failed = strings(0);
    failed = run_case(failed, 'ST_Mbaysalt', @() install_test_dependencies(testDir));
    files = dir(fullfile(testDir, 'test_*.m'));
    for k = 1:numel(files)
        name = erase(files(k).name, '.m');
        failed = run_case(failed, name, str2func(name));
    end
    assert(isempty(failed), 'run_all_tests:Failed', 'Failed: %s', strjoin(failed, ', '));
end

function failed = run_case(failed, name, fun)
    % RUN_CASE 运行单个用例并打印 PASS/FAIL。
    % Inputs: failed 已失败的用例名 (string)，name 用例名，fun 无参函数句柄。
    % Outputs: failed 追加本用例名（若失败）。
    try
        fun();
        fprintf('PASS %s\n', name);
    catch exception
        fprintf(2, 'FAIL %s: %s\n', name, exception.message);
        failed(end + 1) = string(name);
    end
end

function install_test_dependencies(testDir)
    % INSTALL_TEST_DEPENDENCIES 由 Configurefiles/INSTALL.json 派生只含测试依赖的清单，交给 ST_Mbaysalt 安装并加入路径。
    % 清单写在 Tests/INSTALL_test.json（已忽略）：ST_Mbaysalt 以清单所在目录的上一级作为仓库根目录。
    % Inputs: testDir Tests 目录绝对路径。Outputs: none.
    % Throws: 依赖安装后仍找不到对应函数时报错。
    repoRoot = fileparts(testDir);
    config = jsondecode(fileread(fullfile(repoRoot, 'Configurefiles', 'INSTALL.json')));
    config.packages.gitclone = only_packages(config.packages.gitclone, {'matFVCOM', 'funcsign', 'TMDToolbox_v2_5', 'TMDToolbox_v3_0'});
    config.packages.download = only_packages(config.packages.download, {'seawater', 't_tide'});
    improveNames = fieldnames(config.improve);
    for k = 1:numel(improveNames)
        config.improve.(improveNames{k}) = any(strcmp(improveNames{k}, {'matFVCOM', 'tmd_v2_5_parpool'}));
    end
    if ~isempty(getenv('GITHUB_ACTIONS'))
        config.git.mirror = ''; % GitHub 上直连，不用国内镜像
    end
    testConfig = fullfile(testDir, 'INSTALL_test.json');
    fid = fopen(testConfig, 'w');
    fprintf(fid, '%s', jsonencode(config, 'PrettyPrint', true));
    fclose(fid);

    addpath(repoRoot);
    ST_Mbaysalt('add', testConfig, 'init');
    for name = {'f_load_grid', 'hs_signfunc', 'TMD', 'tmd_harp', 'sw_dens', 't_tide'}
        assert(exist(name{1}, 'file') == 2, 'run_all_tests:MissingDependency', 'ST_Mbaysalt 安装后找不到 %s', name{1});
    end
end

function packages = only_packages(packages, keepNames)
    % ONLY_PACKAGES 只安装并加入 keepNames 中的包，其余包的 INSTALL、SETPATH 置为 false。
    % Inputs: packages INSTALL.json 中 gitclone 或 download 节点，keepNames 保留的包名。Outputs: packages。
    names = fieldnames(packages);
    for k = 1:numel(names)
        isKept = any(strcmp(names{k}, keepNames));
        packages.(names{k}).INSTALL = isKept;
        packages.(names{k}).SETPATH = isKept;
    end
end
