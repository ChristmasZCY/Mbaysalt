function ST_Mbaysalt(varargin)
    %       To setup path of Mbaysalt
    % =================================================================================================================
    % Parameters:
    %       varargin: (optional) 
    %           add:        add all path        || required: False|| type: Text       || format: 'add'
    %           rm:         remove all path     || required: False|| type: Text       || format: 'rm'
    %           cd:         cd here             || required: False|| type: Text       || format: 'cd'
    %           noclone:    Not add new pkgs    || required: False|| type: flag       || format: 'noclone'
    %           init:       Initialize          || required: False|| type: flag       || format: 'init'
    %           *.json:     INSTALL JsonFile    || required: False|| type: positional || format: './INSTALL.json'
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Updates:
    %       ****-**-**:     See Mainpath.m
    %       2024-04-26:     Code Refactoring,                                       by Christmas;
    %       2024-05-12:     Added check git:mirror,                                 by Christmas;
    %       2024-05-12:     Added improve:minmax, submodule gitclone:irfu_matlab,   by Christmas;
    %       2024-05-12:     Judged init first,                                      by Christmas;
    %       2024-05-16:     Added improve:m_etopo2,                                 by Christmas;
    %       2024-06-15:     Added improve:matFigure,                                by Christmas;
    %       2024-12-09:     Added ETOPO1_Bed_g_gmt4, ETOPO1_Ice_g_gmt4,             by Christmas;
    %       2024-12-09:     Added ungz_file, export Proxy from MATLAB to CMD,       by Christmas;
    %       2024-12-19:     Fixed 'setup_nctoolbox_java' automatically if not init, by Christmas;
    %       2024-12-21:     Added improve:tmd_ellipse_v2_5, for parpool('T'),       by Christmas;
    %       2024-12-26:     Added improve:cdt,                                      by Christmas;
    %       2025-01-05:     Changed to improve:tmd_v2_5_parpool for more,           by Christmas;
    %       2025-01-05:     Added test instead of 'INSTALL_all.json',               by Christmas;
    % =================================================================================================================
    % Examples:
    %       ST_Mbaysalt                             % Add all path
    %       ST_Mbaysalt('add')                      % Add all path
    %       ST_Mbaysalt('rm')                       % Remove all path
    %       ST_Mbaysalt('noclone')                  % Add all path without clone git
    %       ST_Mbaysalt('cd')                       % Change current directory to the path of this function
    %       ST_Mbaysalt('init')                     % Initialize
    %       ST_Mbaysalt('add','init')               % Initialize and add all path
    %       ST_Mbaysalt('add','./INSTALL.json')     % Add all path
    % =================================================================================================================
    
    arguments(Input, Repeating)
        varargin
    end

    % --> DEFAULT
    PATH.basepath = fileparts(mfilename("fullpath"));
    cmd = 'add';   % 默认是 add
    init = false;  % 默认是不初始化
    Jfile = fullfile(PATH.basepath,'Configurefiles','INSTALL.json');  % ./**/Mbaysalt/Configurefiles/INSTALL.json
    % <-- DEFAULT
    for i = 1: length(varargin)
        switch lower(varargin{i})
        case {'add','rm','noclone','test'} 
            cmd = lower(convertStringsToChars(varargin{i}));
            varargin(i) = [];
            break
        case {'cd'}  % cd to the path of this function
            cd(fileparts(mfilename("fullpath")))
            return
        end
    end

    if ispref('Mbaysalt','init') && strcmp(getpref('Mbaysalt','init'), 'DONE')
        init = false;
    else
        init = true;
    end
    for i = 1 : length(varargin)
        switch lower(varargin{i})
        case 'init'
            init = true;
        otherwise 
            if endsWith(varargin{i},'.json')
                Jfile = varargin{i};
            end
        end
    end
    clear i
    
    if exist('./INSTALL.json','file')
        Jfile = './INSTALL.json';
    end
    Jstruct = jsondecode(fileread(Jfile)); Jstruct.FILEPATH = Jfile;
    PATH.modules = fullfile(PATH.basepath, Jstruct.packages.modules.PATH); % modules
    PATH.builtin = fullfile(PATH.basepath, Jstruct.packages.builtin.PATH); % builtin
    
    STATUS = 0;
    if strcmp(cmd,'add') | strcmp(cmd,'noclone')
        addpath(strjoin(PATH.modules, pathsep)); % cellfun(@addpath, PATH.module); 慢
        addpath(strjoin(PATH.builtin, pathsep));
    end

    if strcmp(cmd,'test')
        Jstruct = reset_Jstruct(Jstruct, 'test');
        cmd = 'add';
    end

    switch cmd
    case 'add'  % addpath
        Jstruct.git.TF = true;
    case 'noclone'   % noclone
        Jstruct.git.TF = false;
    case 'rm'  % rmpath
        [~, PATH] = install_pkgs(PATH, Jstruct, 'rm');
        Crmpath(PATH.modules)  % rmpath(strjoin(PATH.modules, pathsep))
        Crmpath(PATH.builtin)  % rmpath(strjoin(PATH.builtin, pathsep))
        Crmpath(PATH.exfunctions.download)
        Crmpath(PATH.exfunctions.gitclone)
        if ispref('Mbaysalt','init'); rmpref('Mbaysalt'); end
    otherwise
        error('Parameter error !!!');
    end

    switch cmd
    case {'add', 'noclone'}
        [~, ~] = install_pkgs(PATH, Jstruct, cmd);  % install_pkgs
        if init
            STATUS1 = Fixed_functions(Jstruct);
        else
            STATUS1 = 0;
        end
        STATUS2 = Javaaddpath(Jstruct);
        STATUS = any([STATUS1,STATUS2]);
        clear STATUS1 STATUS2
    end

    if STATUS || init
        print_info()
    end
    
    if init
        if ispref('Mbaysalt','PATH_toolbox'); rmpref('Mbaysalt'); end  % Fixed Mainpath 
        if ~checkOS('LNX')  % 非LNX才会设置，因为LNX上不同需要，一个包可能在多个位置出现
            setpref('Mbaysalt','init','DONE')
        else
            if ispref('Mbaysalt','init'); rmpref('Mbaysalt'); end% 之前设置的去掉
        end
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

