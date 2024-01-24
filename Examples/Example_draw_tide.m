clm

%--------------------------Settings----------------------------------------
ffvcom = '/Users/christmas/Desktop/exampleNC/gfvcomv1_20231008_20231031_zeta.nc';
t1 = datenum(2023,10,08);
t2 = datenum(2023,10,31);
f = f_load_grid(ffvcom, 'MaxLon', 360, 'Coordinate', 'Geo','Global');
tides = ["M2" "N2" "S2"];
%--------------------------------------------------------------------------


% Read FVCOM data
% time
time = f_load_time(ffvcom);
it1 = find(time==t1);
it2 = find(time==t2);
nt = it2 - it1 + 1;
time = time(it1:it2);
% zeta
zeta = ncread(ffvcom, 'zeta', [1 it1], [Inf nt]);

% Harmonic analysis
if ~exist('T_mod.mat', 'file')
    for i = 1 : f.node
        disp(i)
        [T_mod(i), mod1] = t_tide(zeta(i,:), 'interval',1, 'latitude',f.y(i), 'start',time(1),'rayleigh',['M2  '; 'N2  '; 'S2  ']);
    end
    save('T_mod.mat', 'T_mod')
else
    disp('T_mod.mat already exists. Loading...')
    load('T_mod.mat')
end

% Extract the amplitude and phase data
for j = 1 : length(tides)
    Cid = find(ismember(T_mod(1).name,tides{j}, 'rows'));
    for i = 1 : f.node
        amp(i,j) = T_mod(i).tidecon(Cid,1);
        pha(i,j) = T_mod(i).tidecon(Cid,3);
    end
end

% Plot
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
    title(['GFVCOM ' tides{j} ' tide'])
    % mf_save(['gfvcom_' tides{j} '.png'])
end
