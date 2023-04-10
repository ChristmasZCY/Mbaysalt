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

    try
        ncid = netcdf.create(fin, mode, varargin{:});
    catch
        delete(fin)
        ncid = netcdf.create(fin, mode, varargin{:});
    end

end