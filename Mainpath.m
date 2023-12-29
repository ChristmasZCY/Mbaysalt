function Mainpath(varargin)
    %       Mainpath is a function to add all path of this package
    % =================================================================================================================
    % Parameters:
    %       varargin:        optional parameters      
    %           add:        add all path             || required: False|| type: string || format: 'add'
    %           rm:         remove all path          || required: False|| type: string || format: 'rm'
    %           noclone:    add all path without clone git || required: False|| type: string || format: 'noclone'
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Updates:
    %       2023-**-**:     Created, by Christmas;
    %       2023-12-27:     Added check_command, OceanData, FVCOM_NML, by Christmas;
    % =================================================================================================================
    % Examples:
    %       Mainpath
    %       Mainpath('add')
    %       Mainpath('rm')
    %       Mainpath('noclone')
    % =================================================================================================================

    [PathALL, path] = Cmakepath;  % get all path

    if nargin ==0
        Caddpath(PathALL)  % add all path
        gitclone()  % clone all git
        Caddpath(PathALL)  % add all path
    else
        for i = 1 : nargin
            switch lower(varargin{i})
                case 'add'
                    Caddpath(PathALL)
                    gitclone()
                    Caddpath(PathALL)
                case 'rm'
                    Crmpath(PathALL)  % remove all path
                    Caddpath(path)
                case 'noclone'
                    Caddpath(PathALL)
                otherwise
                    error('parameter error')
            end
        end
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
        "Gridfunctions"
        "Exfunctions"
        "Readfunctions"
        "Ncfunctions"
        "Examples"
        "Py"
        "Matesetfunctions"
        ];
    FunI = cellstr(FunI);
    
    Cdata = path + division + [
        "Inputfiles",
        ];
    Cdata = cellstr(Cdata);

    FunE = path + division + [
        "Exfunctions/cprintf"
        "Exfunctions/matFVCOM"
        "Exfunctions/Extend/matWRF"
        "Exfunctions/matFigure"
        "Exfunctions/matWRF"
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
        ];
    FunE = cellstr(FunE);
    addpath(path + division + 'Exfunctions/genpath2');
    FunE = cellfun(@genpath2,FunE,repmat({".git"},length(FunE),1),'UniformOutput', false);

    FunctionPath = [path; FunI; Cdata; FunE];
    path = {path};
end

function Caddpath(Path)
    cellfun(@addpath, Path)
end


function Crmpath(Path)
    cellfun(@rmpath, Path)
end