function STATUS = Javaaddpath(Jstruct)
    STATUS = 0;
    if exist('setup_nctoolbox_java','file') == 2 && Jstruct.packages.gitclone.nctoolbox.SETPATH
        javadir = fileparts(which('setup_nctoolbox_java.m'));
        if ismember(javadir,javaclasspath)
            return
        end
        try
            setup_nctoolbox_java()
        catch ME1
            if strcmp(ME1.identifier, 'MATLAB:dispatcher:noMatchingConstructor')
                STATUS = fixed_setup_nctoolbox_java(Jstruct);
                setup_nctoolbox_java()
            end
        end
    end
end

function STATUS = Fixed_functions(Jstruct)
    % 修正一些函数
    STATUS_list = [];
    if Jstruct.improve.t_tide
        STATUS_list = [STATUS_list,fixed_t_tide(Jstruct)]; % 添加输出ref基准面的信息
    end
    if Jstruct.improve.setup_nctoolbox_java
        STATUS_list = [STATUS_list,fixed_setup_nctoolbox_java(Jstruct)]; % 关闭setup_nctoolbox_java的一行，MATLAB高版本会报错
    end
    if Jstruct.improve.matFVCOM
        STATUS_list = [STATUS_list,supplement_matFVCOM(Jstruct)];  % 完善包函数
    end
    if Jstruct.improve.mexcdf
        STATUS_list = [STATUS_list,fixed_mexcdf(Jstruct)];  % 修正一些函数在高版本matlab中的报错
    end
    if Jstruct.improve.m_gshhs
        STATUS_list = [STATUS_list,fixed_m_gshhs(Jstruct)];  % 修正文件路径
    end
    if Jstruct.improve.m_etopo2
        STATUS_list = [STATUS_list,fixed_m_etopo2(Jstruct)];  % 修正文件路径
    end
    if Jstruct.improve.ann_wrapper
        STATUS_list = [STATUS_list,install_ann_wrapper(Jstruct)];  % 编译安装
    end
    if Jstruct.improve.DHIMIKE
        STATUS_list = [STATUS_list,install_DHIMIKE(Jstruct)];  % 安装
    end
    if Jstruct.improve.irfu_matlab
        STATUS_list = [STATUS_list,install_irfu_matlab(Jstruct)];  % 安装
    end
    if Jstruct.improve.matFigure
        STATUS_list = [STATUS_list,supplement_matFigure(Jstruct)];  % 完善包函数
    end
    if Jstruct.improve.tmd_v2_5_parpool
        STATUS_list = [STATUS_list,fixed_tmd_v2_5_parpool(Jstruct,'tmd_ellipse')];    % 修复parpool遇到问题
        STATUS_list = [STATUS_list,fixed_tmd_v2_5_parpool(Jstruct,'tide_pred_v2_5')]; % 修复parpool遇到问题
        STATUS_list = [STATUS_list,fixed_tmd_v2_5_parpool(Jstruct,'extract_HC')];     % 修复parpool遇到问题
    end
    if Jstruct.improve.cdt
        STATUS_list = [STATUS_list,supplement_cdt(Jstruct)];  % 完善包函数
    end
    STATUS = any(STATUS_list);
