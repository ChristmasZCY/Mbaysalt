function Mainpath(varargin)
    % =================================================================================================================
    % discription:
    %       Mainpath is a function to add all path of this package
    % =================================================================================================================
    % parameter:   
    %       varargin:        optional parameters      
    %           add:        add all path             || required: False|| type: string || format: 'add'
    %           rm:         remove all path          || required: False|| type: string || format: 'rm'
    %           noclone:    add all path without clone git || required: False|| type: string || format: 'noclone'
    % =================================================================================================================
    % example:
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
        ];
    FunE = cellstr(FunE);
    addpath([path + division + 'Exfunctions/genpath2']);
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

    TF = check_command('git');

    if TF
        if ~(exist('ncdateread', 'file') == 2)  % CDT
            system(['git clone https://github.com/chadagreene/CDT.git ', Edir, 'cdt']);
        end
        
        if ~(exist('f_load_grid', 'file') == 2)  % matFVCOM
            system(['git clone https://github.com/SiqiLiOcean/matFVCOM.git ', Edir, 'MatFVCOM']);
        end

        if ~(exist('mf_save', 'file') == 2)  % matFigure
            system(['git clone https://github.com/SiqiLiOcean/matFigure.git ', Edir, 'matFigure']);
        end

        if ~(exist('load_constants', 'file') == 2)  % matWRF
            system(['git clone https://github.com/SiqiLiOcean/matWRF.git ', Edir, 'matWRF']);
        end

        if ~(exist('nc_close', 'file') == 2) % matNC
            system(['git clone https://github.com/SiqiLiOcean/matNC.git ', Edir, 'matNC']);
        end
    else
        warning('git is not installed, some functions will not be installed, please install git and run Mainpath again');
    end

    if ~(exist('t_tide', 'file') == 2) % t_tide
        if check_command('wget')
            system(['wget https://www.eoas.ubc.ca/~rich/t_tide/t_tide_v1.5beta.zip -O ', Edir, 't_tide_v1.5beta.zip']);
        elseif check_command('curl')
            system(['curl https://www.eoas.ubc.ca/~rich/t_tide/t_tide_v1.5beta.zip -o ', Edir, 't_tide_v1.5beta.zip']);
        else
            warning('wget and curl are not installed, t_tide will not be installed');
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
        delete([Edir, 't_tide_v1.5beta.zip']);
    end
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
