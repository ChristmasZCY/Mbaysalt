function [lon,lat,depth,time,varargout] = read_ncfile_lldtv(fnc, varargin)
    % =================================================================================================================
    % discription:
    %       read nc file
    % =================================================================================================================
    % parameter:
    %       fnc: nc file name                               || required: True  || type: string || format: 'wave.nc'
    %       varargin:
    %                conf: conf file                        || required: False || type: string || format: 'Read_file.conf'
    %                Lon_Name: lon name                     || required: False || type: string || format: 'lon'
    %                Lat_Name: lat name                     || required: False || type: string || format: 'lat'
    %                Depth_Name: depth name                 || required: False || type: string || format: 'depth'
    %                Time_Name: time name                   || required: False || type: string || format: 'time'
    %                Time_type: time type                   || required: False || type: string || format: 'datetime'
    %                Time_format: time format               || required: False || type: string || format: 'yyyy-MM-dd HH:mm:ss'
    %                Var_Name: var name                     || required: False || type: dell   || format: {{'swh'},{'mpts'}}
    %                Switch_log: switch log                 || required: False || type: bool   || format: (optional)
    %                Log_file: log file                     || required: False || type: string || format: 'log.txt'
    %                'INFO': whether run osprints           || required: False || type: bool   || format: '(optional)
    % =================================================================================================================
    % example:
    %       [lon,lat,depth,time,varargout] = read_ncfile_lldtv(fnc);
    %       [lon,lat,depth,time,swh,mpts] = read_ncfile_lldtv(fnc, 'Var_Name',{{'swh'},{'mpts'}});
    %       [lon,lat,depth,time,varargout] = read_ncfile_lldtv(fnc,'conf','Read_file.conf','Lon_Name','lon', ...
    %                                                          'Lat_Name','lat','Depth_Name','depth', ...
    %                                                          'Time_Name','time','Time_type','datetime', ...
    %                                                          'Time_format','yyyy-MM-dd HH:mm:ss', ...
    %                                                          'Var_Name',{{'swh'},{'mpts'}},...
    %                                                          'Switch_log','Log_file','log.txt')
    % =================================================================================================================

    varargin = read_varargin(varargin,{'conf'},{'Read_file.conf'});
    varargin = read_varargin(varargin,{'Lon_Name'},{false});
    varargin = read_varargin(varargin,{'Lat_Name'},{false});
    varargin = read_varargin(varargin,{'Depth_Name'},{false});
    varargin = read_varargin(varargin,{'Time_Name'},{false});
    varargin = read_varargin(varargin,{'Time_type'},{false});
    varargin = read_varargin(varargin,{'Time_format'},{false});
    varargin = read_varargin(varargin,{'Var_Name'},{false});
    varargin = read_varargin2(varargin,{'Switch_log'});
    varargin = read_varargin(varargin,{'Log_file'},{false});
    varargin = read_varargin2(varargin,{'INFO'});

    if ~isempty(Switch_log)
        Switch_log = true;
    else
        Switch_log = false;
    end

    if ~isempty(INFO)
        INFO = true;
    else
        INFO = false;
    end

    if ~iscell(Var_Name)
        Var_Name = {Var_Name};
    end
    Var_Name = [Var_Name{:}];

    para_conf = read_conf(conf);
    name_cell = {Lon_Name, Lat_Name,Depth_Name,Time_Name,Time_type,Time_format,Var_Name,Switch_log};
    conf_cell = {para_conf.Lon_Name, para_conf.Lat_Name,para_conf.Depth_Name,para_conf.Time_Name, ...
                para_conf.Time_type,para_conf.Time_format,para_conf.Var_Name,para_conf.Switch_log};

    Name_cell = cellfun(@isexist_var, name_cell,conf_cell, 'UniformOutput', false);
    [Lon_Name, Lat_Name,Depth_Name,Time_Name,Time_type,Time_format,Var_Name,Switch_log] = Name_cell{:};
    clearvars name_cell conf_cell Name_cell

    lldt_name = {'Lon_Name', 'Lat_Name','Depth_Name','Time_Name','Var_Name','Switch_log'};
    lldt_name_var = {Lon_Name, Lat_Name,Depth_Name,Time_Name,Var_Name,Switch_log};

    % var_name_of_read
    var_name_of_read = cell2struct(lldt_name_var,lldt_name,2);
    clear lldt_name lldt_name_var

    % nc_contains_var_name
    info = ncinfo(fnc);
    nc_contains_var_name = {info.Variables.Name};
    clear info

    % read switch
    read_lon = false;
    read_lat = false;
    read_depth = false;
    read_time = false;
    read_var = false;

    % read lon
    if any(strcmp(nc_contains_var_name, var_name_of_read.Lon_Name))
        read_lon = true;
        lon = nr(fnc,var_name_of_read.Lon_Name);
    else
        lon = [];
    end

    % read lat
    if any(strcmp(nc_contains_var_name, var_name_of_read.Lat_Name))
        read_lat = true;
        lat = nr(fnc,var_name_of_read.Lat_Name);
    else
        lat = [];
    end

    % read depth
    if any(strcmp(nc_contains_var_name, var_name_of_read.Depth_Name))
        read_depth = true;
        depth = nr(fnc,var_name_of_read.Depth_Name);
    else
        depth = [];
    end

    % read time
    if any(strcmp(nc_contains_var_name, var_name_of_read.Time_Name))
        read_time = true;
        switch Time_type
            case 'datetime'
                time = ncdateread(fnc,Time_Name);
                time.Format = Time_format;
            case 'double'
                time = nr(fnc,Time_Name);
            otherwise
                error('Time_type must be datetime or double')
        end
    else
        switch Time_type
            case 'datetime'
                time = datetime([],[],[],[],[],[]);
                time.Format = Time_format;
            case 'double'
                time = [];
            otherwise
                error('Time_type must be datetime or double')
        end
    end

    % read var
    for i = 1:length(var_name_of_read.Var_Name)
        if any(strcmp(nc_contains_var_name, var_name_of_read.Var_Name{i}))
            read_var = true;
            varargout{i} = nr(fnc,var_name_of_read.Var_Name{i});
        else
            varargout{i} = [];
        end
    end

    var_of_read = [];
    if read_lon
        var_of_read = [var_of_read, Lon_Name, ' '];
    end
    if read_lat
        var_of_read = [var_of_read, Lat_Name, ' '];
    end
    if read_depth
        var_of_read = [var_of_read, Depth_Name, ' '];
    end
    if read_time
        var_of_read = [var_of_read, Time_Name, ' '];
    end
    if read_var
        var_of_read_var = cellfun(@(x) [x, ' '], Var_Name, 'UniformOutput', false);
        var_of_read = [var_of_read, var_of_read_var{:}, ' '];
    end

    % log
    if INFO
        if Switch_log
            if ~Log_file
                Log_file = para_conf.Log_file;
            end
            osprints('INFO','Reading from nc','new_line',1,'ddt_log',1,'wrfile',Log_file)
            osprints('INFO',var_of_read,'new_line',0,'ddt_log',0,'wrfile',Log_file)
        else
            osprints('INFO','Reading from nc','new_line',0,'ddt_log',1)
            osprints('INFO',var_of_read,'new_line',1,'ddt_log',0)
        end
    end

    % varargout{1} = cell(varargin);

end