function ST_Mbaysalt(varargin)
    %       To setup path of Mbaysalt
    % =================================================================================================================
    % Parameters:
    %       varargin: (optional) 
    %           add:        add all path        || required: False|| type: Text      || format: 'add'
    %           rm:         remove all path     || required: False|| type: Text      || format: 'rm'
    %           cd:         cd here             || required: False|| type: Text      || format: 'cd'
    %           noclone:    Not add new pkgs    || required: False|| type: flag      || format: 'noclone'
    %           init:       Initialize          || required: False|| type: flag      || format: 'init'
    % =================================================================================================================
    % Returns:
    % =================================================================================================================
    % Updates:
    %       ****-**-**:     See Mainpath.m
    %       2024-04-26:     Code Refactoring,                                       by Christmas;
    %       2024-05-12:     Added check git:mirror,                                 by Christmas;
    %       2024-05-12:     Added improve:minmax, submodule gitclone:irfu_matlab,   by Christmas;
    %       2024-05-12:     Judged init first,                                      by Christmas;
    %       2024-05-16:     Added improve:m_etopo2,                                 by Christmas;
    % =================================================================================================================
    % Examples:
    %       ST_Mbaysalt                        % Add all path
    %       ST_Mbaysalt('add')                 % Add all path
    %       ST_Mbaysalt('rm')                  % Remove all path
    %       ST_Mbaysalt('noclone')             % Add all path without clone git
    %       ST_Mbaysalt('cd')                  % Change current directory to the path of this function
    %       ST_Mbaysalt('init')                % Initialize
    %       ST_Mbaysalt('add','init')          % Initialize and add all path
    % =================================================================================================================
    
    arguments(Input, Repeating)
        varargin
    end

    cmd = 'add'; % 默认是 add
    for i = 1: length(varargin)
        switch lower(varargin{i})
        case {'add','rm','noclone'} 
            cmd = convertStringsToChars(varargin{i});
            varargin(i) = [];
            break
        case {'cd'}  % cd to the path of this function
            cd(fileparts(mfilename("fullpath")))
            return
        end
    end

    if ispref('Mbaysalt','init')
        init = getpref('Mbaysalt','init');
        if strcmp(init,'DONE')
            init = false;
        end
    else
        init = true;
    end
    for i = 1 : length(varargin)
        switch lower(varargin{i})
        case 'init'
            init = true;
        end
    end
    clear i
    
    PATH.basepath = fileparts(mfilename("fullpath"));
    Jfile = fullfile(PATH.basepath,'Configurefiles/INSTALL.json');
    Jstruct = jsondecode(fileread(Jfile)); Jstruct.FILEPATH = Jfile;
    PATH.modules = fullfile(PATH.basepath,Jstruct.packages.modules.PATH); % modules
    PATH.builtin = fullfile(PATH.basepath,Jstruct.packages.builtin.PATH); % builtin
    
    switch lower(cmd)
    case 'add'
        % addpath
        addpath(strjoin(PATH.modules, pathsep)); % cellfun(@addpath, PATH.module); 慢
        addpath(strjoin(PATH.builtin, pathsep));
        Jstruct.git.TF = true;
        [~, ~] = install_pkgs(PATH, Jstruct, 'add');  % install_pkgs
        Javaaddpath(Jstruct)
    case 'rm'
        % rmpath
        [~, PATH] = install_pkgs(PATH, Jstruct, 'rm');
        Crmpath(PATH.modules)  % rmpath(strjoin(PATH.modules, pathsep))
        Crmpath(PATH.builtin)  % rmpath(strjoin(PATH.builtin, pathsep))
        Crmpath(PATH.exfunctions.download)
        Crmpath(PATH.exfunctions.gitclone)
    case 'noclone'
        addpath(strjoin(PATH.modules, pathsep));
        addpath(strjoin(PATH.builtin, pathsep));
        Jstruct.git.TF = false;
        [~, ~] = install_pkgs(PATH, Jstruct, 'noclone');
        Javaaddpath(Jstruct)
    otherwise
        error('parameter error');
    end
    
    if init
        STATUS = Fixed_functions(Jstruct);
        if ispref('Mbaysalt','PATH_toolbox')  % Fixed Mainpath 
            rmpref('Mbaysalt');
        end
        setpref('Mbaysalt','init','DONE')
    else
        STATUS = 0;
    end

    if STATUS
        print_info()
    end

