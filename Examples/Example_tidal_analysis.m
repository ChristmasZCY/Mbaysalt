%% Method 1
clm
rayleigh = ['M2  '; 'N2  '; 'S2  '; 'K2  '; 'K1  '; 'O1  '; 'P1  '; 'Q1  '];
fin = '/home/ocean/ForecastSystem/FVCOM_Global_v2/Run/20240306/output/hindcast_0001.nc';
f = f_load_grid(file,"Global");
time = f_load_time(file,"Times");
u1 = ncread(file,'u',[1,1,1],[Inf,1,24]);
v1 = ncread(file,'u',[1,1,1],[Inf,1,24]);
zeta1 = ncread(file,'zeta',[1,1],[1,24]);


mod0 = complex(u1,v1);
for in = 1 : fn.nele
    disp(in)
    [T_mod, mod1] = t_tide(mod0(in,:), 'interval',1, 'latitude',f.yc(in), 'start',time(1),'output','none','rayleigh',rayleigh);
    mod3 = mod0(in,:) - mod1;
    u1(in,:) = real(mod3);
    v1(in,:) = imag(mod3);
end
u2 = pl66tn(u1, 1, 33);
v2 = pl66tn(v1, 1, 33);


mod0 = zeta1;
for in = 1 : fn.node
    [T_mod, mod1] = t_tide(mod0(in,:), 'interval',1, 'latitude',fn.y(in), 'start',time(1),'output','none','rayleigh',rayleigh);
    zeta2(in,:) = squeeze(mod0(in,:)) - mod1 - T_mod.ref;
end
mod2 = mod0 - mod1 - T_mod.ref; 
mod3 = pl66tn(mod2, 1, 33);

%% Method 2
[NAME,FREQ,TIDECON,XOUT]=t_tide(1:10,'start time',[2016,1,1,0,0,0],'latitude',22,'rayleigh',['M2']);
zhenfu = TIDECON(:,1);  % amp
chijiao = TIDECON(:,3);  % pha