end

function STATUS = fixed_t_tide(Jstruct)
    % 为t_tide工具包的t_tide.m文件添加ref参数
    m_filepath = fullfile(fileparts(fileparts(Jstruct.FILEPATH)),Jstruct.packages.download.t_tide.PATH,'t_tide.m');  % which('t_tide.m');
    STATUS = 0;
    if ~exist(m_filepath,"file")
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
    if ~contains(fileContent, searchStr)  % 不需要替换
        return
    end
    newContent = strrep(fileContent, searchStr, replaceStr);  % 执行替换操作
    fOWC(m_filepath, 'w', newContent);
    STATUS = 1;
end

function STATUS = fixed_setup_nctoolbox_java(Jstruct)
    % 修正nctoolbox工具包的setup_nctoolbox_java.m函数在高版本matlab中的报错
    m_filepath = fullfile(fileparts(fileparts(Jstruct.FILEPATH)),Jstruct.packages.gitclone.nctoolbox.PATH,'java','setup_nctoolbox_java.m');  % which('setup_nctoolbox_java.m');
    STATUS = 0;
    if ~exist(m_filepath,"file")
        return  
    end
    % 备份源文件
    path_DIR = fileparts(m_filepath);
    m_filecopy = fullfile(path_DIR,'setup_nctoolbox_java_origin.m');
    if ~exist(m_filecopy,'file')
        copyfile(m_filepath,m_filecopy);
    end
    fileContent = fileread(m_filepath);  % 读取文件内容
    if contains(fileContent, '% root.addAppender')
        return
    end
    pattern = '(?m)^(?<!%)(root\.addAppender\(org\.apache\.log4j\.ConsoleAppender\(org\.apache\.log4j\.PatternLayout\(''%d\{ISO8601\} \[\%t\] %-5p %c %x - %m%n''\)\)\);)';
    replacement = '% $1';
    newContent = regexprep(fileContent, pattern, replacement);
    fOWC(m_filepath, 'w', newContent);
    STATUS = 1;
end

function STATUS = fixed_tmd_v2_5_parpool(Jstruct, functionName)
    % 修正TMDToolbox_v2_5工具包的${functionName}.m(tmd_ellipse.m)函数,由于'path'函数无法在'parpool("Threads")'中使用
    m_filepath = fullfile(fileparts(fileparts(Jstruct.FILEPATH)),Jstruct.packages.gitclone.TMDToolbox_v2_5.PATH,'TMD',sprintf('%s.m',functionName));  % which('tmd_ellipse.m');
    STATUS = 0;
    if ~exist(m_filepath,"file")
        return  
    end
    % 备份源文件
    path_DIR = fileparts(m_filepath);
    m_filecopy = fullfile(path_DIR,sprintf('%s_origin.m',functionName));
    if ~exist(m_filecopy,'file')
        copyfile(m_filepath,m_filecopy);
    end
    fileContent = fileread(m_filepath);  % 读取文件内容
    if contains(fileContent, '% path(path,funcdir);')
        return
    end
    pattern = '(?m)^(?<!%)(path\(path,funcdir\);)';
    replacement = '% $1';
    newContent = regexprep(fileContent, pattern, replacement);
    fOWC(m_filepath, 'w', newContent);
    STATUS = 1;
end

