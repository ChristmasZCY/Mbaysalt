clm

ffvcom = '/Users/christmas/Desktop/exampleNC/gfvcomv1_20231008_20231031_zeta.nc';
it1 = 1;
it2 = 576;
nt = it2 - it1 + 1;
f = f_load_grid(ffvcom, 'MaxLon', 360, 'Coordinate', 'Geo','Global');
TMD_model = '/Users/christmas/Documents/Code/Project/Server_Program/Mbaysalt/Exfunctions/TMDToolbox/TMD/DATA/Area_define.mat';
tides = ["M2" "N2" "S2"];

time = f_load_time(ffvcom);
time = time(it1:it2);
zeta = ncread(ffvcom, 'zeta', [1 it1], [Inf nt]);

tlims = minmax(time);

% download
outdir = './data/';
xlims = minmax(f.x);
ylims = minmax(f.y);
info = UHSLC_info('xlims', xlims, 'ylims', ylims);  % Get the data information
ID = [info.id];
UHSLC_download(ID, outdir);  % Download the data

% Create the file list
fins = arrayfun(@(x) [outdir '/UHSLC_zeta_' convertStringsToChars(x) '.nc'], ID, 'UniformOutput', false);

% Read the data
out = UHSLC_read(fins, 'tlims', tlims, 'Clean');

% Create the file list
ins = dir('./data/UHSLC_zeta_*');
for i = 1 : length(ins)
    fins{i} = [ins(i).folder '/' ins(i).name];
end

% Read the data
sta = UHSLC_read(fins, 'tlims', tlims, 'Clean');

figure
hold on 
f_2d_range(f);
f_2d_boundary(f, 'Color', 'k');
plot([sta.lon], [sta.lat], 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 4)
% mf_save('UHSLC_stations.png')



% Find the nearest node
id = f_find_node(f, [sta.lon], [sta.lat]);




for i = 1 : length(sta)
% i = 104;
node = id(i);
% Model
mod0 = zeta(node,:);
[T_mod, mod1] = t_tide(mod0, 'interval',1, 'latitude',f.y(node), 'start',time(1));
mod2 = mod0 - mod1 - T_mod.ref; 
mod3 = pl66tn(mod2, 1, 33);
% Observe
[~, obs0] = data_random2hourly(sta(i).time, sta(i).zeta, 'tlims', tlims, 'Twindow', 2);
[T_obs, obs1] = t_tide(obs0, 'interval',1, 'latitude',sta(i).lat, 'start',time(1));
obs2 = obs0 - obs1 - T_obs.ref;
obs3 = pl66tn(obs2, 1, 33);
% TMD
[~, ~, ~, conList] = tmd_extract_HC(TMD_model, f.y(node), f.x(node), 'z', []);
for j = 1 : length(tides)
    k = find(ismember(upper(conList), tides{j}, 'rows'));
    if isempty(k)
        error(['Tide ' tides{j} ' is not included.'])
    else
        Cid(j) = k;
    end
end
[amp, pha, depth] = tmd_extract_HC(TMD_model, f.y(node), f.x(node), 'z', Cid);
T_tmd = create_tidestruc(tides, amp', pha');
tmd1 = t_predic(time, T_tmd, 'latitude', f.y(node), 'synthesis', 0);

tlims_plot = [datenum(2023,10,08) datenum(2023,10,31)];
close all
figure('Position', [1 1 1200 732])
ax1 = subplot(2,1,1);
hold on
xlim(tlims_plot)
plot(time, mod1, 'b-')
plot(time, obs1, 'r-')
plot(time, tmd1, 'k-')
plot(minmax(time), [0 0], 'k--')
legend('GFVCOM', 'Observe', 'TMD')
mf_xtick_shift(ax1, -datenum(2023,10,08)-1)  % Wrong, 目的mf_xtick_shift
title(sta(i).descr)
ax2 = subplot(2,1,2);
hold on
xlim(tlims_plot)
plot(time, mod3, 'b-')
plot(time, obs3, 'r-')
plot(minmax(time), [0 0], 'k--')
legend('GFVCOM', 'Observe')
mf_xtick_shift(ax2, -datenum(2023,10,08)-1)
ffig = ['./fig/zeta_' num2str(i,'%3.3d') '.png'];
mf_save(ffig)
end