end


function Crmpath(Path)
    % currentPaths = strsplit(path, pathsep);
    % cellfun(@rmpath, Path(cellfun(@(x) ismember(x, currentPaths), Path)));
    % exception = warning('on','last');
    % identifier = exception.identifier;
    identifier = 'MATLAB:rmpath:DirNotFound';
    warning('off',identifier);
    % FunD = cellfun(@genpath2,FunD,repmat({'.git'},length(FunD),1),'UniformOutput', false);
    FunD = cellfun(@genpath2,Path,repmat({{'.git', '.svn'}},length(Path),1),'UniformOutput', false);
    FunD (cellfun(@isempty,FunD))= [];
    rmpath(strjoin(FunD))
    warning('on',identifier);
end

function Javaaddpath(Jstruct)
    if exist('setup_nctoolbox_java','file') == 2 && Jstruct.packages.gitclone.nctoolbox.SETPATH
        setup_nctoolbox_java()
    end
end

function STATUS = Fixed_functions(Jstruct)
    % 修正一些函数在高版本matlab中的报错
    STATUS_list = [];
    if Jstruct.improve.t_tide
        STATUS_list = [STATUS_list,fixed_t_tide(Jstruct)]; % 添加输出ref基准面的信息
    end
    if Jstruct.improve.setup_nctoolbox_java
        STATUS_list = [STATUS_list,fixed_setup_nctoolbox_java(Jstruct)]; % 关闭setup_nctoolbox_java的一行，MATLAB高版本会报错
    end
    if Jstruct.improve.matFVCOM
        STATUS_list = [STATUS_list,supplement_matFVCOM(Jstruct)];
    end
    if Jstruct.improve.mexcdf
        STATUS_list = [STATUS_list,fixed_mexcdf(Jstruct)];
    end
    if Jstruct.improve.m_gshhs
        STATUS_list = [STATUS_list,fixed_m_gshhs(Jstruct)];
    end
    if Jstruct.improve.m_etopo2
        STATUS_list = [STATUS_list,fixed_m_etopo2(Jstruct)];
    end
    if Jstruct.improve.ann_wrapper
        STATUS_list = [STATUS_list,install_ann_wrapper(Jstruct)];
    end
    if Jstruct.improve.DHIMIKE
        STATUS_list = [STATUS_list,install_DHIMIKE(Jstruct)];
    end
    if Jstruct.improve.irfu_matlab
        STATUS_list = [STATUS_list,install_irfu_matlab(Jstruct)];
    end
    STATUS = any(STATUS_list);
end

function STATUS = fixed_t_tide(Jstruct)
    % 为t_tide工具包的t_tide.m文件添加ref参数
    m_filepath = fullfile(fileparts(fileparts(Jstruct.FILEPATH)),Jstruct.packages.download.t_tide.PATH,'t_tide.m');  % which('t_tide.m');
    if ~exist(m_filepath,"file")
        STATUS = 0;
        return
    end
    % 备份源文件
    path_DIR = fileparts(m_filepath);
    m_filecopy = fullfile(path_DIR,'t_tide_origin.m');
    if ~ exist(m_filecopy,'file')
        copyfile(m_filepath,m_filecopy);
    end
    fileContent = fileread(m_filepath);  % 读取文件内容
    searchStr = "nameu = struct('name',nameu,'freq',fu,'tidecon',tidecon,'type',ltype);";  % 定义要查找的字符串
    replaceStr = "nameu = struct('name',nameu,'freq',fu,'tidecon',tidecon,'type',ltype,'ref',z0);";  % 定义替换后的字符串
    newContent = strrep(fileContent, searchStr, replaceStr);  % 执行替换操作
    fOWC(m_filepath, 'w', newContent);
    STATUS = 1;
end

