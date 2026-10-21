function c = calc_sound_speed(T, S, z)
    %       Calculate sound speed using Del Grosso (1974) empirical formula
    % =================================================================================================================
    % Parameters:
    %       T:      sea temperature (degrees C), single/double; NaN denotes missing
    %               required: True; dimensions: lon-lat-depth-time
    %       S:      sea salinity (PSU), single/double; same shape as T; NaN allowed
    %       z:      depth (m), depth vector or an array compatible with T
    %               vector length must equal the third dimension of T
    % =================================================================================================================
    % Returns:
    %       c:      sound speed (m/s), same shape as T; MATLAB numeric type rules apply
    %               Horner 分组保留系数及公式，运算顺序改变可能带来末位舍入差异
    %       Errors: T and S must have equal sizes; incompatible z cannot broadcast
    % =================================================================================================================
    % Updates:
    %       ****-**-**:     Created,                from Wenhua Song;
    %       2025-08-19:     Code Refactoring,       by Christmas;
    % =================================================================================================================
    % Examples:
    %       T = nr('/Users/christmas/Downloads/forecast_0p05_20250819_5d.nc', 'to');
    %       S = nr('/Users/christmas/Downloads/forecast_0p05_20250819_5d.nc', 'so');
    %       z = nr('./data/temperature_20250513.nc', 'depth');
    %       c = calc_sound_speed(T, S, z);
    % =================================================================================================================
    % References:
    %       Del Grosso, V. A., 'New Equation for the Speed of Sound in Natural Water (with comparisons to other equations)', J. Acoust. Soc. Am., Vol.56 No.4, p.1084 1974
    % =================================================================================================================

    % 校验
    if ~isequal(size(T), size(S))
        error('T, S must have the same size');
    end

    if isvector(z) && numel(z) == size(T, 3) % lon*lat*depth*time
        % 同一深度的压力供所有经纬度和时次广播使用，避免复制完整四维深度场。
        pressure_depth = reshape(z, 1, 1, [], 1);
    else
        pressure_depth = z;
    end

    % Horner 分组减少大数组的重复幂运算与临时量；保持原 Del Grosso 系数。
    P = 1.033 + pressure_depth .* (1.028126e-1 + pressure_depth .* (2.38e-7 - 6.8e-17 .* pressure_depth .^ 2));

    DCT = T .* (5.01109398873 + T .* (-5.50946843172e-2 + 2.21535969240e-4 .* T));
    DCS = S .* (1.32952290781 + 1.28955756844e-4 .* S);
    DCP = P .* (1.56059257041e-1 + P .* (2.44998688441e-5 - 8.83392332513e-9 .* P));

    DCTSP = T .* (P .* (6.35191613389e-3 + P .* (-1.59349479045e-6 + 5.22116437235e-10 .* P)) ...
        + S .* (-1.27562783426e-2 - 3.40597039004e-4 .* P) ...
        + T .* (2.65484716608e-8 .* P .^ 2 - 4.38031096213e-7 .* P .* T + 9.68403156410e-5 .* S)) ...
        + S .^ 2 .* P .* (-1.61674495909e-9 .* P + 4.85639620015e-6 .* T);

    c = 1402.392 + DCT + DCS + DCP + DCTSP;

end
