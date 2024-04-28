function varargout = Mainpath(varargin)
    %       Mainpath is a function to add all path of this package
    % =================================================================================================================
    % Parameters:
    %       varargin:       optional parameters      
    %           add:        add all path                    || required: False|| type: Text || format: 'add'
    %           rm:         remove all path                 || required: False|| type: Text || format: 'rm'
    %           noclone:    add all path without clone git  || required: False|| type: Text || format: 'noclone'
    %           init:       Initialize                      || required: False|| type: Text || format: 'init',true
    %           cd:         cd here                         || required: False|| type: Text || format: 'cd'
    %           noset:      no set pref                     || required: False|| type: Text || format: 'noset'
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Updates:
    %       2023-**-**:     Created, by Christmas;
    %       2023-12-27:     Added check_command, OceanData, FVCOM_NML, by Christmas;
    %       2024-01-02:     Added path pref, by Christmas;
    %       2024-01-31:     Added gitclone(built-in) and return clones info, by Christmas;
    %       2024-02-05:     Added 'cd' feature, by Christmas;
    %       2024-02-22:     Added Exfunctions-kmz2struct, by Christmas;
    %       2024-02-22:     Added Exfunctions/SupplementFiles for toolox, by Christmas;
    %       2024-03-17:     Added Exfunctions/inpolygons-pkg for toolox, by Christmas;
    %       2024-03-21:     Added seawater, GSW, WindRose toolbox , by Christmas; 
    %       2024-03-21:     Extract download,unzip to function, by Christmas; 
    %       2024-04-01:     Added Post_mitgcm, MITgcmTools, by Christmas; 
    %       2024-04-03:     Added install DHI-MATLAB-Toolbox,   by Christmas;
    %       2024-04-04:     Added noset,   by Christmas;
    %       2024-04-07:     Fixed init, change noset,    by Christmas;
    %       2024-04-18:     Added lanczosfilter, CallCodes, by Christmas;
    %       2024-04-23:     Changed TMDToolbox to TMDToolbox_v2_5,  by Christmas;
    %       2024-04-23:     Added TMDToolbox_v3_0, ellipse, JSONLab, MEXNC,  by Christmas;
    %       2024-04-26:     Added OceanMesh2D, ann_wrapper,  by Christmas;
    % =================================================================================================================
    % Examples:
    %       Mainpath                        % Add all path
    %       Mainpath('add')                 % Add all path
    %       Mainpath('rm')                  % Remove all path
    %       Mainpath('noclone')             % Add all path without clone git
    %       Mainpath('init', true)          % Initialize
    %       Mainpath('cd')                  % Change current directory to the path of this function
    %       Mainpath('noset', true)         % Do not set pref
    %       Mainpath('add','init', true)    % Initialize and add all path
    % =================================================================================================================
    
    arguments(Input, Repeating)
        varargin
    end

    cmd = 'add';
    for i = 1: length(varargin)
        switch lower(varargin{i})
            case {'add','rm','noclone'}
                cmd = convertStringsToChars(varargin{i});
                varargin(i) = [];
                break
            case {'cd'}  % cd to the path of this function
                path__ = mfilename("fullpath");
                [path,~]=fileparts(path__);
                cd(path)
                return
        end
    end
    init  = false;
    noset = false;
    for i = 1 : length(varargin)
        switch lower(varargin{i})
        case 'init'
            init = logical(varargin{i+1});
        case 'noset'
            noset = logical(varargin{i+1});
        end
    end

    % 初始化
    if ~isempty(noset)
        [PATH_contains, PATH_toolbox] = Cmakepath;
    else
        if ispref('Mbaysalt','PATH_contains') && ispref('Mbaysalt','PATH_toolbox') && ~init
            PATH_contains = getpref('Mbaysalt','PATH_contains');
            PATH_toolbox = getpref('Mbaysalt','PATH_toolbox');
        else
            if ispref('Mbaysalt')
                rmpref('Mbaysalt')
            end
            [PATH_contains, PATH_toolbox] = Cmakepath;  % get all path
            setpref('Mbaysalt','PATH_contains',PATH_contains)
            setpref('Mbaysalt','PATH_toolbox',PATH_toolbox)
        end
    end
    
    STATUS = 0;
    switch lower(cmd)
    case 'add'
        Caddpath(PATH_contains);              % add all path
        [STATUS, CLONES] = download_pkgs();   % install all pkgs
        if STATUS == 1  % 如果Exfunctions增加了新工具包，则运行重置路径表
            [PATH_contains, PATH_toolbox] = Cmakepath;  % get all path
            if ~noset
                setpref('Mbaysalt','PATH_contains',PATH_contains)
                setpref('Mbaysalt','PATH_toolbox',PATH_toolbox)
            end
        end
        Caddpath(PATH_contains);             % add all path
    case 'rm'
        Crmpath(PATH_contains);   % remove all path
        Caddpath(PATH_toolbox);
    case 'noclone'
        Caddpath(PATH_contains);
    otherwise
        error('parameter error');
    end

    if init
        try
            STATUS = Fixed_functions();  % Fixed some functions
        catch ME1
            STATUS = 0;
        end
        Install_functions()
    end

    if nargout > 0
        varargout{1} = CLONES;
    end
    if STATUS == 1
        print_info()
    end

