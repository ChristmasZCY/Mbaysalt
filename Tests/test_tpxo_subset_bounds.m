function test_tpxo_subset_bounds()
    repoRoot = fileparts(fileparts(mfilename('fullpath')));
    addpath(fullfile(repoRoot, 'Post_tpxo'));
    addpath(fullfile(repoRoot, 'Infunctions'));
    addpath(fullfile(repoRoot, 'Exfunctions', 'matFVCOM'));
    addpath(fullfile(repoRoot, 'Exfunctions', 'Otherpkgs'));
    addpath(fullfile(repoRoot, 'Exfunctions', 'SupplementFiles', 'matFVCOM'));
    addpath(fullfile(repoRoot, 'Exfunctions', 'TMDToolbox_v2_5', 'TMD', 'FUNCTIONS'));

    test_tide_template();
    test_preuvh2_bounds();
    test_atlas_crop();
end

function test_tide_template()
    tideList = ["M2", "N2", "K1", "O1"];
    amplitude = [0.2, 0.3, 0.4, 0.5];
    phase = [20, 30, 40, 50];
    reference = create_tidestruc(tideList, amplitude, phase);
    template = create_tidestruc(tideList, zeros(size(amplitude)), zeros(size(phase)));
    [found, tideIndex] = ismember(strtrim(string(template.name)), tideList);
    assert(all(found));
    template.tidecon(:, 1) = amplitude(tideIndex).';
    template.tidecon(:, 3) = phase(tideIndex).';
    assert(isequal(reference, template));

    major = [0.2, 0.3, 0.4, 0.5];
    minor = [-0.02, 0.03, -0.04, 0.05];
    inclination = [60, 70, 80, 90];
    reference = create_tidestruc(tideList, major, minor, inclination, phase);
    template = create_tidestruc(tideList, zeros(size(major)), zeros(size(minor)), ...
        zeros(size(inclination)), zeros(size(phase)));
    [found, tideIndex] = ismember(strtrim(string(template.name)), tideList);
    assert(all(found));
    template.tidecon(:, 1) = major(tideIndex).';
    template.tidecon(:, 3) = minor(tideIndex).';
    template.tidecon(:, 5) = inclination(tideIndex).';
    template.tidecon(:, 7) = phase(tideIndex).';
    assert(isequal(reference, template));
end

