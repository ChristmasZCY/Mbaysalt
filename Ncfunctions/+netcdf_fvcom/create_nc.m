function ncid = create_nc(fin, mode, varargin)
    % =================================================================================================================
    % discription:
    %       create a NETCDF4 file
    % =================================================================================================================
    % parameter:
    %       fin:             file name               || required: True || type: string || format: 'test.nc'
    %       mode:            file mode               || required: True || type: string || format: 'NETCDF4'
    % =================================================================================================================
    % example:
    %       ncid = netcdf_fvcom.create_nc('test.nc', 'NETCDF4')
    % =================================================================================================================
    
    path = fileparts(fin);  % get the path of the file
    makedirs(path);       % create the path if it does not exist

    rmfiles(fin);       % remove the file if it exists
    ncid = netcdf.create(fin, mode, varargin{:});  % create the file

end