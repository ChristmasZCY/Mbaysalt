clm

%--------------------------Settings----------------------------------------
ffvcom = '/Users/christmas/Desktop/exampleNC/gfvcom_20231208_20240118_zeta.nc';
f = f_load_grid(ffvcom, 'MaxLon', 360, 'Coordinate', 'Geo','Global');
TMD_model = '/Users/christmas/Documents/Code/MATLAB/test3/TMD_Matlab_Toolbox_v2.5/TMD/DATA/Model_tpx9_1:6_0_360';
tides = ["M2" "S2" "K1" "O1"];
%--------------------------------------------------------------------------
%{  
TMD_model contains
/Users/christmas/Documents/Code/MATLAB/数据/TPXO9-atlas-v5/bin_1_6/DATA/h_tpxo9.v2
/Users/christmas/Documents/Code/MATLAB/数据/TPXO9-atlas-v5/bin_1_6/DATA/uv_tpxo9.v2
/Users/christmas/Documents/Code/MATLAB/数据/TPXO9-atlas-v5/bin_1_6/DATA/grid_tpxo9v2
%}

% Find the tide index in TMD
[~, ~, ~, conList] = tmd_extract_HC(TMD_model, f.y(1), f.x(1), 'z', []);
for j = 1 : length(tides)
    k = find(ismember(upper(conList), tides{j}, 'rows'));
    if isempty(k)
        error(['Tide ' tides{j} ' is not included.'])
    else
        Cid(j) = k;
    end
end

% Extract the tide amplitude and phase
[amp, pha] = tmd_extract_HC(TMD_model, f.y, f.x, 'z', Cid);
amp = amp';
pha = pha';

% Plot
clims2 = [];
close all
for j = 1 : length(tides)
    cm = cm_load('Turbo');
    figure('Position', [1 1 1680 930])
    hold on
    f_2d_range(f);
    f_2d_image(f, amp(:,j));
    f_2d_contour(f, pha(:,j), 'Levels', 0:30:330, 'Angle');
    f_2d_mask_boundary(f, 'FaceColor', [222,184,135]/255);
    colorbar
    colormap(cm)
    clim([0 1.2])
    set(gca, 'xtick', -180:45:180)
    set(gca, 'ytick', -90:45:90)
    xlabel('Longitude(^o)')
    ylabel('Latitude(^o)')
    title(['TMD ' tides{j} ' tide'])
    % mf_save(['TMD_' tides{j} '.png'])
end
