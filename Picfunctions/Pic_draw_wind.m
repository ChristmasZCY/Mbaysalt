function Pic_draw_wind(varargin)
    % =================================================================================================================
    % discription:
    %       draw picture of wind speed and direction from netcdf file
    %       netcdf file: wind_5.nc(from standard WRF output)
    % =================================================================================================================
    % parameter:
    %       varargin{1}: date        || required: True || type: number || format: yyyymmdd
    %       varargin{2}: day length  || required: True || type: number || format: 1,2,3,4,5,6,7
    %       varargin{3}: region      || required: True || type: string || format: "scs_project","scs","ecs","global"
    % =================================================================================================================
    % example:
    %       Pic_draw_wind(str2double(char(datetime("now","Format","yyyyMMdd"))),7,"scs_project")
    %       Pic_draw_wind(20230305,1,"scs_project")
    % =================================================================================================================
    %% colorbar
    cc = make_colormap();
    %% 文件夹
    InputDir = split_dir(grep("Pic_draw.conf","Wind_Dir"));
    OutputDir = split_dir(grep("Pic_draw.conf","Output_Dir"));
    %% 区域
    [projection,lon_select,lat_select,gshhs] = select_proj_s_ll(varargin{3});
    %% 日期
    nowday=datetime(num2str(varargin{1}),"Format","yyyyMMdd");
    nowday_2=string(datetime(nowday,"Format","yyyy-MM-dd"));
    nowday=char(nowday);
    DAY_LENGTH = varargin{2};% 当天开始向后处理的天数

    %% main
    for k=0:(DAY_LENGTH-1)
        nd=char(datetime(nowday, "Format", 'yyyyMMdd') + k);
        [nd_year,nd_month,nd_day]=datevec(datetime(nd,"Format","yyyyMMdd"));
        nd_year=num2str(nd_year,'%04d');
        nd_month = num2str(nd_month,'%02d');
        nd_day = num2str(nd_day,'%02d');
        folder_name=[OutputDir, 'wind/', nd];
        makedirs(folder_name)
        ncfile = [InputDir, nd, '/wind_5.nc'];

        [lon,lat,time,U10,V10] = ncread_llt_v(ncfile,'longitude','latitude','time',[1 24],'wind_U10','wind_V10');
        disp(['预测数据的时间 --> ',char(time(1))]);

        [lon,lat,U10,V10] = region_cutout(lon_select,lat_select,lon,lat,U10,V10);

        S = sqrt(U10.^2 + V10.^2);

        Lon = lon(1:5:end); Lat = lat(1:5:end);
        [Lon,Lat] = meshgrid(Lon,Lat);

        for hour = 1:length(time)

            u10 = U10(:,:,hour);
            v10 = V10(:,:,hour);
            s = S(:,:,hour);

            figure('visible','off');%不显示图片  测试时要打开！！！
            clf

            % m_map
            m_proj(projection,'lon',lon_select,'lat',lat_select);%确定投影方式和绘图界线
            m_pcolor(lon,lat,s');
            hold on;
            m_windbarb(Lon,Lat,u10(1:5:end,1:5:end)',v10(1:5:end,1:5:end)',1.,'color','k');  % m_map包中画风羽图的代码
            m_grid;
            m_gshhs(gshhs,'linewidth',0.8,'color','black');

            % colorbar
            h = colorbar; colormap(cc);
            s_max = floor(max(S,[],'all')); s_max = s_max + mod(s_max,2);
            caxis([0 s_max]);  
            %load('color.mat');
            %colormap(CustomColormap);

            % 标题部分
            start_date = datetime(ncreadatt(ncfile,'/','start'),"format","yyyy-MM-dd_HH:mm:ss");
            start_date = char(datetime(start_date,"format","yyyy-MM-dd HH:mm:ss"));
            time_title = char(datetime(time(hour),'format','yyyy-MM-dd HH:mm:ss'));

            title("South China Sea Wind Velocity    Unit:  m/s" + ...
                    newline + ...
                    "Start: "+ start_date + " (UTC)"+ ...
                    "    Forecast: " + time_title +" " + " (UTC)", ...
                    'FontWeight','Normal','FontName','Microsoft YaHei UI' );

            ax=gca;
            ax.TitleHorizontalAlignment = 'center';
            set(gca,'TitleHorizontalAlignment','center');

            make_typhoon_warningline(24,48) % 画24 48小时台风警戒线

            time_name = char(datetime(time(hour),'format','yyyy-MM-dd''T''HHmmss'));
            txt=[folder_name, '/P_southchinasea_wind_depth_10m@',time_name,'.png'];
            export_fig(txt,'-r300','-transparent'); %保存图片
        end
    end

end
