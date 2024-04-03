function [GridStruct, VarStruct, Ttimes] = c_load_model(fin, varargin)
    %       To load model data
    % =================================================================================================================
    % Parameters:
    %       fin:            input file name                 || required: True || type: Text   || format: '*.nc'
    %       varargin:       optional parameters      
    %           Global:     Switiching global or local      || required: False|| type: Text   || example: 'Global'
    %           Coordinate: Coordinate system               || required: False|| type: Text   || format: 'Coordinate','geo'
    % =================================================================================================================
    % Returns:
    %       GridStruct:    Model Grid Struct                || required: False|| type: struct || example: 
    %       VarStruct:     Model Variable Struct            || required: False|| type: struct || example: 
    %       Ttimes:        Model Ttimes                     || required: False|| type: struct || example: 
    % =================================================================================================================
    % Updates:
    %       2024-04-03:     Created, by Christmas; 
    % =================================================================================================================
    % Examples:
    %       [GridStruct, VarStruct, Ttimes] = c_load_model('ww3.nc')
    %       [GridStruct, VarStruct, Ttimes] = c_load_model('ww3.nc', 'Global', 'Coordinate', 'geo')
    %       [GridStruct, VarStruct, Ttimes] = c_load_model('ww3.nc', 'Global')
    %       [GridStruct, VarStruct, Ttimes] = c_load_model('fvcom.nc')
    %       [GridStruct, VarStruct, Ttimes] = c_load_model('fvcom.nc', 'Global', 'Coordinate', 'geo')
    %       [GridStruct, VarStruct, Ttimes] = c_load_model('fvcom.nc', 'Coordinate', 'geo')
    % =================================================================================================================
    % Dependencies:
    %       f_load_grid.m
    %       f_load_time.m
    %       w_load_grid.m
    %       nc_var_exist.m
    %       nc_attrName_exist.m
    %       nc_attrValue_exist.m
    %       ncdateread.m
    %       read_varargin.m
    %       read_varargin2.m
    %       Mdatetime.m
    % =================================================================================================================

    arguments(Input)
        fin (1,:) {mustBeFile}
    end

    arguments(Input,Repeating)
        varargin
    end

    varargin = read_varargin2(varargin, {'Global'});
    varargin = read_varargin(varargin, {'Coordinate'}, {'geo'});

    fin = convertStringsToChars(fin);
    if endsWith(fin, '.nc')
        if nc_attrName_exist(fin, 'WAVEWATCH', 'method','START')
            lon = ncread(fin, 'longitude');
            lat = ncread(fin, 'latitude');
            if nc_var_exist(fin, 'tri')
                nv = ncread(fin, 'tri')';
                if isempty(Global)
                    GridStruct = f_load_grid(lon, lat, nv);
                else
                    GridStruct = f_load_grid(lon, lat, nv, Global);
                end
            else
                if isempty(Global)
                    GridStruct = w_load_grid(lon, lat);
                else
                    GridStruct = w_load_grid(lon, lat, Global);
                end
            end
            GridStruct.ModelName = 'WW3';
        elseif nc_attrValue_exist(fin, 'FVCOM', 'method','START')
            GridStruct = f_load_grid(fin, Global,"Coordinate",Coordinate);
            GridStruct.ModelName = 'FVCOM';
        else
            error('Just for WW3 or FVCOM now !!!')
        end
        SWITCH.read_var = true;
    elseif endsWith(fin, '.2dm') || endsWith(fin, '.msh')
        GridStruct = f_load_grid(fin,'Global');
        SWITCH.read_var = false;
        if endsWith(fin, '.2dm')
            GridStruct.ModelName = '2dm';
        elseif endsWith(fin, '.msh')
            GridStruct.ModelName = 'msh';
        end
    end

    if SWITCH.read_var
        switch upper(GridStruct.ModelName)
            case 'WW3'
                if nc_var_exist(fin,'hs')
                    VarStruct.hs = ncread(fin,'hs');
                end
                if nc_var_exist(fin,'dir')
                    VarStruct.dir = ncread(fin,'dir');
                end
                if nc_var_exist(fin,'t02')
                    VarStruct.t02 = ncread(fin,'t02');
                end
                if nc_var_exist(fin,'lm')
                    VarStruct.lm = ncread(fin,'lm');
                end
                if nc_var_exist(fin,'fp')
                    VarStruct.fp = ncread(fin,'fp');
                end
                if nc_var_exist(fin,'hmaxe')
                    VarStruct.hmaxe = ncread(fin,'hmaxe');
                end
                if nc_var_exist(fin,'cge')
                    VarStruct.hmaxe = ncread(fin,'cge');
                end
                if nc_var_exist(fin,'time')
                    Ttimes = Mdatetime(ncdateread(fin,'time'));
                end
                
            case 'FVCOM'
                if nc_var_exist(fin,'u')
                    VarStruct.u = ncread(fin,'u');
                end
                if nc_var_exist(fin,'v')
                    VarStruct.v = ncread(fin,'v');
                end
                if nc_var_exist(fin,'ww')
                    VarStruct.ww = ncread(fin,'ww');
                end
                if nc_var_exist(fin,'temp')
                    VarStruct.temp = ncread(fin,'temp');
                end
                if nc_var_exist(fin,'salinity')
                    VarStruct.salinity = ncread(fin,'salinity');
                end
                if nc_var_exist(fin,'zeta')
                    VarStruct.zeta = ncread(fin,'zeta');
                end
                if nc_var_exist(fin,'ua')
                    VarStruct.ua = ncread(fin,'ua');
                end
                if nc_var_exist(fin,'va')
                    VarStruct.va = ncread(fin,'va');
                end
                if nc_var_exist(fin,'Times') || nc_var_exist(fin,'Itime')
                    if nc_var_exist(fin,'Times')
                        ftime = f_load_time(fin,'Times');
                    elseif nc_var_exist(fin,'Itime')
                        ftime = f_load_time(fin);
                    end
                    Ttimes = Mdatetime(ftime,'Cdatenum');
                end
            otherwise 
        end
    else
        VarStruct = struct();
        Ttimes = Mdatetime();
    end
    

       
end