end


function [FunctionPath,path] = Cmakepath
    path__ = mfilename("fullpath");
    [path,~]=fileparts(path__);
    division = string(filesep);

    FunI = path + division + [
        "Prefunctions"
        "Configurefiles"
        "Picfunctions"
        "Infunctions"
        "Post_fvcom"
        "Post_ww3"
        "Post_tpxo"
        "Post_wrf2fvcom"
        "Post_mitgcm"
        "Gridfunctions"
        "Exfunctions"
        "Readfunctions"
        "Ncfunctions"
        "Examples"
        "Py"
        "Matesetfunctions"
        "Mapfunctions"
        "Mimetifunctions"
        "Docs"
        "CallCodes"
        ];
    FunI = cellstr(FunI);
    
    Cdata = path + division + [
        "Inputfiles"
        "Savefiles"
        "Data"
        ];
    Cdata = cellstr(Cdata);

    FunE = path + division + [
        "Exfunctions/cprintf"
        "Exfunctions/matFVCOM"
        "Exfunctions/matFigure"
        "Exfunctions/matWRF"
        "Exfunctions/HYCOM2FVCOM"
        "Exfunctions/WRF2FVCOM"
        "Exfunctions/cdt"
        "Exfunctions/matNC"
        "Exfunctions/t_tide"
        "Exfunctions/INI"
        "Exfunctions/struct2ini"
        "Exfunctions/inifile"
        "Exfunctions/iniconfig"
        "Exfunctions/m_map"
        "Exfunctions/nctoolbox"
        "Exfunctions/OceanData"
        "Exfunctions/FVCOM_NML"
        "Exfunctions/htool"
        "Exfunctions/ZoomPlot"
        "Exfunctions/TMDToolbox_v2_5"
        "Exfunctions/TMDToolbox_v3_0"
        "Exfunctions/vtkToolbox"
        "Exfunctions/kmz2struct"
        "Exfunctions/inpolygons-pkg"
        "Exfunctions/Extend/matWRF"
        "Exfunctions/Extend/matFVCOM"
        "Exfunctions/SupplementFiles/matFVCOM"
        "Exfunctions/Otherpkgs"
        "Exfunctions/seawater_ver3_3.1"  % https://www.cmar.csiro.au/datacentre/ext_docs/seawater.html
        "Exfunctions/gsw_matlab_v3_06_16"
        "Exfunctions/inploygons-pkg"
        "Exfunctions/WindRose"
        "Exfunctions/MITgcmTools"
        "Exfunctions/DHIMatlabToolbox"
        "Exfunctions/lanczosfilter"
        "Exfunctions/ellipse"
        % "Exfunctions/mexcdf"
        "Exfunctions/JSONLab"
        % "Exfunctions/OceanMesh2D"
        % "Exfunctions/ann_wrapper"
        ];
    FunE = cellstr(FunE);

    fun_genpath2 = path + division + 'Exfunctions/genpath2';
    addpath(fun_genpath2);

    % FunE = cellfun(@genpath2,FunE,repmat({'.git'},length(FunE),1),'UniformOutput', false);
    FunE = cellfun(@genpath2,FunE,repmat({{'.git', '.svn'}},length(FunE),1),'UniformOutput', false);
    FunE (cellfun (@isempty,FunE))= [];

    FunctionPath = [path; FunI; Cdata; FunE; fun_genpath2];
    path = {path};
end

function Caddpath(Path)
    cellfun(@addpath, Path);
    if length(Path) > 1  % PATH_contains才会运行
        Javaaddpath();  % add java path
    end
end


function Crmpath(Path)
    % currentPaths = strsplit(path, pathsep);
    % cellfun(@rmpath, Path(cellfun(@(x) ismember(x, currentPaths), Path)));
    % exception = warning('on','last');
    % identifier = exception.identifier;
    identifier = 'MATLAB:rmpath:DirNotFound';
    
    warning('off',identifier);
    cellfun(@rmpath, Path);
    warning('on',identifier);
