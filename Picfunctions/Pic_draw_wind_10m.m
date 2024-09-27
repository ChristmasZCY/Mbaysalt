function Pic_draw_wind_10m(date, day_length, region, varargin)
    %       draw picture of wind velocity at 10 meter above the ground from netcdf file
    %       netcdf file: wind_5.nc(from standard WRF output)
    % =================================================================================================================
    % Parameter:
    %       date: date                            || required: True || type: number || format: yyyymmdd
    %       day_length: day length                || required: True || type: number || format: 1,2,3,4,5,6,7
    %       region: region                        || required: True || type: string || format: "scs_project","scs","ecs","global"
    %       varargin:
    %           conf_file: path of configure file || required: False|| type: string || format: "Pic_draw.conf"
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Updates:
    %       2023-**-**:     Created,        by Christmas;
    %       2024-09-27:     Refactoring,    by Wuzhou yan;
    % =================================================================================================================
    % Example:
    %       Pic_draw_wind_10m(20230305,1,"scs_project")
    %       Pic_draw_wind_10m(20230305,1,'ecs','conf_file','Pic_draw.conf')
    %       Pic_draw_wind_10m(str2double(char(datetime("now","Format","yyyyMMdd"))),7,"scs_project")
    % =================================================================================================================
    
    warning('off');
    %% 文件夹
    varargin = read_varargin(varargin, {'conf_file'},{'Pic_draw.conf'});
    conf_para = read_conf(conf_file);
    InputDir = del_filesep(conf_para.Wind_Dir);
    OutputDir = del_filesep(conf_para.Output_Dir);
    %% 区域:113-135E,24-42N
    Sproj = select_proj_s_ll(region);
    projection = Sproj.projection; lon_select = Sproj.lon_select; lat_select = Sproj.lat_select;
    gshhs = Sproj.gshhs; title_area = Sproj.title_area; Fname_section = Sproj.Fname_section;
    %% 日期
    nowday = datetime(num2str(date),"Format","yyyyMMdd");
    nowday = char(nowday);
    day_length = str2num(num2str(day_length));
    DAY_LENGTH = day_length;% 当天开始向后处理的天数
    
    %% main
    for k = 0:(DAY_LENGTH-1)
        nd = char(datetime(nowday, "Format", 'yyyyMMdd') + k);
        [nd_year,nd_month,nd_day] = datevec(datetime(nd,"Format","yyyyMMdd"));
        nd_year = num2str(nd_year,'%04d');
        nd_month = num2str(nd_month,'%02d');
        nd_day = num2str(nd_day,'%02d');
        folder_name=[OutputDir, filesep, Fname_section, filesep, 'wind/', nd_year, nd_month];
        makedirs(folder_name)
        ncfile = [InputDir, filesep, nd, '/wind_5.nc'];
    
        [lon,lat,time,U10,V10] = ncread_llt_v(ncfile,'longitude','latitude','time',[1 24],'wind_U10','wind_V10');
        osprint2('INFO', ['预测数据的时间 --> ',char(time(1))]);
        [lon,lat,U10,V10] = region_cutout(lon_select,lat_select,lon,lat,U10,V10);
    
        Lon = lon(1:2:end); Lat = lat(1:2:end);
        [Lon,Lat] = meshgrid(Lon,Lat);
    
        for hour = 1:length(time)
    
            u10 = U10(:,:,hour);
            v10 = V10(:,:,hour);
            uv = calc_uv2sd(u10, v10, "wind");
    
            figure('visible','off');  % 不显示图片  测试时要打开！！！
            clf
            % 将风速转为风级
            % 山东省气象台色标
            uv(uv<3.4) = 0;
            uv(uv>=3.4  & uv<5.4) = 1;
            uv(uv>=5.4  & uv<8.0) = 2;
            uv(uv>=8.0  & uv<10.8) = 3;
            uv(uv>=10.8 & uv<13.9) = 4;
            uv(uv>=13.9 & uv<17.2) = 5;
            uv(uv>=17.2 & uv<20.8) = 6;
            uv(uv>=20.8 & uv<24.5) = 7;
            uv(uv>=24.5 & uv<28.5) = 8;
            uv(uv>=28.5) = 9;
            level = [0,3.4,5.5,8.0,10.8,13.9,17.2,20.8,24.5,28.5];
    
            % m_map
            m_proj(projection,'lon',lon_select,'lat',lat_select);  % 确定投影方式和绘图界线
            m_contourf(lon,lat,uv',0:9,'linestyle','none');
            hold on;
            m_windbarb(Lon,Lat,u10(1:2:end,1:2:end)',v10(1:2:end,1:2:end)',1.6,'units','m/s','linewi',0.3,'color','k');
            m_grid('box','fancy','tickdir','in','fontsize',6);
            m_gshhs('ib1','linewidth',0.8,'color',[.5 .3 .2]);  % 陆地国界
            m_gshhs('ic1','linewidth',0.8,'color',[.5 .3 .2]);  % 海岸国界
    
            % colorbar
            cmap = [255 255 255;166 255 255;55 251 215;69 234 0;235 249 0;254 216 0;255 162 1;249 108 0;219 38 9;223 90 86]/255;%山东省色标
            colormap(cmap);  % 重新进行填色
            clim([0 length(level)]) ;
            cbar = colorbar;
            set(cbar,'Ticks',0:length(level)-1,'TickLabels',level,'TickLength',0,'fontsize',10,'FontWeight','bold') ;
            ylabel(cbar,'单位(m/s)','FontWeight','bold','fontsize',8,'color','k');
    
            % 标题部分
            start_date = datetime(ncreadatt(ncfile,'/','start'),"format","yyyy-MM-dd_HH:mm:ss");
            start_date = char(datetime(start_date,"format","yyyy-MM-dd  HH:mm:ss"));
            time_title = char(datetime(time(hour),'format','yyyy-MM-dd  HH:mm'));
    
            [t,s]=title("    " + time_title,"  ", 'FontWeight','Normal','FontName','Microsoft YaHei UI');
            t.FontSize = 8;
            s.FontSize = 5;
    
            ax = gca;
            ax.TitleHorizontalAlignment = 'left';
            % make_typhoon_warningline(24,48) % 画24 48小时台风警戒线
    
            time_name = char(datetime(time(hour),'format','yyyy-MM-dd''T''HHmmss'));
            txt=[folder_name, '/P_',Fname_section,'_wind_depth_10m@',time_name,'.png'];
            export_fig(txt,'-r300','-transparent'); %保存图片
        end
    end

end