function STATUS = supplement_matFVCOM(Jstruct)
    % 为matFVCOM添加Contents.m和functionSignatures.json和...
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
            if checkOS("MAC") & strcmp(getHome(),'/Users/christmas')
                % only for MacBook test
                str = sprintf('ln -sf %s %s', file_in, file_out);
                system(str,"-echo");
            else
                copyfile(file_in,file_out);
            end
            STATUS_list(i) = 1;
        else
            if ~readlink(file_out)
                file_out_bak = strcat(file_out,'_bak');
                if ~exist(file_out_bak,"file")  % backup
                    copyfile(file_out,file_out_bak);
                end
                if ~strcmp(fileread(file_in), fileread(file_out))
                    copyfile(file_in,file_out);
                    STATUS_list(i) = 1;
                else
                    STATUS_list(i) = 0;
                end
            end      
        end
    end
    STATUS = any(STATUS_list);

    % T = validateFunctionSignaturesJSON(fullfile(path_matFVCOM,'functionSignatures.json'));
    % if ~isempty(T)
        % validateFunctionSignaturesJSON(fullfile(path_matFVCOM,'functionSignatures.json'));
    % end
end

function STATUS = supplement_matFigure(Jstruct)
    % 为matFigure添加Contents.m和functionSignatures.json和...
    m_filepath = fullfile(fileparts(fileparts(Jstruct.FILEPATH)),Jstruct.packages.gitclone.matFigure.PATH,'cm_disp.m');  % which('cm_disp.m');
    if ~exist(m_filepath,"file")
        STATUS = 0;
        return  
    end
    basepath = fileparts(fileparts(Jstruct.FILEPATH));
    path_in = fullfile(basepath,Jstruct.supplement.matFigure.PATH_IN);
    path_out = fullfile(basepath,Jstruct.supplement.matFigure.PATH_OUT);
    files_in = fullfile(path_in,string(Jstruct.supplement.matFigure.FILES));
    files_out = fullfile(path_out,string(Jstruct.supplement.matFigure.FILES));
    STATUS_list = zeros(length(files_in),1);
    for i = 1 : length(files_in)
        file_in = files_in(i);
        file_out = files_out(i);
        % file_basename = replace(file_out,strcat(fileparts(file_out),filesep),'');
        % file_basename = Jstruct.supplement.matFigure.FILES{i};
        if ~exist(file_out,"file")
            if checkOS("MAC") & strcmp(getHome(),'/Users/christmas')
                % only for MacBook test
                str = sprintf('ln -sf %s %s', file_in, file_out);
                system(str,"-echo");
            else
                copyfile(file_in,file_out);
                STATUS_list(i) = 1;
            end
        else
            if ~readlink(file_out)
                file_out_bak = strcat(file_out,'_bak');
                if ~exist(file_out_bak,"file")  % backup
                    copyfile(file_out,file_out_bak);
                end
                if ~strcmp(fileread(file_in), fileread(file_out))
                    copyfile(file_in,file_out);
                    STATUS_list(i) = 1;
                else
                    STATUS_list(i) = 0;
                end
            end      
        end
    end
    STATUS = any(STATUS_list);

    % T = validateFunctionSignaturesJSON(fullfile(path_matFVCOM,'functionSignatures.json'));
    % if ~isempty(T)
        % validateFunctionSignaturesJSON(fullfile(path_matFVCOM,'functionSignatures.json'));
    % end
end

function STATUS = supplement_cdt(Jstruct)
    % 为cdt添加functionSignatures.json
    m_filepath = fullfile(fileparts(fileparts(Jstruct.FILEPATH)),Jstruct.packages.gitclone.cdt.PATH,'CDT_reduced.jpg');  % which('CDT_reduced.jpg');
    if ~exist(m_filepath,"file")
        STATUS = 0;
        return  
    end
    basepath = fileparts(fileparts(Jstruct.FILEPATH));
    path_in = fullfile(basepath,Jstruct.supplement.cdt.PATH_IN);
    path_out = fullfile(basepath,Jstruct.supplement.cdt.PATH_OUT);
    files_in = fullfile(path_in,string(Jstruct.supplement.cdt.FILES));
    files_out = fullfile(path_out,string(Jstruct.supplement.cdt.FILES));
    STATUS_list = zeros(length(files_in),1);
    for i = 1 : length(files_in)
        file_in = files_in(i);
        file_out = files_out(i);
        % file_basename = replace(file_out,strcat(fileparts(file_out),filesep),'');
        % file_basename = Jstruct.supplement.cdt.FILES{i};
        if ~exist(file_out,"file")
            if checkOS("MAC") & strcmp(getHome(),'/Users/christmas')
                % only for MacBook test
                str = sprintf('ln -sf %s %s', file_in, file_out);
                system(str,"-echo");
            else
                copyfile(file_in,file_out);
                STATUS_list(i) = 1;
            end
        else
            if ~readlink(file_out)
                file_out_bak = strcat(file_out,'_bak');
                if ~exist(file_out_bak,"file")  % backup
                    copyfile(file_out,file_out_bak);
                end
                if ~strcmp(fileread(file_in), fileread(file_out))
                    copyfile(file_in,file_out);
                    STATUS_list(i) = 1;
                else
                    STATUS_list(i) = 0;
                end
            end      
        end
    end
    STATUS = any(STATUS_list);

    % T = validateFunctionSignaturesJSON(fullfile(path_cdt,'functionSignatures.json'));
    % if ~isempty(T)
        % validateFunctionSignaturesJSON(fullfile(path_cdt,'functionSignatures.json'));
    % end
