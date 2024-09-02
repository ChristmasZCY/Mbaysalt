function TF = isNetcdfFile(fin, varargin)
    %       Check if a file is a NetCDF file or not
    % =================================================================================================================
    % Parameter:
    %       fin:             file name               || required: True || type: Text || format: 'test.nc'
    %       attr_str:        attribute str           || required: True || type: Text || format: 'WAVEWATCH'
    %       varargin:        optional parameters
    % =================================================================================================================
    % Returns:
    %       TF:              1 if it is a NetCDF file, 0 otherwise
    % =================================================================================================================
    % Update:
    %       2024-04-09:     Created, by Christmas;
    % =================================================================================================================
    % Example:
    %       TF = isNetcdfFile('wrfout_d01_2023-09-08_00:00:00');
    % =================================================================================================================
    
    arguments(Input)
        fin {mustBeFile}
    end
    arguments(Input, Repeating)
        varargin
    end

    try
        ncinfo(fin);
        TF = true;
    catch
        TF = false;
    end
end