end

function Javaaddpath()
    if exist('setup_nctoolbox_java','file') == 2
        % STATUS = fixed_setup_nctoolbox_java();
        setup_nctoolbox_java()
    end
end


function [STATUS, CLONES] = download_pkgs()
    STATUS = 0;
    path__ = mfilename("fullpath");
    [path,~]=fileparts(path__);
    division = string(filesep);
    Edir = char(path + division + 'Exfunctions' + division);

    para_conf = read_conf(fullfile(path,'Configurefiles/INSTALL.conf'));
    Git = read_Git(para_conf);
    if ~isempty(Git)
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
                    error(sprintf([' MATLAB version less than R2023b! \n ' ...
                                   'Please set "Git.method" in "INSTALL.conf" to "AUTO" or "CMD"']))
                end
            end
        end
    end

    switch lower(Git.method)
    case{'cmd'}
        TF = check_command('git');
    case{'matlab'}
        TF = true;
    end

    if isfield(Git, 'mirror') && ~isempty(Git.mirror) && isa(Git.mirror,"char")
        git_url = Git.mirror;
    else
        git_url = 'https://github.com/';
    end

    CLONES = struct();
    if TF
        if para_conf.cdt
            if ~(exist('ncdateread', 'file') == 2)  % CDT
                url = fullfile(git_url, 'chadagreene/CDT.git');  % https://github.com/chadagreene/CDT.git
                disp('---------> Cloning cdt toolbox')
                switch lower(Git.method)
                case {'cmd'}
                    txt = sprintf('git clone %s %s%s', url, Edir, 'cdt');
                    disp(txt)
                    system(txt);
                case {'matlab'}
                    CLONES.cdt = gitclone(url,[Edir, 'cdt']);
                end
                STATUS = 1;
            end
        end
        
        if para_conf.matFVCOM  % SiqiLiOcean/matFVCOM
            if ~(exist('f_load_grid', 'file') == 2)  % matFVCOM
                url = fullfile(git_url, 'SiqiLiOcean/matFVCOM.git');  % https://github.com/SiqiLiOcean/matFVCOM.git
                disp('---------> Cloning matFVCOM toolbox')
                switch lower(Git.method)
                case {'cmd'}
                    txt = sprintf('git clone %s %s%s', url, Edir, 'matFVCOM');
                    disp(txt)
                    system(txt);
                case {'matlab'}
                    CLONES.matfvcom = gitclone(url,[Edir, 'matFVCOM']);
                end
                STATUS = 1;
            end
        end

        if para_conf.matFigure  % SiqiLiOcean/matFigure
            if ~(exist('mf_save', 'file') == 2)  % matFigure
                url = fullfile(git_url, 'SiqiLiOcean/matFigure.git');  % https://github.com/SiqiLiOcean/matFigure.git
                disp('---------> Cloning matFigure toolbox')
                switch lower(Git.method)
                case {'cmd'}
                    txt = sprintf('git clone %s %s%s', url, Edir, 'matFigure');
                    disp(txt)
                    system(txt);
                case {'matlab'}
                    CLONES.matfigure = gitclone(url,[Edir, 'matFigure']);
                end
                STATUS = 1;
            end
        end

        if para_conf.matWRF  % SiqiLiOcean/matWRF
            if ~(exist('load_constants', 'file') == 2)  % matWRF
                url = fullfile(git_url, 'SiqiLiOcean/matWRF.git');  % https://github.com/SiqiLiOcean/matWRF.git
                disp('---------> Cloning matWRF toolbox')
                switch lower(Git.method)
                case {'cmd'}
                    txt = sprintf('git clone %s %s%s', url, Edir, 'matWRF');
                    disp(txt)
                    system(txt);
                case {'matlab'}
                    CLONES.matwrf = gitclone(url,[Edir, 'matWRF']);
                end
                STATUS = 1;
            end
        end
            
        if para_conf.matNC  % SiqiLiOcean/matNC
            if ~(exist('nc_close', 'file') == 2) % matNC
                url = fullfile(git_url, 'SiqiLiOcean/matNC.git');  % https://github.com/SiqiLiOcean/matNC.git
                disp('---------> Cloning matNC toolbox')
                switch lower(Git.method)
                case {'cmd'}
                    txt = sprintf('git clone %s %s%s', url, Edir, 'matNC');
                    disp(txt)
                    system(txt);
                case {'matlab'}
                    CLONES.matnc = gitclone(url,[Edir, 'matNC']);
                end
                STATUS = 1;
            end
        end

        if para_conf.OceanData  % SiqiLiOcean/OceanData
            if ~(exist('UHSLC_info', 'file') == 2) % OceanData
                url = fullfile(git_url, 'SiqiLiOcean/OceanData.git');  % https://github.com/SiqiLiOcean/OceanData.git
                disp('---------> Cloning OceanData toolbox')
                switch lower(Git.method)
                case {'cmd'}
                    txt = sprintf('git clone %s %s%s', url, Edir, 'OceanData');
                    disp(txt)
                    system(txt);
                case {'matlab'}
                    CLONES.oceandata = gitclone(url,[Edir, 'OceanData']);
                end
                STATUS = 1;
            end
        end

        if para_conf.FVCOM_NML  % SiqiLiOcean/FVCOM_NML
            if ~(exist('FVCOM_NML', 'dir') == 7) % FVCOM_NML
                url = fullfile(git_url, 'SiqiLiOcean/FVCOM_NML.git');  % https://github.com/SiqiLiOcean/FVCOM_NML.git
                disp('---------> Cloning FVCOM_NML toolbox')
                switch lower(Git.method)
                case {'cmd'}
                    txt = sprintf('git clone %s %s%s', url, Edir, 'FVCOM_NML');
                    disp(txt)
                    system(txt);
                case {'matlab'}
                    CLONES.FVCOM_NML = gitclone(url,[Edir, 'FVCOM_NML']);
                end
                STATUS = 1;
            end
        end

        if para_conf.HYCOM2FVCOM  % SiqiLiOcean/HYCOM2FVCOM
            if ~(exist('hycom2fvcom_iniTS_create', 'file') == 2) % HYCOM2FVCOM
                url = fullfile(git_url, 'SiqiLiOcean/HYCOM2FVCOM.git');  % https://github.com/SiqiLiOcean/HYCOM2FVCOM.git
                disp('---------> Cloning HYCOM2FVCOM toolbox')
                switch lower(Git.method)
                case {'cmd'}
                    txt = sprintf('git clone %s %s%s', url, Edir, 'HYCOM2FVCOM');
                    disp(txt)
                    system(txt);
                case {'matlab'}
                    CLONES.hycom2fvcom = gitclone(url,[Edir, 'HYCOM2FVCOM']);
                end
                STATUS = 1;
            end
        end

        if para_conf.WRF2FVCOM  % SiqiLiOcean/WRF2FVCOM
            if ~(exist('wrf2fvcom.f90', 'file') == 2) % WRF2FVCOM
                url = fullfile(git_url, 'SiqiLiOcean/WRF2FVCOM.git');  % https://github.com/SiqiLiOcean/WRF2FVCOM.git
                disp('---------> Cloning WRF2FVCOM toolbox')
                switch lower(Git.method)
                case {'cmd'}
                    txt = sprintf('git clone %s %s%s', url, Edir, 'WRF2FVCOM');
                    disp(txt)
                    system(txt);
                case {'matlab'}
                    CLONES.hycom2fvcom = gitclone(url,[Edir, 'WRF2FVCOM']);
                end
                STATUS = 1;
            end
        end

        if para_conf.nctoolbox  % nctoolbox
            if ~(exist('ncload', 'file') == 2)
                url = fullfile(git_url, 'nctoolbox/nctoolbox.git');  % https://github.com/nctoolbox/nctoolbox.git
                disp('---------> Cloning nctoolbox toolbox')
                switch lower(Git.method)
                case {'cmd'}
                    txt = sprintf('git clone %s %s%s', url, Edir, 'nctoolbox');
                    disp(txt)
                    system(txt);
                case {'matlab'}
                    CLONES.nctoolbox = gitclone(url,[Edir, 'nctoolbox']);
                end
                STATUS = 1;
            end
        end

        if para_conf.TMDToolbox_v2_5  % TMDToolbox_v2.5
            if ~(exist('TMD','file') == 2)
                url = fullfile(git_url, 'EarthAndSpaceResearch/TMD_Matlab_Toolbox_v2.5.git');  % https://github.com/EarthAndSpaceResearch/TMD_Matlab_Toolbox_v2.5.git
                disp('---------> Cloning TMDToolbox_v2_5 toolbox')
                switch lower(Git.method)
                case {'cmd'}
                    txt = sprintf('git clone %s %s%s', url, Edir, 'TMDToolbox_v2_5');
                    disp(txt)
                    system(txt);
                case {'matlab'}
                    CLONES.tmdtoolbox = gitclone(url,[Edir, 'TMDToolbox_v2_5']);
                end
                STATUS = 1;
            end
        end

        if para_conf.TMDToolbox_v3_0  % TMDToolbox_v3_0
            if ~(exist('TPXO9_atlas_v5_to_NetCDF','file') == 2)
                url = fullfile(git_url, 'chadagreene/Tide-Model-Driver.git');  % git clone https://github.com/chadagreene/Tide-Model-Driver.git
                disp('---------> Cloning TMDToolbox_v3_0 toolbox')
                switch lower(Git.method)
                case {'cmd'}
                    txt = sprintf('git clone %s %s%s', url, Edir, 'TMDToolbox_v3_0');
                    disp(txt)
                    system(txt);
                case {'matlab'}
                    CLONES.tmdtoolbox = gitclone(url,[Edir, 'TMDToolbox_v3_0']);
                end
                STATUS = 1;
            end
        end

        if para_conf.vtkToolbox  % vtkToolbox
            if ~(exist('vtkRead','file') == 2) && ~(exist('vtkRead','file') == 3)
                url = fullfile(git_url, 'KIT-IBT/vtkToolbox.git');  % https://github.com/KIT-IBT/vtkToolbox.git
                disp('---------> Cloning vtkToolbox toolbox')
                switch lower(Git.method)
                case {'cmd'}
                    txt = sprintf('git clone %s %s%s', url, Edir, 'vtkToolbox');
                    disp(txt)
                    system(txt);
                case {'matlab'}
                    CLONES.vtktoolbox = gitclone(url,[Edir, 'vtkToolbox']);
                end
                STATUS = 1;
            end
        end

        if para_conf.kmz2struct  % kmz2struct
            if ~(exist('kmz2struct','file') == 2)
                url = fullfile(git_url, 'njellingson/kmz2struct.git');  % https://github.com/njellingson/kmz2struct.git
                disp('---------> Cloning kmz2struct toolbox')
                switch lower(Git.method)
                case {'cmd'}
                    txt = sprintf('git clone %s %s%s', url, Edir, 'kmz2struct');
                    disp(txt)
                    system(txt);
                case {'matlab'}
                    CLONES.kmz2struct = gitclone(url,[Edir, 'kmz2struct']);
                end
                STATUS = 1;
            end
        end

        if para_conf.inploygons_pkg  % inploygons-pkg
            if ~(exist('inpolygons','file') == 2)
                url = fullfile(git_url, 'kakearney/inpolygons-pkg.git');  % https://github.com/kakearney/inpolygons-pkg.git
                disp('---------> Cloning inploygons-pkg toolbox')
                switch lower(Git.method)
                case {'cmd'}
                    txt = sprintf('git clone %s %s%s', url, Edir, 'inploygons-pkg');
                    disp(txt)
                    system(txt);
                case {'matlab'}
                    CLONES.inploygons_pkg = gitclone(url,[Edir, 'inploygons-pkg']);
                end
                STATUS = 1;
            end
        end

        if para_conf.JSONLab  % JSONLab
            if ~(exist('loadjson','file') == 2)
                url = fullfile(git_url, 'fangq/jsonlab.git');  % https://github.com/fangq/jsonlab.git
                disp('---------> Cloning JSONLab toolbox')
                switch lower(Git.method)
                case {'cmd'}
                    txt = sprintf('git clone %s %s%s', url, Edir, 'JSONLab');
                    disp(txt)
                    system(txt);
                case {'matlab'}
                    CLONES.JSONLab = gitclone(url,[Edir, 'JSONLab']);
                end
                STATUS = 1;
            end
        end

        if para_conf.OceanMesh2D  % OceanMesh2D
            if ~(exist('setup_oceanmesh2d','file') == 2)
                url = fullfile(git_url, 'CHLNDDEV/OceanMesh2D.git');  % https://github.com/CHLNDDEV/OceanMesh2D.git
                disp('---------> Cloning OceanMesh2D toolbox')
                switch lower(Git.method)
                case {'cmd'}
                    txt = sprintf('git clone %s %s%s', url, Edir, 'OceanMesh2D');
                    disp(txt)
                    system(txt);
                case {'matlab'}
                    CLONES.OceanMesh2D = gitclone(url,[Edir, 'OceanMesh2D']);
                end
                STATUS = 1;
            end
        end

        if para_conf.ann_wrapper  % ann_wrapper
            if ~(exist('ann_class_compile','file') == 2)
                url = fullfile(git_url, 'shaibagon/ann_wrapper.git');  % https://github.com/shaibagon/ann_wrapper.git
                disp('---------> Cloning ann_wrapper toolbox')
                switch lower(Git.method)
                case {'cmd'}
                    txt = sprintf('git clone %s %s%s', url, Edir, 'ann_wrapper');
                    disp(txt)
                    system(txt);
                case {'matlab'}
                    CLONES.ann_wrapper = gitclone(url,[Edir, 'ann_wrapper']);
                end
                STATUS = 1;
            end
        end
       
    else
        warning('git is not installed, some functions will not be installed, please install git or set in INSTALL.conf and run Mainpath again.');
    end

    % DHIMIKE
    if para_conf.DHIMIKE %%&& ispc % DHIMIKE
        if ~(exist('read_dfs2', 'file') == 2)  % DHIMIKE
            local_file = [Edir, 'DHIMatlabToolbox-v19.0.0-20201217.zip'];
            if ~(exist(local_file, 'file') ==2)  % No cache will download.
                % url = 'https://github.com/DHI/DHI-MATLAB-Toolbox/releases/download/v19.0.0/DHIMatlabToolbox-v19.0.0-20201217.zip';
                url = fullfile(git_url, 'DHI/DHI-MATLAB-Toolbox/releases/download/v19.0.0/DHIMatlabToolbox-v19.0.0-20201217.zip');
                disp('---------> Downloading DHI-MATLAB-Toolbox')
                download_urlfile(url, local_file)
            end
            if ~(exist('DHIMatlabToolbox-v19.0.0-20201217.zip', 'file') == 2)
                error('DHIMatlabToolbox-v19.0.0-20201217.zip is not downloaded, please download it manually');
            else
                unzip_file(local_file, [Edir, 'DHIMatlabToolbox']);
            end
            % delete(local_file);
            STATUS = 1;
        end
    end

    % t_tide
    if para_conf.t_tide
        if ~(exist('t_tide', 'file') == 2)  % t_tide
            local_file = [Edir, 't_tide_v1.5beta.zip'];
            if ~(exist(local_file, 'file') ==2)  % No cache will download.
                url = 'https://www.eoas.ubc.ca/~rich/t_tide/t_tide_v1.5beta.zip';
                disp('---------> Downloading t_tide toolbox')
                download_urlfile(url, local_file)
            end
            if ~(exist('t_tide_v1.5beta.zip', 'file') == 2)
                error('t_tide_v1.5beta.zip is not downloaded, please download it manually');
            else
                unzip_file(local_file, [Edir, 't_tide']);
            end
            % delete(local_file);
            STATUS = 1;
        end
    end

    % m_map
    if para_conf.m_map
        if ~(exist('m_demo', 'file') ==2)  % m_map
            local_file = [Edir, 'm_map1.4.zip'];
            if ~(exist(local_file, 'file') ==2)  % No cache will download.
                url = 'https://www.eos.ubc.ca/%7Erich/m_map1.4.zip';
                disp('---------> Downloading m_map toolbox')
                download_urlfile(url, local_file)
            end
            if ~(exist('m_map1.4.zip', 'file') == 2)
                error('m_map1.4.zip is not downloaded, please download it manually');
            else
                unzip_file(local_file, [Edir]); %#ok<NBRAK2>
            end
            % delete(local_file);
            STATUS = 1;
        end
    end

    % GSW Oceanographic Toolbox
    if para_conf.GSW  % http://www.teos-10.org/software.htm
        if ~(exist('gsw_check_functions', 'file') ==2)  % GSW Oceanographic Toolbox
            local_file = [Edir, 'gsw_matlab_v3_06_16.zip'];
            if ~(exist(local_file, 'file') ==2)  % No cache will download.
                url = 'http://www.teos-10.org/software/gsw_matlab_v3_06_16.zip';
                disp('---------> Downloading GSW Oceanographic Toolbox');
                download_urlfile(url, local_file);
            end
            if ~(exist('gsw_matlab_v3_06_16.zip', 'file') == 2)
                error('gsw_matlab_v3_06_16.zip is not downloaded, please download it manually');
            else
                unzip_file(local_file, [Edir, 'gsw_matlab_v3_06_16']);
            end
            % delete(local_file);
            STATUS = 1;
        end
    end

    % seawater
    if para_conf.seawater  % https://www.cmar.csiro.au/datacentre/ext_docs/seawater.html
        if ~(exist('sw_info', 'file') ==2)  % seawater
            local_file = [Edir, 'seawater_ver3_3.1.zip'];
            if ~(exist(local_file, 'file') ==2)  % No cache will download.
                url = 'https://www.marine.csiro.au/datacentre/projects/seawater/seawater_ver3_3.1.zip';
                disp('---------> Downloading seawater toolbox');
                download_urlfile(url, local_file)
            end
            if ~(exist('seawater_ver3_3.1.zip', 'file') == 2)
                error('seawater_ver3_3.1.zip is not downloaded, please download it manually');
            else
                unzip_file(local_file, [Edir, 'seawater_ver3_3.1']);
            end
            % delete(local_file);
            STATUS = 1;
        end
    end

    % WindRose             % https://ww2.mathworks.cn/matlabcentral/fileexchange/47248-wind-rose
    if para_conf.WindRose  % https://dpereira.asempyme.com/windrose/
        if ~(exist('WindRose', 'file') ==2)  % WindRose
            local_file = [Edir, 'WindRose.zip'];
            if ~(exist(local_file, 'file') ==2)  % No cache will download.
                url = 'https://dpereira.asempyme.com/windrose/files/windrose_230215.zip';
                disp('---------> Downloading WindRose toolbox');
                download_urlfile(url, local_file)
            end
            if ~(exist('WindRose.zip', 'file') == 2)
                error('WindRose.zip is not downloaded, please download it manually');
            else
                unzip_file(local_file, [Edir, 'WindRose']);
            end
            % delete(local_file);
            STATUS = 1;
        end
    end

    % MEXNC             % https://sourceforge.net/code-snapshots/svn/m/me/mexcdf/svn/mexcdf-svn-r4054.zip
    if para_conf.MEXNC  % https://sourceforge.net/p/mexcdf/svn/HEAD/tree/
        if ~(exist('netcdf.m', 'file') ==2)  % MEXNC
            local_file = [Edir, 'mexcdf-svn-r4054.zip'];
            % TODO: YN
            if ~(exist(local_file, 'file') ==2)  % No cache will download.
                url = 'https://sourceforge.net/code-snapshots/svn/m/me/mexcdf/svn/mexcdf-svn-r4054.zip';
                disp('---------> Downloading MEXNC toolbox');
                download_urlfile(url, local_file)
            end
            if ~(exist('mexcdf-svn-r4054.zip', 'file') == 2)
                error('mexcdf-svn-r4054.zip is not downloaded, please download it manually');
            else
                rmfiles([Edir, 'mexcdf-svn-r4054/'], [Edir, 'mexcdf'])
                unzip_file(local_file, [Edir, '/']);  % mexcdf-svn-r4054
                move_mexcdf_branch([Edir, 'mexcdf-svn-r4054'], [Edir, 'mexcdf']);
            end
            % delete(local_file);
            STATUS = 1;
        end
    end

    % gshhs
    if para_conf.gshhs
        if ~(exist([Edir,'m_map/data/gshhs_c.b',], 'file') ==2) && (exist([Edir,'m_map/data',], 'file') ==7) % gshhs
            local_file = [Edir, 'm_map/data/gshhg-bin-2.3.7.zip'];
            if ~(exist(local_file, 'file') ==2)  % No cache will download.
                url = 'https://www.ngdc.noaa.gov/mgg/shorelines/data/gshhs/latest/gshhg-bin-2.3.7.zip';
                disp('---------> Downloading gshhs data')
                download_urlfile(url, local_file)
            end
            if ~(exist([Edir, 'm_map/data/gshhg-bin-2.3.7.zip'], 'file') == 2)
                error('gshhg-bin-2.3.7.zip is not downloaded, please download it manually');
            else
                unzip_file(local_file, [Edir, 'm_map/data']);
            end
            % delete(local_file);
            STATUS = 1;
        end
    end

    % etopo1
    % m_etopo2
    % url = 'https://www.ngdc.noaa.gov/mgg/global/relief/ETOPO1/data/ice_surface/grid_registered/binary/etopo1_ice_g_i2.zip';

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

