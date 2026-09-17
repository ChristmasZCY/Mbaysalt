function test_tpxo_subset_bounds()
    repoRoot = fileparts(fileparts(mfilename('fullpath')));
    addpath(fullfile(repoRoot, 'Post_tpxo'));
    addpath(fullfile(repoRoot, 'Infunctions'));
    addpath(fullfile(repoRoot, 'Exfunctions', 'matFVCOM'));
    addpath(fullfile(repoRoot, 'Exfunctions', 'Otherpkgs'));
    addpath(fullfile(repoRoot, 'Exfunctions', 'SupplementFiles', 'matFVCOM'));
    addpath(fullfile(repoRoot, 'Exfunctions', 'TMDToolbox_v2_5', 'TMD', 'FUNCTIONS'));

    test_preuvh2_bounds();
    test_atlas_crop();
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
    value = ones(size(depth));
    h_out(fullfile(sourceDir, 'h_m2_tpxo10_atlas_30_v2.nc'), value, ...
        gridLimits(3:4), gridLimits(1:2), 'M2  ');
    uv_out(fullfile(sourceDir, 'u_m2_tpxo10_atlas_30_v2.nc'), value, value, ...
        gridLimits(3:4), gridLimits(1:2), 'M2  ');

    cases = {
        [170, -170], [0, 0], [150; 210; -20; 20];
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