function STATUS = fixed_setup_nctoolbox_java(Jstruct)
    % 修正nctoolbox工具包的setup_nctoolbox_java.m函数在高版本matlab中的报错
    m_filepath = fullfile(fileparts(fileparts(Jstruct.FILEPATH)),Jstruct.packages.gitclone.nctoolbox.PATH,'java/setup_nctoolbox_java.m');  % which('setup_nctoolbox_java.m');
    if ~exist(m_filepath,"file")
        STATUS = 0;
        return  
    end
    % 备份源文件
    path_DIR = fileparts(m_filepath);
    m_filecopy = fullfile(path_DIR,'setup_nctoolbox_java_origin.m');
    if ~exist(m_filecopy,'file')
        copyfile(m_filepath,m_filecopy);
    end
    fileContent = fileread(m_filepath);  % 读取文件内容
    pattern = '(?m)^(?<!%)(root\.addAppender\(org\.apache\.log4j\.ConsoleAppender\(org\.apache\.log4j\.PatternLayout\(''%d\{ISO8601\} \[\%t\] %-5p %c %x - %m%n''\)\)\);)';
    replacement = '% $1';
    newContent = regexprep(fileContent, pattern, replacement);
    fOWC(m_filepath, 'w', newContent);
    STATUS = 1;
end

function STATUS = supplement_matFVCOM(Jstruct)
    % 为matFVCOM添加Contents.m和functionSignatures.json
    m_filepath = fullfile(fileparts(fileparts(Jstruct.FILEPATH)),Jstruct.packages.gitclone.matFVCOM.PATH,'f_load_grid.m');  % which('f_load_grid.m');
    if ~exist(m_filepath,"file")
        STATUS = 0;
        return  
    end
    basepath = fileparts(fileparts(Jstruct.FILEPATH));
    path_in = fullfile(basepath,Jstruct.supplement.matFVCOM.PATH_IN);
    path_out = fullfile(basepath,Jstruct.supplement.matFVCOM.PATH_OUT);
    files_in = fullfile(path_in,string(Jstruct.supplement.matFVCOM.FILES));
    files_out = fullfile(path_out,string(Jstruct.supplement.matFVCOM.FILES));
    STATUS_list = zeros(length(files_in),1);
    for i = 1 : length(files_in)
        file_in = files_in(i);
        file_out = files_out(i);
        % file_basename = replace(file_out,strcat(fileparts(file_out),filesep),'');
        % file_basename = Jstruct.supplement.matFVCOM.FILES{i};
        if ~exist(file_out,"file")
            copyfile(file_in,file_out);
            STATUS_list(i) = 1;
        else
            if ~readlink(file_out)
                file_out_bak = strcat(file_out,'_bak');
                if ~exist(file_out_bak,"file")  % backup
                    copyfile(file_out,file_out_bak);
                end
                copyfile(file_in,file_out);
                STATUS_list(i) = 1;
            end
        end
    end
    STATUS = any(STATUS_list);

    % T = validateFunctionSignaturesJSON(fullfile(path_matFVCOM,'functionSignatures.json'));
    % if ~isempty(T)
        % validateFunctionSignaturesJSON(fullfile(path_matFVCOM,'functionSignatures.json'));
    % end
end

function STATUS = fixed_mexcdf(Jstruct)
    % 修复mexcdf工具包的ncmex.m在MATLAB高版本的报错
    m_filepath = fullfile(fileparts(fileparts(Jstruct.FILEPATH)),Jstruct.packages.download.mexcdf.PATH,'netcdf_toolbox/netcdf/ncutility/ncmex.m');  % which('ncmex.m');
    if ~exist(m_filepath,"file")
        STATUS = 0;
        return  
    end
    % 备份源文件
    path_DIR = fileparts(m_filepath);
    m_filecopy = fullfile(path_DIR,'ncmex_origin.m');
    if ~exist(m_filecopy,'file')
        copyfile(m_filepath,m_filecopy);
    end
    fileContent = fileread(m_filepath);  % 读取文件内容
    searchStr = "error(' ## Unrecognized Matlab version.')";  % 定义要查找的字符串
    replaceStr = "fcn = 'mexcdf53';";  % 定义替换后的字符串
    newContent = strrep(fileContent, searchStr, replaceStr);  % 执行替换操作
    fOWC(m_filepath, 'w', newContent);
    STATUS = 1;