function download_urlfile(urlin, fileOut)
    if check_command('wget')
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

function Git = read_Git(structIn)
    Git = read_start(structIn,'Git');
end

function INSTALL = read_INSTALL(structIn)
    INSTALL = read_start(structIn,'INSTALL');
end

function SETPATH = read_SETPATH(structIn)
    SETPATH = read_start(structIn,'SETPATH');
end

function STATUS = Fixed_functions()
    % 修正一些函数在高版本matlab中的报错
    STATUS = 0;
    STATUS1 = fixed_t_tide();
    STATUS2 = fixed_setup_nctoolbox_java();
    STATUS3 = fixed_matFVCOM();
    STATUS4 = fixed_MEXNC();
    if any([STATUS1,STATUS2,STATUS3,STATUS4])
        STATUS = 1;
    end
end

function Install_functions()
    % Install toolbox
    % install_DHIMIKE()
    install_ann_wrapper()
end

function STATUS = fixed_t_tide()
    % 为t_tide工具包的t_tide.m文件添加ref参数
    STATUS = 0;
    m_filepath = which('t_tide.m');
    if isempty(m_filepath)
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
    fid = fopen(m_filepath, 'w');  % 将修改后的内容写回文件
    fwrite(fid, newContent);
    fclose(fid);
    STATUS = 1;
