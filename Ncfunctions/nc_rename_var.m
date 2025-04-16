function nc_rename_var(fin, ori_varname, new_varname, varargin)
    %       Rename varname in netCDF file.
    % =================================================================================================================
    % Parameter:
    %       fin:                file name                       || required: True  || type: Text || format: 'test.nc'
    %       ori_varname:        origin variable name            || required: True  || type: Text || format: 'x'
    %       new_varname:        new variable name               || required: True  || type: Text || format: 'longitude'
    %       varargin:   optional parameters     
    %           NochangeDim:    do not change related dim name  || required: False || type: flag || format: 'NochangeDim'
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Updates:
    %       2025-04-11:     Created, by Christmas;
    % =================================================================================================================
    % Example:
    %       nc_rename_var('test.nc', 'longitude', 'x');
    %       nc_rename_var('test.nc', 'longitude', 'x', 'NochangeDim');
    % =================================================================================================================
    
    arguments (Input)
        fin {mustBeFile}
        ori_varname {mustBeText}
        new_varname {mustBeText}
    end

    arguments (Input, Repeating)
        varargin 
    end

    varargin = read_varargin2(varargin,{'NochangeDim'});


    ncid = netcdf.open(fin, 'NC_WRITE');  % 以写模式打开 netCDF 文件
    netcdf.reDef(ncid);  % 进入定义模式
    
    varid = netcdf.inqVarID(ncid, ori_varname);  % 获取变量 ID
    netcdf.renameVar(ncid, varid, new_varname);  % 重命名变量

    if isempty(NochangeDim)
        nc_info = ncinfo(fin);
        TF = any(strcmp({nc_info.Dimensions.Name}, ori_varname));
        if TF
            dimid = netcdf.inqDimID(ncid,ori_varname);
            netcdf.renameDim(ncid, dimid, new_varname);
        end
    end

    netcdf.endDef(ncid);  % 退出定义模式
    netcdf.close(ncid);  % 关闭文件

end
