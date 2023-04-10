function para_conf = read_conf_fvcom(conf_file)
    % =================================================================================================================
    % discription:
    %       read the configuration file of fvcom
    % =================================================================================================================
    % parameter:
    %       conf_file: configuration file of fvcom     || required: True || type: string  || format: 'Post_fvcom.conf'
    %       para_conf: parameters of fvcom             || required: True || type: struct  || format: struct
    
    % =================================================================================================================
    % example:
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
