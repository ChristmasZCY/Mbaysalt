function test_science_array_reuse()
    % TEST_SCIENCE_ARRAY_REUSE 验证阈值批处理、温跃层筛选、纯温度梯度和声速重排的数值契约。
    % Inputs: none. Outputs: none. Throws assertion errors on regression.
    repoRoot = fileparts(fileparts(mfilename('fullpath')));
    originalPath = path;
    pathCleanup = onCleanup(@() path(originalPath));
    addpath(fullfile(repoRoot, 'Infunctions'));
    addpath(fullfile(repoRoot, 'Exfunctions', 'seawater_ver3_3.1'));

    for precision = {'single', 'double'}
        depth = cast([0.5, 5, 10, 20, 50, 100, 500], precision{1});
        temperature = repmat(reshape(cast([28, 28, 27.9, 27.5, 25, 20, 10], precision{1}), 1, 1, [], 1), 4, 3, 1, 4);
        salinity = repmat(reshape(cast([33, 33, 33.1, 34, 34.5, 35, 35], precision{1}), 1, 1, [], 1), 4, 3, 1, 4);
        temperature(:, :, :, 2) = temperature(:, :, :, 2) + cast(0.3, precision{1});
        temperature(:, :, :, 4) = temperature(:, :, :, 4) - cast(0.6, precision{1});
        temperature = temperature + reshape(cast(0:3, precision{1}), 4, 1, 1, 1) * cast(0.15, precision{1});
        temperature(1, 1, :, :) = nan;
        salinity(1, 1, :, :) = nan;
        salinity(1, 2, :, :) = nan;
        temperature(2, 1, 3, :) = nan;
        temperature(2, 2, 6:end, :) = nan;
        salinity(2, 2, 6:end, :) = nan;
        temperature(3, 2, :, :) = 26;
        salinity(3, 2, :, :) = 35;
        lon = cast([100, 101, 102, 103], precision{1});
        lat = cast([-30, 0, 30], precision{1});

        [mixedLayer, barrierLayer] = calc_barrierlayer(lon, lat, depth, temperature, salinity);
        for timeIndex = 1:size(temperature, 4)
            [hourMixed, hourBarrier] = calc_barrierlayer(lon, lat, depth, temperature(:, :, :, timeIndex), salinity(:, :, :, timeIndex));
            assert(isequaln(mixedLayer(:, :, timeIndex), hourMixed));
            assert(isequaln(barrierLayer(:, :, timeIndex), hourBarrier));
        end
        assert(all(isnan(barrierLayer(1, 1, :))));
        assert(all(isnan(barrierLayer(1, 2, :))));

        expandedDepth = repmat(reshape(depth, 1, 1, [], 1), 4, 3, 1, 4);
        vectorSound = calc_sound_speed(temperature, salinity, depth);
        fieldSound = calc_sound_speed(temperature, salinity, expandedDepth);
        assert(isequaln(vectorSound, fieldSound));
        assert(isequal(size(vectorSound), size(temperature)));
        assert(strcmp(class(vectorSound), precision{1}));
        for timeIndex = 1:size(temperature, 4)
            hourSound = calc_sound_speed(temperature(:, :, :, timeIndex), salinity(:, :, :, timeIndex), depth);
            assert(isequaln(vectorSound(:, :, :, timeIndex), hourSound));
        end
        assert(isequaln(calc_sound_speed(temperature(:, :, 1, 1), salinity(:, :, 1, 1), depth(1)), ...
            calc_sound_speed(temperature(:, :, 1, 1), salinity(:, :, 1, 1), expandedDepth(:, :, 1, 1))));

        [~, ~, fullGradient] = calc_weather_front(lon, lat, depth, temperature, salinity);
        [frontMask, frontStrength, surfaceGradient, saltGradient] = calc_weather_front(lon, lat, depth(1), temperature(:, :, 1, :), [], 'temperature_only', true);
        assert(isequaln(fullGradient, surfaceGradient));
        assert(isempty(frontMask) && isempty(frontStrength) && isempty(saltGradient));
        test_thermocline_segment_selection(precision{1});
        test_thermocline_single_interval(precision{1});
        test_thermocline_index_restoration(precision{1});
        test_thermocline_depth_threshold(precision{1});
        test_sound_speed_polynomial_precision(precision{1});

    end
