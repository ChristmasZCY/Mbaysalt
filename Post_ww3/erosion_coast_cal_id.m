function I_D = erosion_coast_cal_id(lon, lat, value, K, judge_num)
    %       calculate the erosion of the coast id, only for the grid data, such as WRF
    % =================================================================================================================
    % Parameter:
    %       lon: longitude of the grid point        || required: True || type: double ||  format: matrix
    %       lat: latitude of the grid point         || required: True || type: double ||  format: matrix
    %       value: value of the grid point          || required: True || type: double ||  format: matrix
    %       K: knnsearch points, except itself      || required: True || type: double ||  format: 16
    %       judge_num: the number of water values   || required: True || type: double ||  format: 5
    %       I_D: id and distance                    || required: True || type: double ||  format: struct
    % =================================================================================================================
    % Example:
    %       I_D = erosion_coast_cal_id(lon, lat, value, 16, 5)
    % =================================================================================================================

    if numel(lon) == length(lon)
        [lat,lon] = meshgrid(lat,lon);
        lon=reshape(lon,[],1);
        lat=reshape(lat,[],1);
    end
    if ndims(value) > 2
        value = value(:,:,1,1,1,1);
    end
    % Find the nearest K points in the two-dimensional grid data to the grid point 
    [Idx,D] = knnsearch([lon,lat],[lon,lat],"K",K+1);
    judge_nan = ~isnan(value(Idx));
    nan_number = sum(judge_nan,2);
    
    flag = find(nan_number > judge_num);
    judge_nan = judge_nan(flag,:);
    id = Idx(flag,:);
    d = D(flag,:);
    flag_0 = find(judge_nan(:,1) == 1);
    id(flag_0,:) = [];
    d(flag_0,:) = [];
    I_D.id = id;
    I_D.distance = d;
    I_D.judgeNum = [K, judge_num];

end
