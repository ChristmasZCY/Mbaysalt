function Mainpath
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
        "Gridfunctions"
        "Exfunctions"
        "Readfunctions"
        "Examples"
        "Py"
        ];
    
    Cdata = path + division + [
        "Inputfiles",
        ];
    
    FunE = path + division + [
        "Exfunctions/cprintf"
        "Exfunctions/matFVCOM"
        "Exfunctions/matFVCOM/Extend/matFVCOM"
        "Exfunctions/matFigure"
        "Exfunctions/matWRF"
        "Exfunctions/CDT"
        ];

    Fun_pkg = path + division + [
        "Post_fvcom/+netcdf_fvcom"
        "Post_fvcom/+netcdf_nemuro"
        "Post_fvcom/+griddata_fvcom"
        ];
    %
    addpath(path)
    addpath(FunI{:});
    addpath(Cdata{:});
    addpath(Fun_pkg{:});
    FunE = cellstr(FunE);
    FunE = cellfun(@genpath2,FunE,repmat({".git"},length(FunE),1),'UniformOutput', false);
    cellfun(@addpath,FunE)
    
end
