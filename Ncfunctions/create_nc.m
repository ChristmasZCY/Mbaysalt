function [ncid, NC] = create_nc(fin, mode, varargin)
    %       Create a NETCDF4 file
    % =================================================================================================================
    % Parameter:
    %       fin:             file name              || required: True || type: string  || format: 'test.nc'
    %       mode:            file mode              || required: True || type: string  || format: 'NETCDF4'
    % =================================================================================================================
    % Returns:
    %       ncid:            file id                || type: integer || format: 1
    %       NC:              struct of file info    || type: struct  || format: struct
    %           .ncid:         file id              || type: integer || format: 1
    %           .fin:          file absolute path   || type: string  || format: '/home/user/test.nc'
    % =================================================================================================================
    % Update:
    %       ****-**-**:     Created,                                                by Christmas;
    %       2024-05-30:     Fixed input filename contains '~/', replace to HOME,    by Christmas;
    %       2026-03-30:     Added NC struct to return file info,                    by Christmas;
    % =================================================================================================================
    % Example:
    %       ncid = create_nc('test.nc', 'NETCDF4')
    %       [ncid, NC] = create_nc('test.nc', 'NETCDF4')
    % =================================================================================================================


    fin = getPath(fin);
    
    path = fileparts(fin);  % get the path of the file
    makedirs(path);       % create the path if it does not exist

    rmfiles(fin);       % remove the file if it exists
    if nargin == 1
        mode = 'NETCDF4';
    end

    ncid = netcdf.create(fin, mode, varargin{:});  % create the file

    NC.ncid = ncid;
    NC.fin = fin;

end
