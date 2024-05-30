function ncid = create_nc(fin, mode, varargin)
    %       Create a NETCDF4 file
    % =================================================================================================================
    % Parameter:
    %       fin:             file name               || required: True || type: string  || format: 'test.nc'
    %       mode:            file mode               || required: True || type: string  || format: 'NETCDF4'
    % =================================================================================================================
    % Returns:
    %       ncid:            file id                 || required: True || type: integer || format: 1
    % =================================================================================================================
    % Update:
    %       ****-**-**:     Created,                                                by Christmas;
    %       2024-05-30:     Fixed input filename contains '~/', replace to HOME,    by Christmas;
    % =================================================================================================================
    % Example:
    %       ncid = create_nc('test.nc', 'NETCDF4')
    % =================================================================================================================


    if startsWith(fin, '~/')
        HOME = getHome();
        fin = replace(fin, '~/', [HOME, filesep]);
    end
    
    path = fileparts(fin);  % get the path of the file
    makedirs(path);       % create the path if it does not exist

    rmfiles(fin);       % remove the file if it exists
    if nargin == 1
        mode = 'NETCDF4';
    end

    ncid = netcdf.create(fin, mode, varargin{:});  % create the file

end
