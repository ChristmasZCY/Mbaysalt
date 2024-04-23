function [node, mdst] = calc_nearest_node(fgrid, lon_dst, lat_dst)
    %       To calculate the nearest node and distance from FVCOM grid.
    % =================================================================================================================
    % Parameters:
    %       fgrid:          FVCOM grid                          || required: True  || type: struct  || example: fgrid
    %       lon_dst:        Longitude of destination            || required: True  || type: double  || example: 120.5
    %       lat_dst:        Latitude of destination             || required: True  || type: double  || example: 30.5
    %       varargin:       optional parameters
    % =================================================================================================================
    % Returns:
    %       node:           Nearest node                        || required: True  || type: double  || example: 1112
    %       mdst:           Distance from destination           || required: True  || type: double  || example: 0.5
    % =================================================================================================================
    % Updates:
    %       2024-04-23:     Created, by Christmas;
    % =================================================================================================================
    % Examples:
    %       [node, mdts] = calc_nearest_node(fgrid, 120.5, 30.5);
    % =================================================================================================================
    % Reference:
    %       https://www.bilibili.com/read/cv4527582/
    % =================================================================================================================
    
    R = 6378137;%earth radius

    if(lon_dst<0)
        lon_dst = lon_dst+360;
    end

    lon_src = fgrid.x;
    lat_src = fgrid.y;

    dtx = cos(lat_src./180.*pi).*(lon_dst-lon_src)./180.*pi.*R;
    dty = (lat_dst-lat_src)./180.*pi.*R;
    dst = sqrt(dtx.^2+(dty.^2));

    [mdst,node] = min(dst); % mdst is minium distant of node(m), node is indice

    return
end
