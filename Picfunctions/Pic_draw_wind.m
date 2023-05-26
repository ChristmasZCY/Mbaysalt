function Pic_draw_wind(date, day_length, region, varargin)
    % =================================================================================================================
    % discription:
    %       draw picture of wind speed and direction from netcdf file
    %       netcdf file: wind_5.nc(from standard WRF output)
    % =================================================================================================================
    % parameter:
    %       date: date                            || required: True || type: number || format: yyyymmdd
    %       day_length: day length                || required: True || type: number || format: 1,2,3,4,5,6,7
    %       region: region                        || required: True || type: string || format: "scs_project","scs","ecs","global"
    %       varargin:
    %           conf_file: path of configure file || required: False|| type: string || format: "Pic_draw.conf"
    % =================================================================================================================
    % example:
    %       Pic_draw_wind(str2double(char(datetime("now","Format","yyyyMMdd"))),7,"scs_project")
    %       Pic_draw_wind(20230305,1,'ecs','Pic_draw.conf')
    %       Pic_draw_wind(20230305,1,"scs_project")
    %
    % =================================================================================================================
    warning('off');
    %% colorbar
    cc = make_colormap('2');
    %% 文件夹
    varargin = read_varargin(varargin, {'conf_file'},{'Pic_draw.conf'});
    conf_para = read_conf(conf_file);
    InputDir = split_path(conf_para.Wind_Dir);
    OutputDir = split_path(conf_para.Output_Dir);
    %% 区域
    [projection,lon_select,lat_select,gshhs,title_area,Fname_section] = select_proj_s_ll(region);
    %% 日期
    nowday = datetime(num2str(date),"Format","yyyyMMdd");
    nowday = char(nowday);
    day_length = str2num(day_length);
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
        osprints('INFO', ['预测数据的时间 --> ',char(time(1))]);

        [lon,lat,U10,V10] = region_cutout(lon_select,lat_select,lon,lat,U10,V10);

        S = sqrt(U10.^2 + V10.^2);

        Lon = lon(1:2:end); Lat = lat(1:2:end);
        [Lon,Lat] = meshgrid(Lon,Lat);

        for hour = 1:length(time)

            u10 = U10(:,:,hour);
            v10 = V10(:,:,hour);
            s = S(:,:,hour);

            figure('visible','off');%不显示图片  测试时要打开！！！
            clf

            % m_map
            m_proj(projection,'lon',lon_select,'lat',lat_select);%确定投影方式和绘图界线
            % m_pcolor(lon,lat,s');
            [C,h]=m_contourf(lon,lat,s',4:2:16,'ShowText','on');  %,'edgecolor','none'
            clabel(C,h,'FontSize',6)
            hold on;
            m_windbarb(Lon,Lat,u10(1:2:end,1:2:end)',v10(1:2:end,1:2:end)', .8,'units','m/s','linewi',0.3,'color','k');  % m_map包中画风羽图的代码
            m_grid('box','fancy','tickdir','out','fontsize',6);
            m_gshhs(gshhs,'color','black');

            % colorbar
            h = colorbar; colormap(cc);
            s_max = floor(max(S,[],'all')); s_max = s_max + mod(s_max,2);
            % caxis([0 s_max]);
            clim([3.8 16.2])
            h.FontSize=6;
            set(get(h, 'Title'), 'string', '[m/s]');
            num2str(4:1:16);
            set(h,'YTick',4:1:16);
            set(h,'YTickLabel',{'<4','5','6','7','8','9','10','11','12','13','14','15','>16'});
            %load('color.mat');
            %colormap(CustomColormap);

            % 标题部分
            start_date = datetime(ncreadatt(ncfile,'/','start'),"format","yyyy-MM-dd_HH:mm:ss");
            start_date = char(datetime(start_date,"format","yyyy-MM-dd  HH:mm:ss"));
            time_title = char(datetime(time(hour),'format','yyyy-MM-dd  HH:mm'));

            [t,s]=title("    " + time_title,"  ", ...
                 'FontWeight','Normal','FontName','Microsoft YaHei UI');
            t.FontSize = 8;
            s.FontSize = 5;

            ax=gca;
            ax.TitleHorizontalAlignment = 'left';

            % make_typhoon_warningline(24,48) % 画24 48小时台风警戒线

            time_name = char(datetime(time(hour),'format','yyyy-MM-dd''T''HHmmss'));
            txt=[folder_name, '/P_',Fname_section,'_wind_depth_10m@',time_name,'.png'];
            export_fig(txt,'-r300','-transparent'); %保存图片
        end
    end

end