end

function STATUS = fixed_m_gshhs(Jstruct)
    % 更改m_map工具包的m_gshhs.m文件的FILNAME
    m_filepath = fullfile(fileparts(fileparts(Jstruct.FILEPATH)),Jstruct.packages.download.m_map.PATH,'m_gshhs.m');  % which('m_gshhs.m');
    gshhsc_path = fullfile(fileparts(fileparts(Jstruct.FILEPATH)),Jstruct.packages.download.gshhs.PATH,'gshhs_c.b');
    gshhs_filepath = [fileparts(gshhsc_path) filesep];
    if ~(exist(m_filepath,"file") && exist(gshhsc_path,"file"))
        STATUS = 0;
        return  
    end
    % 备份源文件
    path_DIR = fileparts(m_filepath);
    m_filecopy = fullfile(path_DIR,'m_gshhs_origin.m');
    if ~exist(m_filecopy,'file')
        copyfile(m_filepath,m_filecopy);
    end
    fileContent = fileread(m_filepath);  % 读取文件内容
    if isempty(grep(m_filepath,gshhs_filepath))
        searchStr = "FILNAME=[fileparts(which('m_gshhs.m')) '/data/'];";  % 定义要查找的字符串
        replaceStr = sprintf("%% %s \nFILNAME = '%s';",searchStr, gshhs_filepath);  % 定义替换后的字符串
        newContent = strrep(fileContent, searchStr, replaceStr);  % 执行替换操作
        fOWC(m_filepath, 'w', newContent);
    end
    STATUS = 1;
end

function STATUS = fixed_m_etopo2(Jstruct)
    % 更改m_map工具包的m_etopo2.m文件的FILNAME
    m_filepath = fullfile(fileparts(fileparts(Jstruct.FILEPATH)),Jstruct.packages.download.m_map.PATH,'m_etopo2.m');  % which('m_etopo2.m');
    etopo2_path = fullfile(fileparts(fileparts(Jstruct.FILEPATH)),Jstruct.packages.download.etopo1.PATH,'etopo1_ice_g_i2.bin');
    etopo2_filepath = [fileparts(etopo2_path) filesep];
    if ~(exist(m_filepath,"file") && exist(etopo2_path,"file"))
        STATUS = 0;
        return  
    end
    % 备份源文件
    path_DIR = fileparts(m_filepath);
    m_filecopy = fullfile(path_DIR,'m_etopo2_origin.m');
    if ~exist(m_filecopy,'file')
        copyfile(m_filepath,m_filecopy);
    end
    fileContent = fileread(m_filepath);  % 读取文件内容
    if isempty(grep(m_filepath,etopo2_filepath))
        searchStr = 'PATHNAME=''/ocean/rich/more/mmapbase/etopo2v2/'';   % Be sure to end the path with a "/" or';  % 定义要查找的字符串
        replaceStr = sprintf("%% %s \n PATHNAME = '%s';",searchStr, etopo2_filepath);  % 定义替换后的字符串
        newContent = strrep(fileContent, searchStr, replaceStr);  % 执行替换操作
        fOWC(m_filepath, 'w', newContent);
    end
    STATUS = 1;
end

function STATUS = install_ann_wrapper(Jstruct)
    % 安装 ann_wrapper
    m_filepath = fullfile(fileparts(fileparts(Jstruct.FILEPATH)),Jstruct.packages.gitclone.ann_wrapper.PATH,'ann_class_compile.m');  % which('ann_class_compile.m');
    if ~exist(m_filepath,"file")
        STATUS = 0;
    else
        PWD = pwd();
        cd(fileparts(m_filepath))
        ann_class_compile()
        cd(PWD)
        STATUS = 1;
    end
    return
end

function STATUS = install_DHIMIKE(Jsruct) %#ok<INUSD>
    %  https://github.com/DHI/DHI-MATLAB-Toolbox
    STATUS = 0;
    warning("INSTALL.conf:improve:%s do not take effect. \n" + ...
            "%s will be installed by INSTALL.conf:gitclone:%s", 'DHIMIKE','DHIMIKE','DHIMIKE')
    if ispc
        %{
        1. wget https://dist.nuget.org/win-x86-commandline/latest/nuget.exe
        2. Change InstallPackages.bat line 1 with nuget.exe path
        3. Run InstallPackages.bat
        4. Run BuildBin.bat
        5. cd MatlabDfsUtil
        6. Run MatlabDfsUtilBuild.bat
        7. cp MatlabDfsUtil.dll mbin/
        8. Run CreateZip.bat (optional)
        %}
    end
