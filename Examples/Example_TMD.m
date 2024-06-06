clm
pwd = '/Users/christmas/Documents/Code/Project/Server_Program/Mbaysalt/Exfunctions/TMDToolbox_v2_5/TMD/DATA';
cd(pwd)

%% make control file
writelines('/Users/christmas/Documents/Code/MATLAB/数据/TPXO9-atlas-v5/bin/h_*_tpxo9_atlas_30_v5','tpxobin_file.mat','WriteMode','overwrite');
writelines('/Users/christmas/Documents/Code/MATLAB/数据/TPXO9-atlas-v5/bin/u_*_tpxo9_atlas_30_v5','tpxobin_file.mat','WriteMode','append');
writelines('/Users/christmas/Documents/Code/MATLAB/数据/TPXO9-atlas-v5/bin/grid_tpxo9_atlas_30_v5','tpxobin_file.mat','WriteMode','append');

%% make out_modfile
area_dir = sprintf('%s/AreaDir',pwd);
makedirs(area_dir)
writelines(sprintf('%s/h_area',area_dir),"Area_define.mat","WriteMode","overwrite")
writelines(sprintf('%s/uv_area',area_dir),"Area_define.mat","WriteMode","append")
writelines(sprintf('%s/grid_area',area_dir),"Area_define.mat","WriteMode","append")

%% run function
tpxo_atlas2local('tpxobin_file.mat','Area_define.mat',[-85 85],[0.001 360]);

%% TMD
cd ../
TMD  % 选择 Area_define.mat


%% to NETCDF

% TPXO9_atlas_v5_to_NetCDF
