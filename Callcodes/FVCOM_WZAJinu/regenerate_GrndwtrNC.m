clm;

fgrndwtr_nc = '/home/ocean/ForecastSystem/FVCOM_WZAJinu/Control/data/wzajinu_grndwtr_20240101_20251231.nc';
fout = '/home/ocean/ForecastSystem/FVCOM_WZAJinu/Control/data/x.nc';

copyfile(fgrndwtr_nc, fout)
Times = ncdateread(fgrndwtr_nc,'time');
Ttimes = Mdatetime(Times);
time = Ttimes.datenumC(1):1:Ttimes.datenumC(end);

[time, Itime, Itime2, Times] = convert_fvcom_time(time);

ncwrite(fout, 'time', time)