end

function test_thermocline_segment_selection(precision)
    % TEST_THERMOCLINE_SEGMENT_SELECTION 验证并列段顺序、全部输出及未检出语义。
    % Input: precision，char，single 或 double。
    % Outputs: none. Throws assertion errors when a scientific selection rule changes.
    depth = cast(0:10, precision);
    profile = cast([28, 28, 27.5, 27, 27, 27, 26.25, 26, 26, 26, 26], precision);
    temperature = repmat(reshape(profile, 1, 1, [], 1), 2, 2, 1, 3);
    temperature(1, 1, :, :) = nan;
    [strength, thickness, upper, lower] = calc_thermocline(depth, temperature);
    assert(all(isnan(strength(1, 1, :))));
    assert(all(strength(2, 2, :) == 0.5));
    assert(all(thickness(2, 2, :) == 1));
    assert(all(upper(2, 2, :) == 1.5));
    assert(all(lower(2, 2, :) == 2.5));
    for timeIndex = 1:3
        [hourStrength, hourThickness, hourUpper, hourLower] = calc_thermocline(depth, temperature(:, :, :, timeIndex));
        assert(isequaln(strength(:, :, timeIndex), hourStrength));
        assert(isequaln(thickness(:, :, timeIndex), hourThickness));
        assert(isequaln(upper(:, :, timeIndex), hourUpper));
        assert(isequaln(lower(:, :, timeIndex), hourLower));
    end
    [strength, thickness, upper, lower] = calc_thermocline(depth, ones(2, 2, 11, precision) * 28);
    assert(all(isnan(strength(:))));
    assert(all(thickness(:) == 0));
    assert(all(upper(:) == 9.5) && all(lower(:) == 9.5));
end


function test_thermocline_single_interval(precision)
    % TEST_THERMOCLINE_SINGLE_INTERVAL 验证仅一个候选米段时的标量与多剖面输出。
    % Input: precision，char，single 或 double，指定深度及温度类型。
    % Outputs: none. Throws assertion errors on shape or known boundary regression.
    depth = cast(0:10, precision);
    profile = cast([28, 28, 28, 28, 28, 27, 27, 27, 27, 27, 27], precision);
    for profileCount = [1, 4]
        temperature = repmat(reshape(profile, 1, 1, [], 1), 1, profileCount, 1, 2);
        [strength, thickness, upper, lower] = calc_thermocline(depth, temperature);
        assert(isequal(size(strength), [1, profileCount, 2]));
        assert(all(strength(:) == 1));
        assert(all(thickness(:) == 0));
        assert(all(upper(:) == 4.5) && all(lower(:) == 4.5));
    end
end

