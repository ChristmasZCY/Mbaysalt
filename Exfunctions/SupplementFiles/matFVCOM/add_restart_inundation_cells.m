%==========================================================================
% Add inundation_cells in the restart file.
% 
% Input  : --- fin, original input nesting file
%          --- fout, the new nesting file with center variables included
%
% Output : \
% 
% Usage  : add_restart_inundation_cells(fin, fout);
%
% v1.0
%
% Christmas
% 2024-12-08
%
% Updates:
%
%==========================================================================
function add_restart_inundation_cells(fin, fout)


copyfile(fin, fout);


% Open the output NC file
ncid = netcdf.open(fout, 'NC_WRITE');

% Re-define mode
netcdf.reDef(ncid);

% Get the dimension id and length.
dimid_nele = netcdf.inqDimID(ncid, 'nele');
[~, nele] = netcdf.inqDim(ncid, dimid_nele);
dimid_time = netcdf.inqDimID(ncid, 'time');
[~, nt] = netcdf.inqDim(ncid, dimid_time);

inundation_cells = zeros(nele, nt);


% Define the inundation_cells variable.
varid_inundation_cells = netcdf.defVar(ncid, 'inundation_cells', 'int', [dimid_nele dimid_time]);
netcdf.putAtt(ncid, varid_inundation_cells, 'long_name', 'Inundation_Cells');
netcdf.putAtt(ncid, varid_inundation_cells, 'grid', 'fvcom_grid');
netcdf.putAtt(ncid, varid_inundation_cells, 'type', 'data');

% End define mode
netcdf.endDef(ncid);

% Write data into the output NC file.
for it = 1 : nt
    netcdf.putVar(ncid, varid_inundation_cells,[0 it-1],[nele 1],inundation_cells(:, it));
end
% Close the output NC file.
netcdf.close(ncid);
