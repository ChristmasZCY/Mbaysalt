clm;

friver_nc = 'River_data_2024.nc';
fout = 'River_data_2024_2025.nc';
ftime = f_load_time(friver_nc,"Times");
Ttimes = Mdatetime([ftime(1:end-2);ftime+366],'Cdatenum');
time = Ttimes.datenumC(1):1:Ttimes.datenumC(end);

NC = ncstruct(friver_nc);
river_flux = NC.river_flux(:,:);
river_temp = NC.river_temp(:,:);
river_salt = NC.river_salt(:,:);
river_names = cellstr(NC.river_names');

write_river(fout, river_names, time, ...
            'Flux', [river_flux(:,1:end-2),river_flux], ...
            'Temperature', [river_temp(:,1:end-2),river_temp], ...
            'Salinity', [river_salt(:,1:end-2),river_salt]);


