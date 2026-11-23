function test_security_maintenance()
    % Exercise the approved main-repository changes in an isolated working directory.
    % No inputs/outputs. A failed contract raises an assertion or the underlying error.
    root = fileparts(fileparts(mfilename('fullpath')));
    before = pwd;
    savedPath = path;
    work = tempname;
    mkdir(work);
    restore = onCleanup(@() finish(before, savedPath, work)); %#ok<NASGU>
    cd(work);
    addpath(root, fullfile(root, 'Infunctions'), fullfile(root, 'Exfunctions', 'matFVCOM'), fullfile(root, 'Examples'));
    test_config();
    test_progress();
    printed = evalc('osprint(''literal $HOME and 100% "quoted"'', "second line")');
    assert(contains(printed, ' ---> literal $HOME and 100% "quoted"'));
    assert(contains(printed, ' ---> second line'));
    assert(numel(regexp(printed, ' ---> ')) == 2);
    test_manifest();
    test_links(root);
    test_stations(root);
    test_clone(root);
end

function test_config()
    % Exercise the supported syntax with independent configuration values.
    writelines(["a = [0, 5*2, (3+1)^2, -2^2, 2^-3]"; "b = [0:1/2:1]"; ...
        "c = [[1 -2]; [3 4]]"; "d = ['x,y', 'z']"; "e = [1e-3 +2.5]"; "range = [-1:.2:1]"; "depth = [[0,300]]"; ...
        "f = [temp, salt]"; "g = ['a b', c_1]"; "h = []"; "k = [温度, 盐度]"; "p = [pi, Inf]"; "t = [true, false]"; ...
        "n = [1, NaN]"; "x = [not_supported(2)]"; "q = [1a, b]"; "s = [system('touch pwned.txt')]"; ...
        "1day = 5"; "2d = [1,2]"; "3flag = .True."; ...
        "u = [1:1,4]"; "col = [1;2;3]"; "emptyrange = [1:0]"; "w = /data/path/"; "z = ""'mixed"""; ...
        "empty ="; "s1 = NaN"; "s2 = 1E5"; "s8 = 1."; "sp = 1 2 3"; "flag = .True."; ...
        "dict = {'KK':'sds', 'YY':2}"; "links = {'A':'http://x:8080/p', 'B':'v'}"; ...
        "FILEPATH = /custom/dir/"; "DEFAULT = keepme"; ...
        "u1 = ١٢٣"; "ieee = [1/0, -1/0, 0/0, 2^1e300, -2^1e300]"; "cplx = [(-1)^0.5]"; ...
        "bc1 = [1:Inf]"; "bc2 = [0:NaN:1]"; "d1 = {}"; "d2 = {abc, 'k':'v'}"; "d3 = {a:1}b"; ...
        "p1 = [(-2)^1026]"; "p2 = [(-2)^1025]"; "p3 = [(-0)^-1]"; "p4 = [(-0)^-2]"; "p5 = [0^-1]"; "p6 = [(-8)^(1/3)]"; ...
        "deep64 = " + repmat('[',1,64) + "1" + repmat(']',1,64); ...
        "deep65 = " + repmat('[',1,65) + "1" + repmat(']',1,65); ...
        "deepB = " + repmat('[',1,3000) + "1" + repmat(']',1,3000); ...
        "deepP = [" + repmat('(',1,3000) + "1" + repmat(')',1,3000) + "]"; ...
        "deepU = [" + repmat('-',1,3000) + "1]"; ...
        "! c1 = 1"; "// c2 = 1"; "; c3 = 1"; "abc"; " = 7"], 'test.conf');
    c = read_conf('test.conf');
    assert(isequal(c.a, [0 10 16 -4 0.125]));
    assert(isequal(c.b, [0 0.5 1]) && isequal(c.c, [1 -2; 3 4]));
    assert(isequal(c.range, -1:.2:1) && isequal(c.depth, [0 300]));
    assert(isequal(c.d, {'x', 'y', 'z'}) && isequal(c.e, [1e-3 2.5]));
    assert(isequal(c.f, {'temp', 'salt'}) && isequal(c.g, {'a b', 'c_1'}));
    assert(isempty(c.h) && isempty(c.emptyrange) && isempty(c.empty));
    assert(isequal(c.k, {'温度', '盐度'}));
    assert(isequal(c.p, [pi Inf]) && isequal(c.t, [1 0]));
    assert(isequaln(c.n, [1 NaN]) && isequal(c.x, {'not_supported(2)'}) && isequal(c.q, {'1a', 'b'}));
    assert(iscell(c.s) && ~isfile('pwned.txt'));
    assert(c.f1day == 5 && isequal(c.f2d, [1 2]) && isequal(c.f3flag, true));
    assert(isequal(c.u, [1 4]) && isequal(c.col, [1; 2; 3]));
    assert(strcmp(c.w, '/data/path/') && strcmp(c.z, '''mixed'));
    assert(isnan(c.s1) && c.s2 == 100000 && c.s8 == 1);
    assert(strcmp(c.sp, '1 2 3') && isequal(c.flag, true));
    assert(strcmp(c.dict.KK, 'sds') && strcmp(c.dict.YY, '2'));
    assert(strcmp(c.links.A, 'http://x:8080/p') && strcmp(c.links.B, 'v'));
    assert(strcmp(c.FILEPATH, '/custom/dir/') && strcmp(c.DEFAULT, 'keepme'));
    assert(~isfield(c, 'c1') && ~isfield(c, 'c2') && ~isfield(c, 'c3'));
    assert(strcmp(c.u1, '١٢٣'));
    assert(isequaln(c.ieee, [Inf -Inf NaN Inf -Inf]));
    assert(isequal(c.cplx, {'(-1)^0.5'}) && isequal(c.bc1, {'1:Inf'}) && isequal(c.bc2, {'0:NaN:1'}));
    assert(isempty(fieldnames(c.d1)) && strcmp(c.d2.k, 'v') && numel(fieldnames(c.d2)) == 1);
    assert(strcmp(c.d3.a, '1}b'));
    assert(c.p1 == Inf && c.p2 == -Inf && c.p3 == -Inf && c.p4 == Inf && c.p5 == Inf);
    assert(isequal(c.p6, {'(-8)^(1/3)'}));
    assert(isequal(c.deep64, 1));
    assert(strcmp(c.deep65{1}, repmat('[',1,64) + "1" + repmat(']',1,64)));
    assert(strcmp(c.deepB{1}, repmat('[',1,2999) + "1" + repmat(']',1,2999)));
    assert(strcmp(c.deepP{1}, repmat('(',1,3000) + "1" + repmat(')',1,3000)));
    assert(strcmp(c.deepU{1}, repmat('-',1,3000) + "1"));
    writelines(["A = 1"; "A = 2"; "A_1 = 3"; "A = 4"; "A_dup1 = 9"], 'dup.conf');
    d = read_conf('dup.conf');
    assert(d.A == 1 && d.A_dup2 == 2 && d.A_1 == 3 && d.A_dup3 == 4 && d.A_dup1 == 9);
    writelines([char(65279) 'B = 2'], 'bom.conf');
    b = read_conf('bom.conf');
    assert(isfield(b, 'B') && b.B == 2);
end

function test_progress()
    % Independent instances can initialize and close in either order.
    a = parfor_pgb(4);
    ca = onCleanup(@() a.close()); %#ok<NASGU>
    a.iterate(1);
    b = parfor_pgb(2);
    cb = onCleanup(@() b.close()); %#ok<NASGU>
    assert(~strcmp(a.ipcfile, b.ipcfile) && isfile(a.ipcfile));
    b.iterate(1);
    clear cb
    a.iterate(1);
    assert(a.Nnum == 2 && a.percent == 0.5 && ~isfile(b.ipcfile));
    p = parfor_pgb(2);
    p.iterate();
    assert(p.Nnum == 1);
    p.close();
end

function test_manifest()
    % Explicit file selection must take precedence over the working-directory default.
    writelines('{', 'INSTALL.json');
    try
        ST_Mbaysalt('add', 'chosen-missing.json');
        error('test:ExpectedError', 'Missing manifest was accepted.');
    catch problem
        assert(contains(problem.message, 'chosen-missing.json'));
    end
    delete('INSTALL.json');
end

function test_links(root)
    % Force the pre-R2024b branch on current MATLAB using a private version stub.
    mkdir('legacy');
    mkdir(fullfile('legacy', 'private'));
    copyfile(fullfile(root, 'Infunctions', 'ln.m'), 'legacy');
    copyfile(fullfile(root, 'Infunctions', 'readlink.m'), 'legacy');
    writelines(["function tf = isMATLABReleaseOlderThan(~)"; "tf = true;"; "end"], ...
        fullfile('legacy','private','isMATLABReleaseOlderThan.m'));
    addpath(fullfile(pwd, 'legacy'), '-begin');
    target = fullfile(pwd, 'file with ''quote''.nc');
    dest = fullfile(pwd, 'alias with ''quote''');
    if ispc
        dest = [dest '.lnk'];
    end
    writelines("first", target);
    ln(target, dest);
    [linked, actual] = readlink(dest);
    assert(linked && java.io.File(actual).getCanonicalFile().equals(java.io.File(target).getCanonicalFile()));
    try
        ln(target, dest);
        error('test:ExpectedError', 'Protected link was replaced.');
    catch problem
        assert(strcmp(problem.identifier, 'ln:Exists'));
    end
    other = fullfile(pwd, 'other file.nc');
    writelines("second", other);
    ln(other, dest, 'O');
    [linked, actual] = readlink(dest);
    assert(linked && java.io.File(actual).getCanonicalFile().equals(java.io.File(other).getCanonicalFile()));
    if ~ispc
        mkdir('relative dir');
        writelines("relative", fullfile('relative dir', 'source.nc'));
        ln('source.nc', fullfile('relative dir', 'link.nc'));
        [linked, actual] = readlink(fullfile('relative dir', 'link.nc'));
        assert(linked && isfile(actual) && endsWith(actual, fullfile('relative dir', 'source.nc')));
    end
    rmpath(fullfile(pwd, 'legacy'));
end

function test_stations(root)
    % Stub the transfer and post-download reader; exercise the actual example offline.
    mkdir('stations');
    stationDir = fullfile(pwd, 'stations');
    cd(stationDir);
    back = onCleanup(@() cd(fileparts(stationDir))); %#ok<NASGU>
    copyfile(fullfile(root, 'Examples', 'Example_read_kml_xml.m'), stationDir);
    mkdir('private');
    writelines(["function websave(file, ~)"; "writelines('<Station/>', file);"; "end"], fullfile('private','websave.m'));
    writelines(["function s = kmz2struct(~)"; "s = struct();"; "end"], fullfile('private','kmz2struct.m'));
    writelines(["function clm()"; "end"], fullfile('private','clm.m'));
    rehash;
    template = '<kml><Folder><NetworkLink><name>%s</name><Link><href>fixture</href></Link></NetworkLink></Folder></kml>';
    writelines(sprintf(template, '青岛 港'), 'stations.xml');
    Example_read_kml_xml;
    assert(isfile('青岛 港.xml'));
    writelines(sprintf(template, '../outside'), 'stations.xml');
    try
        Example_read_kml_xml;
        error('test:ExpectedError', 'Directory traversal accepted.');
    catch problem
        assert(strcmp(problem.identifier, 'Mbaysalt:StationPathEscape') && contains(problem.message, '../outside'));
        assert(~isfile(fullfile('..','outside.xml')));
    end
end

function finish(before, savedPath, work)
    % Restore original directory/path and remove only the test-owned tree.
    cd(before);
    path(savedPath);
    rmdir(work, 's');
end

function test_clone(root)
    % Run a real Git clone against a local transport fixture (POSIX test host).
    % The helper only accepts our synthetic authenticated URL; no network is used.
    if ispc
        return
    end
    here = pwd;
    mkdir('installer');
    cd('installer');
    back = onCleanup(@() cd(here)); %#ok<NASGU>
    copyfile(fullfile(root, 'ST_Mbaysalt.m'), pwd);
    mkdir('private');
    writelines(["function yes = ispref(varargin)"; "yes = true;"; "end"], fullfile('private','ispref.m'));
    writelines(["function s = getpref(varargin)"; "s = 'DONE';"; "end"], fullfile('private','getpref.m'));
    mkdir('helpers');
    fixtureURL = 'https://fixture.invalid/team/repo';
    helper = fullfile(pwd,'helpers','git-remote-https');
    writelines(["#!/bin/sh"; ...
        "test ""$2"" = 'https://fixture-user:synthetic%40value@fixture.invalid/team/repo' || exit 3"; ...
        "exec git remote-ext ""$1"" ""git-upload-pack $MBAYSALT_TEST_SEED"""], helper);
    assert(fileattrib(helper,'+x','u'));
    assert(system('git init -q -b fixture seed') == 0);
    assert(system('git -C seed -c user.name=test -c user.email=test@example.invalid -c commit.gpgsign=false -c core.hooksPath=/dev/null commit -q --allow-empty -m fixture') == 0);
    vars = {'GIT_EXEC_PATH','MBAYSALT_TEST_SEED','GIT_CONFIG_GLOBAL','GIT_CONFIG_NOSYSTEM'};
    previous = cellfun(@getenv,vars,'UniformOutput',false);
    envCleanup = onCleanup(@() restore_env(vars,previous)); %#ok<NASGU>
    setenv('GIT_EXEC_PATH',fullfile(pwd,'helpers'));
    setenv('MBAYSALT_TEST_SEED',fullfile(pwd,'seed'));
    setenv('GIT_CONFIG_GLOBAL','/dev/null');
    setenv('GIT_CONFIG_NOSYSTEM','1');
    cfg.git = struct('method','cmd','username','fixture-user','password','synthetic@value');
    cfg.packages.modules.PATH = {'.'};
    cfg.packages.builtin.PATH = {'.'};
    checkout = 'new checkout';
    pkg = struct('INSTALL',true,'SETPATH',true,'PATH',checkout,'BRANCH','fixture','DEPTH',1,'URL',fixtureURL);
    pkg.CHECK = {'mbaysalt_test_fixture_absent','file','2'};
    cfg.packages.gitclone.sample = pkg;
    cfg.packages.gitclone.nctoolbox = pkg;
    cfg.packages.gitclone.nctoolbox.SETPATH = false;
    cfg.packages.download.sample = pkg;
    cfg.packages.download.sample.SETPATH = false;
    writelines(jsonencode(cfg),'selected.json');
    writelines('{','INSTALL.json');
    rehash;
    ST_Mbaysalt('add', fullfile(pwd,'selected.json'));
    [status, origin] = system('git -C "new checkout" config --local --get remote.origin.url');
    assert(status == 0 && strcmp(strtrim(origin),fixtureURL));
    assert(~contains(fileread(fullfile(checkout,'.git','config')), 'synthetic'));

    % The destination now exists, so the repeated clone warns and continues.
    lastwarn('');
    ST_Mbaysalt('add', fullfile(pwd,'selected.json'));
    [~, id] = lastwarn;
    assert(strcmp(id, 'Mbaysalt:CloneFailed'));

    % Without an explicit argument the working directory wins, then the packaged default.
    mkdir('working-modules');
    cfg.packages.modules.PATH = {'working-modules'};
    writelines(jsonencode(cfg),'INSTALL.json');
    ST_Mbaysalt('noclone');
    assert(ismember(fullfile(pwd,'working-modules'), strsplit(path,pathsep)));
    delete('INSTALL.json');
    mkdir('Configurefiles');
    mkdir('default-modules');
    cfg.packages.modules.PATH = {'default-modules'};
    writelines(jsonencode(cfg),fullfile('Configurefiles','INSTALL.json'));
    ST_Mbaysalt('noclone');
    assert(ismember(fullfile(pwd,'default-modules'), strsplit(path,pathsep)));

    % An invalid git.method reports its manifest line instead of warning.
    cfg.git.method = 'auto2';
    writelines(jsonencode(cfg),'bad-method.json');
    try
        ST_Mbaysalt('add', fullfile(pwd,'bad-method.json'));
        error('test:ExpectedError', 'Invalid git.method accepted.');
    catch problem
        assert(strcmp(problem.identifier, 'Mbaysalt:InvalidGitMethod') && contains(problem.message, 'auto2'));
    end
end

function restore_env(names, values)
    % Restore fixture environment for subsequent tests.
    for k = 1:numel(names)
        setenv(names{k}, values{k});
    end
end
