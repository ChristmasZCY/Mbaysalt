function Pic_draw_slp(date, day_length, region, varargin)
    %       draw picture of sea level pressure from netcdf file
    %       netcdf file: slp_5.nc(from standard WRF output)
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
    %       2024-09-27:     Created,    by Wuzhou yan;
    % =================================================================================================================
    % Example:
    %       Pic_draw_slp(20230305,1,"scs_project")
    %       Pic_draw_slp(20230305,1,'ecs','conf_file','Pic_draw.conf')
    %       Pic_draw_slp(str2double(char(datetime("now","Format","yyyyMMdd"))),7,"scs_project")
    % =================================================================================================================
    
    %% 文件夹
    varargin = read_varargin(varargin, {'conf_file'},{'Pic_draw.conf'});
    conf_para = read_conf(conf_file);
    InputDir = del_filesep(conf_para.Slp_Dir);%海表面气压数据
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
        folder_name=[OutputDir, filesep, Fname_section, filesep, 'slp/', nd_year, nd_month];%可能需要海表面压力数据，暂时文件夹取名
        makedirs(folder_name)
        ncfile = [InputDir, filesep, nd, '/slp_5.nc'];  % 暂时文件取名
    
        [lon,lat,time,slp] = ncread_llt_v(ncfile,'longitude','latitude','time',[1 24],'slp'); %slp= sea level pressure
        osprint2('INFO', ['预测数据的时间 --> ',char(time(1))]);
    
        [lon,lat,slp] = region_cutout(lon_select,lat_select,lon,lat,slp);
    
        [Lon,Lat] = meshgrid(lon,lat);
    
        for hour = 1:length(time)
    
            slp = slp(:,:,hour);
    
            figure('visible','off');%不显示图片  测试时要打开！！！
            clf
    
            % m_map
            m_proj(projection,'lon',lon_select,'lat',lat_select);  % 确定投影方式和绘图界线
            slp = squeeze(slp)';
            slp = fliplr(slp/100);
            slp(slp<970)  = 965;
            slp(slp>1055) = 1060;
            [c,h] = m_contourf(Lon,Lat,slp,965:5:1060,'color',[33,33,144]/255,'linewidth',1);
            hold on;
            m_gshhs('lb1','linewidth',0.8,'color',[.5 .3 .2]);  % 陆地国界
            m_gshhs('lc1','linewidth',0.8,'color',[.5 .3 .2]);  % 海岸国界
            m_grid('tickdir','in','fontsize',10);
    
            % colorbar
            colormap(flipud(m_colmap('diverging',19)));% 重新进行填色
            clim([965 1060]);
            cbar=colorbar;
            set(cbar,'tickdir','out')
            set(cbar,'Ticks',[970:5:1055],'TickLabels',[970:5:1055],'TickLength',0,'fontsize',10,'FontWeight','bold');
            clabel(c,h,[970:5:1055],'FontSize',7,'margin',0.01,...
                'FontWeight','bold','Color','b','LabelSpacing',5000,'EdgeColor','w','BackgroundColor','w');
            ylabel(cbar,'单位(hpa)','FontWeight','bold','fontsize',8,'color',[33,33,144]/255);
    
            % 标题部分
            start_date = datetime(ncreadatt(ncfile,'/','start'),"format","yyyy-MM-dd_HH:mm:ss");
            start_date = char(datetime(start_date,"format","yyyy-MM-dd  HH:mm:ss"));
            time_title = char(datetime(time(hour),'format','yyyy-MM-dd  HH:mm'));
    
            [t,s]=title("    " + time_title,"  ", 'FontWeight','Normal','FontName','Microsoft YaHei UI');
            t.FontSize = 8;
            s.FontSize = 5;
    
            ax = gca;
            ax.TitleHorizontalAlignment = 'left';
    
            time_name = char(datetime(time(hour),'format','yyyy-MM-dd''T''HHmmss'));
            txt = [folder_name, '/P_',Fname_section,'_slp@',time_name,'.png'];
            export_fig(txt,'-r300','-transparent'); %保存图片
        end
    end

end
