function Postprocess_nemuro(conf_file, interval, yyyymmdd, day_length, varargin)
    %       This function is used to postprocess the nemuro output netcdf files, contains daily/hourly.
    % =================================================================================================================
    % Parameter:
    %       conf_file: configure file                 || required: True || type: string  || format: 'Post_nemuro.conf'
    %       interval: interval                        || reauired: True || type: string  || format: 'daily','hourly'
    %       yyyymmdd: date                            || required: True || type: double. || format: 20221110
    %       day_length: length of date                || required: True || type: double  || format: 5
    % =================================================================================================================
    % Example:
    %       Postprocess_nemuro('Post_nemuro.conf','daily',20230410,1)
    %       Postprocess_nemuro('Post_nemuro.conf','hourly',20230410,1)
    % =================================================================================================================

    Version = '2.0';

    %% 读取
    tic % 计时开始
    switch interval
        case {'daily','hourly'}
            interval = char(interval); % daily hourly
        otherwise
            error("interval must be 'daily' or 'hourly'")
    end

    para_conf = read_conf(conf_file);
    Inputpath = para_conf.ModelOutputDir;
    Outputpath = para_conf.StandardDir;
    file_ncmask = para_conf.MaskncFile;
    file_matmask = para_conf.MaskmatFile;
    file_Mcasename = para_conf.ModelCasename;
    OutputRes = para_conf.OutputRes;
    ResName = num2str(para_conf.ResName);
    switch_ww = para_conf.Switch_ww;
    switch_make_weight = para_conf.Switch_make_Weight;
    Method_interpn = para_conf.Method_interpn;
    lon = para_conf.Lon_source;
    lat = para_conf.Lat_source;
    switch_warning = para_conf.Switch_warningtext;
    switch_to_std_level = para_conf.Switch_to_std_level;
    switch_change_maxlon = para_conf.Switch_change_MaxLon;
    switch_daily_1hour = para_conf.Switch_daily_1hour;
    switch_read_ll_from_nc = para_conf.Switch_read_ll_from_nc;
    ll_file = para_conf.LLFile;
    makedirs(para_conf.TemporaryDir)

    if switch_warning;warning('on');else; warning('off');end

    if switch_to_std_level
        osprint('Transfor to standard level --> TRUE')
        Depth_std = para_conf.Depth;
    else
        osprint('Transfor to standard level --> FALSE')
    end

    getdate=datetime(num2str(yyyymmdd),"format","yyyyMMdd");
    Length = day_length;% 当天开始向后处理的天数
    makedirs(Outputpath) % 创建文件夹

    osprint(['Date parameter --> ',char(getdate),' total transfor ',num2str(Length),' days'])
    osprint(['Method --> ',Method_interpn])
    osprint(['Transfor ', interval ,' variable --> pp zp no3 sand'])

    for dr=1:Length
        dr1=dr-1;
        deal_date_dt=dateshift(getdate,'start','day',dr1);
        deal_date=char(datetime(deal_date_dt,"format","yyyyMMdd"));
        if strcmp(interval,"daily")
            ncfile = fullfile(Inputpath,[char(getdate),'/forecast/',file_Mcasename,'_avg_',num2str(dr,'%04d'),'.nc']); % 输入文件
        elseif strcmp(interval,"hourly")
            ncfile = fullfile(Inputpath,[char(getdate),'/forecast/',file_Mcasename,'_',num2str(dr,'%04d'),'.nc']); % 输入文件
        end

        OutputDir_chlo=fullfile(Outputpath,'chlorophyll',interval,deal_date); % 输出路径
        OutputDir_no3=fullfile(Outputpath,'no3',interval,deal_date); % 输出路径
        OutputDir_pp=fullfile(Outputpath,'phytoplankton',interval,deal_date); % 输出路径
        OutputDir_zp=fullfile(Outputpath,'zooplankton',interval,deal_date); % 输出路径
        OutputDir_sand=fullfile(Outputpath,'sand',interval,deal_date); % 输出路径
        makedirs(OutputDir_chlo,OutputDir_no3,OutputDir_pp,OutputDir_zp,OutputDir_sand); % 创建文件夹

        clear deal_date_dt deal_date % 日期处理中间变量

        if dr == 1
            if switch_read_ll_from_nc
                % read grid
                f_nc = f_load_grid(ncfile,'Coordinate', 'Geo');
                save(ll_file, 'f_nc', '-v7.3');
            else
                f_nc = load(ll_file).f_nc;
            end
        end
        clear dr1 dr

        % read nc file
        ps = double(ncread(ncfile,'PS')); % PS 小型浮游植物
        pl = double(ncread(ncfile,'PL')); % PL 大型浮游植物
        zp = double(ncread(ncfile,'ZP')); % ZP 食肉浮游动物
        zs = double(ncread(ncfile,'ZS')); % ZS 小型浮游动物
        zl = double(ncread(ncfile,'ZL')); % ZL 大型浮游动物
        no3 = double(ncread(ncfile,'NO3')); % NO3 氮氧化物
        cs = double(ncread(ncfile,'coarse_sand')); % cs 粗沙
        ms = double(ncread(ncfile,'medium_sand')); % ms 中沙
        fs = double(ncread(ncfile,'fine_sand')); % fs 细沙

        pp = ps+pl; % phytoplankton pp 浮游植物
        zp = zp+zs+zl; % zooplankton zp 浮游动物
        sand = cs+ms+fs; % 沙质
        clear ps pl zs zl   ps pl   cs ms fs

        Time = ncread(ncfile,'Times')';
        % Time = datetime(1858,11,17)+ hours(Itime*24 + Itime2/(3600*1000));

        % switch Method_interpn
        %     case {'Siqi_interp', 'Siqi_ESMF'}
        %         u_int = f_interp_cell2node(f_nc, u);
        %         v_int = f_interp_cell2node(f_nc, v);
        %         clear u v

        %         if switch_ww
        %             w = double(ncread(ncfile, 'ww'));
        %             w_int = f_interp_cell2node(f_nc, w);
        %             clear w
        %         end
        % end

        switch Method_interpn
            case {'Siqi_interp', 'Siqi_ESMF'}
                if switch_to_std_level

                    %weight
                    file_weight_vertical = para_conf.WeightFile_vertical;

                    if switch_make_weight
                        tic
                        Weight_vertical = interp_vertical_calc_weight(f_nc.deplay,repmat(Depth_std,f_nc.node,1));
                        delete (file_weight_vertical)
                        save(file_weight_vertical, 'Weight_vertical', '-v7.3');
                        toc
                    else
                        Weight_vertical = load(file_weight_vertical).Weight_vertical;
                    end

                        pp1 = zeros(f_nc.node,length(Depth_std),size(pp,3));
                        zp1 = zeros(f_nc.node,length(Depth_std),size(zp,3));
                        no31 = zeros(f_nc.node,length(Depth_std),size(no3,3));
                        sand1 = zeros(f_nc.node,length(Depth_std),size(sand,3));

                        for it = 1:size(pp,3)
                            pp1(:,:,it) = interp_vertical_via_weight(pp(:,:,it),Weight_vertical);
                            zp1(:,:,it) = interp_vertical_via_weight(zp(:,:,it),Weight_vertical);
                            no31(:,:,it) = interp_vertical_via_weight(no3(:,:,it),Weight_vertical);
                            sand1(:,:,it) = interp_vertical_via_weight(sand(:,:,it),Weight_vertical);
                        end
                        clear pp zp no3 sand
                        pp = pp1; zp = zp1; no3 = no31; sand = sand1;
                        clear pp1 zp1 no31 sand1
                end
        end

        if strcmp(interval,"daily")
            if switch_daily_1hour
                Time = datetime(Time,'Format','yyyy-MM-dd''T''HH:mm:ssSSSSSS') - 1;
            else
                Time = datetime(Time,'Format','yyyy-MM-dd''T''HH:mm:ssSSSSSS');
            end
        elseif strcmp(interval,"hourly")
            Time = datetime(Time,'Format','yyyy-MM-dd''T''HH:mm:ssSSSSSS');
        end
        
        time = posixtime(Time); % POSIX时间 1970 01 01 shell的date +%s

        Lon=lon;Lat=lat;


        switch Method_interpn
            case 'Siqi_interp'

                % weight
                file_weight = para_conf.WeightFile_Siqi_interp;

                if switch_make_weight
                    [Lat,Lon] = meshgrid(Lat,Lon);
                    tic
                    Weight_2d = interp_2d_calc_weight('TRI',f_nc.LON,f_nc.LAT,f_nc.nv,Lon,Lat);
                    delete (file_weight)
                    save(file_weight,'Weight_2d','-v7.3');
                    Lon=lon;Lat=lat;
                    toc
                else
                    Weight_2d = load(file_weight).Weight_2d;
                end

                Pp = interp_2d_via_weight(pp,Weight_2d);
                Zp = interp_2d_via_weight(zp,Weight_2d);
                No3 = interp_2d_via_weight(no3,Weight_2d);
                Sand = interp_2d_via_weight(sand,Weight_2d);
                Depth = interp_2d_via_weight(f_nc.deplay,Weight_2d);
                clear pp zp no3 sand

                % if switch_ww
                %     W = interp_2d_via_weight(w_int,Weight_2d);
                %     clear w_int
                % end

                
            case 'Siqi_ESMF'

                % weight
                file_weight = para_conf.WeightFile_Siqi_ESMF;

                if switch_make_weight

                    exe = para_conf.ESMF_exe;
                    % ESMFMAFILE = para_conf.ESMF_MAFILE;
                    GridFile_fvcom = para_conf.GridFile_fvcom;
                    GridFile_wrf = para_conf.GridFile_wrf;
                    ESMF_NCweightfile = para_conf.ESMF_NCweightfile;
                    ESMF_RegridMethod = para_conf.ESMF_RegridMethod;
                    [Lat,Lon] = meshgrid(Lat,Lon);
                    tic
                    esmf_write_grid(GridFile_fvcom , 'FVCOM', f_nc.LON,f_nc.LAT,f_nc.nv);
                    esmf_write_grid(GridFile_wrf, 'WRF', Lon,Lat);
                    esmf_regrid_weight(GridFile_fvcom, GridFile_wrf, ESMF_NCweightfile, ...
                                        'exe', exe, 'Src_loc', 'corner', 'Method', ESMF_RegridMethod); % temperature corner
                    Weight_2d = esmf_read_weight(ESMF_NCweightfile);
                    delete (file_weight)
                    save(file_weight,'Weight_2d','-v7.3');
                    Lon=lon;Lat=lat;
                    toc
                    clear GridFile_fvcom GridFile_wrf ESMF_NCweightfile
                else
                    Weight_2d = load(file_weight).Weight_2d;
                end

                    for iz = 1 : size(pp,2)
                        for it = 1: size(pp,3)
                            Pp(:,:,iz,it) =  esmf_regrid(pp(:,iz,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                            Zp(:,:,iz,it) =  esmf_regrid(zp(:,iz,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                            No3(:,:,iz,it) =  esmf_regrid(no3(:,iz,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                            Sand(:,:,iz,it) =  esmf_regrid(sand(:,iz,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                            Depth(:,:,iz) =  esmf_regrid(f_nc.deplay(:,iz),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                            % if switch_ww
                            %     W(:,:,iz,it) =  esmf_regrid(w_int(:,iz,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                            % end
                        end
                    end
                    clear pp zp no3 sand


            case 'Christmas_interp'

                parpool(20)

                % read grid
                lonc = f_nc.xc;
                latc = f_nc.yc;
                lon = f_nc.x;
                lat = f_nc.y;
                h = f_nc.h;
                siglay = double(ncread(ncfile,'siglay',[1,1],[1,Inf]));

                % mask
                switch_make_mask = para_conf.Switch_make_mask;
                if switch_make_mask
                    make_maskmat(file_ncmask,Lon,Lat,file_matmask);
                end

                [Depth,Pp,Zp,No3,Sand]=griddata_fvcom.griddata_node(lon,lat,time,h,siglay,Lon,Lat,pp,zp,no3,sand);
                clear lonc latc h siglay pp zp no3 sand

                [Pp,Zp,No3,Sand,Depth] = mask2data(file_matmask,Pp,Zp,No3,Sand,Depth);

            otherwise
                error('Method_interpn error')
    
            end

        %% make std depth
        if switch_to_std_level
            Depth = Depth_std;
        else
            [~,Depth] = ll_to_ll(Lon,Depth);
        end

        %% change 0-360 to -180-180
        if switch_change_maxlon
            [Lon,Pp,Zp,No3,Sand] = ll_to_ll(Lon,Pp,Zp,No3,Sand);
        end

        clear ncfile

        Chlo = 1.59*(Pp); % 叶绿素

        % Depth_std_nc = repmat(Depth_std,[length(Lon),1,length(Lat)]);
        % Depth = permute(Depth_std_nc,[1,3,2]);


        %% global attribute start
        GA_start_date = [char(datetime("now","Format","yyyy-MM-dd")), '_00:00:00'];

        %% 写入
        file = fullfile(OutputDir_chlo,['chlorophyll',OutputRes,'.nc']);
        ncid = netcdf_fvcom.create_nc(file,'NETCDF4');
        netcdf_nemuro.wrnc_chlorophyll(ncid,Lon,Lat,Depth,time,Chlo,GA_start_date)
        clear filename_chlo Chlo ncid file

        file = fullfile(OutputDir_no3,['no3',OutputRes,'.nc']);
        ncid = netcdf_fvcom.create_nc(file,'NETCDF4');
        netcdf_nemuro.wrnc_no3(ncid,Lon,Lat,Depth,time,No3,GA_start_date)
        clear filename_no3 No3 ncid file

        file = fullfile(OutputDir_zp,['zooplankton',OutputRes,'.nc']);
        ncid = netcdf_fvcom.create_nc(file,'NETCDF4');
        netcdf_nemuro.wrnc_zooplankton(ncid,Lon,Lat,Depth,time,Zp,GA_start_date)
        clear filename_zp Zp ncid file

        file = fullfile(OutputDir_pp,['phytoplankton',OutputRes,'.nc']);
        ncid = netcdf_fvcom.create_nc(file,'NETCDF4');
        netcdf_nemuro.wrnc_phytoplankton(ncid,Lon,Lat,Depth,time,Pp,GA_start_date)
        clear filename_pp Pp ncid file

        file = fullfile(OutputDir_sand,['sand',OutputRes,'.nc']);
        ncid = netcdf_fvcom.create_nc(file,'NETCDF4');
        netcdf_nemuro.wrnc_sand(ncid,Lon,Lat,Depth,time,Sand,GA_start_date)
        clear filename_sand Sand ncid file

        clear Lon Lat Depth time TIME TIME_*
        clear time_filename
        clear OutputDir_*
    end

    clear dr1 Length % 循环天数
    clear *path *Dir Version % 路径 文件名 程序版本信息等
    disp(['GivenDate   --> ',char(getdate),' 处理完成'])
    clear getdate    % 基准天
    toc % 计时终止
end