function test_thermocline_index_restoration(precision)
    % TEST_THERMOCLINE_INDEX_RESTORATION 验证跨批次/小池重排后仍回到原网格和时次。
    % Input: precision，char，single 或 double，指定深度及温度类型。
    % Outputs: none. Throws assertion errors on ordering, missing data or output regression.
    % 8450 条错序阶跃剖面跨过 256/4096 边界，包含未检出、全缺测及不同有效底层。
    nx = 65; ny = 65; nt = 2;
    profileNumber = 1:(nx * ny * nt);
    stepIndex = mod(37 * (profileNumber - 1), 8) + 1;
    profiles = cast(28 - ((0:10)' >= stepIndex), precision);
    isConstant = mod(profileNumber, 17) == 0;
    isMissing = mod(profileNumber, 31) == 0;
    hasShortBottom = mod(profileNumber, 13) == 0;
    profiles(:, isConstant) = 28;
    profiles(11, hasShortBottom) = nan;
    profiles(:, isMissing) = nan;
    temperature = permute(reshape(profiles, 11, nx, ny, nt), [2, 3, 1, 4]);
    expectedStrength = ones(1, numel(profileNumber));
    expectedThickness = zeros(1, numel(profileNumber));
    expectedBounds = stepIndex - 0.5;
    expectedStrength(isConstant) = nan;
    expectedBounds(isConstant) = 9.5;
    expectedBounds(isConstant & hasShortBottom) = 8.5;
    expectedStrength(isMissing) = nan;
    expectedThickness(isMissing) = nan;
    expectedBounds(isMissing) = nan;
    expected = {reshape(expectedStrength, nx, ny, nt), reshape(expectedThickness, nx, ny, nt), ...
        reshape(expectedBounds, nx, ny, nt), reshape(expectedBounds, nx, ny, nt)};
    actual = cell(1, 4);
    [actual{:}] = calc_thermocline(cast(0:10, precision), temperature);
    for outputIndex = 1:4
        assert(isequaln(actual{outputIndex}, expected{outputIndex}));
        assert(strcmp(class(actual{outputIndex}), 'double'));
    end
    for timeIndex = 1:nt
        hour = cell(1, 4);
        [hour{:}] = calc_thermocline(cast(0:10, precision), temperature(:, :, :, timeIndex));
        for outputIndex = 1:4
            assert(isequaln(actual{outputIndex}(:, :, timeIndex), hour{outputIndex}));
        end
    end
end

function test_thermocline_depth_threshold(precision)
    % TEST_THERMOCLINE_DEPTH_THRESHOLD 验证最深有效层在 200 米两侧的原阈值切换。
    % Input: precision，char，single 或 double，指定深度及温度类型。
    % Outputs: none. Throws assertion errors when screening changes detection rules.
    % 精确线性梯度 0.125 degrees C/m 位于浅水 0.2 与深水 0.05 阈值之间。
    for bottom = [200, 201]
        depth = cast([0, 50, 100, 150, bottom], precision);
        profile = cast(28 - double(depth) * 0.125, precision);
        temperature = repmat(reshape(profile, 1, 1, [], 1), 2, 2, 1, 2);
        [strength, thickness, upper, lower] = calc_thermocline(depth, temperature);
        if bottom == 200
            assert(all(isnan(strength(:))) && all(thickness(:) == 0));
            assert(all(upper(:) == 199.5) && all(lower(:) == 199.5));
        else
            assert(all(strength(:) == 0.125) && all(thickness(:) == 200));
            assert(all(upper(:) == 0.5) && all(lower(:) == 200.5));
        end
    end
end

function test_sound_speed_polynomial_precision(precision)
    % TEST_SOUND_SPEED_POLYNOMIAL_PRECISION 用高精度多项式参考值约束重排的舍入误差。
    % Input: precision，char，single 或 double，指定温盐及默认深度的类型。
    % Outputs: none. Throws assertion errors on coefficient, rounding or class regression.
    % 下列参考值由原系数以 50 位十进制计算，覆盖交叉项；不是经验公式的适用范围声明。
    cases = [-2, 35, 0, 1439.9058857698083;
        0, 0, 0.5, 1402.5612604498351;
        10, 20, 10, 1471.8508336347488;
        20, 35, 200, 1524.9267452094766;
        30, 40, 1000, 1567.2411578247545;
        40, 42, 6000, 1668.6858959555516;
        2, 35, 11000, 1653.873095696699;
        25, 35, 3000, 1583.8593942017067;
        35, 0, 6000, 1747.8446292258682;
        0, 42, 11000, 1654.7902393515137;
        -2, 42, 500, 1457.498897675617;
        15, 35, 5727.5, 1603.881237465043];
    temperature = cast(cases(:, 1), precision);
    salinity = cast(cases(:, 2), precision);
    expected = cases(:, 4);
    % 允许四个输出 ULP，single 在约 1500 m/s 处每 ULP 约 0.000122 m/s。
    tolerance = 4 * double(eps(cast(expected, precision)));
    for coordinatePrecision = {precision, 'double'}
        actual = calc_sound_speed(temperature, salinity, cast(cases(:, 3), coordinatePrecision{1}));
        assert(strcmp(class(actual), precision));
        assert(all(abs(double(actual) - expected) <= tolerance));
    end
end