end

function STATUS = install_irfu_matlab(Jstruct)
    % 安装 ann_wrapper
    m_filepath = fullfile(fileparts(fileparts(Jstruct.FILEPATH)),Jstruct.packages.gitclone.irfu_matlab.PATH,'irf.m');  % which('irf.m');
    if ~exist(m_filepath,"file")
        STATUS = 0;
    else
        PWD = pwd();
        cd(fileparts(m_filepath))
        irf();
        cd(PWD)
        STATUS = 1;
    end
    return
end

function [STATUS, PATH] = install_pkgs(PATH, Jstruct, control)
    % packages.gitclone --> START
    fields_gitclone = fieldnames(Jstruct.packages.gitclone)';
    Git = Jstruct.git;
    Git = get_git_method(Git); %get git是CMD还是MATLAB自带 | add .CHECK 
    CLONES = struct(''); 
    PATH.exfunctions.gitclone = [];
    if ~Git.CHECK
        warning("git is not installed, functions at packages:gitclone will not be installed, please install git or set in 'INSTALL.json' and run %s again.", mfilename);
    end
    for field_cell = fields_gitclone
        field = field_cell{1};
        STATUS1.(field) = 0;
        pkg = Jstruct.packages.gitclone.(field);
        pkg_path = fullfile(PATH.basepath, pkg.PATH);
        PATH.exfunctions.gitclone = [PATH.exfunctions.gitclone, convertCharsToStrings(pkg_path)];
        if isequal(control, 'rm')
            continue
        elseif isequal(control, 'noclone')
            if pkg.SETPATH
                addpath(genpath2(pkg_path,{'.git', '.svn', '.github'}))
            end
            continue
        end
        if pkg.SETPATH
            addpath(genpath2(pkg_path,{'.git', '.svn', '.github'}))
        end
        if Git.TF && Git.CHECK
            if pkg.INSTALL
                if ~(exist(pkg.CHECK{1},pkg.CHECK{2}) == str2double(pkg.CHECK{3})) && pkg.SETPATH  % 如果不同时判断pkg.SETPATH 当pkg.INSATLL && ~pkg.SETPATH 由于不在路径中检测不到会重复下载
                    if isfield(Git,'mirror')
                        pkg_url = replace(pkg.URL,'https://github.com',del_filesep(Git.mirror));  % mirror
                    else
                        pkg_url = pkg.URL;
                    end
                    
                    fprintf('---------> Cloning %s toolbox into %s\n', field, pkg.PATH)
                    CLONES(1).(field) = git_clone(Git, pkg_url, pkg_path, pkg);
                    STATUS1.(field) = 1;
                end
                clearvars txt field field_cell
            end
            if pkg.SETPATH
                addpath(genpath2(pkg_path,{'.git', '.svn', '.github'}))
            end  
        end

        clearvars pkg pkg_url pkg_path
    end
    STATUS_gitclone = any(struct2array(STATUS1));

    clearvars STATUS1
    % END <-- packages.gitclone

    % packages.download --> START
    fields_download = fieldnames(Jstruct.packages.download)';
    PATH.exfunctions.download = [];
    for field_cell = fields_download
        field = field_cell{1};
        STATUS1.(field) = 0;
        pkg = Jstruct.packages.download.(field);
        pkg_path = fullfile(PATH.basepath, pkg.PATH);
        PATH.exfunctions.download = [PATH.exfunctions.download, convertCharsToStrings(pkg_path)];
        if isequal(control, 'rm')
            continue
        elseif isequal(control, 'noclone')
            if pkg.SETPATH
                addpath(genpath2(pkg_path,{'.git', '.svn', '.github'}))
            end
            continue
        end
        if pkg.SETPATH
            addpath(genpath2(pkg_path,{'.git', '.svn', '.github'}))
        end
        if ~(exist(pkg.CHECK{1},pkg.CHECK{2}) == str2double(pkg.CHECK{3})) && pkg.INSTALL && pkg.SETPATH  % 如果不同时判断pkg.SETPATH 当pkg.INSATLL && ~pkg.SETPATH 由于不在路径中检测不到会重复下载
            pkg_localfile = fullfile(PATH.basepath, pkg.LOCALFILE);
            if ~(exist(pkg_localfile, 'file') == 2)  % No cache will download.
                pkg_url = pkg.URL;
                fprintf('---------> Downloading %s toolbox into %s\n', field, pkg.LOCALFILE)
                download_urlfile(pkg_url, pkg_localfile, Jstruct.down.thread)
            end
            if ~(exist(pkg_localfile, 'file') == 2)
                error('%s is not downloaded, please download it manually!',pkg.LOCALFILE);
            else
                switch field
                    case {'m_map', 'mexcdf'}
                    unzip_file(pkg_localfile, fileparts(pkg_localfile));  % Exfunctions/ 
                case {'DHIMIKE', 't_tide', 'GSW', 'seawater', 'WindRose', 'gshhs', 'etopo1'}
                    unzip_file(pkg_localfile, pkg_path);  % Exfunctions/t_tide
                end     
                if isequal(field, 'mexcdf')
                    [pathstr, name] = fileparts(pkg_localfile);
                    branch_path = fullfile(pathstr,name);
                    move_mexcdf_branch(branch_path, pkg_path);
                    % rmfiles(branch_path)
                end
                % delete(local_file);
                if pkg.SETPATH
                    addpath(genpath2(pkg_path,{'.git', '.svn', '.github'}))
                end
            end
            STATUS1.(field) = 1;
        end
        clearvars field field_cell pkg local_file pkg_url pkg_localfile
    end
    STATUS_download = any(struct2array(STATUS1));
    clearvars STATUS1
    % END <-- packages.download

    STATUS = or(STATUS_gitclone,STATUS_download);

    clearvars STATUS_gitclone STATUS_download
    PATH.exfunctions.gitclone = cellstr(PATH.exfunctions.gitclone)';
    PATH.exfunctions.download = cellstr(PATH.exfunctions.download)';
    return
