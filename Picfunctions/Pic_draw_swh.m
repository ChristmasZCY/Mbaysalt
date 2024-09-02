function Pic_draw_swh(date, day_length, region, varargin)
    %       draw picture of significant wave height and direction from netcdf file
    %       netcdf file: wave_5.nc(from standard WW3 output)
    % =================================================================================================================
    % Parameter:
    %       date: date                            || required: True || type: number || format: yyyymmdd
    %       day_length: day length                || required: True || type: number || format: 1,2,3,4,5,6,7
    %       region: region                        || required: True || type: string || format: "scs_project","scs","ecs","global"
    %       varargin:
    %           conf_file: path of configure file || required: False|| type: string || format: "Pic_draw.conf"
    % =================================================================================================================
    % Example:
    %       Pic_draw_swh(str2double(char(datetime("now","Format","yyyyMMdd"))),7,"scs_project")
    %       Pic_draw_swh(20230305,1,'ecs','conf_file','Pic_draw.conf')
    %       Pic_draw_swh(20230305,1,"scs_project")
    % =================================================================================================================

    warning('off');
    %% colorbar
    cc = make_colormap('2');
    %% 文件夹
    varargin = read_varargin(varargin, {'conf_file'},{'Pic_draw.conf'});
    conf_para = read_conf(conf_file);
    InputDir = del_filesep(conf_para.Wave_Dir);
    OutputDir = del_filesep(conf_para.Output_Dir);
    %% 区域
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
        folder_name = [OutputDir, filesep, Fname_section, filesep, 'swh/', nd_year, nd_month];
        makedirs(folder_name)
        ncfile = [InputDir, filesep, nd, '/wave_5.nc'];

        [lon,lat,time,Swh,Mwd] = ncread_llt_v(ncfile,'longitude','latitude','time',[1 24],'swh','mwd');
        osprint2('INFO', ['预测数据的时间 --> ',char(time(1))]);

        [lon,lat,Swh,Mwd] = region_cutout(lon_select,lat_select,lon,lat,Swh,Mwd);

        caxis_max = ceil(max(Swh,[],'all'));
        caxis_min = floor(min(Swh,[],'all'));

        Lon = lon(1:2:end); Lat = lat(1:2:end);
        [Lon,Lat] = meshgrid(Lon,Lat);

        for hour = 1:length(time)

            swh = Swh(:,:,hour);
            mwd = Mwd(:,:,hour);
            u = sin(deg2rad(mwd+180)); % U 表示风浪的去向 (U,V)=(1,0)表示风从西往东吹，浪从西往东流
            v = cos(deg2rad(mwd+180)); % V 表示风浪的去向 (U,V)=(1,0)表示风从西往东吹，浪从西往东流

            figure('visible','off');
            levels_contour = 0.5:0.5:3;
            clf

            % m_map
            m_proj(projection,'lon',lon_select,'lat',lat_select);%确定投影方式和绘图界线
            m_pcolor(lon,lat,swh'); %绘制等值线
            m_vec(20,Lon,Lat,u(1:2:end,1:2:end)',v(1:2:end,1:2:end)','shaftwidth',0.2,'headlength',1.4,'edgeclip','on');  % 包中画波高的函数
            hold on;
            [C,h] = m_contour(lon,lat,swh',levels_contour,'color','k','showtext','on');
            clabel(C,h,'FontSize',8)
            m_gshhs(gshhs,'patch',[0.8 0.8 0.8],'EdgeColor','k');
            m_grid('box','fancy','tickdir','out','fontsize',6);
            hold off;

            % colorbar
            h = colorbar; colormap(cc);
            clim([0.05 3.15])
            h.FontSize = 6;
            set(get(h, 'Title'), 'string', '[m]');
            h.Position(1) = 0.77;
            h.Position(3)=0.03;
            h.FontSize=6;
            set(h,'YTick',[0.1:0.5:3.1]);
            set(h,'YTickLabel',{'<0.1','0.5','1','1.5','2','2.5','>3'});

            % 标题部分
            start_date = datetime(ncreadatt(ncfile,'/','start'),"format","yyyy-MM-dd_HH:mm:ss");
            start_date = char(datetime(start_date,"format","yyyy-MM-dd HH:mm:ss"));
            time_title = char(datetime(time(hour),'format','yyyy-MM-dd HH:mm:ss'));

            [t,s]=title("    " + time_title,"  ", 'FontWeight','Normal','FontName','Microsoft YaHei UI');
            t.FontSize = 8;
            s.FontSize = 5;

            ax = gca;
            ax.TitleHorizontalAlignment = 'left';

            time_name = char(datetime(time(hour),'format','yyyy-MM-dd''T''HHmmss'));
            txt=[folder_name, '/P_',Fname_section,'_swh_level_1@',time_name,'.png'];
            export_fig(txt,'-r300','-transparent'); %保存图片
        end
    end

end

