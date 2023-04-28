function Mainpath(varargin)
    % addpath for all functions

    [PathALL, path] = Cmakepath;  % get all path

    if nargin ==0
        Caddpath(PathALL)  % add all path
        gitclone()  % clone all git
        Caddpath(PathALL)  % add all path
    else
        for i = 1 : nargin
            switch varargin{i}
                case {'add', 'Add'}
                    Caddpath(PathALL)
                    gitclone()
                    Caddpath(PathALL)
                case 'rm'
                    Crmpath(PathALL)  % remove all path
                    Caddpath(path)
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
        "Gridfunctions"
        "Exfunctions"
        "Readfunctions"
        "Ncfunctions"
        "Examples"
        "Py"
        ];
    FunI = cellstr(FunI);
    
    Cdata = path + division + [
        "Inputfiles",
        ];
    Cdata = cellstr(Cdata);

    FunE = path + division + [
        "Exfunctions/cprintf"
        "Exfunctions/matFVCOM"
        "Exfunctions/Extend/matFVCOM"
        "Exfunctions/matFigure"
        "Exfunctions/matWRF"
        "Exfunctions/cdt"
        "Exfunctions/matNC"
        "Exfunctions/t_tide"
        ];
    FunE = cellstr(FunE);
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
   

    if ~(exist('ncdateread', 'file') == 2)  % CDT
        system(['git clone https://github.com/chadagreene/CDT.git ', Edir, 'cdt'])
    end
    
    if ~(exist('f_load_grid', 'file') == 2)  % matFVCOM
        system(['git clone https://github.com/SiqiLiOcean/matFVCOM.git ', Edir, 'MatFVCOM'])
    end

    if ~(exist('mf_save', 'file') == 2)  % matFigure
        system(['git clone https://github.com/SiqiLiOcean/matFigure.git ', Edir, 'matFigure'])
    end

    if ~(exist('load_constants', 'file') == 2)  % matWRF
        system(['git clone https://github.com/SiqiLiOcean/matWRF.git ', Edir, 'matWRF'])
    end

    if ~(exist('nc_close', 'file') == 2) % matNC
        system(['git clone https://github.com/SiqiLiOcean/matNC.git ', Edir, 'matNC'])
    end

    if ~(exist('t_tide', 'file') == 2) % t_tide
        system(['wget https://www.eoas.ubc.ca/~rich/t_tide/t_tide_v1.5beta.zip -O ', Edir, 't_tide_v1.5beta.zip'])
        system(['unzip ', Edir, 't_tide_v1.5beta.zip -d ', Edir, 't_tide'])
        system(['rm ', Edir, 't_tide_v1.5beta.zip'])
    end
end