end

function STATUS = move_mexcdf_branch(Afolder, Ufolder)
    % STATUS = 0;
    Dir1 = {'mexnc', 'netcdf_toolbox', 'snctools'};
    makedirs(Ufolder)  % [Edir, 'mexcdf']
    for d = Dir1
        copyfile(fullfile(Afolder, d{1}, '/trunk/*'), fullfile(Ufolder, d{1}))  % Afolder --> [Edir, 'mexcdf-svn-r4054']
    end
    rmfiles(Afolder)
    clear d
    STATUS = 1;
end

function TF = check_command(command)
    switch computer('arch')
        case {'win32','win64'}
            command = ['where ' command];
        case {'glnxa64','maci64','maca64'}
            command = ['which ' command];
        otherwise
            error('platform error')
    end
    [status,~] = system(command);
    if status == 0
        TF = true;
    else
        TF = false;
    end
end

function download_urlfile(urlin, fileOut, thread)
    if check_command('axel')
        txt = ['axel -a -v -n ', num2str(thread) ,' ', urlin, ' -o ', fileOut];
        % txt = ['axel -a -v -n 4 ', url, ' -o ', Edir, 't_tide_v1.5beta.zip'];
        disp(txt);
        system(txt);
    elseif check_command('wget')
        txt = ['wget ', urlin, ' -O ', fileOut];
        % txt = ['wget ', url, ' -O ', Edir, 't_tide_v1.5beta.zip'];
        disp(txt);
        system(txt);
    elseif check_command('curl')
        txt = ['curl -L ', urlin, ' -o ', fileOut];
        % txt = ['curl ', url, ' -o ', Edir, 't_tide_v1.5beta.zip'];
        disp(txt);
        system(txt);
    else
        websave(fileOut, url);
        % warning('wget and curl are not installed, t_tide will not be installed');
    end
end