function test_preuvh2_bounds()
    testDir = string(tempname);
    cleanup = onCleanup(@() cleanup_dir(testDir));
    sourceDir = fullfile(testDir, 'source');
    mkdir(sourceDir);

    gridLimits = [0; 360; -90; 90];
    depth = reshape(1:(36 * 18), [36, 18]);
    gridFile = fullfile(sourceDir, 'grid_tpxo10_atlas_30_v2.nc');
    grd_out(gridFile, gridLimits, depth, ones(size(depth)), [], 12);
    for constituent = ["k1", "m2"]
        value = ones(size(depth)) * find(constituent == ["k1", "m2"]);
        h_out(fullfile(sourceDir, "h_" + constituent + "_tpxo10_atlas_30_v2.nc"), value, ...
            gridLimits(3:4), gridLimits(1:2), pad(upper(constituent), 4));
        uv_out(fullfile(sourceDir, "u_" + constituent + "_tpxo10_atlas_30_v2.nc"), value, value, ...
            gridLimits(3:4), gridLimits(1:2), pad(upper(constituent), 4));
    end

    cases = {
        [170, -170], [-10, 10], [150; 210; -30; 30];
        [-1, 359, 1], [0, 0, 0], [-20; 20; -20; 20];
        [120, 120.01, 130], [0, 0, 0], [100; 150; -20; 20]
    };

    for index = 1:size(cases, 1)
        areaDir = fullfile(testDir, "area_" + index);
        preuvh2(cases{index, 1}, cases{index, 2}, datetime(2026, 1, 1), ...
            [], sourceDir, areaDir, 'createOnly');
        outputLimits = grd_in(fullfile(areaDir, 'grid_area'));
        assert(max(abs(outputLimits - cases{index, 3})) < 1e-12);
    end

    times = datetime(2026, 1, 1) + hours(0:5);
    tideList = ["M2", "K1"];
    areaDir = fullfile(testDir, 'area_1');
    tide = preuvh2(cases{1, 1}, cases{1, 2}, times, tideList, [], ...
        fullfile(testDir, 'area_1'), 'Vname', 'all');
    assert(all(isfinite(tide.h), 'all'));
    assert(all(isfinite(tide.u), 'all'));
    assert(all(isfinite(tide.v), 'all'));

    referenceControl = fullfile(testDir, 'reference_model');
    writelines([fullfile(areaDir, 'h_area'); fullfile(areaDir, 'uv_area'); fullfile(areaDir, 'grid_area')], referenceControl);
    referenceVelocity = complex(zeros(numel(cases{1, 1}), numel(times)));

    for pointIndex = 1:numel(cases{1, 1})
        major = zeros(1, numel(tideList)); minor = major; phase = major; inclination = major;

        for tideIndex = 1:numel(tideList)
            [major(tideIndex), minor(tideIndex), phase(tideIndex), inclination(tideIndex)] = ...
                tmd_ellipse(char(referenceControl), cases{1, 2}(pointIndex), cases{1, 1}(pointIndex), char(tideList(tideIndex)));
        end

        referenceStruct = create_tidestruc(tideList, major / 100, minor / 100, inclination, phase);
        referenceVelocity(pointIndex, :) = t_predic(datenum(times), referenceStruct, ...
            'latitude', cases{1, 2}(pointIndex), 'synthesis', 0);
    end

    assert(max(abs(tide.u(:) - real(referenceVelocity(:)))) < 1e-12);
    assert(max(abs(tide.v(:) - imag(referenceVelocity(:)))) < 1e-12);

    parallelTide = preuvh2(cases{1, 1}, cases{1, 2}, times, tideList, [], ...
        areaDir, 'Vname', 'uv', 'INFO', 'none', 'Parallel', 2);
    assert(isequaln(parallelTide.u, tide.u));
    assert(isequaln(parallelTide.v, tide.v));
end

function test_atlas_crop()
    testDir = string(tempname);
    cleanup = onCleanup(@() cleanup_dir(testDir));
    hDir = fullfile(testDir, 'h');
    uDir = fullfile(testDir, 'long_current_directory');
    outDir = fullfile(testDir, 'out');
    mkdir(hDir); mkdir(uDir); mkdir(outDir);

    gridFile = fullfile(testDir, 'grid_test');
    gridLimits = [0; 360; -90; 90];
    depth = reshape(1:72, [12, 6]);
    grd_out(gridFile, gridLimits, depth, ones(size(depth)), [], 12);

    for constituent = ["k1", "m2"]
        value = ones(size(depth));
        h_out(fullfile(hDir, "h_" + constituent + "_test"), value, ...
            gridLimits(3:4), gridLimits(1:2), pad(upper(constituent), 4));
        uv_out(fullfile(uDir, "u_" + constituent + "_test"), value, value, ...
            gridLimits(3:4), gridLimits(1:2), pad(upper(constituent), 4));
    end

    atlasControl = fullfile(testDir, 'atlas.txt');
    outputControl = fullfile(testDir, 'output.txt');
    outputH = fullfile(outDir, 'h_area');
    outputU = fullfile(outDir, 'uv_area');
    outputGrid = fullfile(outDir, 'grid_area');
    writelines([fullfile(hDir, 'h_*'); fullfile(uDir, 'u_*'); gridFile], atlasControl);
    writelines([outputH; outputU; outputGrid], outputControl);

    tpxo_atlas2local(atlasControl, outputControl, [-20, 20], [-20, 20]);

    [outputLimits, outputDepth] = grd_in(outputGrid);
    assert(max(abs(outputLimits - [-30; 30; -30; 30])) < 1e-12);
    assert(isequal(size(outputDepth), [2, 2]));
    assert(isequal(upper(strtrim(string(rd_con(outputH)))), ["K1"; "M2"]));
    assert(isequal(upper(strtrim(string(rd_con(outputU)))), ["K1"; "M2"]));
end

function cleanup_dir(directory)
    if isfolder(directory)
        rmdir(directory, 's');
    end
end
