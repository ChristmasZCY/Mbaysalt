function STATUS = nc_var_exist(fin, varname, varargin)
    %       Check if a variable exists in a netcdf file
    % =================================================================================================================
    % Parameter:
    %       fin:             file name               || required: True || type: string || format: 'test.nc'
    %       varname:         variable name           || required: True || type: string || format: 'var1'
    % =================================================================================================================
    % Returns:
    %       STATUS:          1 if the variable exists, 0 otherwise
    % =================================================================================================================
    % Update:
    %       2024-03-25:     Created, by Christmas;
    % =================================================================================================================
    % Example:
    %       STATUS = nc_var_exist('test.nc', 'swh')
    % =================================================================================================================
    
    arguments (Input)
        fin {mustBeFile}
        varname {mustBeText}
    end

    arguments (Input, Repeating)
        varargin 
    end

    nc_info = ncinfo(fin);

    % if isempty(nc_info.Variables)
    %     return
    % end
    STATUS = any(strcmp({nc_info.Variables.Name}, varname));

end
