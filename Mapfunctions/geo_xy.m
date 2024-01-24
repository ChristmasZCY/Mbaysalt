function [xlon_dst,ylat_dst] = geo_xy(proj_ori,proj_dst,xlon_ori,ylat_ori,options)
    %       Convert the lat/lon to x/y coordinate or x/y coordinate to lat/lon
    % =================================================================================================================
    % Parameter:
    %       proj_ori: original projection           || required: True || type: string         ||  example: '4326'
    %       proj_dst: destination projection        || required: True || type: string         ||  example: '3857'
    %       xlon_ori: longitude or y coordinate     || required: True || type: 1D array       ||  example: [118,120]
    %       ylat_ori: latitude or x coordinate      || required: True || type: 1D array       ||  example: [30,32]
    %       options: (optional)
    %           Method: Mapping Toolbox or epsg web || required: True || type: 1D array       ||  format: 'Mapping' or 'web'
    % =================================================================================================================
    % Returns:
    %       xlon_dst: longitude or y coordinate     || required: True || type: 1D array       ||  example: [118,120]
    %       ylat_dst: latitude or x coordinate      || required: True || type: 1D array       ||  example: [30,32]
    % =================================================================================================================
    % Update:
    %       2024-01-12:     Created, by Christmas;
    % =================================================================================================================
    % Example:
    %       [x,y] = geo_xy('4326','3857',118.5,31.5)
    %       [lon,lat] = geo_xy('3857','4326',13191359,3697855)
    %       [x,y] = geo_xy('3857','3857',13267848,4148549)
    %       [lon,lat] = geo_xy('4326','4326',118.5,31.5)
    %       [x,y] = geo_xy('4326','UTM',118.5,31.5)
    %       [x,y] = geo_xy('4326','3857',118.5,31.5,'Method','web')
    %       [lon,lat] = geo_xy('3857','4326',13191359,3697855,'Method','web')
    %       [x,y] = geo_xy('3857','3857',13267848,4148549,'Method','web')
    %       [lon,lat] = geo_xy('4326','4326',118.5,31.5,'Method','web')
    %       [x,y] = geo_xy('4326','UTM',118.5,31.5,'Method','web')
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

    arguments(Input)
        proj_ori 
        proj_dst
        xlon_ori
        ylat_ori
        options.Method {mustBeMember(options.Method,{'Mapping','web'})} = 'Mapping'
    end

    proj_ori = convertStringsToChars(proj_ori);
    proj_dst = convertStringsToChars(proj_dst);

    if strcmp(proj_ori,proj_dst)
        ylat_dst = ylat_ori;
        xlon_dst = xlon_ori;
        return
    end

    switch options.Method
    case 'Mapping'
        % if all(proj_ori == '4326') && all(proj_dst == '3857') % WGS84 to Web Mercator (经纬度坐标转平面坐标)
        if strcmp(proj_ori,'4326') && strcmp(proj_dst,'3857') % WGS84 to Web Mercator (经纬度坐标转平面坐标)
            proj = projcrs(str2double(proj_dst));
            [xlon_dst,ylat_dst] = projfwd(proj,ylat_ori,xlon_ori);
        % elseif all(proj_ori == '3857') && all(proj_dst == '4326') % Web Mercator to WGS84 (平面坐标转经纬度坐标)
        elseif strcmp(proj_ori,'3857') && strcmp(proj_dst,'4326') % Web Mercator to WGS84 (平面坐标转经纬度坐标)
            proj = projcrs(str2double(proj_ori));
            [ylat_dst,xlon_dst] = projinv(proj,xlon_ori,ylat_ori);
        % elseif all(proj_ori == '4326') && strcmp(proj_dst,'UTM') % WGS84 to UTM (经纬度坐标转 UTM 坐标)
        elseif strcmp(proj_ori,'4326') && strcmp(proj_dst,'UTM') % Web Mercator to UTM (平面坐标转 UTM 坐标)
            esriCode = latlonToUTMESRI(xlon_ori,ylat_ori);
            if max(esriCode) - min(esriCode) ~= 0
                warning(sprintf(['There are at least 2 UTM Region at matrix. \n' ...
                    '      Maybe %d UTM region'], int16(max(esriCode) - min(esriCode)+1)))
            end
            esriCode = round(mean(esriCode(:)),0);
            proj = projcrs(esriCode);
            [xlon_dst,ylat_dst] = projfwd(proj,ylat_ori,xlon_ori);
        else
            % The projection is not supported!
            % The supported projection is:
            %   1. WGS84 to Web Mercator(4326 to 3857)
            %   2. Web Mercator to WGS84(3857 to 4326)
            %   3. Web Mercator to Web Mercator(3857 to 3857)
            %   4. WGS84 to WGS84(4326 to 4326)
            %   5. WGS84 to UTM(4326 to UTM)
            error(sprintf(['The projection is not supported!\n' ...
                ' The supported projection is:\n ' ...
                '   1. WGS84 to Web Mercator(4326 to 3857)\n ' ...
                '   2. Web Mercator to WGS84(3857 to 4326)\n ' ...
                '   3. Web Mercator to Web Mercator(3857 to 3857)\n ' ...
                '   4. WGS84 to WGS84(4326 to 4326)\n ' ...
                '   5. WGS84 to UTM(4326 to UTM)']));
        end
    case 'web'
        if length(xlon_ori) == 1 && length(ylat_ori) == 1
            if strcmp(proj_dst,'UTM')
                proj_dst = latlonToUTMESRI(xlon_ori,ylat_ori);
            end
            if isa(proj_ori,"char")
                proj_ori = str2double(proj_ori);
            end
            if isa(proj_dst,"char")
                proj_dst = str2double(proj_dst);
            end
            url = sprintf('https://epsg.io/srs/transform/%f,%f.json?key=default&s_srs=%d&t_srs=%d',xlon_ori,ylat_ori,proj_ori,proj_dst);
            try
                data = webread(url);
            catch ME1
                if (strcmp(ME1.identifier,'MATLAB:webservices:HTTP422StatusCodeError'))
                    xlon_dst = NaN;
                    ylat_dst = NaN;
                    warning(sprintf('Wrong input!\n Something makes error in the input parameters!\n Please check the input parameters!'));  %#ok<*SPWRN>
                    return
                end
            end
            xlon_dst = data.results.x;
            ylat_dst = data.results.y;
        else
            error(sprintf('The method:web is just for test the function is right or not!\n The input xlon_ori and ylat_ori must be a single value!'));
        end

    otherwise
        error(sprintf('The method is not supported!\n The supported method is:\n 1. Mapping Toolbox\n 2. epsg web'));
    end

end


function esriCode = latlonToUTMESRI(lon,lat)
    % 根据给定的经纬度计算对应的 ESRI UTM 代码
    % 输入：
    %   lon - 经度
    %   lat - 纬度
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
