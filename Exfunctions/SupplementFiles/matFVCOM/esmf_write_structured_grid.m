function esmf_write_structured_grid(fout, lon, lat, varargin)
    %       Write a structured grid NC file for ESMF_RegridWeightGen
    % =================================================================================================================
    % Parameter:
    %       fout: output NC file name              || required: True || type: text          ||  example: 'grid.nc'
    %       lon: longitude or x coordinate         || required: True || type: 1D array      ||  example: [118,120]
    %       lat: latitude or y coordinate          || required: True || type: 1D array      ||  example: [30,32]
    %       varargin: (optional)
    %
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Update:
    %       2024-01-25  Created, by Christmas;
    % =================================================================================================================
    % Example:
    %       esmf_write_structured_grid('grid.nc', [118,120], [30,32]);
    % =================================================================================================================

    arguments(Input)
        fout (1,:) {mustBeTextScalar}
        lon (:,1) double
        lat (:,1) double
    end

    arguments(Repeating)
        varargin
    end

    % ESMF_RegridWeightGen --ignore_unmapped --method bilinear --extrap_method none ...
    % -s ${NC_src} --src_regional --src_loc corner ... 
    % -d ${NC_dst} --dst_regional ...
    % --weight ${NC_wgh} --no_log

    system(sprintf('%s --ignore_unmapped --method bilinear --extrap_method none -s x.nc --src_loc corner -d y.nc  --weight z.nc --no_log --dst_regional --src_regional',exe));

    ncid = netcdf.create(fout,'NETCDF4');

    londimID = netcdf.defDim(ncid, 'lon',length(lon));  % 定义lon维度
    latdimID = netcdf.defDim(ncid, 'lat',length(lat));  % 定义lat纬度

    lon_id = netcdf.defVar(ncid,  'lon', 'NC_FLOAT', londimID);  % 经度
    lat_id = netcdf.defVar(ncid,  'lat', 'NC_FLOAT', latdimID);  % 纬度

    netcdf.putVar(ncid, lon_id, lon);  % 经度
    netcdf.putVar(ncid, lat_id, lat);  % 纬度

    netcdf.putAtt(ncid,lon_id, 'units', 'degrees_east');  % 经度
    netcdf.putAtt(ncid,lon_id, 'long_name', 'longitude');  % 经度
    netcdf.putAtt(ncid,lat_id, 'units', 'degrees_north');  % 纬度
    netcdf.putAtt(ncid,lat_id, 'long_name', 'latitude');  % 纬度
    netcdf.close(ncid)
    
    return

end
