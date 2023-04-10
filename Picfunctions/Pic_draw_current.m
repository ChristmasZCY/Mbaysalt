function Pic_draw_current(varargin)
    % =================================================================================================================
    % discription:
    %       draw picture of daily mean current velocity from netcdf file
    %       netcdf file: current_10.nc(from standard FVCOM output)
    % =================================================================================================================
    % parameter:
    %       varargin{1}: date        || required: True || type: number || format: yyyymmdd
    %       varargin{2}: day length  || required: True || type: number || format: 1,2,3,4,5,6,7
    %       varargin{3}: region      || required: True || type: string || format: "scs_project","scs","ecs","global"
    %       varargin{4}: interval    || required: True || type: string || format: "daily","hourly"
    %       varargin{5}: depth level || required: True || type: number || format: 1,2,3,4,5,6,7,8,9,10
    % =================================================================================================================
    % example:
    %       Pic_draw_current(str2double(char(datetime("now","Format","yyyyMMdd"))),7,"scs_project","daily",1)
    %       Pic_draw_current(20230305,1,"scs_project","daily",1)
    % =================================================================================================================
    %% colorbar
    % cc=load("/home/ocean/Oceanmax/Data/input/MarginalSea/SCS/RGB.mat").RGB.wh_bl_gr_ye_re;
    cc = make_colormap();
    %% 文件夹
    Current_Dir = split_dir(grep("Pic_draw.conf","Current_Dir"));
    InputDir = [Current_Dir,char(varargin{4})];
    OutputDir = split_dir(grep("Pic_draw.conf","Output_Dir"));
    %% 区域
    [projection,lon_select,lat_select,gshhs] = select_proj_s_ll(varargin{3});
    %% 日期
    nowday=datetime(num2str(varargin{1}),"Format","yyyyMMdd");
    nowday_2=string(datetime(nowday,"Format","yyyy-MM-dd"));
    nowday=char(nowday);
    DAY_LENGTH = varargin{2};% 当天开始向后处理的天数
    d_level = varargin{5};

    %% main
    for k=0:(DAY_LENGTH-1)
        nd=char(datetime(nowday, "Format", 'yyyyMMdd') + k);
        [nd_year,nd_month,nd_day]=datevec(datetime(nd,"Format","yyyyMMdd"));
        nd_year=num2str(nd_year,'%04d');
        nd_month = num2str(nd_month,'%02d');
        nd_day = num2str(nd_day,'%02d');
        if strcmp(varargin{4},"daily")
            folder_name=[OutputDir, 'current_daily/', nd];
        elseif strcmp(varargin{4},"hourly")
            folder_name=[OutputDir, 'current_hourly/', nd];
        end
        makedirs(folder_name)
        ncfile = [InputDir,'/',nd,'/current_10.nc'];
        if strcmp(varargin{4},"daily")
            [lon,lat,depth,time,Water_u,Water_v] = ncread_lltd_v(ncfile,'longitude','latitude','depth','time',[d_level,1],[1 1],'u','v');
        elseif strcmp(varargin{4},"hourly")
            [lon,lat,depth,time,Water_u,Water_v] = ncread_lltd_v(ncfile,'longitude','latitude','depth','time',[d_level,1],[1 24],'u','v');
        end
        disp(['预测数据的时间 --> ',char(time(1))]);

        [lon,lat,Water_u,Water_v] = region_cutout(lon_select,lat_select,lon,lat,Water_u,Water_v);

        S = sqrt(Water_u.^2 + Water_v.^2);

        Lon = lon(1:5:end); Lat = lat(1:5:end);
        [Lon,Lat] = meshgrid(Lon,Lat);

        for hour = 1:length(time)
            water_u = Water_u(:,:,hour);
            water_v = Water_v(:,:,hour);
            s = S(:,:,hour);

            figure('visible','off');
            clf

            % m_map
            m_proj(projection,'lon',lon_select,'lat',lat_select);%确定投影方式和绘图界线
            m_pcolor(lon,lat,s');
            hold on;
            m_quiver(Lon,Lat,water_u(1:5:end,1:5:end)',water_v(1:5:end,1:5:end)',1,'color','k',"LineWidth",1);
            m_grid;
            m_gshhs(gshhs,'linewidth',0.8,'color','black');

            % colorbar
            h = colorbar; colormap(cc);
            caxis([0.1 1]);
            %load('color.mat');
            %colormap(CustomColormap);

            % 标题部分
            start_date = datetime(ncreadatt(ncfile,'/','start'),"format","yyyy-MM-dd_HH:mm:ss");
            start_date = char(datetime(start_date,"format","yyyy-MM-dd HH:mm:ss"));
            time_name = char(datetime(time(hour),'format','yyyy-MM-dd''T''HHmmss'));
            time_title = char(datetime(time(hour),'format','yyyy-MM-dd HH:mm:ss'));

            if strcmp(varargin{4},"daily")
                title("Daily Mean Current Velocity of South China Seas level="+ num2str(d_level) + "   Unit:  m/s" + ...
                newline + ...
                "Start: "+ start_date + " (UTC)"+ ...
                "    Forecast: " + time_title +" " + " (UTC)", ...
                'FontWeight','Normal','FontName','Microsoft YaHei UI' );
            elseif strcmp(varargin{4},"hourly")
                title("Instant Current Velocity of South China Seas level="+ num2str(d_level) + "   Unit:  m/s" + ...
                newline + ...
                "Start: "+ start_date + " (UTC)"+ ...
                "    Forecast: " + time_title +" " + " (UTC)", ...
                'FontWeight','Normal','FontName','Microsoft YaHei UI' );
            end
        txt=[folder_name,'/P_southchinasea_current',char(varargin{4}),'_level_' , num2str(d_level) ,'@',time_name,'.png'];
        export_fig(txt,'-r300','-transparent'); %保存图片
    end

end