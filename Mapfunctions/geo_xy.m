function [ylat_dst,xlon_dst] = geo_xy(proj_ori,proj_dst,ylat_ori,xlon_ori,varargin)
    %       Convert the lat/lon to x/y coordinate or x/y coordinate to lat/lon
    % =================================================================================================================
    % Parameter:
    %       proj_ori: original projection          || required: True || type: string         ||  example: 4326
    %       proj_dst: destination projection       || required: True || type: string         ||  example: 3857
    %       ylat_ori: latitude or x coordinate     || required: True || type: 1D array       ||  example: [30,32]
    %       xlon_ori: longitude or y coordinate    || required: True || type: 1D array       ||  example: [118,120]
    %       varargin: (optional)
    % =================================================================================================================
    % Returns:
    %       ylat_dst: latitude or x coordinate     || required: True || type: 1D array       ||  example: [30,32]
    %       xlon_dst: longitude or y coordinate    || required: True || type: 1D array       ||  example: [118,120]
    % =================================================================================================================
    % Update:
    %       2024-01-12:     Created, by Christmas;
    % =================================================================================================================
    % Example:
    %       [lat,lon] = geo_xy(4326,3857,118.5,31.5)
    %       [x,y] = geo_xy(3857,4326,13267848,4148549)
    %       [x,y] = geo_xy(3857,3857,13267848,4148549)
    %       [lat,lon] = geo_xy(4326,4326,118.5,31.5)
    %       [x,y] = geo_xy(4326,'UTM',31.5,118.5)
    % =================================================================================================================
    % Explains: 
    %       Geographic Coordinate Systems, GCS: (经纬度坐标, 地理坐标系, 大地坐标系)
    %           1. WGS84: 4326 --> (Ellipsoidal 2D CS. Axes: latitude, longitude. Orientations: north, east. UoM: degree)
    %           2. NAD83: 4269 --> (Ellipsoidal 2D CS. Axes: latitude, longitude. Orientations: north, east. UoM: degree)
    %           3. NAD27: 4267 --> (Ellipsoidal 2D CS. Axes: latitude, longitude. Orientations: north, east. UoM: degree)
    %           4. Beijing 1954: 4214 --> (Ellipsoidal 2D CS. Axes: latitude, longitude. Orientations: north, east. UoM: degree)
    %           5. Xian 1980: 4610 --> (Ellipsoidal 2D CS. Axes: latitude, longitude. Orientations: north, east. UoM: degree)
    %           6. CGCS2000: 4490 --> (Ellipsoidal 2D CS. Axes: latitude, longitude. Orientations: north, east. UoM: degree)
    %           7. New Beijing: 4555 --> (Ellipsoidal 2D CS. Axes: latitude, longitude. Orientations: north, east. UoM: degree)
    %       Projected Coordinate Systems, PCS: (投影坐标系, 平面坐标系)
    %           1. Web Mercator: 3857 --> (Cartesian 2D CS. Axes: easting, northing (X,Y). Orientations: east, north. UoM: m.)
    %           2. UTM: 32601-32660, 32701-32760
    %       Other Coordinate Systems, OCS: (其他坐标系)
    %           1. Spherical Coordinate System, SCS: (球坐标系)
    %           2. Polar Coordinate System, PCS: (极坐标系)
    %           3. Cartesian Coordinate System, CCS: (笛卡尔坐标系, 直角坐标系)
    %       Other Geodetic Parameters: (其他大地测量参数)
    %           1. Alaska Polar Stereographic: 5936 --> (Cartesian 2D CS for north polar azimuthal lonO 150°W. Axes: X,Y. Orientations: X along 60°W, Y along 30°E meridians. UoM: m.)
    %                                               --> World - N hemisphere - north of 60°N
    %           2. NSIDC EASE-Grid Global: 6933 --> (Cartesian 2D CS. Axes: easting, northing (X,Y). Orientations: east, north. UoM: m.)
    %                                           --> World - 86°S to 86°N
    %           3. NSIDC EASE-Grid North: 3408 --> (Cartesian 2D CS. Axes: easting, northing (X,Y). Orientations: east, north. UoM: m.)
    % =================================================================================================================


    if all(proj_ori == 4326) && all(proj_dst == 3857) % WGS84 to Web Mercator (经纬度坐标转平面坐标)
        proj = projcrs(proj_dst);
        [ylat_dst,xlon_dst] = projinv(proj,ylat_ori,xlon_ori);
    elseif all(proj_ori == 3857) && all(proj_dst == 4326) % Web Mercator to WGS84 (平面坐标转经纬度坐标)
        proj = projcrs(proj_ori);
        [ylat_dst,xlon_dst] = projfwd(proj,ylat_ori,xlon_ori);
    elseif all(proj_ori == 3857) && all(proj_dst == 3857) % Web Mercator to Web Mercator (平面坐标转平面坐标)
        ylat_dst = ylat_ori;
        xlon_dst = xlon_ori;
    elseif all(proj_ori == 4326) && all(proj_dst == 4326) % WGS84 to WGS84 (经纬度坐标转经纬度坐标)
        ylat_dst = ylat_ori;
        xlon_dst = xlon_ori;
    elseif all(proj_ori == 4326) && strcmp(proj_dst,'UTM') % WGS84 to UTM (经纬度坐标转 UTM 坐标)
        esriCode = latlonToUTMESRI(ylat_ori, xlon_ori);
        proj = projcrs(esriCode);
        assignin('caller','proj',proj)
        assignin('caller','ylat_ori',ylat_ori)
        assignin('caller','xlon_ori',xlon_ori)
        [ylat_dst,xlon_dst] = projfwd(proj,ylat_ori,xlon_ori);
    else
        % The projection is not supported!
        % The supported projection is:
        %   1. WGS84 to Web Mercator(4326 to 3857)
        %   2. Web Mercator to WGS84(3857 to 4326)
        %   3. Web Mercator to Web Mercator(3857 to 3857)
        %   4. WGS84 to WGS84(4326 to 4326)
        %   5. WGS84 to UTM(4326 to UTM)
        error('The projection is not supported!\n The supported projection is:\n 1. WGS84 to Web Mercator(4326 to 3857)\n 2. Web Mercator to WGS84(3857 to 4326)\n 3. Web Mercator to Web Mercator(3857 to 3857)\n 4. WGS84 to WGS84(4326 to 4326)\n 5. WGS84 to UTM(4326 to UTM)');
    end








    % =================================================================================================================

end

function esriCode = latlonToUTMESRI(lat, lon)
    % 根据给定的经纬度计算对应的 ESRI UTM 代码
    % 输入：
    %   lat - 纬度
    %   lon - 经度
    % 输出：
    %   esriCode - ESRI UTM 代码

    % 计算 UTM 分区
    zone = floor((lon + 180) / 6) + 1;

    % 确定是北半球还是南半球
    if lat < 0
        % 南半球
        esriCode = 32700 + zone;
    else
        % 北半球
        esriCode = 32600 + zone;
    end
end
