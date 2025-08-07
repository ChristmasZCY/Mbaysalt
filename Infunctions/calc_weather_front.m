function [combined_fronts, ...
        fronts_strength, ...
        temp_gradient_magnitude, ...
        salt_gradient_magnitude] = calc_weather_front(lon, lat, depth, T, S, varargin)
    %       Calculate weather front where and strength, sea temperature gradient, and sea salinity gradient.
    % =================================================================================================================
    % Parameters:
    %       lon:    longitude       || required: True  || type: 1D
    %       lat:    latitude        || required: True  || type: 1D
    %       depth:  depth           || required: True  || type: 1D
    %       T:      sea temperature || required: True  || type: 4D(lon-lat-depth-time)
    %       S:      sea salinity    || required: True  || type: 4D(lon-lat-depth-time)
    % =================================================================================================================
    % Returns:
    %       combined_fronts: Ocean Fronts Detection                 ||type: 3D(lon-lat-time) 锋面位置
    %                       Binary mask for ocean fronts (1=front, 0=no front)
    %       fronts_strength: Ocean Fronts Strength                  ||type: 3D(lon-lat-time) 锋面强度
    %                       Normalized combined fronts strength (0-1)
    %       temp_gradient_magnitude: Temperature Gradient Magnitude ||type: 3D(lon-lat-time) 温度梯度
    %                       Horizontal temperature gradient magnitude (degrees_C/m)
    %       salt_gradient_magnitude: Salinity Gradient Magnitude    ||type: 3D(lon-lat-time) 盐度梯度
    %                       Horizontal salinity gradient magnitude (PSU/m)
    % =================================================================================================================
    % Updates:
    %       ****-**-**:     Created,                by Jiaqi Dou;
    %       2025-08-06:     Code Refactoring,       by Christmas;
    % =================================================================================================================
    % Examples:
    %       lon = nr('./data/salinity_20250513.nc','longitude');
    %       lat = nr('./data/temperature_20250513.nc', 'latitude');
    %       depth = nr('./data/temperature_20250513.nc', 'depth');
    %
    %       T = nr('./data/temperature_20250513.nc', 'to');
    %       S = nr('./data/salinity_20250513.nc', 'so');
    %       [combined_fronts, ...
    %               fronts_strength, ...
    %               temp_gradient_magnitude, ...
    %               salt_gradient_magnitude] = calc_weather_front(lon, lat, depth, T, S);
    % =================================================================================================================
    % References:
    %       None
    % =================================================================================================================

    % 默认表层深度阈值为0.5米
    varargin = read_varargin(varargin, {'surface_depth_threshold'}, {0.5});
    % 计算综合锋面强度
    % 使用加权平均，温度梯度权重更高
    varargin = read_varargin(varargin, {'weight_temp'}, {0.6});
    varargin = read_varargin(varargin, {'weight_salt'}, {0.6});

    % 找到表层深度索引
    surface_depth_idx = find(depth <= surface_depth_threshold);
    % fprintf('表层深度范围: 0 - %d 米 (共 %d 层)\n', surface_depth_threshold, length(surface_depth_idx));

    % 初始化结果数组
    [nx, ny, ~, nt] = size(T);
    temp_gradient_magnitude = zeros(nx, ny, length(surface_depth_idx), nt);
    salt_gradient_magnitude = zeros(nx, ny, length(surface_depth_idx), nt);
    combined_fronts = zeros(nx, ny, length(surface_depth_idx), nt);
    fronts_strength = zeros(nx, ny, length(surface_depth_idx), nt);
    clear nx ny

    % 计算网格间距（假设为规则网格）
    dx = abs(lon(2) - lon(1)) * 111000; % 转换为米（近似）
    dy = abs(lat(2) - lat(1)) * 111000; % 转换为米（近似）

    % fprintf('网格分辨率: dx = %.2f km, dy = %.2f km\n', dx/1000, dy/1000);

    % 逐时间步处理
    for it = 1:nt

        t0 = T(:, :, surface_depth_idx, it);
        s0 = S(:, :, surface_depth_idx, it);

        % 逐深度层处理
        for ih = 1:length(surface_depth_idx)
            salt_layer = squeeze(s0(:, :, ih));
            temp_layer = squeeze(t0(:, :, ih));

            % 计算温度梯度
            [temp_grad_x, temp_grad_y] = gradient(temp_layer, dx, dy);
            temp_grad_mag = sqrt(temp_grad_x.^2 + temp_grad_y.^2);

            % 计算盐度梯度
            [salt_grad_x, salt_grad_y] = gradient(salt_layer, dx, dy);
            salt_grad_mag = sqrt(salt_grad_x.^2 + salt_grad_y.^2);

            % 存储梯度幅值
            temp_gradient_magnitude(:, :, ih, it) = temp_grad_mag;
            salt_gradient_magnitude(:, :, ih, it) = salt_grad_mag;

            % 标准化梯度值
            temp_grad_norm = temp_grad_mag / (max(temp_grad_mag(:)) + eps);
            salt_grad_norm = salt_grad_mag / (max(salt_grad_mag(:)) + eps);

            combined_strength = weight_temp * temp_grad_norm + weight_salt * salt_grad_norm;
            fronts_strength(:, :, ih, it) = combined_strength;

            % 锋面识别：使用阈值方法
            % 计算各深度层的阈值（使用90%分位数）
            temp_threshold = prctile(temp_grad_mag(~isnan(temp_grad_mag)), 90);
            salt_threshold = prctile(salt_grad_mag(~isnan(salt_grad_mag)), 90);
            combined_threshold = prctile(combined_strength(~isnan(combined_strength)), 85);

            % 锋面标识：满足温度或盐度梯度阈值，或综合强度阈值
            fronts_mask = (temp_grad_mag > temp_threshold) | ...
                (salt_grad_mag > salt_threshold) | ...
                (combined_strength > combined_threshold);

            combined_fronts(:, :, ih, it) = double(fronts_mask);
        end
    end

end
