function [d, dx, dy] = calc_geodistance(lonArray1, latArray1, lonArray2, latArray2, varargin)
    %       Calculate geo distance, can be used to point-grid // point-point // grid-grid // grid-point
    % =================================================================================================================
    % Parameters:
    %       lonArray1:    longitude 1D array -1     || required: True || type: 1D        || example: [120,121]
    %       latArray1:    latitude  1D array -1     || required: True || type: 1D        || example: [33,34]
    %       lonArray2:    longitude 1D array -2     || required: True || type: 1D        || example: [119,119]
    %       latArray2:    latitude  1D array -2     || required: True || type: 1D        || example: [32,32]
    %       varargin:   (optional)
    %           method:   calculate method          || required: False|| type: namevalue || default: 'method','common'
    % =================================================================================================================
    % Returns:
    %        d:    distance Space
    %        dx:   distance east
    %        dy:   distance north
    % =================================================================================================================
    % Updates:
    %       2024-05-10:     Created,                by Christmas;
    %       2024-05-14:     Added method 'MATLAB',  by Christmas;
    % =================================================================================================================
    % Examples:
    %       [d,d_east,d_north]= calc_geodistance([120,121,122],[33,34,33],[119,119,119],[32,32,32]);
    %       [d,d_east,d_north]= calc_geodistance([120,121,122],[33,34,33],119,32);
    %       [d,d_east,d_north]= calc_geodistance([120,121,122],[33,34,33],119,32,'method','common');
    %       [d,d_east,d_north]= calc_geodistance([120,121,122],[33,34,33],119,32,'method','MATLAB');
    % =================================================================================================================
    % References:
    %
    %    See also CALC_DISTANCE, GEO_XY.
    %    <a href="matlab: matlab.desktop.editor.openAndGoToLine(which('calc_geodistance_readme.mlx'), 2^31-1); ">see Picture</a>
    % =================================================================================================================

    arguments
        lonArray1 (:,:) {mustBeFloat}
        latArray1 (:,:) {mustBeFloat}
        lonArray2 (:,:) {mustBeFloat}
        latArray2 (:,:) {mustBeFloat}
    end

    arguments (Input,Repeating)
        varargin
    end

    varargin = read_varargin(varargin,{'method'},{'common'});
    
    switch lower(method)
    case 'common'

        R = 6378.137*10^3;  % 地球半径(m)
        x = deg2rad(lonArray1) - deg2rad(lonArray2);  % lon1*pi/180 - lon2*pi/180;
        y = deg2rad(latArray1) - deg2rad(latArray2);  % lat1*pi/180 - lat2*pi/180;
        d = R*2*asin(sqrt(sin(y/2).^2 + cos(latArray1*pi/180).*cos(latArray2*pi/180).*sin(x/2).^2));
        dx = lonArray2 - lonArray1;
        dy = latArray2 - latArray1;
        if dy >= 0
            theta = atan2d(dy,dx);
        else
            theta = 360+atan2d(dy,dx);
        end
    
        dx = d.*cos(theta);
        dy = d.*sin(theta);

    case 'matlab'
        wgs84 = wgs84Ellipsoid("m");
        d  = distance(latArray1, lonArray1, latArray2, lonArray2, wgs84);
        % d2 = distance(latArray1, lonArray1, latArray2, lonArray2)./180*pi*6370*1000;
        dx = NaN;
        dy = NaN;

    otherwise
        error('Method must be one of ''common'', ''MATLAB''');
    end


end