end

function STATUS = fixed_mexcdf(Jstruct)
    % 修复mexcdf工具包的ncmex.m在MATLAB高版本的报错
    m_filepath = fullfile(fileparts(fileparts(Jstruct.FILEPATH)),Jstruct.packages.download.mexcdf.PATH,'netcdf_toolbox','netcdf','ncutility','ncmex.m');  % which('ncmex.m');
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
    if ~contains(fileContent, searchStr)  % 不需要替换
        return
    end
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
    warning("INSTALL.json:improve:%s do not take effect. \n" + ...
            "%s will be installed by INSTALL.json:gitclone:%s", 'DHIMIKE','DHIMIKE','DHIMIKE')
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
    % 安装 irfu_matlab
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
                if ~(exist(pkg.CHECK{1},pkg.CHECK{2}) == str2double(pkg.CHECK{3})) && pkg.SETPATH  % 如果不同时判断pkg.SETPATH, 当pkg.INSATLL && ~pkg.SETPATH 由于不在路径中检测不到会重复下载
                    if isfield(Git,'mirror') && ~isempty(Git.mirror)
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
            if ~(exist(pkg_localfile, 'file') == 2) || java.io.File(pkg_localfile).length() == 0  % 如果下载为空则删除空白文件
                rmfiles(pkg_localfile);
                error(['%s downloaded failed, please download it manually! \n' ...
                       'URL is %s \n', ...
                       'Then return %s !'], pkg.LOCALFILE, pkg.URL, mfilename());
            else
                switch field
                case {'m_map', 'mexcdf', 'dace'}
                    STAUS_unzip = unzip_file(pkg_localfile, fileparts(pkg_localfile));  % Exfunctions/ 
                case {'DHIMIKE', 't_tide', 'GSW', 'seawater', 'WindRose', 'gshhs', 'etopo1', 'Mesh2d'}
                    STAUS_unzip = unzip_file(pkg_localfile, pkg_path);  % Exfunctions/t_tide
                case {'ETOPO1_Bed_g_gmt4', 'ETOPO1_Ice_g_gmt4'}
                    STAUS_unzip = ungz_file(pkg_localfile, pkg_path);  %.gz
                otherwise
                    error('packages %s : unzip is not defined !!!' )
                end
                if ~STAUS_unzip
                    warning_state = warning("query").state;
                    warning('on')
                    warning(['%s downloaded failed, please download it manually! \n' ...
                             'URL is %s', ...
                             'Then return %s !'], pkg.LOCALFILE, pkg_url, mfilename());
                    warning(warning_state)
                end
                if isequal(field, 'mexcdf')
                    [pathstr, name] = fileparts(pkg_localfile);
                    branch_path = fullfile(pathstr,name);
                    move_mexcdf_branch(branch_path, pkg_path);
                    % rmfiles(branch_path)
                elseif isequal(field, 'Mesh2d')
                    fin = fullfile(pkg_path, sprintf('Mesh2d %s', pkg.VERSION));
                    fout = pkg_path;
                    movefile(sprintf('%s/*',fin), fout)
                    rmdir(fin); clear fin fout
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
        copyfile(fullfile(Afolder, d{1}, 'trunk','*'), fullfile(Ufolder, d{1}))  % Afolder --> [Edir, 'mexcdf-svn-r4054']
    end
    rmfiles(Afolder)
    clear d
    STATUS = 1;
