function [xlon_dst,ylat_dst,zh_dst] = geo_ecef(rule,xlon_ori,ylat_ori,zh_ori,options)
    %       Transform geocentric Earth-centered Earth-fixed coordinates to geodetic or reverse
    % =================================================================================================================
    % Parameter:
    %       rule: convert rule                      || required: True || type: string        ||  example: 'geo2ecef','ecef2geo'
    %       xlon_ori: longitude or y coordinate    || required: True || type: 1D array       ||  example: [30,32]
    %       ylat_ori: latitude or x coordinate     || required: True || type: 1D array       ||  example: [118,120]
    %       zh_ori: altitude or z coordinate       || required: True || type: 1D array       ||  example: [0,0]
    %       options: (optional)
    %           .lengthUnit: unit of length        || required: False || type: string        ||  default: 'meter'
    % =================================================================================================================
    % Returns:
    %       xlon_dst: longitude or y coordinate    || required: True || type: 1D array       ||  example: [118,120]
    %       ylat_dst: latitude or x coordinate     || required: True || type: 1D array       ||  example: [30,32]
    %       zh_dst: altitude or z coordinate       || required: True || type: 1D array       ||  example: [0,0]
    % =================================================================================================================
    % Update:
    %       2024-01-12:     Created, by Christmas;
    % =================================================================================================================
    % Example:
    %       [xlon_dst,ylat_dst,zh_dst] = geo_ecef('geo2ecef',112.3508,48.8562,0.0674,'lengthUnit','kilometer');
    %       [xlon_dst,ylat_dst,zh_dst] = geo_ecef('geo2ecef',112.3508,48.8562,0.0674,'lengthUnit','meter');
    %       [xlon_dst,ylat_dst,zh_dst] = geo_ecef('geo2ecef',112.3508,48.8562,0.0674);
    %       [xlon_dst,ylat_dst,zh_dst] = geo_ecef('ecef2geo',4201,172.46,4780.1,'lengthUnit','kilometer');
    % =================================================================================================================

    arguments
        rule {mustBeMember(rule,{'geo2ecef','ecef2geo'})}
        xlon_ori
        ylat_ori
        zh_ori
        options.lengthUnit = 'meter'
    end

    wgs84 = wgs84Ellipsoid(options.lengthUnit);
    if strcmp(rule,'geo2ecef')
        [xlon_dst,ylat_dst,zh_dst] = geodetic2ecef(wgs84,ylat_ori,xlon_ori,zh_ori);
    elseif strcmp(rule,'ecef2geo')
        [ylat_dst,xlon_dst,zh_dst] = ecef2geodetic(wgs84,xlon_ori,ylat_ori,zh_ori);
    end


end