function unzip_file(fileIn, dirOut)
    if check_command('unzip')
        txt = ['unzip ', fileIn, ' -d ', dirOut];
        % txt = ['unzip ', Edir, 'm_map/data/gshhg-bin-2.3.7.zip -d ', Edir, 'm_map/data/'];
        disp(txt);
        system(txt);
    else
        unzip(fileIn, dirOut);
        % unzip([Edir, 'm_map/data/gshhg-bin-2.3.7.zip'], [Edir, 'm_map/data/']);
    end
end

function CLONE = git_clone(Git, pkg_url, pkg_path, pkg)
    CLONE = '';
    method = Git.method;
    username = Git.username;
    password = Git.password;
    Depth = pkg.DEPTH;
    Branch = pkg.BRANCH;
    switch lower(method)
    case {'cmd'}
        if Depth == 0
            Depth = 99999999;
        end
        if ~strcmp(username,'None') && ~strcmp(password,'None')
            % https://blog.csdn.net/qq_45859054/article/details/108036754
            username = replace(username,'@','%40');
            password = replace(password,'@','%40');
            pkg_url = replace(pkg_url,'://',sprintf('://%s:%s@',username,password));
        end
            txt = sprintf('git clone -b %s --depth %d %s %s', Branch, Depth, pkg_url, pkg_path);
        disp(txt)
        system(txt);
    case {'matlab'}
        CLONE = gitclone(pkg_url, pkg_path, 'Depth', Depth);
    end
end

function Git = get_git_method(Git)
    if isfield(Git, 'method') && ~isempty(Git.method) && isa(Git.method,"char")
        switch lower(Git.method)
        case {'cmd'}
            if isfield(Git, 'path') && ~isempty(Git.path) && isa(Git.path,"char")
                setenv('PATH', [Git.path, pathsep, getenv('PATH')]);
            end
        case {'auto'}
            if ~isMATLABReleaseOlderThan("R2023b")
                Git.method = 'MATLAB';
            else
                Git.method = 'cmd';
            end
        case {'matlab'}
            if ~isMATLABReleaseOlderThan("R2023b")
            else
                [list_content,line_id] = grep(Jstruct.FILEPATH, '"method"');
                error([' MATLAB version less than R2023b! \n ' ...
                    'Please set "method" at line %d, in "INSTALL.json" to "AUTO" or "CMD"! \n ' ...
                    'You set --> %s'],line_id(1),char(list_content))
            end
        end
    end

    switch lower(Git.method)
    case{'cmd'}
        Git.CHECK = check_command('git');
    case{'matlab'}
        Git.CHECK = true;
    end

end

function fOWC(filename, mode, content)
    fid = fopen(filename, mode);  % 将修改后的内容写回文件
    fwrite(fid, content);
    fclose(fid);
end

function print_info()
    fprintf('\n')
    fprintf('=====================================================================\n')
    fprintf('As adding files, if it does not take efect, please restart MATLAB    \n')
    fprintf('=====================================================================\n')
    fprintf('\n')
end

function fun = ABANDON()
    fun.read_start = @read_start;
    fun.save_clones = @save_clones;
    function S2 = read_start(structIn, prefix)
        % 从struct中读取以prefix_开头的变量，将变量写入到PATH结构体中
        % eg: 将struct中的Git_path写入到Git.path中
        S2 = struct();
        key = fieldnames(structIn);
        pattern = sprintf('^%s_', prefix);  % ^Git_
        for i = 1 : length(key)
            if ~isempty(regexp(key{i},pattern,'once'))
                S2.(key{i}(length(pattern):end)) = structIn.(key{i});
            end
        end
    end

    function save_clones(clones)
        path__ = mfilename("fullpath");
        [path,~]=fileparts(path__);
        Sdir = fullfile(path, 'Data');
        Sfile = fullfile(Sdir, 'GitRepository.mat');
        keys = fieldnames(clones);
        for i = 1 : length(keys)
            if exist(Sfile,'file')
                load(Sfile,'GitRepository')
                GitRepository.(keys{i}) = clones.(keys{i});
            else
                GitRepository = clones;
            end
            save(Sfile,'GitRepository',"GitRepository","-mat",'-v7.3')
        end
    end
end
