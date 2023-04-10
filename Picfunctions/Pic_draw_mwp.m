function Pic_draw_mwp(varargin)
    % =================================================================================================================
    % discription:
    %       draw picture of mwp and mwd from netcdf file
    %       netcdf file: wave_5.nc(from standard WW3 output)
    % =================================================================================================================
    % parameter:
    %       varargin{1}: date        || required: True || type: number || format: yyyymmdd
    %       varargin{2}: day length  || required: True || type: number || format: 1,2,3,4,5,6,7
    %       varargin{3}: region      || required: True || type: string || format: "scs_project","scs","ecs","global"
    % =================================================================================================================
    % example:
    %       Pic_draw_mwp(str2double(char(datetime("now","Format","yyyyMMdd"))),7,"scs_project")
    %       Pic_draw_mwp(20230305,1,"scs_project")
    % =================================================================================================================
    %% colorbar
    cc = make_colormap();
    %% 文件夹
    InputDir = split_dir(grep("Pic_draw.conf","Wave_Dir"));
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
        folder_name=[OutputDir, 'mwp/', nd];
        makedirs(folder_name)
        ncfile = [InputDir, nd, '/wave_5.nc'];

        [lon,lat,time,Mwp,Mwd] = ncread_llt_v(ncfile,'longitude','latitude','time',[1 24],'mwp','mwd');
        disp(['预测数据的时间 --> ',char(time(1))]);

        [lon,lat,Mwp,Mwd] = region_cutout(lon_select,lat_select,lon,lat,Mwp,Mwd);

        caxis_max=ceil(max(Mwp,[],'all'));
        caxis_min=floor(min(Mwp,[],'all'));

        Lon = lon(1:8:end); Lat = lat(1:8:end);
        [Lon,Lat] = meshgrid(Lon,Lat);

        for hour = 1:length(time)

            mwp = Mwp(:,:,hour);      
            mwd = Mwd(:,:,hour);
            u = sin(deg2rad(mwd+180)); % U 表示风浪的去向 (U,V)=(1,0)表示风从西往东吹，浪从西往东流
            v = cos(deg2rad(mwd+180)); % V 表示风浪的去向 (U,V)=(1,0)表示风从西往东吹，浪从西往东流

            levels=20;
            figure('visible','off');
            clf

            % m_map
            m_proj(projection,'lon',lon_select,'lat',lat_select);%确定投影方式和绘图界线
            m_contourf(lon,lat,mwp',levels,'linestyle','none'); %绘制等高线
            hold on;
            m_quiver(Lon,Lat,u(1:8:end,1:8:end)',v(1:8:end,1:8:end)',0.6,'color','k');
            m_grid;
            m_gshhs(gshhs,'linewidth',0.8,'color','black');

            % colorbar
            h = colorbar; colormap(cc);
            caxis([caxis_min caxis_max]);  
            %load('color.mat');
            %colormap(CustomColormap);

            % 标题部分
            start_date = datetime(ncreadatt(ncfile,'/','start'),"format","yyyy-MM-dd_HH:mm:ss");
            start_date = char(datetime(start_date,"format","yyyy-MM-dd HH:mm:ss"));
            time_title = char(datetime(time(hour),'format','yyyy-MM-dd HH:mm:ss'));
            
            title("South China Sea Wave Mean Period   Unit: s "+...
                    newline+...
                    "Start: "+ start_date + " (UTC)"+ ...
                    "    Forecast: " + time_title +" " + " (UTC)", ...
                    'FontWeight','Normal','FontName','Microsoft YaHei UI'  );

            ax=gca;
            ax.TitleHorizontalAlignment = 'center';
            set(gca,'TitleHorizontalAlignment','center');

            time_name = char(datetime(time(hour),'format','yyyy-MM-dd''T''HHmmss'));
            txt=[folder_name,'/P_southchinasea_mwp_level_1@',time_name,'.png'];
            export_fig(txt,'-r300','-transparent'); %保存图片

        end
    end

end