function gitclone()
    path__ = mfilename("fullpath");
    [path,~]=fileparts(path__);
    division = string(filesep);
    Edir = char(path + division + 'Exfunctions' + division);

    para_conf = read_conf(fullfile(path,'Configurefiles/INSTALL.conf'));
    PATH = read_PATH(para_conf);
    if ~isempty(PATH)
        if isfield(PATH, 'git')
            if ~isempty(PATH.git)
                setenv('PATH', [PATH.git, pathsep, getenv('PATH')]);
            end
        end
    end
    TF = check_command('git');

    if TF
        if para_conf.cdt
            if ~(exist('ncdateread', 'file') == 2)  % CDT
                txt = ['git clone https://github.com/chadagreene/CDT.git ', Edir, 'cdt'];
                disp('---------> Cloning cdt toolbox')
                disp(txt)
                system(txt);
            end
        end
        
        if para_conf.matFVCOM  % SiqiLiOcean/matFVCOM
            if ~(exist('f_load_grid', 'file') == 2)  % matFVCOM
                txt = ['git clone https://github.com/SiqiLiOcean/matFVCOM.git ', Edir, 'MatFVCOM'];
                disp('---------> Cloning matFVCOM toolbox')
                disp(txt)
                system(txt);
            end
        end

        if para_conf.matFigure  % SiqiLiOcean/matFigure
            if ~(exist('mf_save', 'file') == 2)  % matFigure
                txt = ['git clone https://github.com/SiqiLiOcean/matFigure.git ', Edir, 'matFigure'];
                disp('---------> Cloning matFigure toolbox')
                disp(txt)
                system(txt);
            end
        end

        if para_conf.matWRF  % SiqiLiOcean/matWRF
            if ~(exist('load_constants', 'file') == 2)  % matWRF
                txt = ['git clone https://github.com/SiqiLiOcean/matWRF.git ', Edir, 'matWRF'];
                disp('---------> Cloning cdt toolbox')
                disp(txt)
                system(txt);
            end
        end
            
        if para_conf.matNC  % SiqiLiOcean/matNC
            if ~(exist('nc_close', 'file') == 2) % matNC
                txt = ['git clone https://github.com/SiqiLiOcean/matNC.git ', Edir, 'matNC'];
                disp('---------> Cloning matNC toolbox')
                disp(txt)
                system(txt);
            end
        end

        if para_conf.OceanData  % SiqiLiOcean/OceanData
            if ~(exist('UHSLC_info', 'file') == 2) % OceanData
                txt = ['git clone https://github.com/SiqiLiOcean/OceanData.git ', Edir, 'OceanData'];
                disp('---------> Cloning OceanData toolbox')
                disp(txt)
                system(txt);
            end
        end

        if para_conf.FVCOM_NML  % SiqiLiOcean/FVCOM_NML
            if ~(exist('FVCOM_NML', 'dir') == 7) % FVCOM_NML
                txt = ['git clone https://github.com/SiqiLiOcean/FVCOM_NML.git ', Edir, 'FVCOM_NML'];
                disp('---------> Cloning FVCOM_NML toolbox')
                disp(txt)
                system(txt);
            end
        end

        if para_conf.nctoolbox
            if ~(exist('ncload', 'file') == 2) % nctoolbox
                txt = ['git clone https://github.com/nctoolbox/nctoolbox.git ', Edir, 'nctoolbox'];
                disp('---------> Cloning nctoolbox toolbox')
                disp(txt)
                system(txt);
            end
        end
    else
        warning('git is not installed, some functions will not be installed, please install git or set in INSTALL.conf and run Mainpath again.');
    end

    % t_tide
    if para_conf.t_tide
        if ~(exist('t_tide', 'file') == 2)  % t_tide
            if ~(exist([Edir, 't_tide_v1.5beta.zip'], 'file') ==2)  % No cache will download.
                url = 'https://www.eoas.ubc.ca/~rich/t_tide/t_tide_v1.5beta.zip';
                if check_command('wget')
                    txt = ['wget ', url, ' -O ', Edir, 't_tide_v1.5beta.zip'];
                    disp('---------> Downloading t_tide toolbox')
                    disp(txt)
                    system(txt);
                elseif check_command('curl')
                    txt = ['curl ', url, ' -o ', Edir, 't_tide_v1.5beta.zip'];
                    disp('---------> Downloading t_tide toolbox')
                    disp(txt)
                    system(txt);
                else
                    warning('wget and curl are not installed, t_tide will not be installed');
                end
            end
            if ~(exist('t_tide_v1.5beta.zip', 'file') == 2)
                error('t_tide_v1.5beta.zip is not downloaded, please download it manually');
            else
                if check_command('unzip')
                    system(['unzip ', Edir, 't_tide_v1.5beta.zip -d ', Edir, 't_tide']);
                else
                    unzip([Edir, 't_tide_v1.5beta.zip'], [Edir, 't_tide']);
                end
            end
            % delete([Edir, 't_tide_v1.5beta.zip']);
        end
    end

    % m_map
    if para_conf.m_map
        if ~(exist('m_demo', 'file') ==2)  % m_map
            if ~(exist([Edir, 'm_map1.4.zip'], 'file') ==2)  % No cache will download.
                url = 'https://www.eos.ubc.ca/%7Erich/m_map1.4.zip';
                if check_command('wget')
                    txt = ['wget ', url, ' -O ', Edir, 'm_map1.4.zip'];
                    disp('---------> Downloading m_map toolbox')
                    disp(txt)
                    system(txt);
                elseif check_command('curl')
                    txt = ['curl -L ', url, ' -o ', Edir, 'm_map1.4.zip'];
                    disp('---------> Downloading m_map toolbox')
                    disp(txt)
                    system(txt);
                else
                    warning('wget and curl are not installed, m_map will not be installed');
                end
            end
            if ~(exist('m_map1.4.zip', 'file') == 2)
                    error('m_map1.4.zip is not downloaded, please download it manually');
            else
                if check_command('unzip')
                    system(['unzip ', Edir, 'm_map1.4.zip -d ', Edir]);
                else
                    unzip([Edir, 'm_map1.4.zip'], [Edir]);
                end
            end
            % delete([Edir, 'm_map1.4.zip']);
        end  
    end
    
    % gshhs
    if para_conf.gshhs
        if ~(exist([Edir,'m_map/data/gshhs_c.b',], 'file') ==2) && (exist([Edir,'m_map/data',], 'file') ==7) % gshhs
            if ~(exist([Edir, 'm_map/data/gshhg-bin-2.3.7.zip'], 'file') ==2)  % No cache will download.
                url = 'https://www.ngdc.noaa.gov/mgg/shorelines/data/gshhs/latest/gshhg-bin-2.3.7.zip';
                if check_command('wget')
                    txt = ['wget ', url, ' -O ', Edir, 'm_map/data/gshhg-bin-2.3.7.zip'];
                    disp('---------> Downloading gshhs data')
                    disp(txt)
                    system(txt);
                elseif check_command('curl')
                    txt = ['curl -L ', url, ' -o ', Edir, 'm_map/data/gshhg-bin-2.3.7.zip'];
                    disp('---------> Downloading gshhs data')
                    disp(txt)
                    system(txt);
                else
                    warning('wget and curl are not installed, m_map will not be installed');
                end
            end
            if ~(exist([Edir, 'm_map/data/gshhg-bin-2.3.7.zip'], 'file') == 2)
                    error('gshhg-bin-2.3.7.zip is not downloaded, please download it manually');
            else
                if check_command('unzip')
                    system(['unzip ', Edir, 'm_map/data/gshhg-bin-2.3.7.zip -d ', Edir, 'm_map/data/']);
                else
                    unzip([Edir, 'm_map/data/gshhg-bin-2.3.7.zip'], [Edir, 'm_map/data/']);
                end
            end
            % delete([Edir, 'm_map/data/gshhg-bin-2.3.7.zip']);
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


function PATH = read_PATH(structIn)
    % 从struct中读取以PATH_开头的变量，将变量写入到PATH结构体中
    % eg: 将struct中的PATH_git写入到PATH.git中
    PATH = struct();
    key = fieldnames(structIn);
    for i = 1 : length(key)
        if ~isempty(regexp(key{i},'^PATH_','once'))
            PATH.(key{i}(6:end)) = structIn.(key{i});
        end
    end
end