end


function STATUS = fixed_setup_nctoolbox_java()
    % 修正nctoolbox工具包的setup_nctoolbox_java.m函数在高版本matlab中的报错
    STATUS = 0;
    m_filepath = which('setup_nctoolbox_java.m');
    if isempty(m_filepath)
        return
    end
    % 备份源文件
    path_DIR = fileparts(m_filepath);
    m_filecopy = fullfile(path_DIR,'setup_nctoolbox_java_origin.m');
    if ~ exist(m_filecopy,'file')
        copyfile(m_filepath,m_filecopy);
    end
    fileContent = fileread(m_filepath);  % 读取文件内容
    pattern = '(?m)^(?<!%)(root\.addAppender\(org\.apache\.log4j\.ConsoleAppender\(org\.apache\.log4j\.PatternLayout\(''%d\{ISO8601\} \[\%t\] %-5p %c %x - %m%n''\)\)\);)';
    replacement = '% $1';
    newContent = regexprep(fileContent, pattern, replacement);
    fid = fopen(m_filepath, 'w');  % 将修改后的内容写回文件
    fwrite(fid, newContent);
    fclose(fid);
    STATUS = 1;
end

function STATUS = fixed_matFVCOM()
    % 为matFVCOM添加Contents.m和functionSignatures.json
    STATUS = 0;
    m_filepath = which('f_load_grid');
    path_matFVCOM = fileparts(m_filepath);
    if isempty(m_filepath)
        return
    end
    path__ = mfilename("fullpath");
    [path,~]=fileparts(path__);
    File_supplements = fullfile(path, 'Exfunctions/SupplementFiles/matFVCOM');
    File_Contents = fullfile(File_supplements, 'Contents.m');
    File_functionSignatures = fullfile(File_supplements, 'functionSignatures.json');
    if ~ exist(fullfile(path_matFVCOM,'Contents.m'),"file")
        copyfile(File_Contents,fullfile(path_matFVCOM,'Contents.m'));
        STATUS = 1;
    end
    if ~ exist(fullfile(path_matFVCOM,'functionSignatures.json'),"file")
        copyfile(File_functionSignatures,fullfile(path_matFVCOM,'functionSignatures.json'));
        STATUS = 1;
    end
    
    % T = validateFunctionSignaturesJSON(fullfile(path_matFVCOM,'functionSignatures.json'));
    % if ~isempty(T)
        % validateFunctionSignaturesJSON(fullfile(path_matFVCOM,'functionSignatures.json'));
    % end
