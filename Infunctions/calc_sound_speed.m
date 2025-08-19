function c = Del_Grosso_cn(T, S, z)
    %       Calculate sound speed using Del Grosso (1974) empirical formula
    % =================================================================================================================
    % Parameters:
    %       T:      sea temperature || required: True  || Dimensions: lon-lat-depth-time
    %       S:      sea salinity    || required: True  || Dimensions: lon-lat-depth-time
    %       z:      depth           || required: True  || Dimensions: lon-lat-depth
    % =================================================================================================================
    % Returns:
    %       c:      sound speed (m/s) || Dimensions: lon-lat-depth-time
    % =================================================================================================================
    % Updates:
    %       ****-**-**:     Created,                from Wenhua Song;
    %       2025-08-19:     Code Refactoring,       by Christmas;
    % =================================================================================================================
    % Examples:
    %       T = nr('/Users/christmas/Downloads/forecast_0p05_20250819_5d.nc', 'to');
    %       S = nr('/Users/christmas/Downloads/forecast_0p05_20250819_5d.nc', 'so');
    %       z = nr('./data/temperature_20250513.nc', 'depth');
    %       c = Del_Grosso_cn(T, S, z);
    % =================================================================================================================
    % References:
    %       Del Grosso, V. A., 'New Equation for the Speed of Sound in Natural Water (with comparisons to other equations)', J. Acoust. Soc. Am., Vol.56 No.4, p.1084 1974
    % =================================================================================================================

    % 校验
    if ~isequal(size(T), size(S))
        error('T, S must have the same size');
    end

    if numel(z) == len(z) && ndims(T) == 4 % lon*lat*depth*time
        if size(z, 2) ~= 1; z = z'; end  % 1*31 --> 31*1
        z = permute(z, [3, 4, 1, 2]); % 31*1 --> 1*1*31*1
        z = repmat(z, [size(T, [1, 2]), 1, size(T, 4)]); % --> 140*100*31*120
    end

    P = 1.033 ...
        +1.028126e-1 .* z ...
        +2.38e-7 .* z .^ 2 ...
        -6.8e-17 .* z .^ 4;
    %P=1.04+0.102506*(1.+0.00528*(sin(fai*pi/180))^2)*z+...
    %   2.524e-7*z^2; % Valid Except in Black Sea and Baltic Sea

    DCT = 5.01109398873 .* T ...
        -5.50946843172e-2 .* T .^ 2 ...
        +2.21535969240e-4 .* T .^ 3;

    DCS = 1.32952290781 .* S ...
        +1.28955756844e-4 .* S .^ 2;

    DCP = 1.56059257041e-1 .* P ...
        +2.44998688441e-5 .* P .^ 2 ...
        -8.83392332513e-9 .* P .^ 3;

    DCTSP = -1.27562783426e-2 .* (T .* S) ...
        +6.35191613389e-3 .* (T .* P) ...
        +2.65484716608e-8 .* (T .* T .* P .* P) ...
        -1.59349479045e-6 .* (T .* P .* P) ...
        +5.22116437235e-10 .* (T .* (P .^ 3)) ...
        -4.38031096213e-7 .* (P .* (T .^ 3)) ...
        -1.61674495909e-9 .* (S .* S .* P .* P) ...
        +9.68403156410e-5 .* (S .* (T .^ 2)) ...
        +4.85639620015e-6 .* (T .* P .* (S .^ 2)) ...
        -3.40597039004e-4 .* (T .* S .* P);

    c = 1402.392 + DCT + DCS + DCP + DCTSP;

end
