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
    %       Postprocess_fvcom('Post_fvcom.conf','hourly',20230525,1)
    %       Postprocess_fvcom('Post_fvcom.conf','daily',20230525,1)
    % =================================================================================================================

    %% 读取
    tic % 计时开始
    switch interval
        case {'daily','hourly'}
            interval = char(interval); % daily hourly
        otherwise
            error("interval must be 'daily' or 'hourly'")
    end

    para_conf              =  read_conf(conf_file);           % 读取配置文件
    Inputpath              =  para_conf.ModelOutputDir;       % 输入路径  --> '/home/ocean/ForecastSystem/FVCOM_Global/Run/'
    Outputpath             =  para_conf.StandardDir;          % 输出路径  --> '/home/ocean/ForecastSystem/Output/Standard/'
    file_Mcasename         =  para_conf.ModelCasename;        % fvcom的casename  --> 'forecast'
    OutputRes              =  para_conf.OutputRes;            % 生成文件的后缀  --> _global_5
    Method_interpn         =  para_conf.Method_interpn;       % 插值方法  --> 'Siqi_interp'
    lon_dst                =  para_conf.Lon_destination;      % 模型的经度范围  --> [-180,180]
    lat_dst                =  para_conf.Lat_destination;      % 模型的纬度范围  --> [20,30]
    % makedirs(para_conf.TemporaryDir)                          % 创建临时文件夹
    SWITCH = read_switch(para_conf); % 读取开关

    if ~SWITCH.out_std_level && ~SWITCH.out_sgm_level  % 至少输出一种层
        error('At least one of the two output levels must be selected')
    end

    if SWITCH.warningtext;warning('on');else; warning('off');end  % 是否显示警告信息

    if SWITCH.out_std_level  % 标准层
        Depth_std = para_conf.Depth_std;
    end
    if SWITCH.out_sgm_level % sigma层
        Level_sgm = para_conf.Level_sgm;
    end
    osprints('INFO',['Output standard levels --> ',logical_to_char(SWITCH.out_std_level)])
    osprints('INFO',['Output sigma levels --> ',logical_to_char(SWITCH.out_sgm_level)])

    getdate = datetime(num2str(yyyymmdd),"format","yyyyMMdd"); clear yyyymmdd
    Length = day_length;clear day_length;% 当天开始向后处理的天数

    osprints('INFO', ['Date parameter --> ',char(getdate),' total transfor ',num2str(Length),' days'])  % 输出处理的日期信息
    osprints('INFO', ['Method --> ',Method_interpn])  % 输出插值方法
    osprints('INFO', ['Transfor ', interval ,' variable --> temp salt zeta u v', double(SWITCH.ww)*' w', double(SWITCH.ww)*' ice'])  % 打印处理的变量

    for dr = 1 : Length
        dr1 = dr-1;
        deal_date_dt = dateshift(getdate,'start','day',dr1);
        deal_date = char(datetime(deal_date_dt,"format","yyyyMMdd"));
        if strcmp(interval,"daily")
            ncfile = fullfile(Inputpath,[char(getdate),'/forecast/',file_Mcasename,'_avg_',num2str(dr,'%04d'),'.nc']); % 输入文件
        elseif strcmp(interval,"hourly")
            ncfile = fullfile(Inputpath,[char(getdate),'/forecast/',file_Mcasename,'_',num2str(dr,'%04d'),'.nc']); % 输入文件
        end

        OutputDir.curr = fullfile(Outputpath,'current',interval,deal_date); % current输出路径
        OutputDir.salt = fullfile(Outputpath,'sea_salinity',interval,deal_date); % salinity输出路径
        OutputDir.temp = fullfile(Outputpath,'sea_temperature',interval,deal_date); % temperature输出路径
        OutputDir.adt = fullfile(Outputpath,'adt',interval,deal_date); % adt输出路径
        OutputDir.ice = fullfile(Outputpath,'ice',interval,deal_date); % aice输出路径
        structfun(@(x) makedirs(x),OutputDir); % 创建文件夹

        clear deal_date_dt deal_date % 日期处理中间变量

        if dr == 1 % 只有第一次需要读取经纬度
            SWITCH.read_ll_from_nc = para_conf.Switch_read_ll_from_nc; % 是否从nc文件中读取经纬度  --> True
            ll_file = para_conf.LLFile; % 经纬度文件  --> 'll.mat'
            if SWITCH.read_ll_from_nc
                f_nc = f_load_grid(ncfile,'Coordinate',para_conf.Load_Coordinate,'MaxLon',para_conf.MaxLon);  % read grid
                save(ll_file, 'f_nc', '-v7.3', '-nocompression');
            else
                f_nc = load(ll_file).f_nc;
            end
            clear ll_file SWITCH.read_ll_from_nc
        end
        clear dr1 dr

        if f_nc.MaxLon == 180 && max(lon_dst,[],'all') > 180  % 判断是否需要转换经度，并记录change_maxlon开关
            Lon = ll_to_ll(lon_dst);
            SWITCH.change_maxlon = true;
        elseif f_nc.MaxLon == 360 && min(lon_dst,[],'all') < 0
            Lon = ll_to_ll(lon_dst);
            SWITCH.change_maxlon = true;
        else
            Lon = lon_dst;
            SWITCH.change_maxlon = false;
        end
        Lat = lat_dst;

        % read nc file
        u = double(ncread(ncfile, 'u'));
        v = double(ncread(ncfile, 'v'));
        temp = double(ncread(ncfile,'temp'));
        salt = double(ncread(ncfile,'salinity'));
        zeta = double(ncread(ncfile,'zeta'));

        if SWITCH.ww
            w = double(ncread(ncfile, 'ww'));
        end
        if SWITCH.aice % 是否包含海冰密集度
            aice = double(ncread(ncfile,'aice'));
        end

        Time = ncread(ncfile,'Times')';
        % Time = datetime(1858,11,17)+ hours(Itime*24 + Itime2/(3600*1000));

        switch Method_interpn
            case {'Siqi_interp', 'Siqi_ESMF'}
                u_int = f_interp_cell2node(f_nc, u);
                v_int = f_interp_cell2node(f_nc, v);
                if SWITCH.ww
                    w_int = f_interp_cell2node(f_nc, w);
                end
                clear u v w
        end
        % temp salt zeta u_int v_int w_int

        if strcmp(interval,"daily")
            Time = datetime(Time,'Format','yyyy-MM-dd''T''HH:mm:ssSSSSSS') - double(SWITCH.daily_1hour);
        elseif strcmp(interval,"hourly")
            Time = datetime(Time,'Format','yyyy-MM-dd''T''HH:mm:ssSSSSSS');
        end

        time = posixtime(Time); % POSIX时间 1970 01 01 shell的date +%s

        switch Method_interpn
            case 'Siqi_interp'

                % weight
                file_weight = para_conf.WeightFile_Siqi_interp;
                if SWITCH.make_weight
                    [Lat_m,Lon_m] = meshgrid(Lat,Lon);
                    tic
                    Weight_2d = interp_2d_calc_weight('TRI',f_nc.LON,f_nc.LAT,f_nc.nv,Lon_m,Lat_m);
                    delete(file_weight)
                    save(file_weight,'Weight_2d','-v7.3','-nocompression');
                    clear Lon_m Lat_m
                    osprints('INFO',['Calculate 2d weight costs ',num2str(toc),' 秒'])
                else
                    Weight_2d = load(file_weight).Weight_2d;
                end

                Temp = interp_2d_via_weight(temp,Weight_2d);
                Salt = interp_2d_via_weight(salt,Weight_2d);
                Zeta = interp_2d_via_weight(zeta,Weight_2d);
                Depth = interp_2d_via_weight(f_nc.deplay,Weight_2d);
                Siglay = interp_2d_via_weight(f_nc.siglay,Weight_2d);
                U = interp_2d_via_weight(u_int,Weight_2d);
                V = interp_2d_via_weight(v_int,Weight_2d);
                Depth_origin_to_wrf_grid =  interp_2d_via_weight(f_nc.h,Weight_2d);

                if SWITCH.ww
                    W = interp_2d_via_weight(w_int,Weight_2d);
                end
                if SWITCH.aice
                    Aice = interp_2d_via_weight(aice,Weight_2d);
                end
                clear temp salt zeta u_int v_int w_int aice
                clear file_weight Weight_2d

            case 'Siqi_ESMF'

                % weight
                file_weight = para_conf.WeightFile_Siqi_ESMF;
                if SWITCH.make_weight
                    exe = para_conf.ESMF_exe;
                    % ESMFMAFILE = para_conf.ESMF_MAFILE;
                    GridFile_fvcom = para_conf.GridFile_fvcom;
                    GridFile_wrf = para_conf.GridFile_wrf;
                    ESMF_NCweightfile = para_conf.ESMF_NCweightfile;
                    ESMF_RegridMethod = para_conf.ESMF_RegridMethod;
                    [Lat_m,Lon_m] = meshgrid(Lat,Lon);
                    tic
                    esmf_write_grid(GridFile_fvcom , 'FVCOM', f_nc.LON,f_nc.LAT,f_nc.nv);
                    esmf_write_grid(GridFile_wrf, 'WRF', Lon_m,Lat_m);
                    esmf_regrid_weight(GridFile_fvcom, GridFile_wrf, ESMF_NCweightfile, ...
                                        'exe', exe, 'Src_loc', 'corner', 'Method', ESMF_RegridMethod); % temperature corner
                    Weight_2d = esmf_read_weight(ESMF_NCweightfile);
                    delete(file_weight)
                    save(file_weight,'Weight_2d','-v7.3','-nocompression');
                    clear Lon_m Lat_m
                    osprints('INFO',['Calculate 2d weight costs ',num2str(toc),' 秒'])
                else
                    Weight_2d = load(file_weight).Weight_2d;
                end
                clear GridFile_fvcom GridFile_wrf ESMF_NCweightfile ESMFMAFILE ESMF_RegridMethod exe file_weight

                for it = 1: size(temp,3) % time
                    for iz = 1 : size(temp,2) % depth
                        Temp(:,:,iz,it) =  esmf_regrid(temp(:,iz,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                        Salt(:,:,iz,it) =  esmf_regrid(salt(:,iz,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                        U(:,:,iz,it) =  esmf_regrid(u_int(:,iz,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                        V(:,:,iz,it) =  esmf_regrid(v_int(:,iz,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                        if SWITCH.ww
                            W(:,:,iz,it) =  esmf_regrid(w_int(:,iz,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                        end
                        if it == 1  % 不随time变化，只需要计算一次
                            Depth(:,:,iz) =  esmf_regrid(f_nc.deplay(:,iz),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                            Siglay(:,:,iz) =  esmf_regrid(f_nc.siglay(:,iz),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                        end
                    end
                    Zeta(:,:,it) =  esmf_regrid(zeta(:,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                    if SWITCH.aice
                        Aice(:,:,it) =  esmf_regrid(aice(:,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                    end
                end
                Depth_origin_to_wrf_grid =  esmf_regrid(f_nc.h,Weight_2d,'Dims',[length(Lon),length(Lat)]); % depth of WRF grid
                clear temp salt zeta u_int v_int w_int aice it iz Weight_2d

            case 'Christmas_interp'
                warning('Not Recommend! Need parpool, extremely slow, only can interp depth as sigma level')
                YN = input('Are you sure to continue? Y/N [N]:','s');
                if lower(YN) ~= 'y'
                    error('stop')
                end
                % parpool(20)

                % read grid
                lonc = f_nc.xc; latc = f_nc.yc;
                lon = f_nc.x; lat = f_nc.y;
                h = f_nc.h; siglay = double(ncread(ncfile,'siglay',[1,1],[1,Inf]));

                % mask
                SWITCH.make_mask = para_conf.Switch_make_mask;
                file_ncmask = para_conf.MaskncFile;  % Christmas_interp mask地形文件 gebco_2022.nc
                file_matmask = para_conf.MaskmatFile;  % Christmas_interp 海洋为1，陆地为0的mask文件
                if SWITCH.make_mask
                    make_maskmat(file_ncmask,Lon,Lat,file_matmask);
                end

                [Temp,Salt,Zeta,Depth] = griddata_fvcom.griddata_tsz(lon,lat,time,temp,salt,zeta,h,siglay,Lon,Lat);

                if SWITCH.ww
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
        % lon                      --> 1*lon                                --- wrnc(function) lon
        % lat                      --> 1*lat                                --- wrnc(function) lat
        % Depth_origin_to_wrf_grid --> lon*lat(bathy)                       --- wrnc(function) bathy
        % Depth_std                --> 1*level (standard depth)             --- wrnc(function) depth
        % Depth                    --> lon*lat*sigma_orig (depth of fvcom vertical grid) 
        % Temp                     --> lon*lat*sigma_orig*time (temperature of fvcom vertical grid)
        % Salt                     --> lon*lat*sigma_orig*time (salinity of fvcom vertical grid)
        % U                        --> lon*lat*sigma_orig*time (u of fvcom vertical grid)
        % V                        --> lon*lat*sigma_orig*time (v of fvcom vertical grid)
        % W                        --> lon*lat*sigma_orig*time (w of fvcom vertical grid)
        % Zeta                     --> lon*lat*time (zeta of fvcom vertical grid)
        % Aice                     --> lon*lat*time (aice of fvcom vertical grid)

        if SWITCH.out_sgm_level % 是否输出sigma层
            VAelement.U_sgm = U;
            VAelement.V_sgm = V;
            if SWITCH.ww
                VAelement.W_sgm = W;
            end
            VAelement.Temp_sgm = Temp;
            VAelement.Salt_sgm = Salt;
        end

        switch Method_interpn 
            case {'Siqi_interp', 'Siqi_ESMF'}
                if SWITCH.out_std_level  % 是否转换到标准层

                    %weight
                    file_weight_vertical = para_conf.WeightFile_vertical;
                    size_2d_to_1d_ll = size(Depth,1)*size(Depth,2);  % num of lon*lat

                    if SWITCH.make_weight
                        tic
                        % Weight_vertical = interp_vertical_calc_weight(f_nc.deplay,repmat(Depth_std,f_nc.node,1));
                        depth_2d_to_1d = reshape(Depth,size_2d_to_1d_ll,[]);
                        F_noNaN = find(~isnan(depth_2d_to_1d(:,1)),1);  % 找到第一个不是NaN的数字，否则interp_vertical_calc_weight会报错
                        if isempty(F_noNaN)
                            osprints('ERROR', 'Depth is all NaN'); error('Depth is all NaN')
                        elseif F_noNaN ~= 1
                            depth_2d_to_1d = [depth_2d_to_1d(F_noNaN:end,:); depth_2d_to_1d(1:F_noNaN-1,:)];
                        end
                        Weight_vertical = interp_vertical_calc_weight(depth_2d_to_1d,repmat(Depth_std,size_2d_to_1d_ll,1)); 
                        Weight_vertical = structfun(@(x) flip2_to_recover(x,F_noNaN), Weight_vertical, 'UniformOutput', false);  % 顺序转换回去
                        delete(file_weight_vertical); clear F_noNaN depth_2d_to_1d
                        save(file_weight_vertical, 'Weight_vertical','-v7.3','-nocompression');
                        osprints('INFO',['Calculate vertical weight costs ',num2str(toc),' 秒'])
                    else
                        Weight_vertical = load(file_weight_vertical).Weight_vertical;
                    end
                    clear file_weight_vertical

                    % WRF grid --> FVCOM grid
                    Temp1 = reshape(Temp,[size_2d_to_1d_ll,size(Temp,[3,4])]);clear Temp
                    Salt1 = reshape(Salt,[size_2d_to_1d_ll,size(Salt,[3,4])]);clear Salt
                    U1 = reshape(U,[size_2d_to_1d_ll,size(U,[3,4])]);clear U
                    V1 = reshape(V,[size_2d_to_1d_ll,size(V,[3,4])]);clear V
                    if SWITCH.ww
                        W1 = reshape(W,[size_2d_to_1d_ll,size(W,[3,4])]);clear W
                    end

                    % make empty matrix
                    Temp = zeros(size_2d_to_1d_ll,length(Depth_std),size(Temp1,3));
                    Salt = zeros(size_2d_to_1d_ll,length(Depth_std),size(Salt1,3));
                    U = zeros(size_2d_to_1d_ll,length(Depth_std),size(U1,3));
                    V = zeros(size_2d_to_1d_ll,length(Depth_std),size(V1,3));
                    if SWITCH.ww
                        W = zeros(size_2d_to_1d_ll,length(Depth_std),size(W1,3));
                    end
                    clear size_2d_to_1d_ll

                    % interp with FVCOM grid
                    for it = 1:size(Temp1,3) % size(Temp1,3) -- time
                        Temp(:,:,it) = interp_vertical_via_weight(Temp1(:,:,it),Weight_vertical);
                        Salt(:,:,it) = interp_vertical_via_weight(Salt1(:,:,it),Weight_vertical);
                        U(:,:,it) = interp_vertical_via_weight(U1(:,:,it),Weight_vertical);
                        V(:,:,it) = interp_vertical_via_weight(V1(:,:,it),Weight_vertical);
                        if SWITCH.ww
                            W(:,:,it) = interp_vertical_via_weight(W1(:,:,it),Weight_vertical);
                        end
                    end
                    clear Temp1 Salt1 U1 V1 W1 it
                    clear Weight_vertical

                    Temp = reshape(Temp,[size(Depth,[1, 2]),size(Temp,[2,3,4])]);
                    Salt = reshape(Salt,[size(Depth,[1, 2]),size(Salt,[2,3,4])]);
                    U = reshape(U,[size(Depth,[1, 2]),size(U,[2,3,4])]);
                    V = reshape(V,[size(Depth,[1, 2]),size(V,[2,3,4])]);
                    if SWITCH.ww
                        W = reshape(W,[size(Depth,[1, 2]),size(W,[2,3,4])]);
                    end
                end
        end
        % Temp Salt U V W Zeta Depth Aice --> std_level
        Velement.Zeta = Zeta;
        if SWITCH.aice
            Velement.Aice = Aice;
        end
        % -----> std_level
        if SWITCH.out_std_level
            Velement.Temp = Temp; 
            Velement.Salt = Salt;
            Velement.U = U; 
            Velement.V = V;
            if SWITCH.ww
                Velement.W = W; 
            end
            Delement.Depth_std = Depth_std;
        end
        clear Temp Salt U V W Zeta Aice
        % <----- std_level
        % -----> sgm_level
        if SWITCH.out_sgm_level
            Level_sgm  = int64(Level_sgm);
            if min(Level_sgm) < 1 || max(Level_sgm) > size(Depth,3)
                error('Level_sgm exceed the range of sigma level')
            end
            Velement.Temp_sgm = VAelement.Temp_sgm(:,:,Level_sgm,:);
            Velement.Salt_sgm = VAelement.Salt_sgm(:,:,Level_sgm,:);
            Velement.U_sgm = VAelement.U_sgm(:,:,Level_sgm,:);
            Velement.V_sgm = VAelement.V_sgm(:,:,Level_sgm,:);
            Delement.Siglay = Siglay(:,:,Level_sgm); clear Siglay
            if SWITCH.ww
                Velement.W_sgm = VAelement.W_sgm(:,:,Level_sgm,:);
            end
            Delement.Bathy = Depth_origin_to_wrf_grid;
            Delement.Sigma = Level_sgm;
        end
        clear VAelement
        % <----- sgm_level
        if SWITCH.change_maxlon
            [~,Velement] = structfun(@(x) ll_to_ll(Lon,x), Velement, 'UniformOutput', false);
            [DAelement,Delement] = separate_var_gt_nd(Delement, 3);
            [~,DAelement] = structfun(@(x) ll_to_ll(Lon,x), DAelement, 'UniformOutput', false);
            Delement = merge_struct(Delement,DAelement);
            clear DAelement
            Lon = ll_to_ll(Lon);
        end

        clear ncfile

        %% mask vertical data
        if SWITCH.out_std_level
            file_mask = para_conf.MaskVerticalmatFile;
            if SWITCH.make_mask
                tic
                Standard_depth_mask = make_mask_depth_data(Depth_origin_to_wrf_grid, Delement.Depth_std); 
                [~, Standard_depth_mask] = ll_to_ll(Lon, Standard_depth_mask);
                delete(file_mask)
                save(file_mask,'Standard_depth_mask','-v7.3','-nocompression');
                osprints('INFO',['Calculate depth mask costs ',num2str(toc),' 秒'])
            else
                Standard_depth_mask = load(file_mask).Standard_depth_mask;
            end
            clear file_mask
            if SWITCH.vertical_mask
                if strcmp(interval,"hourly")
                    [VAelement,Velement] = separate_var_gt_nd(Velement,4);  % 4D hourly --> lon*lat*depth*time
                elseif strcmp(interval,"daily")
                    [VAelement,Velement] = separate_var_gt_nd(Velement,3); % 3D daily --> lon*lat*depth
                end
                [VAelement,VBelement] = separate_var_nd_gt_n(VAelement,'dim',3,'n',length(Delement.Depth_std));  % dim --> length  n --> length of standard level 
                VAelement = structfun(@(x) mask_depth_data(Standard_depth_mask, x), VAelement, 'UniformOutput', false);
                Velement = merge_struct(Velement,VAelement);
                Velement = merge_struct(Velement,VBelement);
                clear VAelement VBelement
                clear Standard_depth_mask
            end
            osprints('INFO',['Masking depth of data greater than bathy --> ', logical_to_char(SWITCH.vertical_mask)])
        end
        clear Depth_origin_to_wrf_grid

        %% 岸线侵蚀
        if SWITCH.erosion
            osprints('INFO',['Erosion coastline --> ',logical_to_char(SWITCH.erosion)]);
            file_erosion = para_conf.ErosionFile;
            if SWITCH.make_erosion
                if ~SWITCH.out_std_level && SWITCH.out_sgm_level
                    I_D_1 = erosion_coast_cal_id(Lon, Lat, Velement.Temp_sgm, 16, 5);
                elseif SWITCH.out_std_level && ~SWITCH.out_sgm_level
                    I_D_1 = erosion_coast_cal_id(Lon, Lat, Velement.Temp, 16, 5);
                elseif SWITCH.out_std_level && SWITCH.out_sgm_level
                    I_D_1 = erosion_coast_cal_id(Lon, Lat, Velement.Temp, 16, 5);
                end
                save(file_erosion, 'I_D_1', '-v7.3','-nocompression');
            else
                I_D_1 = load(file_erosion).I_D_1;
            end
            [VAelement,Velement] = separate_var_gt_nd(Velement,4);
            VAelement = structfun(@(x) erosion_coast_via_id(I_D_1, x,'cycle_dim',4), VAelement, 'UniformOutput', false);
            Velement = merge_struct(Velement,VAelement); clear VAelement
            if SWITCH.make_erosion
                if ~SWITCH.out_std_level && SWITCH.out_sgm_level
                    I_D_2 = erosion_coast_cal_id(Lon, Lat, Velement.Temp_sgm, 16, 5);
                elseif SWITCH.out_std_level && ~SWITCH.out_sgm_level
                    I_D_2 = erosion_coast_cal_id(Lon, Lat, Velement.Temp, 16, 5);
                elseif SWITCH.out_std_level && SWITCH.out_sgm_level
                    I_D_2 = erosion_coast_cal_id(Lon, Lat, Velement.Temp, 16, 5);
                end
                save(file_erosion, 'I_D_2', '-append','-nocompression');
            else
                I_D_2 = load(file_erosion).I_D_2;
            end
            [VAelement,Velement] = separate_var_gt_nd(Velement,4);
            VAelement = structfun(@(x) erosion_coast_via_id(I_D_2, x,'cycle_dim',4), VAelement, 'UniformOutput', false);
            Velement = merge_struct(Velement,VAelement); clear VAelement
            clear I_D_* file_erosion
        end

        %% global attribute start date
        GA_start_date = [char(datetime("now","Format","yyyy-MM-dd")), '_00:00:00'];

        %% 写入
        file = fullfile(OutputDir.curr,['current',OutputRes,'.nc']);
        ncid = netcdf_fvcom.create_nc(file, 'NETCDF4');
        [Velement_current,Velement] = rmfields_key_from_struct(Velement,{'Temp','Temp_sgm','Salt','Salt_sgm','Zeta','Aice'});
        netcdf_fvcom.wrnc_current(ncid,Lon,Lat,Delement,time,Velement_current,GA_start_date,'conf',para_conf);
        clear Velement_current ncid file

        file = fullfile(OutputDir.temp,['temperature',OutputRes,'.nc']);
        ncid = netcdf_fvcom.create_nc(file, 'NETCDF4');
        [Velement_temperature,Velement] = rmfields_key_from_struct(Velement,{'Salt','Salt_sgm','Zeta','Aice'});
        netcdf_fvcom.wrnc_temp(ncid,Lon,Lat,Delement,time,Velement_temperature,GA_start_date,'conf',para_conf)
        clear Velement_temperature ncid file

        file = fullfile(OutputDir.salt,['salinity',OutputRes,'.nc']);
        ncid = netcdf_fvcom.create_nc(file, 'NETCDF4');
        [Velement_salt,Velement] = rmfields_key_from_struct(Velement,{'Zeta','Aice'});
        netcdf_fvcom.wrnc_salt(ncid,Lon,Lat,Delement,time,Velement_salt,GA_start_date,'conf',para_conf);
        clear Velement_salt ncid file

        file = fullfile(OutputDir.adt,['adt',OutputRes,'.nc']);
        ncid = netcdf_fvcom.create_nc(file, 'NETCDF4');
        [Velement_adt,Velement] = rmfields_key_from_struct(Velement,{'Aice'});
        netcdf_fvcom.wrnc_adt(ncid,Lon,Lat,time,Velement_adt.Zeta,GA_start_date,'conf',para_conf);
        clear Velement_adt ncid file

        if SWITCH.aice
            file = fullfile(OutputDir.ice,['ice',OutputRes,'.nc']);
            ncid = netcdf_fvcom.create_nc(file, 'NETCDF4');
            [Velement_ice,Velement] = rmfields_key_from_struct(Velement,{''});
            netcdf_fvcom.wrnc_ice(ncid,Lon,Lat,time,Velement_ice.Aice,GA_start_date,'conf',para_conf);
            clear Velement_ice ncid file
        end

        clear Lon Lat Depth time TIME TIME_* Time Velement
        clear time_filename
        clear OutputDir_*
        clear GA_start_date
    end

    clear dr1 Length % 循环天数
    clear lon_dst lat_dst Level_sgm Depth_std Delement % 网格信息 变量
    clear *path *Dir % 路径 文件名 信息等
    clear OutputRes  % suffix
    clear f_nc     % f_load_grid.struct
    clear conf_file para_conf SWITCH  % 配置
    clear Method_interpn % 插值方法
    clear file_Mcasename
    clear varargin
    osprint(['GivenDate   --> ',char(getdate),' interval ',interval,' 处理完成耗时 ', num2str(toc),' 秒']);
    clear getdate interval  % 基准天 间隔
end


function switch_char = logical_to_char(switch_logical)
    switch switch_logical
    case true
        switch_char = 'TRUE';
    case false
        switch_char = 'FALSE';
    otherwise
        error('Unexpected input.')
    end
end

function var = flip2_to_recover(var, F)
    var = flip(var,1);
    var = [var(F:end,:); var(1:F-1,:)];
    var = flip(var,1);
end

function SWITCH = read_switch(struct)
    % 从struct中读取以SWITCH.开头的变量，将变量写入到switch结构体中
    % eg: 将struct中的Switch_erosion写入到switch.erosion中
    key = fieldnames(struct);
    for i = 1 : length(key)
        if ~isempty(regexp(key{i},'^Switch_','once'))
            SWITCH.(key{i}(8:end)) = struct.(key{i});
        end
    end
end

function [Struct1,Struct2] = separate_var_gt_nd(structIn,ndim)
    % 从struct中读取以维度>=ndim的变量，将变量写入到Struct1结构体中,其余变量写入到Struct2中
    Struct1 = struct; Struct2 = struct;
    key = fieldnames(structIn);
    for i = 1 : length(key)
        if length(size(structIn.(key{i}))) >= ndim && ~isvector(structIn.(key{i}))
            Struct1.(key{i}) = structIn.(key{i});
        else
            Struct2.(key{i}) = structIn.(key{i});
        end
    end
end

function [Struct1,Struct2] = separate_var_nd_gt_n(structIn,varargin)
    % 从struct找到第dim维度长度>=n的变量，将变量写入到Struct结构体中,其余变量写入到Struct2中
    varargin = read_varargin(varargin,{'dim'},{3});  % 默认第三维
    varargin = read_varargin(varargin,{'n'},{2});  % 默认长度>=2
    Struct1 = struct; Struct2 = struct;
    key = fieldnames(structIn);
    for i = 1 : length(key)
        if size(structIn.(key{i}),dim) >= n
            Struct1.(key{i}) = structIn.(key{i});
        else
            Struct2.(key{i}) = structIn.(key{i});
        end
    end
end

function Sstruct = merge_struct(varargin)
    % 合并结构体
    Sstruct = struct;
    for i = 1 : nargin
        key = fieldnames(varargin{i});
        for j = 1 : length(key)
            Sstruct.(key{j}) = varargin{i}.(key{j});
        end
    end
end

function [Struct1,Struct2] = rmfields_key_from_struct(structIn,keysIn)
    % Struct1 --> 从struct中删除指定key的变量 | Struct2 --> 从struct中保留指定key的变量
    Struct1 = structIn;
    key = fieldnames(structIn);
    for i = 1 : length(key)
        if any(strcmp(key{i},keysIn))
            Struct1 = rmfield(Struct1,key{i});
        end
    end
    Struct2 = rmfield(structIn,setdiff(key,keysIn));
end
