function [max_grad_total, thickness_total, upper_bound_total, lower_bound_total] = calc_thermocline(depth, T)
    %       Calculate thermocline strength, thickness, upper bound, lower bound
    % =================================================================================================================
    % Parameters:
    %       depth:  depth           || required: True  || type: 1D
    %       T:      sea temperature || required: True  || type: 4D(lon-lat-depth-time)
    % =================================================================================================================
    % Returns:
    %       max_grad_total: thermocline strength (Celsius/meter)
    %                       the max grad of the sea water temperature   ||type: 3D(lon-lat-time) 温跃层强度
    %       thickness_total: thermocline thickness (meter)
    %                       thickness of the sea water thermocline      ||type: 3D(lon-lat-time) 温跃层厚度
    %       upper_bound_total: thermocline upper bound (meter)
    %                       Upper boundary of the sea water thermocline ||type: 3D(lon-lat-time) 温跃层上边界
    %       lower_bound_total: thermocline lower bound (meter)
    %                       Lower boundary of the sea water thermocline ||type: 3D(lon-lat-time) 温跃层下边界
    % =================================================================================================================
    % Updates:
    %       ****-**-**:     Created,                by Jiaqi Dou;
    %       2025-07-23:     Code Refactoring,       by Christmas;
    % =================================================================================================================
    % Examples:
    %       depth = nr('./data/temperature_20250513.nc', 'depth');
    %       T = nr('./data/temperature_20250513.nc', 'to');
    %       [max_grad_total, thickness_total, upper_bound_total, lower_bound_total] = calc_thermocline(depth, T);
    % =================================================================================================================
    % References:
    %       None
    % =================================================================================================================

    max_grad_total = nan(size(T, [1, 2, 4]));
    thickness_total = nan(size(T, [1, 2, 4]));
    upper_bound_total = nan(size(T, [1, 2, 4]));
    lower_bound_total = nan(size(T, [1, 2, 4]));

    for it = 1:size(T, 4)
        % Thermocline Detection using Vertical Gradient Method
        % This program calculates thermocline boundaries from 3D temperature data
        % Based on the paper "A study of thermocline calculations in the China Sea"
        % pcolor(thickness');
        % shading interp;

        upper_bound = nan(size(T, [1, 2]));
        lower_bound = nan(size(T, [1, 2]));
        thickness = nan(size(T, [1, 2]));
        max_grad = nan(size(T, [1, 2]));

        % Loop through each horizontal grid point
        for i = 1:size(T, 1)

            for j = 1:size(T, 2)
                % Extract temperature profile at this location
                profile = reshape(T(i, j, :, it), [], 1);

                % Skip locations with NaN (land or missing data)
                if all(isnan(profile))
                    continue;
                end

                % Get maximum depth at this location
                max_depth = depth(find(~isnan(profile), 1, 'last'));

                % Set minimum gradient criterion based on depth as described in the paper
                if max_depth <= 200
                    min_grad = 0.2; % For depth <= 200m
                else
                    min_grad = 0.05; % For depth > 200m
                end

                % Find thermocline boundaries using vertical gradient method
                [up, low, thick, m_grad] = find_thermocline_boundaries(profile, depth, min_grad);

                upper_bound(i, j) = up;
                lower_bound(i, j) = low;
                thickness(i, j) = thick;
                max_grad(i, j) = m_grad;
            end

        end

        upper_bound_total(:, :, it) = upper_bound; % upper_bound_total
        lower_bound_total(:, :, it) = lower_bound; % lower_bound_total
        thickness_total(:, :, it) = thickness; % thickness
        max_grad_total(:, :, it) = max_grad; % strength

    end

end

function [upper_bound, lower_bound, thickness, max_grad] = find_thermocline_boundaries(temp_profile, depth, min_grad)
    % Calculate the temperature gradient profile
    valid_points = ~isnan(temp_profile);
    temp_valid = temp_profile(valid_points);
    depth_valid = depth(valid_points);

    % % Make sure we have at least 3 valid points
    % if length(temp_valid) < 3
    %     upper_bound = nan;
    %     lower_bound = nan;
    %     thickness = nan;
    %     max_grad = nan;
    %     return;
    % end

    % Interpolate to 1-meter resolution as mentioned in the paper
    depth_interp = (ceil(min(depth_valid)):floor(max(depth_valid)))';
    temp_interp = interp1(depth_valid, temp_valid, depth_interp, 'pchip');

    % Calculate the vertical gradient (typically negative for thermocline)
    grad = diff(temp_interp) ./ diff(depth_interp);
    depth_grad = depth_interp(1:end - 1) + diff(depth_interp) / 2;

    % Find segments where absolute gradient exceeds the threshold
    thermo_indices = find(abs(grad) >= min_grad);

    % Check if any thermocline was detected
    if isempty(thermo_indices)
        upper_bound = max(depth_grad);
        lower_bound = max(depth_grad);
        thickness = 0;
        max_grad = nan;
        return;
    end

    % Find the continuous segment with the largest average gradient.
    best_start = thermo_indices(1);
    best_end = best_start;
    best_average = -inf;
    segment_start = 1;

    for k = 2:(length(thermo_indices) + 1)

        if k > length(thermo_indices) || thermo_indices(k) ~= thermo_indices(k - 1) + 1
            segment_end = k - 1;
            start_index = thermo_indices(segment_start);
            end_index = thermo_indices(segment_end);
            average_gradient = mean(abs(grad(start_index:end_index)));

            if average_gradient > best_average
                best_average = average_gradient;
                best_start = start_index;
                best_end = end_index;
            end

            segment_start = k;
        end

    end

    upper_bound = depth_grad(best_start);
    lower_bound = depth_grad(best_end);
    thickness = lower_bound - upper_bound;
    max_grad = max(abs(grad(best_start:best_end)));
end
