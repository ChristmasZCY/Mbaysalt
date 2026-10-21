function [MLD_total, BLT_total] = calc_barrierlayer(lon, lat, depth, T, S)
    % CALC_BARRIERLAYER 计算温度阈值混合层深度及障碍层厚度。
    % Inputs:
    %   lon, lat: numeric 经度、纬度一维坐标，长度与 T 前两维一致。
    %   depth: numeric 深度坐标，单位 m，与 T 第三维一致，正值向下。
    %   T: single/double 温度数组，单位 degrees C，lon-lat-depth-time；NaN 为缺测。
    %   S: single/double 盐度数组，单位 PSU，形状与 T 一致；NaN 为缺测。
    % Outputs:
    %   MLD_total: double、lon-lat-time，原接口的温度阈值混合层深度，单位 m。
    %   BLT_total: double、lon-lat-time，温度阈值深度减密度阈值深度，负值截为 0。
    %   无有效参考层、缺测或插值邻点缺测时，保留原有 NaN 结果。
    % Errors: 温盐、坐标维度不匹配或 seawater 工具箱不可用时抛出。
    % Reference: 于瑶, 吴松华. 基于2007—2018年Argo数据分析全球混合层和障碍层时空特征.
    % 中国海洋大学学报(自然科学版), 2021, 51(12): 123-132.

    nLon = size(T, 1);
    nLat = size(T, 2);
    nDepth = size(T, 3);
    nTime = size(T, 4);
    MLD_total = nan(nLon, nLat, nTime);
    BLT_total = nan(nLon, nLat, nTime);
    if nTime == 0
        return;
    end

    referenceIndex = find(depth >= 10, 1, 'first');
    % 同一纬度、深度的压力不随经度和时次改变，只保留 depth-lat 小矩阵。
    pressure = sw_pres(repmat(reshape(depth, [], 1), 1, nLat), repmat(reshape(lat, 1, []), nDepth, 1));
    referencePressure = double(repmat(pressure(referenceIndex, :), nLon, 1));

    for timeIndex = 1:nTime
        temperature = T(:, :, :, timeIndex);
        salinity = S(:, :, :, timeIndex);
        density = nan(nLon, nLat, nDepth);
        for depthIndex = 1:nDepth
            layerPressure = double(repmat(pressure(depthIndex, :), nLon, 1));
            density(:, :, depthIndex) = sw_dens(salinity(:, :, depthIndex), temperature(:, :, depthIndex), layerPressure);
        end

        referenceTemperature = temperature(:, :, referenceIndex);
        referenceDensity = sw_dens(salinity(:, :, referenceIndex), referenceTemperature - 0.2, referencePressure);
        temperatureProfiles = reshape(temperature, [], nDepth);
        salinityProfiles = reshape(salinity, [], nDepth);
        validTemperature = ~all(isnan(temperatureProfiles), 2) & ~all(isnan(salinityProfiles), 2) & ~isnan(referenceTemperature(:));
        temperatureDepth = first_threshold_crossing(temperatureProfiles, referenceTemperature(:) - 0.2, depth, false);
        temperatureDepth(~validTemperature) = nan;

        densityProfiles = reshape(density, [], nDepth);
        densityDepth = first_threshold_crossing(densityProfiles, referenceDensity(:), depth, true);
        densityDepth(all(isnan(densityProfiles), 2) | isnan(referenceDensity(:))) = nan;

        barrierThickness = temperatureDepth - densityDepth;
        barrierThickness(barrierThickness < 0) = 0;
        MLD_total(:, :, timeIndex) = reshape(temperatureDepth, nLon, nLat);
        BLT_total(:, :, timeIndex) = reshape(barrierThickness, nLon, nLat);
    end
end

function crossingDepth = first_threshold_crossing(profiles, thresholds, depth, isDensity)
    % FIRST_THRESHOLD_CROSSING 批量寻找每条剖面的第一个阈值交点。
    % Inputs:
    %   profiles: single/double、profile-depth，每行一条按原深度顺序排列的剖面。
    %   thresholds: numeric、profile-1，每条剖面自己的阈值。
    %   depth: numeric 深度向量，单位 m，与 profiles 列数一致。
    %   isDensity: logical scalar；true 使用 >=，false 使用 <=。
    % Output:
    %   crossingDepth: double 列向量，线性插值后的交点深度；未越界时取最大有效深度。
    %   前一层缺测保留 NaN；调用者负责剔除无效参考层及温盐全缺测剖面。
    % Errors: 输入维度不匹配时由 MATLAB 数组运算抛出。
    if isDensity
        beyond = profiles >= thresholds;
    else
        beyond = profiles <= thresholds;
    end
    [hasCrossing, firstIndex] = max(beyond, [], 2);
    crossingDepth = nan(size(firstIndex));
    firstLayer = hasCrossing & firstIndex == 1;
    crossingDepth(firstLayer) = depth(1);
    rows = find(hasCrossing & firstIndex > 1);
    if ~isempty(rows)
        layers = firstIndex(rows);
        previous = profiles(sub2ind(size(profiles), rows, layers - 1));
        current = profiles(sub2ind(size(profiles), rows, layers));
        previousDepth = reshape(depth(layers - 1), [], 1);
        currentDepth = reshape(depth(layers), [], 1);
        crossingDepth(rows) = previousDepth + (currentDepth - previousDepth) .* (thresholds(rows) - previous) ./ (current - previous);
    end

    % 无交点的剖面逐层确认最大有效深度，避免构造整块 double 深度索引矩阵。
    remaining = find(~hasCrossing);
    [~, depthOrder] = sort(depth, 'descend');
    for layer = reshape(depthOrder, 1, [])
        if isempty(remaining)
            break;
        end
        valid = ~isnan(profiles(remaining, layer));
        crossingDepth(remaining(valid)) = depth(layer);
        remaining = remaining(~valid);
    end
end