end

function save_clones(clones) %#ok<DEFNU>
    path__ = mfilename("fullpath");
    [path,~]=fileparts(path__);
    Sdir = fullfile(path, 'Savefiles');
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

function install_DHIMIKE
    %  https://github.com/DHI/DHI-MATLAB-Toolbox
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

function STATUS = fixed_MEXNC()
    % 为MEXNC工具包的ncmex.m文件添加ref参数
    STATUS = 0;
    m_filepath = which('ncmex.m');
    if isempty(m_filepath)
        return
    end
    % 备份源文件
    path_DIR = fileparts(m_filepath);
    m_filecopy = fullfile(path_DIR,'ncmex_origin.m');
    if ~ exist(m_filecopy,'file')
        copyfile(m_filepath,m_filecopy);
    end
    fileContent = fileread(m_filepath);  % 读取文件内容
    searchStr = "error(' ## Unrecognized Matlab version.')";  % 定义要查找的字符串
    replaceStr = "fcn = 'mexcdf53';";  % 定义替换后的字符串
    newContent = strrep(fileContent, searchStr, replaceStr);  % 执行替换操作
    fid = fopen(m_filepath, 'w');  % 将修改后的内容写回文件
    fwrite(fid, newContent);
    fclose(fid);
    STATUS = 1;
end

function install_ann_wrapper()
    if exist('ann_class_compile','file') == 2
        PWD = pwd();
        m_filepath = which('ann_class_compile.m');
        cd(fileparts(m_filepath))
        ann_class_compile()
        cd(PWD)
        return
    end

end


function print_info()
    fprintf('\n')
    fprintf('=====================================================================\n')
    fprintf('As adding files, if it does not take efect, please restart MATLAB\n')
    fprintf('=====================================================================\n')
    fprintf('\n')
end
