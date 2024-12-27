%==========================================================================
% Write BOTTOM_ROUGHNESS_FILE NetCDF file (Yang Ding. Version)
% 
% Input  : --- fz0b, z0b file path and name
%          --- z0b, Bottom Roughness Lengthscale 底边层的厚度 
%          --- cbcecs, Bottom roughness(CBC_ECS) 底摩擦 曼宁系数--> 也可BOTTOM_ROUGHNESS_TYPE='udef', 写入Cd
%
% Output : \
% 
% Usage  : write_brf_dy(fz0b, z0b, cbcecs);
%
% v1.0
%
% Siqi Li
% 2021-04-22
%
% Updates:
%       2024-12-27: Changed for Yang Ding,  by Christmas;
%
%==========================================================================
function write_brf_dy(fz0b, cbcecs, z0b)

if ~exist("z0b","var")
    z0b = ones(size(cbcecs)) * 0.0005000;  % Yang Ding.
end

nele = length(z0b);

% create the output file.
ncid=netcdf.create(fz0b, 'CLOBBER');

%define the dimension
nele_dimid=netcdf.defDim(ncid, 'nele', nele);

%define variables
% zsl
z0b_varid = netcdf.defVar(ncid,'z0b', 'float', nele_dimid);
netcdf.putAtt(ncid,z0b_varid,'long_name', 'Bottom Roughness Lengthscale');
netcdf.putAtt(ncid,z0b_varid,'unit', 'meter');

% cbcecs
cbcecs_varid = netcdf.defVar(ncid,'cbcecs', 'float', nele_dimid);
netcdf.putAtt(ncid,z0b_varid,'long_name', 'Bottom Roughness');
netcdf.putAtt(ncid,z0b_varid,'unit', 'none');

%end define mode
netcdf.endDef(ncid);

%put data in the output file
netcdf.putVar(ncid, z0b_varid,z0b);
netcdf.putVar(ncid, cbcecs_varid,cbcecs);

% close NC file
netcdf.close(ncid)