end

function TF = check_command(command)
    if checkOS("WIN")
        command = ['where ' command];
    else  % LNX MAC
        command = ['which ' command];
    end
    [status,~] = system(command);
    if status == 0
        TF = true;
    else
        TF = false;
    end
end

function download_urlfile(urlin, fileOut, thread)
    Proxy.TF = com.mathworks.mlwidgets.html.HTMLPrefs.getUseProxy;
    if Proxy.TF
        Proxy.Host = string(com.mathworks.mlwidgets.html.HTMLPrefs.getProxyHost);
        Proxy.Port = string(com.mathworks.mlwidgets.html.HTMLPrefs.getProxyPort);
        Proxy.LNXCMD = sprintf('export https_proxy=http://%s:%s http_proxy=http://%s:%s all_proxy=socks5://%s:%s && ', repmat([Proxy.Host, Proxy.Port],1,3));
        Proxy.WINCMD = sprintf('$Env:http_proxy="http://%s:%s";$Env:https_proxy="http://%s:%s";', repmat([Proxy.Host, Proxy.Port],1,2));
        Proxy.WINPWS = sprintf('set http_proxy=http://%s:%s & set https_proxy=http://%s:%s & ', repmat([Proxy.Host, Proxy.Port],1,2));
        setenv('https_proxy', sprintf('http://%s:%s',Proxy.Host, Proxy.Port));
        setenv('http_proxy',  sprintf('http://%s:%s',Proxy.Host, Proxy.Port));
        setenv('all_proxy',   sprintf('socks5://%s:%s',Proxy.Host, Proxy.Port));
    else
        Proxy.Host = "";
        Proxy.Port = "";
        Proxy.LNXCMD = "";
        Proxy.WINCMD = "";
        Proxy.WINPWS = "";
    end

    if checkOS("WIN")
        Proxy.CMD = convertStringsToChars(Proxy.WINPWS);
    else  % MAC LNX
        Proxy.CMD = convertStringsToChars(Proxy.LNXCMD);
    end

    if check_command('axel')
        txt = [Proxy.CMD, 'axel -a -v -n ', num2str(thread) ,' ', urlin, ' -o ', fileOut];
        % txt = ['axel -a -v -n 4 ', url, ' -o ', Edir, 't_tide_v1.5beta.zip'];
        disp(txt);
        system(txt);
    elseif check_command('wget')
        txt = [Proxy.CMD, 'wget ', urlin, ' -O ', fileOut];
        % txt = ['wget ', url, ' -O ', Edir, 't_tide_v1.5beta.zip'];
        % wget --max-redirect=20 --wait=5 -O mexcdf.r4053.zip https://sourceforge.net/projects/mexcdf/files/mexcdf/mexcdf.r4053.zip/download
        disp(txt);
        system(txt);
    elseif check_command('curl')
        txt = [Proxy.CMD, 'curl -L ', urlin, ' -o ', fileOut];
        % txt = ['curl ', url, ' -o ', Edir, 't_tide_v1.5beta.zip'];
        disp(txt);
        system(txt);
    else
        websave(fileOut, url);
        % warning('wget and curl are not installed, t_tide will not be installed');
    end
end

function STATUS = unzip_file(fileIn, dirOut)
    STATUS = 0;
    if check_command('unzip')
        txt = ['unzip ', fileIn, ' -d ', dirOut];
        % txt = ['unzip ', Edir, 'm_map/data/gshhg-bin-2.3.7.zip -d ', Edir, 'm_map/data/'];
        disp(txt);
        [~, cmdout] = system(txt);
        if ~contains(cmdout,'cannot find')
            STATUS = 1;
        end
    else
        try
            unzip(fileIn, dirOut);
            STATUS = 1;
        catch ME1
            if strcmp(ME1.identifier, 'MATLAB:io:archive:unzip:invalidZipFile')
                STATUS = 0;
            end
        end
        % unzip([Edir, 'm_map/data/gshhg-bin-2.3.7.zip'], [Edir, 'm_map/data/']);
    end
end

function STATUS = ungz_file(fileIn, dirOut)
    STATUS = 0;
    try
        filenames = gunzip(fileIn, dirOut);
        if ~isempty(filenames)
            STATUS = 1;
        end
    catch ME1
        disp(ME1)
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
        if Depth == 0 ||  Depth == -1
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
        otherwise
            warning('Wrong git.method at %s !!!', Jstruct.FILEPATH);
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

