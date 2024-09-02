function Pic_draw_precipitation(date, day_length, region, varargin)
    %       draw picture of precipitation from netcdf file
    %       netcdf file: precipitation_5.nc(from standard WRF output)
    % =================================================================================================================
    % Parameter:
    %       date: date                            || required: True || type: number || format: yyyymmdd
    %       day_length: day length                || required: True || type: number || format: 1,2,3,4,5,6,7
    %       region: region                        || required: True || type: string || format: "scs_project","scs","ecs","global"
    %       varargin:
    %           conf_file: path of configure file || required: False|| type: string || format: "Pic_draw.conf"
    % =================================================================================================================
    % Example:
    %       Pic_draw_precipitation(str2double(char(datetime("now","Format","yyyyMMdd"))),7,"scs_project")
    %       Pic_draw_precipitation(20230305,1,'ecs','conf_file','Pic_draw.conf')
    %       Pic_draw_precipitation(20230305,1,"scs_project")
    % =================================================================================================================

    warning('off');
    %% colorbar
    % cc = load('color_precipitation.mat').color;
    cc = make_colormap('2');
    %% 文件夹
    varargin = read_varargin(varargin, {'conf_file'},{'Pic_draw.conf'});
    conf_para = read_conf(conf_file);
    InputDir = del_filesep(conf_para.Precipitation_Dir);
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
        folder_name = [OutputDir, filesep, Fname_section, filesep, 'precipitation/', nd_year, nd_month];
        makedirs(folder_name)
        ncfile = [InputDir, filesep, nd, '/precipitation_5.nc'];

        try
            [lon,lat,time,Precipitation] = ncread_llt_v(ncfile,'longitude','latitude','time',[1 24],'precipitation');
        catch
            osprint2('ERROR', ['读取文件失败 --> ',nd, '/precipitation_5.nc'])
            continue
        end
        osprint2('INFO', ['预测数据的时间 --> ',char(time(1))]);

        [lon,lat,Precipitation] = region_cutout(lon_select,lat_select,lon,lat,Precipitation);

        [Lon,Lat] = meshgrid(lon,lat);

        for hour = 1:length(time)

            precipitation = Precipitation(:,:,hour);

            figure('visible','off');
            clf

            % m_map
            m_proj(projection,'lon',lon_select,'lat',lat_select);%确定投影方式和绘图界线
            m_pcolor(lon,lat,precipitation')
            shading interp
            hold on
            m_contour(Lon,Lat,precipitation',[2,4,6],'color','k','showtext','on');
            m_gshhs(gshhs,'color','k');
            m_grid('box','fancy','tickdir','out','fontsize',6);

            % colorbar
            h = colorbar; colormap(cc);
            set(get(h,'Title'),'string','[mm]');
            clim([0.05 6.15])
            set(h,'YTick',[0.1:1:6.1]);
            set(h,'YTickLabel',{'<0.1','1','2','3','4','5','>6'});

            %% 标题部分
            start_date = datetime(ncreadatt(ncfile,'/','start'),"format","yyyy-MM-dd_HH:mm:ss");
            start_date = char(datetime(start_date,"format","yyyy-MM-dd HH:mm:ss"));
            time_title = char(datetime(time(hour),'format','yyyy-MM-dd HH:mm:ss'));

            [t,s]=title("    " + time_title,"  ", ...
                 'FontWeight','Normal','FontName','Microsoft YaHei UI');
            t.FontSize = 8;
            s.FontSize = 5;

            ax = gca;
            ax.TitleHorizontalAlignment = 'left';

            time_name = char(datetime(time(hour),'format','yyyy-MM-dd''T''HHmmss'));
            txt=[folder_name,'/P_southchinasea_precipitation_level_1@',time_name,'.png'];
            export_fig(txt,'-r300','-transparent'); %保存图片
        end
    end

end


