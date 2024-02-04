ncfile = "/Users/christmas/Desktop/exampleNC/gersem.nc";
f = f_load_grid(ncfile,"Coordinate",'geo');
ph = double(ncread(ncfile,'O3_pH'));
no3 = double(ncread(ncfile,'N3_n'));
pco2 = double(ncread(ncfile,'O3_pCO2'));
chlo_p1 = double(ncread(ncfile,'P1_Chl'));
chlo_p2 = double(ncread(ncfile,'P2_Chl'));
chlo_p3 = double(ncread(ncfile,'P3_Chl'));
chlo_p4 = double(ncread(ncfile,'P4_Chl'));
chlo = chlo_p1 + chlo_p2 + chlo_p3 + chlo_p4;
clear chlo_p1 chlo_p2 chlo_p3 chlo_p4
casfco2 = double(ncread(ncfile,'O3_fair'));

%% pH
figure(1)
clf
ph = limit_var(ph, [0,14]);
Var = make_300m_avg(f,ph);
f_2d_image(f,Var,'MaxLon',180);
colorbar
clim([7.9 8.4])
title(sprintf('pH 300m平均 at 20240112/forecast_avg_0001.nc'), ...
    sprintf('Var: O3_pH  min=%3.1f max=%3.1f mean=%3.1f',min(Var(:)),max(Var(:)),mean(Var(:),'all')), ...
    "Interpreter","none","FontSize",15,"FontWeight","bold")
% mf_save('ersem_v2/pH_20240112.png')
% xlim([90 180])
% ylim([0 50])
% mf_save('ersem_v2/pH_20240112_china.png')
clear Var

%% pCO2
figure(2)
clf
pco2 = limit_var(pco2, [0,10000]);
Var = make_300m_avg(f,pco2);
f_2d_image(f,Var,'MaxLon',180);
colorbar
clim([200 500])
cm = cm_load('mld','NColor',50);
colormap(cm)
title(sprintf('pCO2 300m平均 at 20240112/forecast_avg_0001.nc'), ...
    sprintf('Var: O3_pCO2  min=%3.1f max=%2g mean=%2g',min(Var(:)),max(Var(:)),mean(Var(:),'all')), ...
    "Interpreter","none","FontSize",15,"FontWeight","bold")
% mf_save('ersem_v2/pco2_20240112.png')
% xlim([90 180])
% ylim([0 50])
% mf_save('ersem_v2/pco2_20240112_china.png')
clear Var

%% NO3
figure(3)
clf
no3 = limit_var(no3, [0,400]);
Var = make_300m_avg(f,no3);
f_2d_image(f,Var,'MaxLon',180);
colorbar
clim([0 20])
cm = cm_load('mld','NColor',50);
colormap(cm)
title(sprintf('NO3 300m平均 at 20240112/forecast_avg_0001.nc'), ...
    sprintf('Var: N3_n  min=%3.1f max=%3.1f mean=%3.1f',min(Var(:)),max(Var(:)),mean(Var(:),'all')), ...
    "Interpreter","none","FontSize",15,"FontWeight","bold")
% mf_save('ersem_v2/no3_20240112.png')
% xlim([90 180])
% ylim([0 50])
% mf_save('ersem_v2/no3_20240112_china.png')
clear Var

%% Chlo
figure(4)
clf
chlo = limit_var(chlo, [0,100]);
Var = make_300m_avg(f,chlo);
f_2d_image(f,log10(Var),'MaxLon',180);
c=colorbar;
set(c,'tickdir','out')  % 朝外
set(c,'YTick',log10([0.001,0.01,0.1,1,3,5,7,10])); %色标值范围及显示间隔
set(c,'YTickLabel',{0.001,0.01,0.1,1,3,5,7,10}) %具体刻度赋值
clim([-3,log10(10)])
cm = cm_load('mld','NColor',50);
colormap(cm)
title(sprintf('Chlo 300m平均 at 20240112/forecast_avg_0001.nc'), ...
    sprintf('Var: chlo_p1+chlo_p2+chlo_p3+chlo_p4  min=%3.1f max=%3.1f mean=%3.1f',min(Var(:)),max(Var(:)),mean(Var(:),'all')), ...
    "Interpreter","none","FontSize",15,"FontWeight","bold")
% mf_save('ersem_v2/chlo_20240112.png')
% xlim([90 180])
% ylim([0 50])
% mf_save('ersem_v2/chlo_20240112_china.png')
clear Var

%% casfco2
figure(5)
clf
 casfco2 = limit_var(casfco2, [-300, 300]);
Var = casfco2;
f_2d_image(f,Var,'MaxLon',180);
colorbar
clim([-100 100])
cm = cm_load('mld','NColor',50);
colormap(cm)
title('F_{air-sea} at 20240112/forecast\_avg\_0001.nc', ...
    sprintf('Var: O3\\_fair  min=%2g max=%3.1f mean=%2g',min(Var(:)),max(Var(:)),mean(Var(:),'all')), ...
    "FontSize",15,"FontWeight","bold","Interpreter","tex")
% mf_save('ersem_v2/casfco2_20240112.png')
% xlim([90 180])
% ylim([0 50])
% mf_save('ersem_v2/casfco2_20240112_china.png')
clear Var

%% function
function Var = make_300m_avg(f,var)
    Deplev_use = f.deplev;
    Deplev_use(Deplev_use > 300) = NaN;
    Deplev_interval = Deplev_use(:,2:end) - Deplev_use(:,1:end-1);  % 两层的差，每层的厚度
    sum_depth_avg = sum(Deplev_interval,2,"omitnan");
    coefficient = Deplev_interval./sum_depth_avg;
    Var= sum(coefficient.*var,2,"omitnan");
end


