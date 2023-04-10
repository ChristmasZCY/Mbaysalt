function Postprocess_fvcom(conf_file, interval, yyyymmdd, day_length, varargin)
    % =================================================================================================================
    % discription:
    %       This function is used to postprocess the fvcom output netcdf files, contains daily/hourly.
    % =================================================================================================================
    % parameter:
    %       conf_file: configure file                 || required: True || type: string  || format: 'Post_fvcom.conf'
    %       interval: interval                        || reauired: True || type: string  || format: 'daily','hourly'
    %       yyyymmdd: date                            || required: True || type: double. || format: 20221110
    %       day_length: length of date                || required: True || type: double  || format: 5
    % =================================================================================================================
    % example:
    %       Postprocess_fvcom('Post_fvcom.conf','hourly',20230325,1)
    %       Postprocess_fvcom('Post_fvcom.conf','daily',20230325,1)
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
    if switch_ww
        osprint(['Transfor ', interval ,' variable --> temp salt zeta u v w'])
    else
        osprint(['Transfor ', interval ,' variable --> temp salt zeta u v'])
    end


    for dr=1:Length
        dr1=dr-1;
        deal_date_dt=dateshift(getdate,'start','day',dr1);
        deal_date=char(datetime(deal_date_dt,"format","yyyyMMdd"));
        if strcmp(interval,"daily")
            ncfile = fullfile(Inputpath,[char(getdate),'/forecast/',file_Mcasename,'_avg_',num2str(dr,'%04d'),'.nc']); % 输入文件
        elseif strcmp(interval,"hourly")
            ncfile = fullfile(Inputpath,[char(getdate),'/forecast/',file_Mcasename,'_',num2str(dr,'%04d'),'.nc']); % 输入文件
        end

        OutputDir_curr=fullfile(Outputpath,'current',interval,deal_date); % 输出路径
        OutputDir_salt=fullfile(Outputpath,'sea_salinity',interval,deal_date); % 输出路径
        OutputDir_temp=fullfile(Outputpath,'sea_temperature',interval,deal_date); % 输出路径
        OutputDir_adt=fullfile(Outputpath,'adt',interval,deal_date); % 输出路径
        makedirs(OutputDir_curr,OutputDir_salt,OutputDir_temp,OutputDir_adt); % 创建文件夹

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
        u = double(ncread(ncfile, 'u'));
        v = double(ncread(ncfile, 'v'));
        temp = double(ncread(ncfile,'temp'));
        salt = double(ncread(ncfile,'salinity'));
        zeta = double(ncread(ncfile,'zeta'));

        Time = ncread(ncfile,'Times')';
        % Time = datetime(1858,11,17)+ hours(Itime*24 + Itime2/(3600*1000));

        switch Method_interpn
            case {'Siqi_interp', 'Siqi_ESMF'}
                u_int = f_interp_cell2node(f_nc, u);
                v_int = f_interp_cell2node(f_nc, v);
                clear u v

                if switch_ww
                    w = double(ncread(ncfile, 'ww'));
                    w_int = f_interp_cell2node(f_nc, w);
                    clear w
                end
        end
        % temp salt zeta u_int v_int w_int

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

                        temp1 = zeros(f_nc.node,length(Depth_std),size(temp,3));
                        salt1 = zeros(f_nc.node,length(Depth_std),size(salt,3));
                        u_int1 = zeros(f_nc.node,length(Depth_std),size(u_int,3));
                        v_int1 = zeros(f_nc.node,length(Depth_std),size(v_int,3));

                        for it = 1:size(temp,3)
                            temp1(:,:,it) = interp_vertical_via_weight(temp(:,:,it),Weight_vertical);
                            salt1(:,:,it) = interp_vertical_via_weight(salt(:,:,it),Weight_vertical);
                            u_int1(:,:,it) = interp_vertical_via_weight(u_int(:,:,it),Weight_vertical);
                            v_int1(:,:,it) = interp_vertical_via_weight(v_int(:,:,it),Weight_vertical);
                        end
                        clear temp salt u_int v_int
                        temp = temp1; salt = salt1; u_int = u_int1; v_int = v_int1;
                        clear temp1 salt1 u_int1 v_int1
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

                Temp = interp_2d_via_weight(temp,Weight_2d);
                Salt = interp_2d_via_weight(salt,Weight_2d);
                Zeta = interp_2d_via_weight(zeta,Weight_2d);
                Depth = interp_2d_via_weight(f_nc.deplay,Weight_2d);
                U = interp_2d_via_weight(u_int,Weight_2d);
                V = interp_2d_via_weight(v_int,Weight_2d);
                clear temp salt zeta u_int v_int

                if switch_ww
                    W = interp_2d_via_weight(w_int,Weight_2d);
                    clear w_int
                end

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

                    for iz = 1 : size(temp,2)
                        for it = 1: size(temp,3)
                            Temp(:,:,iz,it) =  esmf_regrid(temp(:,iz,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                            Salt(:,:,iz,it) =  esmf_regrid(salt(:,iz,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                            Zeta(:,:,it) =  esmf_regrid(zeta(:,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                            Depth(:,:,iz) =  esmf_regrid(f_nc.deplay(:,iz),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                            U(:,:,iz,it) =  esmf_regrid(u_int(:,iz,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                            V(:,:,iz,it) =  esmf_regrid(v_int(:,iz,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                            if switch_ww
                                W(:,:,iz,it) =  esmf_regrid(w_int(:,iz,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                            end
                        end
                    end
                    clear temp salt zeta u_int v_int w_int

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

                [Temp,Salt,Zeta,Depth] = griddata_fvcom.griddata_tsz(lon,lat,time,temp,salt,zeta,h,siglay,Lon,Lat);

                if switch_ww
                    [U,V,W] = griddata_fvcom.griddata_nele(lonc, latc, siglay, time, Lon, Lat, u, v, w);
                    clear lonc latc u v w lon lat temp salt zeta h siglay
                    [Temp,Salt,Zeta,Depth,U,V,W] = mask2data(file_matmask,Temp,Salt,Zeta,Depth,U,V,W);
                else
                    [U,V] = griddata_fvcom.griddata_nele(lonc, latc, siglay, time, Lon, Lat, u, v);
                    clear lonc latc u v lon lat temp salt zeta h siglay
                    [Temp,Salt,Zeta,Depth,U,V] = mask2data(file_matmask,Temp,Salt,Zeta,Depth,U,V);
                end

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
            [~,Zeta] = ll_to_ll(Lon,Zeta);
            if switch_ww
                [Lon,Temp,Salt,U,V,W] = ll_to_ll(Lon,Temp,Salt,U,V,W);
            else
                [Lon,Temp,Salt,U,V] = ll_to_ll(Lon,Temp,Salt,U,V);
            end
        end

        clear ncfile

        % Depth_std_nc = repmat(Depth_std,[length(Lon),1,length(Lat)]);
        % Depth = permute(Depth_std_nc,[1,3,2]);

        %% global attribute start
        start_date_gb = [char(datetime("now","Format","yyyy-MM-dd")), '_00:00:00'];

        %% 写入
        file = fullfile(OutputDir_curr,['current',OutputRes,'.nc']);
        ncid = netcdf_fvcom.create_nc(file, 'NETCDF4');
        if switch_ww
            netcdf_fvcom.wrnc_current(ncid,Lon,Lat,Depth,time,U,V,W,start_date_gb)
        else
            netcdf_fvcom.wrnc_current(ncid,Lon,Lat,Depth,time,U,V,start_date_gb)
        end
        clear filename_curr U V W ncid file

        file = fullfile(OutputDir_temp,['temperature',OutputRes,'.nc']);
        ncid = netcdf_fvcom.create_nc(file, 'NETCDF4');
        netcdf_fvcom.wrnc_temp(ncid,Lon,Lat,Depth,time,Temp,start_date_gb)
        clear filename_temp Temp ncid file

        file = fullfile(OutputDir_salt,['salinity',OutputRes,'.nc']);
        ncid = netcdf_fvcom.create_nc(file, 'NETCDF4');
        netcdf_fvcom.wrnc_salt(ncid,Lon,Lat,Depth,time,Salt,start_date_gb)
        clear filename_salt Salt ncid file

        file = fullfile(OutputDir_adt,['adt',OutputRes,'.nc']);
        ncid = netcdf_fvcom.create_nc(file, 'NETCDF4');
        netcdf_fvcom.wrnc_adt(ncid,Lon,Lat,time,Zeta,start_date_gb)
        clear filename_adt Zeta ncid

        clear Lon Lat Depth time TIME TIME_*
        clear time_filename
        clear OutputDir_*
    end

    clear dr1 Length % 循环天数
    clear *path *Dir Version % 路径 文件名 程序版本信息等
    osprint(['GivenDate   --> ',char(getdate),' 处理完成'])
    clear getdate    % 基准天
    toc % 计时终止
end

