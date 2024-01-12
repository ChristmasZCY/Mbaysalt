function [deltaX,deltaY,deltaZ,d] = ecef_distance(lat1,lon1,h1,lat2,lon2,h2,options)
    %       Calculate cartesian ECEF offset between geodetic coordinates
    % =================================================================================================================
    % Parameter:
    %       lat1: latitude or x coordinate         || required: True || type: 1D array       ||  example: [30,32]
    %       lon1: longitude or y coordinate        || required: True || type: 1D array       ||  example: [118,120]
    %       h1: altitude or z coordinate           || required: True || type: 1D array       ||  example: [0,0]
    %       lat2: latitude or x coordinate         || required: True || type: 1D array       ||  example: [30,32]
    %       lon2: longitude or y coordinate        || required: True || type: 1D array       ||  example: [118,120]
    %       h2: altitude or z coordinate           || required: True || type: 1D array       ||  example: [0,0]
    %       options: (optional)
    %           .lengthUnit: unit of length        || required: False || type: string        ||  default: 'meter'
    % =================================================================================================================
    % Returns:
    %       deltaX: x coordinate offset            || type: 1D array ||  example: [0,0]
    %       deltaY: y coordinate offset            || type: 1D array ||  example: [0,0]
    %       deltaZ: z coordinate offset            || type: 1D array ||  example: [0,0]
    %       d: distance between two points         || type: 1D array ||  example: [0,0]
    % =================================================================================================================
    % Update:
    %       2024-01-12:     Created, by Christmas;
    % =================================================================================================================
    % Example:
    %       [dx,dy,dz] = ecef_distance(48.8567,2.3508,80,25.7753,-80.2089,-25,'lengthUnit','meter');
    %       [dx,dy,dz] = ecef_distance(48.8567,2.3508,80,25.7753,-80.2089,-25,'lengthUnit','kilometer');
    %       [dx,dy,dz] = ecef_distance(48.8567,2.3508,80,25.7753,-80.2089,-25);
    %       [dx,dy,dz,d] = ecef_distance(48.8567,2.3508,80,25.7753,-80.2089,-25);
    % =================================================================================================================

    arguments
        lat1 (:,1) {mustBeNumeric,mustBeReal,mustBeFinite}
        lon1 (:,1) {mustBeNumeric,mustBeReal,mustBeFinite}
        h1 (:,1) {mustBeNumeric,mustBeReal,mustBeFinite}
        lat2 (:,1) {mustBeNumeric,mustBeReal,mustBeFinite}
        lon2 (:,1) {mustBeNumeric,mustBeReal,mustBeFinite}
        h2 (:,1) {mustBeNumeric,mustBeReal,mustBeFinite}
        options.lengthUnit (1,:) char {mustBeMember(options.lengthUnit,{'meter','kilometer'})} = 'meter'
    end

    spheroid = wgs84Ellipsoid(options.lengthUnit);
    [deltaX,deltaY,deltaZ] = ecefOffset(spheroid,lat1,lon1,h1,lat2,lon2,h2);

    if nargout == 4
        d = norm([deltaX,deltaY,deltaZ]);
    end

end