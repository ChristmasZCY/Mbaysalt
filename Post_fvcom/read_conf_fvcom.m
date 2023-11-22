function para_conf = read_conf_fvcom(conf_file)
    %       read the configuration file of fvcom
    % =================================================================================================================
    % Parameter:
    %       conf_file: configuration file of fvcom     || required: True || type: string  || format: 'Post_fvcom.conf'
    %       para_conf: parameters of fvcom             || required: True || type: struct  || format: struct
    % =================================================================================================================
    % Example:
    %       para_conf = read_conf_fvcom('Post_fvcom.conf')
    % =================================================================================================================


    Inputpath = split_dir(grep(conf_file,"ModelOutputDir"));
    para_conf.Inputpath = Inputpath;

    Outputpath = split_dir(grep(conf_file,"StandardDir"));
    para_conf.Outputpath = Outputpath;

    Temporarypath = split_dir(grep(conf_file,"TemporaryDir"));
    para_conf.Temporarypath = Temporarypath;
    makedirs(Temporarypath);

    file_ncmask = split_dir(grep(conf_file,"MaskncFile"));
    para_conf.file_ncmask = file_ncmask;

    file_matmask = split_dir(grep(conf_file,"MaskmatFile"));
    para_conf.file_matmask = file_matmask;

    file_Mcasename = split_dir(grep(conf_file,"ModelCasename"));
    para_conf.file_Mcasename = file_Mcasename;

    OutputRes = split_dir(grep(conf_file,"OutputRes"));
    para_conf.OutputRes = OutputRes;

    ResName = split_dir(grep(conf_file,"ResName"));
    para_conf.ResName = ResName;

    switch_ww =  char_to_logical(split_dir(grep(conf_file,"Switch_ww")));
    para_conf.switch_ww = switch_ww;

    switch_make_weight = char_to_logical(split_dir(grep(conf_file,"Switch_make_Weight")));
    para_conf.switch_make_weight = switch_make_weight;

    Method_interpn = split_dir(grep(conf_file,"Method_interpn"));
    para_conf.Method_interpn = Method_interpn;

    lon = str2num(split_dir(grep(conf_file,"Lon_source")));
    lat = str2num(split_dir(grep(conf_file,"Lat_source")));
    para_conf.lon = lon;
    para_conf.lat = lat;

    switch_warning = char_to_logical(split_dir(grep(conf_file,"Switch_warningtext")));
    para_conf.switch_warning = switch_warning;

    switch_to_std_level = char_to_logical(split_dir(grep(conf_file,"Switch_to_std_level")));
    para_conf.switch_to_std_level = switch_to_std_level;
    
    switch_change_maxlon = char_to_logical(split_dir(grep(conf_file,"Switch_change_MaxLon")));
    para_conf.switch_change_maxlon = switch_change_maxlon;
end

function varargout =  char_to_logical(varargin)
    %       convert char to logical
    % =================================================================================================================
    % Parameter:
    %       varargin{n}: char to convert || required: True || type: char     || format: '.True.' or '.False.'
    %       varargout{n}: logical        || required: True || type: logical  || format: true or false
    % =================================================================================================================
    % Example:
    %       TF = char_to_logical('.True.')
    % =================================================================================================================

    for num = 1: nargin
        T = strcmpi(varargin{num},'.True.');
        F = strcmpi(varargin{num},'.False.');
        if T == 1 && F == 0
            varargout{num} = true;
        elseif T == 0 && F == 1
            varargout{num} = false;
        else
            error('char_to_logical: wrong input format')
        end
    end

end


function f4 = split_dir(dir)
    %       split the dir string from the status file with "grep" function
    % =================================================================================================================
    % Parameter:
    %       dir: dir string from the status file  || required: True || type: string || format: "xxxx"
    %       f4: the matched line                  || required: True || type: string || format: "xxxx"
    % =================================================================================================================
    % Example:
    %       file_ncmask = split_dir(file);
    % =================================================================================================================

    f1 = strip(dir);
    if endsWith(f1,",")
        f1 = split(dir,',');
        f1 = f1{1};
    end

    f2 = split(f1,'=');
    f3 = split(strip(f2{2}),"'");
    f3 = (f3{end});
    F = strfind(f3,"#");

    if ~ isempty(F)
        f3 = strip(f3(1:F-1));
    end
    f4 = split(f3," ");
    f4 = f4{end};

end

