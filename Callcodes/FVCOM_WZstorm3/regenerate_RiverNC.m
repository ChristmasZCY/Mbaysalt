clm;

friver_nc = '/Users/christmas/Downloads/dingyang/FVCOM_WZstorm3/Control/data/River_data_wzstorm3_2023_2024.nc';
fout = '/Users/christmas/Downloads/dingyang/FVCOM_WZstorm3/Control/data/River_data_wzstorm3_2025_2026.nc';
ftime = f_load_time(friver_nc,"Times")+365+366;
Ttimes = Mdatetime(ftime,'Cdatenum');
time = Ttimes.datenumC(1):1:Ttimes.datenumC(end);

NC = ncstruct(friver_nc);
river_flux = NC.river_flux(:,:);
river_temp = NC.river_temp(:,:);
river_salt = NC.river_salt(:,:);
river_names = cellstr(NC.river_names');

write_river(fout, river_names, time, ...
            'Flux', river_flux, ...
            'Temperature', river_temp, ...
            'Salinity', river_salt);