function print_info1()
    fprintf('\n')
    fprintf('==========================================================================\n')
    fprintf('                                                                          \n')
    fprintf('               ██╗ ██████╗  ██████╗███████╗ █████╗ ███╗   ██╗             \n')
    fprintf('               ██║██╔═══██╗██╔════╝██╔════╝██╔══██╗████╗  ██║             \n')
    fprintf('               ██║██║   ██║██║     █████╗  ███████║██╔██╗ ██║             \n')
    fprintf('               ██║██║   ██║██║     ██╔══╝  ██╔══██║██║╚██╗██║             \n')
    fprintf('               ██║╚██████╔╝╚██████╗███████╗██║  ██║██║ ╚████║             \n')
    fprintf('               ╚═╝ ╚═════╝  ╚═════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝             \n')
    fprintf('                                                                          \n')
    fprintf('                                            --- Powered by Christmas.     \n')
    fprintf('                                                                          \n')
    fprintf('   As adding files, if it does not take effect, please restart MATLAB !!  \n')
    fprintf('==========================================================================\n')
    fprintf('\n')
end

function print_info()
    fprintf('\n')
    fprintf('==========================================================================\n')
    fprintf('                                                                          \n')
    fprintf('    ███╗   ███╗██████╗  █████╗ ██╗   ██╗███████╗ █████╗ ██╗  ████████╗    \n')
    fprintf('    ████╗ ████║██╔══██╗██╔══██╗╚██╗ ██╔╝██╔════╝██╔══██╗██║  ╚══██╔══╝    \n')
    fprintf('    ██╔████╔██║██████╔╝███████║ ╚████╔╝ ███████╗███████║██║     ██║       \n')
    fprintf('    ██║╚██╔╝██║██╔══██╗██╔══██║  ╚██╔╝  ╚════██║██╔══██║██║     ██║       \n')
    fprintf('    ██║ ╚═╝ ██║██████╔╝██║  ██║   ██║   ███████║██║  ██║███████╗██║       \n')
    fprintf('                                                                          \n')
    fprintf('                                            --- Powered by Christmas.     \n')
    fprintf('                                                                          \n')
    fprintf('   As adding files, if it does not take effect, please restart MATLAB !!  \n')
    fprintf('==========================================================================\n')
    fprintf('\n')
    % https://patorjk.com/software/taag/#p=display&h=2&v=1&f=ANSI%20Shadow&t=Mbaysalt
end

function p = genpath2(d, pattern)

    p = genpath(d);
    % Return if missing or empty input argument
    if nargin < 2 || isempty(pattern)
        return
    end
    % Find folders that match the pattern
    splitP = split(p, pathsep);
    pattern = strcat(filesep, pattern);
    hasPattern = contains(splitP, pattern);
    % Index out folders with pattern
    cleanP = splitP(~hasPattern);
    % Return as list in genpath format
    p = char(strjoin(cleanP, pathsep));
end % function-genpath2

function Jstruct = reset_Jstruct(Jstruct,opt)
    switch lower(opt)
    case 'test'
        fields = fieldnames(Jstruct.packages.download);
        for field = fields'
            if ~strcmp(field, 'mexcdf')
                Jstruct.packages.download.(field{1}).INSTALL = true;
                Jstruct.packages.download.(field{1}).SETPATH = true;
            end
        end
        fields = fieldnames(Jstruct.packages.gitclone);
        for field = fields'
            Jstruct.packages.gitclone.(field{1}).INSTALL = true;
            Jstruct.packages.gitclone.(field{1}).SETPATH = false;
        end
        clear fields
    otherwise
        error('Parameter error !!!');
    end
end

function fun = ABANDON()
    fun.read_start = @read_start;
    fun.save_clones = @save_clones;
    function S2 = read_start(structIn, prefix)
        % 从struct中读取以prefix_开头的变量，将变量写入到PATH结构体中
        % eg: 将struct中的Git_path写入到Git.path中
        S2 = struct('');
        key = fieldnames(structIn);
        pattern = sprintf('^%s_', prefix);  % ^Git_
        for i = 1 : length(key)
            if ~isempty(regexp(key{i},pattern,'once'))
                S2(1).(key{i}(length(pattern):end)) = structIn.(key{i});
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
