%==========================================================================
% Add el_eqi in the restart file.
% 
% Input  : --- fin, original input nesting file
%          --- fout, the new nesting file with center variables included
%
% Output : \
% 
% Usage  : add_restart_el_eqi(fin, fout);
%
% v1.0
%
% Christmas
% 2024-12-08
%
% Updates:
%
%==========================================================================
function add_restart_el_eqi(fin, fout)


copyfile(fin, fout);


% Open the output NC file
ncid = netcdf.open(fout, 'NC_WRITE');

% Re-define mode
netcdf.reDef(ncid);

% Get the dimension id and length.
dimid_node = netcdf.inqDimID(ncid, 'node');
[~, node] = netcdf.inqDim(ncid, dimid_node);
dimid_time = netcdf.inqDimID(ncid, 'time');
[~, nt] = netcdf.inqDim(ncid, dimid_time);

el_eqi = ncread(fout,'el_eqi');
el_eqi_id = netcdf.inqVarID(ncid,'el_eqi');


% Define the el_eqi variable.
varid_el_eqi1 = netcdf.defVar(ncid, 'el_eqi1', 'float', [dimid_node dimid_time]);
netcdf.copyAtt(ncid, el_eqi_id,'long_name', ncid,varid_el_eqi1);
netcdf.copyAtt(ncid, el_eqi_id,'units', ncid,varid_el_eqi1);

% End define mode
netcdf.endDef(ncid);

% Write data into the output NC file.
for it = 1 : nt
    netcdf.putVar(ncid, varid_el_eqi1,[0 it-1],[node 1],el_eqi(:, it));
end
% Close the output NC file.
netcdf.close(ncid);

txt = sprintf('ncks -x -v el_eqi %s', fout);
system(txt,'-echo');

txt = sprintf('ncrename -v el_eqi1,el_eqi %s', fout);
system(txt,'-echo');





ncid = netcdf.open(fout, 'NC_WRITE');
netcdf.reDef(ncid);
dimid_node = netcdf.inqDimID(ncid, 'node');
[~, node] = netcdf.inqDim(ncid, dimid_node);
dimid_time = netcdf.inqDimID(ncid, 'time');
[~, nt] = netcdf.inqDim(ncid, dimid_time);

el_eqi = ncread(fout,'el_eqi');
el_eqi_id = netcdf.inqVarID(ncid,'el_eqi');

varid_el_eqi1 = netcdf.defVar(ncid, 'el_eqi1', 'float', [dimid_node dimid_time]);
netcdf.copyAtt(ncid, el_eqi_id,'long_name', ncid,varid_el_eqi1);
netcdf.copyAtt(ncid, el_eqi_id,'units', ncid,varid_el_eqi1);

% End define mode
netcdf.endDef(ncid);

% Write data into the output NC file.
for it = 1 : nt
    netcdf.putVar(ncid, varid_el_eqi1,[0 it-1],[node 1],el_eqi(:, it));
end
% Close the output NC file.
netcdf.close(ncid);
!ncks -x -v el_eqi x.nc y.nc
!ncrename -v el_eqi1,el_eqi y.nc
