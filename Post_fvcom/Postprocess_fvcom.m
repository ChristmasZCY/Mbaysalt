function Postprocess_fvcom(conf_file, interval, yyyymmdd, day_length, varargin)
    %       This function is used to postprocess the fvcom output netcdf files, contains daily/hourly.
    % =================================================================================================================
    % Parameters:
    %       conf_file: configure file                 || required: True || type: text    || example: 'Post_fvcom.conf'
    %       interval: interval                        || reauired: True || type: text    || example: 'daily','hourly'
    %       yyyymmdd: date                            || required: True || type: double  || example: 20221110
    %       day_length: length of date                || required: True || type: double  || example: 5
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Update:
    %       2023-**-**:     Created, by Christmas;
    %       2023-**-**:     Adjusted method of calculate to rectangule grid, by Christmas;
    %       2023-**-**:     Added vertical mask, by Christmas;
    %       2023-**-**:     Added out sgm level and std level, by Christmas;
    %       2023-**-**:     Added switch of output each value, by Christmas;
    %       2023-12-29:     Added average depth output, by Christmas;
    %       2023-12-29:     Added output casfco2, by Christmas;
    %       2024-01-03:     Fixed aligning of osprint2, by Christmas;
    %       2024-01-03:     Added Avg_depth wrong warning, by Christmas;
    %       2024-01-07:     Added nemuro output(chlo,no3,zp,pp,sand), by Christmas;
    %       2024-01-25:     Added limit for ecological element(ph, no3, pco2, chlo, casfco2)
    %       2024-04-01:     Fixed separate var to vertical mask, by Christmas;
    %       2024-04-01:     Added two parameters at conf file, by Christmas;
    % =================================================================================================================
    % Example:
    %       Postprocess_fvcom('Post_fvcom.conf','hourly',20240401,1)
    %       Postprocess_fvcom('Post_fvcom.conf','daily', 20240401,1)
    % =================================================================================================================

    arguments(Input)
        conf_file {mustBeFile}
        interval {mustBeMember(interval,{'daily','hourly'})} % {mustBeNonzeroLengthText}
        yyyymmdd {mustBeFloat}
        day_length {mustBeFloat}
    end

    arguments(Repeating)
        varargin
    end

    %% 读取
    tt1 = tic; % 计时开始
    switch interval
        case {'daily','hourly'}
            interval = convertStringsToChars(interval); % daily hourly
        otherwise
            error("interval must be 'daily' or 'hourly'")
    end

    para_conf       = read_conf(conf_file);             % 读取配置文件
    Inputpath       = para_conf.ModelOutputDir;         % 输入路径  --> '/home/ocean/ForecastSystem/FVCOM_Global/Run/'
    Outputpath      = para_conf.StandardDir;            % 输出路径  --> '/home/ocean/ForecastSystem/Output/Standard/'
    file_Mcasename  = para_conf.ModelCasename;          % fvcom的casename  --> 'forecast'
    OutputRes       = para_conf.OutputRes;              % 生成文件的后缀  --> _global_5
    Method_interpn  = para_conf.Method_interpn;         % 插值方法  --> 'Siqi_interp'
    lon_dst         = para_conf.Lon_destination;        % 模型的经度范围  --> [-180,180]
    lat_dst         = para_conf.Lat_destination;        % 模型的纬度范围  --> [20,30]
    Ecology_model   = para_conf.Ecology_model;          % 生态模型  --> '.ERSEM.' or 'NEMURO'
    Text_len        = para_conf.Text_len;               % 打印字符的对齐长度
    SWITCH = read_switch(para_conf); % 读取开关

    if ~SWITCH.out_std_level && ~SWITCH.out_sgm_level && ~SWITCH.out_avg_level  % 至少输出一种层
        error('At least one of the three output levels must be selected')
    end

    if SWITCH.warningtext;warning('on');else; warning('off');end  % 是否显示警告信息

    if SWITCH.out_std_level  % 标准层
        Depth_std = para_conf.Depth_std;
    end
    if SWITCH.out_sgm_level % sigma层
        Level_sgm = para_conf.Level_sgm;
    end
    if SWITCH.out_avg_level % 平均层
        Avg_depth = para_conf.Avg_depth;
        if size(Avg_depth,2) ~= 2
            if size(Avg_depth,1) ==1
                Avg_depth = reshape(Avg_depth,2,[])';
                [list_content,line_id] = grep(conf_file, 'Avg_depth');
                warning("Wrong set Avg_depth in '%s' line %d, with '%s' \n Maybe you want to set %s", conf_file, line_id(1), list_content{1}, warningText(Avg_depth))
            end
        end
    end

    osprint2('INFO',[pad('Output standard depth ',Text_len,'right'),'--> ', logical_to_char(SWITCH.out_std_level)])
    osprint2('INFO',[pad('Output sigma levels ',Text_len,'right'),'--> ', logical_to_char(SWITCH.out_sgm_level)])
    osprint2('INFO',[pad('Output average depth ',Text_len,'right'),'--> ', logical_to_char(SWITCH.out_avg_level)])

    getdate = datetime(num2str(yyyymmdd),"format","yyyyMMdd"); clear yyyymmdd
    Length = day_length;clear day_length;% 当天开始向后处理的天数

    osprint2('INFO', [pad('Date parameter ',Text_len,'right'),'--> ', char(getdate)])  % 输出处理的日期信息
    osprint2('INFO', [pad('Total transfor ',Text_len,'right'),'--> ', num2str(Length),' days'])  % 输出处理的日期信息
    osprint2('INFO', [pad('Interp Method ', Text_len,'right'),'--> ', Method_interpn])  % 输出插值方法
    osprint2('INFO', [pad(['Transfor ',interval,' variable '],Text_len,'right'), '-->', repmat(' temp',SWITCH.temp),repmat(' salt',SWITCH.salt) ...
        repmat(' zeta',SWITCH.adt),repmat(' u',SWITCH.u),repmat(' v',SWITCH.v), repmat(' w',SWITCH.w), ...
        repmat(' aice',SWITCH.aice), repmat(' ph',SWITCH.ph), repmat(' no3',SWITCH.no3), repmat(' pco2',SWITCH.pco2), ...
        repmat(' chlo',SWITCH.chlo), repmat(' casfco2',SWITCH.casfco2)])  % 打印处理的变量

    for dr = 1 : Length
        dr1 = dr-1;
        deal_date_dt = dateshift(getdate,'start','day',dr1);
        deal_date = char(datetime(deal_date_dt,"format","yyyyMMdd"));
        if strcmp(interval,"daily")
            ncfile = fullfile(Inputpath,[char(getdate),'/forecast/',file_Mcasename,'_avg_',num2str(dr,'%04d'),'.nc']); % 输入文件
        elseif strcmp(interval,"hourly")
            ncfile = fullfile(Inputpath,[char(getdate),'/forecast/',file_Mcasename,'_',num2str(dr,'%04d'),'.nc']); % 输入文件
        end

        OutputDir.curr = fullfile(Outputpath,'current',interval,deal_date);  % current输出路径
        OutputDir.salt = fullfile(Outputpath,'sea_salinity',interval,deal_date);  % salinity输出路径
        OutputDir.temp = fullfile(Outputpath,'sea_temperature',interval,deal_date);  % temperature输出路径
        OutputDir.adt = fullfile(Outputpath,'adt',interval,deal_date);  % adt输出路径
        OutputDir.ice = fullfile(Outputpath,'aice',interval,deal_date);  % aice输出路径
        OutputDir.ph = fullfile(Outputpath,'ph',interval,deal_date);  % ph输出路径
        OutputDir.no3 = fullfile(Outputpath,'no3',interval,deal_date);  % no3输出路径
        OutputDir.pco2 = fullfile(Outputpath,'pco2',interval,deal_date);  % pco2输出路径
        OutputDir.chlo = fullfile(Outputpath,'chlorophyll',interval,deal_date);  % chlorophyll输出路径
        OutputDir.casfco2 = fullfile(Outputpath,'casfco2',interval,deal_date);  % casfco2输出路径
        OutputDir.zp = fullfile(Outputpath,'zooplankton',interval,deal_date);  % zooplankton输出路径
        OutputDir.pp = fullfile(Outputpath,'phytoplankton',interval,deal_date);  % phytoplankton输出路径
        OutputDir.sand = fullfile(Outputpath,'sand',interval,deal_date);  % sand输出路径
        if SWITCH.DEBUG  % 如果打开DEBUG模式,则OutputDir中的值都为'./'
            Fun_new_dir = @(x) './';
            OutputDir = structfun(Fun_new_dir,OutputDir,'UniformOutput',false);
            clear Fun_new_dir
        end
        structfun(@(x) makedirs(x),OutputDir); % 创建文件夹

        clear deal_date_dt deal_date % 日期处理中间变量

        if dr == 1 % 只有第一次需要读取经纬度
            SWITCH.read_ll_from_nc = para_conf.Switch_read_ll_from_nc; % 是否从nc文件中读取经纬度  --> True
            ll_file = para_conf.LLFile; % 经纬度文件  --> 'll.mat'
            if SWITCH.read_ll_from_nc
                f_nc = f_load_grid(ncfile,'Coordinate',para_conf.Load_Coordinate,'MaxLon',para_conf.MaxLon);  % read grid
                makedirs(fileparts(ll_file));
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
        if SWITCH.temp
            temp = double(ncread(ncfile,'temp'));
        end
        if SWITCH.salt
            salt = double(ncread(ncfile,'salinity'));
        end
        if SWITCH.u
            u = double(ncread(ncfile, 'u'));
        end
        if SWITCH.v
            v = double(ncread(ncfile, 'v'));
        end
        if SWITCH.w
            w = double(ncread(ncfile, 'ww'));
        end
        if SWITCH.adt
            zeta = double(ncread(ncfile,'zeta'));
        end
        if SWITCH.aice % 是否包含海冰密集度
            aice = double(ncread(ncfile,'aice'));
        end
        if SWITCH.ph % 是否包含ph
            if strcmpi(Ecology_model, '.ERSEM.')
                ph = double(ncread(ncfile,'O3_pH'));
            end
            ph = clip(ph, 0, 14);  % ph = limit_var(ph, [0,14]);
        end
        if SWITCH.no3 % 是否包含no3
            if strcmpi(Ecology_model, '.ERSEM.')
                no3 = double(ncread(ncfile,'N3_n'));
            elseif strcmpi(Ecology_model, '.NEMURO.')
                no3 = double(ncread(ncfile,'NO3')); % NO3 氮氧化物
            end
            no3 = clip(no3, 0, 400);  % no3 = limit_var(no3, [0,400]);
        end
        if SWITCH.pco2 % 是否包含pco2
            if strcmpi(Ecology_model, '.ERSEM.')
                pco2 = double(ncread(ncfile,'O3_pCO2'));
            end
            pco2 = clip(pco2, 0, 10000);  % pco2 = limit_var(pco2, [0,10000]);
        end
        if SWITCH.chlo % 是否包含chlorophyll
            if strcmpi(Ecology_model, '.ERSEM.')
                chlo_p1 = double(ncread(ncfile,'P1_Chl'));
                chlo_p2 = double(ncread(ncfile,'P2_Chl'));
                chlo_p3 = double(ncread(ncfile,'P3_Chl'));
                chlo_p4 = double(ncread(ncfile,'P4_Chl'));
                chlo = chlo_p1 + chlo_p2 + chlo_p3 + chlo_p4;
                clear chlo_p1 chlo_p2 chlo_p3 chlo_p4
            elseif strcmpi(Ecology_model, '.NEMURO.')
                ps = double(ncread(ncfile,'PS')); % PS 小型浮游植物
                pl = double(ncread(ncfile,'PL')); % PL 大型浮游植物
                pp = ps+pl; % phytoplankton pp 浮游植物
                chlo = 1.59 * pp;
                clear ps pl pp
            end
            chlo = clip(chlo, 0, 100);  % chlo = limit_var(chlo, [0,100]);
        end
        if SWITCH.casfco2 % 是否包含海气二氧化碳通量
            if strcmpi(Ecology_model, '.ERSEM.')
                casfco2 = double(ncread(ncfile,'O3_fair'));
            end
            casfco2 = clip(casfco2, -300, 300);  % casfco2 = limit_var(casfco2, [-300, 300]);
        end
        if SWITCH.zp  % zooplankton zp 浮游动物
            if strcmpi(Ecology_model, '.NEMURO.')
                zp = double(ncread(ncfile,'ZP')); % ZP 食肉浮游动物
                zs = double(ncread(ncfile,'ZS')); % ZS 小型浮游动物
                zl = double(ncread(ncfile,'ZL')); % ZL 大型浮游动物
                zp = zp+zs+zl; % zooplankton zp 浮游动物
                clear zs zl
            end
        end
        if SWITCH.pp  % phytoplankton pp 浮游植物
            if strcmpi(Ecology_model, '.NEMURO.')
                ps = double(ncread(ncfile,'PS')); % PS 小型浮游植物
                pl = double(ncread(ncfile,'PL')); % PL 大型浮游植物
                pp = ps+pl; % phytoplankton pp 浮游植物
                clear ps pl
            end
        end
        if SWITCH.sand  % 沙质
            if strcmpi(Ecology_model, '.NEMURO.')
                cs = double(ncread(ncfile,'coarse_sand')); % cs 粗沙
                ms = double(ncread(ncfile,'medium_sand')); % ms 中沙
                fs = double(ncread(ncfile,'fine_sand')); % fs 细沙
                sand = cs+ms+fs; % 沙质
                clear cs ms fs
            end
        end

        %% time
        % TIME = datetime(1858,11,17)+ hours(Itime*24 + Itime2/(3600*1000));
        TIME = ncread(ncfile,'Times')';
        if strcmp(interval,"daily")
            Times = datetime(TIME,'Format','yyyy-MM-dd''T''HH:mm:ssSSSSSS') - double(SWITCH.daily_1hour);
        elseif strcmp(interval,"hourly")
            Times = datetime(TIME,'Format','yyyy-MM-dd''T''HH:mm:ssSSSSSS');
        end
        Ttimes = Mdatetime(Times);
        clear TIME Times
        time = Ttimes.time; % POSIX时间 1970 01 01 shell的date +%s

        if SWITCH.u
            u_int = f_interp_cell2node(f_nc, u);
        end
        if SWITCH.v
            v_int = f_interp_cell2node(f_nc, v);
        end
        if SWITCH.w
            w_int = f_interp_cell2node(f_nc, w);
        end

        clear u v w

        % temp salt zeta u_int v_int w_int

        switch Method_interpn
            case 'Siqi_interp'

                % weight
                file_weight = para_conf.WeightFile_Siqi_interp;
                if SWITCH.make_weight
                    [Lat_m,Lon_m] = meshgrid(Lat,Lon);
                    tt2 = tic;
                    Weight_2d = interp_2d_calc_weight('TRI',f_nc.x,f_nc.x,f_nc.nv,Lon_m,Lat_m);
                    delete(file_weight)
                    save(file_weight,'Weight_2d','-v7.3','-nocompression');
                    osprint2('INFO', [pad('Calculate 2d weight costs ',Text_len,'right'),'--> ', num2str(toc(tt2)),' s'])
                    clear Lon_m Lat_m tt2
                else
                    Weight_2d = load(file_weight).Weight_2d;
                end

                if SWITCH.temp
                    Temp = interp_2d_via_weight(temp,Weight_2d);
                end
                if SWITCH.salt
                    Salt = interp_2d_via_weight(salt,Weight_2d);
                end
                if SWITCH.adt
                    Zeta = interp_2d_via_weight(zeta,Weight_2d);
                end
                if SWITCH.u
                    U = interp_2d_via_weight(u_int,Weight_2d);
                end
                if SWITCH.v
                    V = interp_2d_via_weight(v_int,Weight_2d);
                end
                if SWITCH.w
                    W = interp_2d_via_weight(w_int,Weight_2d);
                end
                if SWITCH.aice
                    Aice = interp_2d_via_weight(aice,Weight_2d);
                end
                if SWITCH.ph
                    Ph = interp_2d_via_weight(ph,Weight_2d);
                end
                if SWITCH.no3
                    No3 = interp_2d_via_weight(no3,Weight_2d);
                end
                if SWITCH.pco2
                    Pco2 = interp_2d_via_weight(pco2,Weight_2d);
                end
                if SWITCH.chlo
                    Chlo = interp_2d_via_weight(chlo,Weight_2d);
                end
                if SWITCH.casfco2
                    Casfco2 = interp_2d_via_weight(casfco2,Weight_2d);
                end
                if SWITCH.zp
                    Zp = interp_2d_via_weight(zp,Weight_2d);
                end
                if SWITCH.pp
                    Pp = interp_2d_via_weight(pp,Weight_2d);
                end
                if SWITCH.sand
                    Sand = interp_2d_via_weight(sand,Weight_2d);
                end
                Deplev = interp_2d_via_weight(f_nc.deplevc,Weight_2d);  % each sigma level depth(31) node
                Depth = interp_2d_via_weight(f_nc.deplay,Weight_2d);
                Siglay = interp_2d_via_weight(f_nc.siglay,Weight_2d);
                Depth_origin_to_wrf_grid =  interp_2d_via_weight(f_nc.h,Weight_2d);


                clear temp salt zeta u_int v_int w_int aice ph no3 pco2 chlo casfco2 zp pp sand
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
                    [Lat_m,Lon_m] = meshgrid(Lat,Lon);  % 注意: Lat放在前面
                    tt3 = tic;
                    esmf_write_grid(GridFile_fvcom , 'FVCOM', f_nc.x,f_nc.y,f_nc.nv);
                    esmf_write_grid(GridFile_wrf, 'WRF', Lon_m,Lat_m);
                    esmf_regrid_weight(GridFile_fvcom, GridFile_wrf, ESMF_NCweightfile, ...
                                        'exe', exe, 'Src_loc', 'corner', 'Method', ESMF_RegridMethod); % temperature corner
                    Weight_2d = esmf_read_weight(ESMF_NCweightfile);
                    delete(file_weight)
                    save(file_weight,'Weight_2d','-v7.3','-nocompression');
                    clear Lon_m Lat_m
                    osprint2('INFO', [pad('Calculate 2d weight costs ',Text_len,'right'),'--> ', num2str(toc(tt3)),' s'])
                else
                    Weight_2d = load(file_weight).Weight_2d;
                end
                clear GridFile_fvcom GridFile_wrf ESMF_NCweightfile ESMFMAFILE ESMF_RegridMethod exe file_weight tt3

                % for it = 1: size(temp,3) % time
                for it = 1: length(time)
                    % for iz = 1 : size(temp,2) % depth
                    for iz = 1: f_nc.kbm1
                        if SWITCH.temp
                            Temp(:,:,iz,it) =  esmf_regrid(temp(:,iz,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                        end
                        if SWITCH.salt
                            Salt(:,:,iz,it) =  esmf_regrid(salt(:,iz,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                        end
                        if SWITCH.u
                            U(:,:,iz,it) =  esmf_regrid(u_int(:,iz,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                        end
                        if SWITCH.v
                            V(:,:,iz,it) =  esmf_regrid(v_int(:,iz,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                        end
                        if SWITCH.w
                            W(:,:,iz,it) =  esmf_regrid(w_int(:,iz,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                        end
                        if SWITCH.ph
                            Ph(:,:,iz,it) =  esmf_regrid(ph(:,iz,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                        end
                        if SWITCH.no3
                            No3(:,:,iz,it) =  esmf_regrid(no3(:,iz,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                        end
                        if SWITCH.pco2
                            Pco2(:,:,iz,it) =  esmf_regrid(pco2(:,iz,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                        end
                        if SWITCH.chlo
                            Chlo(:,:,iz,it) =  esmf_regrid(chlo(:,iz,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                        end
                        if SWITCH.zp
                            Zp(:,:,iz,it) = interp_2d_via_weight(zp(:,iz,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                        end
                        if SWITCH.pp
                            Pp(:,:,iz,it) = interp_2d_via_weight(pp(:,iz,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                        end
                        if SWITCH.sand
                            Sand(:,:,iz,it) = interp_2d_via_weight(sand(:,iz,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                        end
                        if it == 1  % 不随time变化，只需要计算一次
                            Depth(:,:,iz) =  esmf_regrid(f_nc.deplay(:,iz),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                            Siglay(:,:,iz) =  esmf_regrid(f_nc.siglay(:,iz),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                        end
                    end
                    if SWITCH.out_avg_level
                        for iz = 1: f_nc.kb
                            Deplev(:,:,iz) =  esmf_regrid(f_nc.deplev(:,iz),Weight_2d,'Dims',[length(Lon),length(Lat)]); % each sigma level depth(31) node
                        end
                    end
                    % 不随深度变化
                    if SWITCH.adt
                        Zeta(:,:,it) =  esmf_regrid(zeta(:,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                    end
                    if SWITCH.aice
                        Aice(:,:,it) =  esmf_regrid(aice(:,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                    end
                    if SWITCH.casfco2
                        Casfco2(:,:,it) =  esmf_regrid(casfco2(:,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                    end
                end
                Depth_origin_to_wrf_grid =  esmf_regrid(f_nc.h,Weight_2d,'Dims',[length(Lon),length(Lat)]); % depth of WRF grid
                clear temp salt zeta u_int v_int w_int aice ph no3 pco2 chlo casfco2 it iz Weight_2d
            otherwise
                error('Method_interpn must be Siqi_interp or Siqi_ESMF!')
        end
        % lon                      --> 1*lon                                --- wrnc(function) lon
        % lat                      --> 1*lat                                --- wrnc(function) lat
        % Depth_origin_to_wrf_grid --> lon*lat(bathy)                       --- wrnc(function) bathy
        % Depth_std                --> 1*level (standard depth)             --- wrnc(function) depth
        % Depth                    --> lon*lat*sigma_layer_orig (depth of fvcom vertical grid)
        % Deplev                   --> lon*lat*sigma_level_orig (each sigma level depth(31))
        % Temp                     --> lon*lat*sigma_layer_orig*time (temperature of fvcom vertical grid)
        % Salt                     --> lon*lat*sigma_layer_orig*time (salinity of fvcom vertical grid)
        % U                        --> lon*lat*sigma_layer_orig*time (u of fvcom vertical grid)
        % V                        --> lon*lat*sigma_layer_orig*time (v of fvcom vertical grid)
        % W                        --> lon*lat*sigma_layer_orig*time (w of fvcom vertical grid)
        % Zeta                     --> lon*lat*time (zeta of fvcom vertical grid)
        % Aice                     --> lon*lat*time (aice of fvcom vertical grid)
        % Ph                       --> lon*lat*sigma_layer_orig*time (ph of fvcom vertical grid)
        % No3                      --> lon*lat*sigma_layer_orig*time (no3 of fvcom vertical grid)
        % Pco2                     --> lon*lat*sigma_layer_orig*time (pco2 of fvcom vertical grid)
        % Chlo                     --> lon*lat*sigma_layer_orig*time (chlorophyll of fvcom vertical grid)
        % Pp                       --> lon*lat*sigma_layer_orig*time (phytoplankton of fvcom vertical grid)
        % Zp                       --> lon*lat*sigma_layer_orig*time (zooplankton of fvcom vertical grid)
        % sand                     --> lon*lat*sigma_layer_orig*time (sand of fvcom vertical grid)
        % Casfco2                     --> lon*lat*time (casfco2 of fvcom vertical grid)

        if SWITCH.out_sgm_level % 是否输出sigma层
            if SWITCH.temp
                VAelement.Temp_sgm = Temp;
            end
            if SWITCH.salt
                VAelement.Salt_sgm = Salt;
            end
            if SWITCH.u
                VAelement.U_sgm = U;
            end
            if SWITCH.v
                VAelement.V_sgm = V;
            end
            if SWITCH.w
                VAelement.W_sgm = W;
            end
            if SWITCH.ph
                VAelement.Ph_sgm = Ph;
            end
            if SWITCH.no3
                VAelement.No3_sgm = No3;
            end
            if SWITCH.pco2
                VAelement.Pco2_sgm = Pco2;
            end
            if SWITCH.chlo
                VAelement.Chlo_sgm = Chlo;
            end
            if SWITCH.zp
                VAelement.Zp_sgm = Zp;
            end
            if SWITCH.pp
                VAelement.Pp_sgm = Pp;
            end
            if SWITCH.sand
                VAelement.Sand_sgm = Sand;
            end
        end

        if SWITCH.out_std_level  % 是否转换到标准层
            switch Method_interpn 
                case {'Siqi_interp', 'Siqi_ESMF'}
                    %weight
                    file_weight_vertical = para_conf.WeightFile_vertical;
                    size_2d_to_1d_ll = size(Depth,1)*size(Depth,2);  % num of lon*lat

                    if SWITCH.make_weight
                        tt4 = tic;
                        % Weight_vertical = interp_vertical_calc_weight(f_nc.deplay,repmat(Depth_std,f_nc.node,1));
                        depth_2d_to_1d = reshape(Depth,size_2d_to_1d_ll,[]);
                        F_noNaN = find(~isnan(depth_2d_to_1d(:,1)),1);  % 找到第一个不是NaN的数字，否则interp_vertical_calc_weight会报错
                        if isempty(F_noNaN)
                            osprint2('ERROR', 'Depth is all NaN'); error('Depth is all NaN')
                        elseif F_noNaN ~= 1
                            depth_2d_to_1d = [depth_2d_to_1d(F_noNaN:end,:); depth_2d_to_1d(1:F_noNaN-1,:)];
                        end
                        Weight_vertical = interp_vertical_calc_weight(depth_2d_to_1d,repmat(Depth_std,size_2d_to_1d_ll,1)); 
                        Weight_vertical = structfun(@(x) flip2_to_recover(x,F_noNaN), Weight_vertical, 'UniformOutput', false);  % 顺序转换回去
                        delete(file_weight_vertical); clear F_noNaN depth_2d_to_1d
                        save(file_weight_vertical, 'Weight_vertical','-v7.3','-nocompression');
                        osprint2('INFO', [pad('Calculate vertical weight costs ',Text_len,'right'),'--> ', num2str(toc(tt4)),' s'])
                    else
                        Weight_vertical = load(file_weight_vertical).Weight_vertical;
                    end
                    clear file_weight_vertical tt4

                    % WRF grid --> FVCOM grid
                    if SWITCH.temp
                        Temp1 = reshape(Temp,[size_2d_to_1d_ll,size(Temp,[3,4])]);clear Temp
                    end
                    if SWITCH.salt
                        Salt1 = reshape(Salt,[size_2d_to_1d_ll,size(Salt,[3,4])]);clear Salt
                    end
                    if SWITCH.u
                        U1 = reshape(U,[size_2d_to_1d_ll,size(U,[3,4])]);clear U
                    end
                    if SWITCH.v
                        V1 = reshape(V,[size_2d_to_1d_ll,size(V,[3,4])]);clear V
                    end
                    if SWITCH.w
                        W1 = reshape(W,[size_2d_to_1d_ll,size(W,[3,4])]);clear W
                    end
                    if SWITCH.ph
                        Ph1 = reshape(Ph,[size_2d_to_1d_ll,size(Ph,[3,4])]);clear Ph
                    end
                    if SWITCH.no3
                        No31 = reshape(No3,[size_2d_to_1d_ll,size(No3,[3,4])]);clear No3
                    end
                    if SWITCH.pco2
                        Pco21 = reshape(Pco2,[size_2d_to_1d_ll,size(Pco2,[3,4])]);clear Pco2
                    end
                    if SWITCH.chlo
                        Chlo1 = reshape(Chlo,[size_2d_to_1d_ll,size(Chlo,[3,4])]);clear Chlo
                    end
                    if SWITCH.zp
                        Zp1 = reshape(Zp,[size_2d_to_1d_ll,size(Zp,[3,4])]);clear Zp
                    end
                    if SWITCH.pp
                        Pp1 = reshape(Pp,[size_2d_to_1d_ll,size(Pp,[3,4])]);clear Pp
                    end
                    if SWITCH.sand
                        Sand1 = reshape(Sand,[size_2d_to_1d_ll,size(Sand,[3,4])]);clear Sand
                    end

                    % make empty matrix
                    if SWITCH.temp
                        Temp = zeros(size_2d_to_1d_ll,length(Depth_std),size(Temp1,3));
                    end
                    if SWITCH.salt
                        Salt = zeros(size_2d_to_1d_ll,length(Depth_std),size(Salt1,3));
                    end
                    if SWITCH.u
                        U = zeros(size_2d_to_1d_ll,length(Depth_std),size(U1,3));
                    end
                    if SWITCH.v
                        V = zeros(size_2d_to_1d_ll,length(Depth_std),size(V1,3));
                    end
                    if SWITCH.w
                        W = zeros(size_2d_to_1d_ll,length(Depth_std),size(W1,3));
                    end
                    if SWITCH.ph
                        Ph = zeros(size_2d_to_1d_ll,length(Depth_std),size(Ph1,3));
                    end
                    if SWITCH.no3
                        No3 = zeros(size_2d_to_1d_ll,length(Depth_std),size(No31,3));
                    end
                    if SWITCH.pco2
                        Pco2 = zeros(size_2d_to_1d_ll,length(Depth_std),size(Pco21,3));
                    end
                    if SWITCH.chlo
                        Chlo = zeros(size_2d_to_1d_ll,length(Depth_std),size(Chlo1,3));
                    end
                    if SWITCH.zp
                        Zp = zeros(size_2d_to_1d_ll,length(Depth_std),size(Zp1,3));
                    end
                    if SWITCH.pp
                        Pp = zeros(size_2d_to_1d_ll,length(Depth_std),size(Pp1,3));
                    end
                    if SWITCH.sand
                        Sand = zeros(size_2d_to_1d_ll,length(Depth_std),size(Sand1,3));
                    end
                    clear size_2d_to_1d_ll

                    % interp with FVCOM grid
                    % for it = 1:size(Temp1,3) % size(Temp1,3) -- time
                    for it = 1:length(time) 
                        if SWITCH.temp
                            Temp(:,:,it) = interp_vertical_via_weight(Temp1(:,:,it),Weight_vertical);
                        end
                        if SWITCH.salt
                            Salt(:,:,it) = interp_vertical_via_weight(Salt1(:,:,it),Weight_vertical);
                        end
                        if SWITCH.u
                            U(:,:,it) = interp_vertical_via_weight(U1(:,:,it),Weight_vertical);
                        end
                        if SWITCH.v
                            V(:,:,it) = interp_vertical_via_weight(V1(:,:,it),Weight_vertical);
                        end
                        if SWITCH.w
                            W(:,:,it) = interp_vertical_via_weight(W1(:,:,it),Weight_vertical);
                        end
                        if SWITCH.ph
                            Ph(:,:,it) = interp_vertical_via_weight(Ph1(:,:,it),Weight_vertical);
                        end
                        if SWITCH.no3
                            No3(:,:,it) = interp_vertical_via_weight(No31(:,:,it),Weight_vertical);
                        end
                        if SWITCH.pco2
                            Pco2(:,:,it) = interp_vertical_via_weight(Pco21(:,:,it),Weight_vertical);
                        end
                        if SWITCH.chlo
                            Chlo(:,:,it) = interp_vertical_via_weight(Chlo1(:,:,it),Weight_vertical);
                        end
                        if SWITCH.zp
                            Zp(:,:,it) = interp_vertical_via_weight(Zp1(:,:,it),Weight_vertical);
                        end
                        if SWITCH.pp
                            Pp(:,:,it) = interp_vertical_via_weight(Pp1(:,:,it),Weight_vertical);
                        end
                        if SWITCH.sand
                            Sand(:,:,it) = interp_vertical_via_weight(Sand1(:,:,it),Weight_vertical);
                        end
                    end
                    clear Temp1 Salt1 U1 V1 W1 Ph1 No31 Pco21 Chlo1 Zp1 Pp1 Sand1 it
                    clear Weight_vertical

                    if SWITCH.temp
                        Temp = reshape(Temp,[size(Depth,[1,2]),size(Temp,[2,3,4])]);
                    end
                    if SWITCH.salt
                        Salt = reshape(Salt,[size(Depth,[1,2]),size(Salt,[2,3,4])]);
                    end
                    if SWITCH.u
                        U = reshape(U,[size(Depth,[1,2]),size(U,[2,3,4])]);
                    end
                    if SWITCH.v
                        V = reshape(V,[size(Depth,[1,2]),size(V,[2,3,4])]);
                    end
                    if SWITCH.w
                        W = reshape(W,[size(Depth,[1,2]),size(W,[2,3,4])]);
                    end
                    if SWITCH.ph
                        Ph = reshape(Ph,[size(Depth,[1,2]),size(Ph,[2,3,4])]);
                    end
                    if SWITCH.no3
                        No3 = reshape(No3,[size(Depth,[1,2]),size(No3,[2,3,4])]);
                    end
                    if SWITCH.pco2
                        Pco2 = reshape(Pco2,[size(Depth,[1, 2]),size(Pco2,[2,3,4])]);
                    end
                    if SWITCH.chlo
                        Chlo = reshape(Chlo,[size(Depth,[1,2]),size(Chlo,[2,3,4])]);
                    end
                    if SWITCH.zp
                        Zp = reshape(Zp,[size(Depth,[1,2]),size(Zp,[2,3,4])]);
                    end
                    if SWITCH.pp
                        Pp = reshape(Pp,[size(Depth,[1,2]),size(Pp,[2,3,4])]);
                    end
                    if SWITCH.sand
                        Sand = reshape(Sand,[size(Depth,[1,2]),size(Sand,[2,3,4])]);
                    end
            end
        end
        % Temp Salt U V W Zeta Depth Aice Ph No3 Pco2 Chlo Casfco2 Zp Pp Sand --> std_level
        if SWITCH.adt
            Velement.Zeta = Zeta;
        end
        if SWITCH.aice
            Velement.Aice = Aice;
        end
        if SWITCH.casfco2
            Velement.Casfco2 = Casfco2;
        end
        % -----> avg_level
        if SWITCH.out_avg_level
            for idep = 1: size(Avg_depth,1)
                Deplev_use = Deplev;
                Deplev_use(Deplev_use < min(Avg_depth(idep,:))) = NaN;
                Deplev_use(Deplev_use > max(Avg_depth(idep,:))) = NaN;
                Deplev_interval = Deplev_use(:,:,2:end) - Deplev_use(:,:,1:end-1);  % 两层的差，每层的厚度
                sum_depth_avg = sum(Deplev_interval,3,"omitnan");
                coefficient = Deplev_interval./sum_depth_avg;
                if SWITCH.temp
                    Velement.Temp_avg(:,:,idep,:)= sum(coefficient.*VAelement.Temp_sgm,3,"omitnan");
                    land_mask = isnan(VAelement.Temp_sgm(:,:,1,:));  % 1800*3600*1*24
                    land_mask = repmat(land_mask,[1,1,size(Velement.Temp_avg,3),1]);  % 1800*3600*2*24
                    Velement.Temp_avg(land_mask) = NaN;
                end
                if SWITCH.salt
                    Velement.Salt_avg(:,:,idep,:)= sum(coefficient.*VAelement.Salt_sgm,3,"omitnan");
                    land_mask = isnan(VAelement.Salt_sgm(:,:,1,:));  % 1800*3600*1*24
                    land_mask = repmat(land_mask,[1,1,size(Velement.Salt_avg,3),1]);  % 1800*3600*2*24
                    Velement.Salt_avg(land_mask) = NaN;
                end
                if SWITCH.u
                    Velement.U_avg(:,:,idep,:)= sum(coefficient.*VAelement.U_sgm,3,"omitnan");
                    land_mask = isnan(VAelement.U_sgm(:,:,1,:));  % 1800*3600*1*24
                    land_mask = repmat(land_mask,[1,1,size(Velement.U_avg,3),1]);  % 1800*3600*2*24
                    Velement.U_avg(land_mask) = NaN;
                end
                if SWITCH.v
                    Velement.V_avg(:,:,idep,:)= sum(coefficient.*VAelement.V_sgm,3,"omitnan");
                    land_mask = isnan(VAelement.V_sgm(:,:,1,:));  % 1800*3600*1*24
                    land_mask = repmat(land_mask,[1,1,size(Velement.V_avg,3),1]);  % 1800*3600*2*24
                    Velement.V_avg(land_mask) = NaN;
                end
                if SWITCH.w
                    Velement.W_avg(:,:,idep,:)= sum(coefficient.*VAelement.W_sgm,3,"omitnan");
                    land_mask = isnan(VAelement.W_sgm(:,:,1,:));  % 1800*3600*1*24
                    land_mask = repmat(land_mask,[1,1,size(Velement.W_avg,3),1]);  % 1800*3600*2*24
                    Velement.W_avg(land_mask) = NaN;
                end
                if SWITCH.ph
                    Velement.Ph_avg(:,:,idep,:)= sum(coefficient.*VAelement.Ph_sgm,3,"omitnan");
                    land_mask = isnan(VAelement.Ph_sgm(:,:,1,:));  % 1800*3600*1*24
                    land_mask = repmat(land_mask,[1,1,size(Velement.Ph_avg,3),1]);  % 1800*3600*2*24
                    Velement.Ph_avg(land_mask) = NaN;
                end
                if SWITCH.no3
                    Velement.No3_avg(:,:,idep,:)= sum(coefficient.*VAelement.No3_sgm,3,"omitnan");
                    land_mask = isnan(VAelement.No3_sgm(:,:,1,:));  % 1800*3600*1*24
                    land_mask = repmat(land_mask,[1,1,size(Velement.No3_avg,3),1]);  % 1800*3600*2*24
                    Velement.No3_avg(land_mask) = NaN;
                end
                if SWITCH.pco2
                    Velement.Pco2_avg(:,:,idep,:)= sum(coefficient.*VAelement.Pco2_sgm,3,"omitnan");
                    land_mask = isnan(VAelement.Pco2_sgm(:,:,1,:));  % 1800*3600*1*24
                    land_mask = repmat(land_mask,[1,1,size(Velement.Pco2_avg,3),1]);  % 1800*3600*2*24
                    Velement.Pco2_avg(land_mask) = NaN;
                end
                if SWITCH.chlo
                    Velement.Chlo_avg(:,:,idep,:)= sum(coefficient.*VAelement.Chlo_sgm,3,"omitnan");
                    land_mask = isnan(VAelement.Chlo_sgm(:,:,1,:));  % 1800*3600*1*24
                    land_mask = repmat(land_mask,[1,1,size(Velement.Chlo_avg,3),1]);  % 1800*3600*2*24
                    Velement.Chlo_avg(land_mask) = NaN;
                end
                if SWITCH.zp
                    Velement.Zp_avg(:,:,idep,:)= sum(coefficient.*VAelement.Zp_sgm,3,"omitnan");
                    land_mask = isnan(VAelement.Zp_sgm(:,:,1,:));  % 1800*3600*1*24
                    land_mask = repmat(land_mask,[1,1,size(Velement.Zp_avg,3),1]);  % 1800*3600*2*24
                    Velement.Zp_avg(land_mask) = NaN;
                end
                if SWITCH.pp
                    Velement.Pp_avg(:,:,idep,:)= sum(coefficient.*VAelement.Pp_sgm,3,"omitnan");
                    land_mask = isnan(VAelement.Pp_sgm(:,:,1,:));  % 1800*3600*1*24
                    land_mask = repmat(land_mask,[1,1,size(Velement.Pp_avg,3),1]);  % 1800*3600*2*24
                    Velement.Pp_avg(land_mask) = NaN;
                end
                if SWITCH.sand
                    Velement.Sand_avg(:,:,idep,:)= sum(coefficient.*VAelement.Sand_sgm,3,"omitnan");
                    land_mask = isnan(VAelement.Sand_sgm(:,:,1,:));  % 1800*3600*1*24
                    land_mask = repmat(land_mask,[1,1,size(Velement.Sand_avg,3),1]);  % 1800*3600*2*24
                    Velement.Sand_avg(land_mask) = NaN;
                end
                clear Deplev_use Deplev_interval sum_depth_avg coefficient close land_mask idep
            end
            Delement.Depth_avg = Avg_depth;
        end
        clear Deplev
        % <----- avg_level
        % -----> std_level
        if SWITCH.out_std_level
            if SWITCH.temp
                Velement.Temp_std = Temp; 
            end
            if SWITCH.salt
                Velement.Salt_std = Salt;
            end
            if SWITCH.u
                Velement.U_std = U; 
            end
            if SWITCH.v
                Velement.V_std = V;
            end
            if SWITCH.w
                Velement.W_std = W; 
            end
            if SWITCH.ph
                Velement.Ph_std = Ph;
            end
            if SWITCH.no3
                Velement.No3_std = No3;
            end
            if SWITCH.pco2
                Velement.Pco2_std = Pco2;
            end
            if SWITCH.chlo
                Velement.Chlo_std = Chlo;
            end
            if SWITCH.zp
                Velement.Zp_std = Zp;
            end
            if SWITCH.pp
                Velement.Pp_std = Pp;
            end
            if SWITCH.sand
                Velement.Sand_std = Sand;
            end
            Delement.Depth_std = Depth_std;
        end
        clear Temp Salt U V W Zeta Aice Ph No3 Pco2 Chlo Casfco2 Zp Pp Sand
        % <----- std_level
        % -----> sgm_level
        if SWITCH.out_sgm_level
            Level_sgm  = int64(Level_sgm);
            if min(Level_sgm) < 1 || max(Level_sgm) > size(Depth,3)
                error('Level_sgm exceed the range of sigma level')
            end
            if SWITCH.temp
                Velement.Temp_sgm = VAelement.Temp_sgm(:,:,Level_sgm,:);
            end
            if SWITCH.salt
                Velement.Salt_sgm = VAelement.Salt_sgm(:,:,Level_sgm,:);
            end
            if SWITCH.u
                Velement.U_sgm = VAelement.U_sgm(:,:,Level_sgm,:);
            end
            if SWITCH.v
                Velement.V_sgm = VAelement.V_sgm(:,:,Level_sgm,:);
            end
            if SWITCH.w
                Velement.W_sgm = VAelement.W_sgm(:,:,Level_sgm,:);
            end
            if SWITCH.ph
                Velement.Ph_sgm = VAelement.Ph_sgm(:,:,Level_sgm,:);
            end
            if SWITCH.no3
                Velement.No3_sgm = VAelement.No3_sgm(:,:,Level_sgm,:);
            end
            if SWITCH.pco2
                Velement.Pco2_sgm = VAelement.Pco2_sgm(:,:,Level_sgm,:);
            end
            if SWITCH.chlo
                Velement.Chlo_sgm = VAelement.Chlo_sgm(:,:,Level_sgm,:);
            end
            if SWITCH.zp
                Velement.Zp_sgm = VAelement.Zp_sgm(:,:,Level_sgm,:);
            end
            if SWITCH.pp
                Velement.Pp_sgm = VAelement.Pp_sgm(:,:,Level_sgm,:);
            end
            if SWITCH.sand
                Velement.Sand_sgm = VAelement.Sand_sgm(:,:,Level_sgm,:);
            end
            Delement.Siglay = Siglay(:,:,Level_sgm); clear Siglay

            Delement.Bathy = Depth_origin_to_wrf_grid;
        end
        clear VAelement
        % <----- sgm_level

        clear ncfile

        %% mask vertical data
        if SWITCH.out_std_level
            osprint2('INFO',[pad('Masking depth of data greater than bathy ',Text_len,'right'),'--> ', logical_to_char(SWITCH.vertical_mask)])
            file_mask = para_conf.MaskVerticalmatFile;
            if SWITCH.make_mask
                tt5 = tic;
                Standard_depth_mask = make_mask_depth_data(Depth_origin_to_wrf_grid, Delement.Depth_std); 
                [~, Standard_depth_mask] = ll_to_ll(Lon, Standard_depth_mask);
                delete(file_mask)
                save(file_mask,'Standard_depth_mask','-v7.3','-nocompression');
                osprint2('INFO', [pad('Calculate depth mask costs ',Text_len,'right'),'--> ', num2str(toc(tt5)),' s'])
            else
                Standard_depth_mask = load(file_mask).Standard_depth_mask;
            end
            clear file_mask tt5
            if SWITCH.vertical_mask
                [VAelement,VBelement] = separate_var_by_name(Velement,'_std');
                VAelement = structfun(@(x) mask_depth_data(Standard_depth_mask, x), VAelement, 'UniformOutput', false);
                Velement = merge_struct(VAelement,VBelement);
                clear VAelement VBelement
                clear Standard_depth_mask
            end
        end
        clear Depth_origin_to_wrf_grid

        %% 岸线侵蚀
        if SWITCH.erosion
            file_erosion = para_conf.ErosionFile;
            num_erosion = para_conf.Erosion_num;
            osprint2('INFO',[pad('Erosion coastline ',Text_len,'right'),'--> ', logical_to_char(SWITCH.erosion)]);
            osprint2('INFO',[pad('Erosion coastline total frequency ',Text_len,'right'),'--> ', num2str(num_erosion)]);
            im = 0;
            while im < num_erosion
                osprint2('INFO',[pad('Erosion coastline counts ',Text_len,'right'),'--> ', num2str(im+1)]);
                if SWITCH.make_erosion
                    fields_Velement = fieldnames(Velement);
                    if im == 0
                        % I_D_1 = erosion_coast_cal_id(Lon, Lat, Velement.Temp_sgm, 16, 5);
                        I_D_1 = erosion_coast_cal_id(lon_dst, lat_dst, Velement.(fields_Velement{1}), 16, 5);
                        rmfiles(file_erosion);
                        save(file_erosion, 'I_D_1', '-v7.3','-nocompression');
                    else
                        % I_D_2 = erosion_coast_cal_id(lon_dst, lat_dst, Velement.(fields_Velement{1}), 16, 5);
                        eval( ['I_D_',num2str(im+1),' = erosion_coast_cal_id(lon_dst, lat_dst, Velement.',fields_Velement{1},', 16, 5);']);
                        % save(file_erosion, 'I_D_2', '-append','-nocompression');
                        eval(['save(file_erosion, ''I_D_',num2str(im+1),''', ''-append'',''-nocompression'');']);
                    end
                else
                    % I_D_1 = load(file_erosion).I_D_1;
                    eval(['I_D_',num2str(im+1),' = load(file_erosion).I_D_',num2str(im+1),';']);
                end
                [VAelement,Velement,dimsMax] = separate_var_gt_nd(Velement);
                % VAelement = structfun(@(x) erosion_coast_via_id(I_D_1, x,'cycle_dim',dimsMax), VAelement, 'UniformOutput', false);
                eval(['VAelement = structfun(@(x) erosion_coast_via_id(I_D_',num2str(im+1),', x,''cycle_dim'',',num2str(dimsMax),'), VAelement, ''UniformOutput'', false);']);
                Velement = merge_struct(Velement,VAelement); clear VAelement
                im = im+1;
            end
            clear I_D_* file_erosion fields_Velement dimsMax im num_erosion
        end

        %% global attribute start date
        GA_start_date = [char(datetime("now","Format","yyyy-MM-dd")), '_00:00:00'];
        
        if SWITCH.DEBUG
            osprint2('WARNING','DEBUG mode is on, the output file will be saved in the current directory!')
            osprint2('WARNING','Stopping writing netcdf file!')
            keyboard
        end

        %% 写入
        if SWITCH.u || SWITCH.v || SWITCH.w
            file = fullfile(OutputDir.curr,['current',OutputRes,'.nc']);
            ncid = create_nc(file, 'NETCDF4');
            % [Velement_current,Velement] = rmfields_key_from_struct(Velement,{'Temp_std','Temp_sgm','Temp_avg','Salt_std','Salt_sgm','Salt_avg','Zeta','Aice','Ph_std','Ph_sgm','Ph_avg','No3_std','No3_sgm','No3_avg','Pco2_std','Pco2_sgm','Pco2_avg','Chlo_std','Chlo_sgm','Chlo_avg','Casfco2','Zp_std','Zp_sgm','Zp_avg','Pp_std','Pp_sgm','Pp_avg','Sand_std','Sand_sgm','Sand_avg'});
            [Velement_current,Velement] = getfields_key_from_struct(Velement,{'U_std','U_sgm','U_avg','V_std','V_sgm','V_avg','W_std','W_sgm','W_avg'});
            netcdf_fvcom.wrnc_current(ncid,Lon,Lat,Delement,time,Velement_current,GA_start_date,'conf',para_conf);
            clear Velement_current ncid file
        end

        if SWITCH.temp
            file = fullfile(OutputDir.temp,['temperature',OutputRes,'.nc']);
            ncid = create_nc(file, 'NETCDF4');
            % [Velement_temperature,Velement] = rmfields_key_from_struct(Velement,{'Salt_std','Salt_sgm','Salt_avg','Zeta','Aice','Ph_std','Ph_sgm','Ph_avg','No3_std','No3_sgm','No3_avg','Pco2_std','Pco2_sgm','Pco2_avg','Chlo_std','Chlo_sgm','Chlo_avg','Casfco2','Zp_std','Zp_sgm','Zp_avg','Pp_std','Pp_sgm','Pp_avg','Sand_std','Sand_sgm','Sand_avg'});
            [Velement_temperature,Velement] = getfields_key_from_struct(Velement,{'Temp_std','Temp_sgm','Temp_avg'});
            netcdf_fvcom.wrnc_temp(ncid,Lon,Lat,Delement,time,Velement_temperature,GA_start_date,'conf',para_conf)
            clear Velement_temperature ncid file
        end

        if SWITCH.salt
            file = fullfile(OutputDir.salt,['salinity',OutputRes,'.nc']);
            ncid = create_nc(file, 'NETCDF4');
            % [Velement_salt,Velement] = rmfields_key_from_struct(Velement,{'Zeta','Aice','Ph_std','Ph_sgm','Ph_avg','No3_std','No3_sgm','No3_avg','Pco2_std','Pco2_sgm','Pco2_avg','Chlo_std','Chlo_sgm','Chlo_avg','Casfco2','Zp_std','Zp_sgm','Zp_avg','Pp_std','Pp_sgm','Pp_avg','Sand_std','Sand_sgm','Sand_avg'});
            [Velement_salt,Velement] = getfields_key_from_struct(Velement,{'Salt_std','Salt_sgm','Salt_avg'});
            netcdf_fvcom.wrnc_salt(ncid,Lon,Lat,Delement,time,Velement_salt,GA_start_date,'conf',para_conf);
            clear Velement_salt ncid file
        end

        if SWITCH.adt
            file = fullfile(OutputDir.adt,['adt',OutputRes,'.nc']);
            ncid = create_nc(file, 'NETCDF4');
            % [Velement_adt,Velement] = rmfields_key_from_struct(Velement,{'Aice','Ph_std','Ph_sgm','Ph_avg','No3_std','No3_sgm','No3_avg','Pco2_std','Pco2_sgm','Pco2_avg','Chlo_std','Chlo_sgm','Chlo_avg','Casfco2','Zp_std','Zp_sgm','Zp_avg','Pp_std','Pp_sgm','Pp_avg','Sand_std','Sand_sgm','Sand_avg'});
            [Velement_adt,Velement] = getfields_key_from_struct(Velement,{'Zeta'});
            netcdf_fvcom.wrnc_adt(ncid,Lon,Lat,time,Velement_adt.Zeta,GA_start_date,'conf',para_conf);
            clear Velement_adt ncid file
        end

        if SWITCH.aice
            file = fullfile(OutputDir.ice,['ice',OutputRes,'.nc']);
            ncid = create_nc(file, 'NETCDF4');
            % [Velement_ice,Velement] = rmfields_key_from_struct(Velement,{'Ph_std','Ph_sgm','Ph_avg','No3_std','No3_sgm','No3_avg','Pco2_std','Pco2_sgm','Pco2_avg','Chlo_std','Chlo_sgm','Chlo_avg','Casfco2','Zp_std','Zp_sgm','Zp_avg','Pp_std','Pp_sgm','Pp_avg','Sand_std','Sand_sgm','Sand_avg'});
            [Velement_ice,Velement] = getfields_key_from_struct(Velement,{'Aice'});
            netcdf_fvcom.wrnc_ice(ncid,Lon,Lat,time,Velement_ice.Aice,GA_start_date,'conf',para_conf);
            clear Velement_ice ncid file
        end

        if SWITCH.ph
            file = fullfile(OutputDir.ph,['ph',OutputRes,'.nc']);
            ncid = create_nc(file, 'NETCDF4');
            % [Velement_ph,Velement] = rmfields_key_from_struct(Velement,{'No3_std','No3_sgm','No3_avg','Pco2_std','Pco2_sgm','Pco2_avg','Chlo_std','Chlo_sgm','Chlo_avg','Casfco2','Zp_std','Zp_sgm','Zp_avg','Pp_std','Pp_sgm','Pp_avg','Sand_std','Sand_sgm','Sand_avg'});
            [Velement_ph,Velement] = getfields_key_from_struct(Velement,{'Ph_std','Ph_sgm','Ph_avg'});
            netcdf_fvcom.wrnc_ph_ersem(ncid,Lon,Lat,Delement,time,Velement_ph,GA_start_date,'conf',para_conf);
            clear Velement_ph ncid file
        end
        if SWITCH.no3
            file = fullfile(OutputDir.no3,['no3',OutputRes,'.nc']);
            ncid = create_nc(file, 'NETCDF4');
            % [Velement_no3,Velement] = rmfields_key_from_struct(Velement,{'Pco2_std','Pco2_sgm','Pco2_avg','Chlo_std','Chlo_sgm','Chlo_avg','Casfco2','Zp_std','Zp_sgm','Zp_avg','Pp_std','Pp_sgm','Pp_avg','Sand_std','Sand_sgm','Sand_avg'});
            [Velement_no3,Velement] = getfields_key_from_struct(Velement,{'No3_std','No3_sgm','No3_avg'});
            netcdf_fvcom.wrnc_no3_ersem(ncid,Lon,Lat,Delement,time,Velement_no3,GA_start_date,'conf',para_conf);
            clear Velement_no3 ncid file
        end
        if SWITCH.pco2
            file = fullfile(OutputDir.pco2,['pco2',OutputRes,'.nc']);
            ncid = create_nc(file, 'NETCDF4');
            % [Velement_pco2,Velement] = rmfields_key_from_struct(Velement,{'Chlo_std','Chlo_sgm','Chlo_avg','Casfco2','Zp_std','Zp_sgm','Zp_avg','Pp_std','Pp_sgm','Pp_avg','Sand_std','Sand_sgm','Sand_avg'});
            [Velement_pco2,Velement] = getfields_key_from_struct(Velement,{'Pco2_std','Pco2_sgm','Pco2_avg'});
            netcdf_fvcom.wrnc_pco2_ersem(ncid,Lon,Lat,Delement,time,Velement_pco2,GA_start_date,'conf',para_conf);
            clear Velement_pco2 ncid file
        end
        if SWITCH.chlo
            file = fullfile(OutputDir.chlo,['chlorophyll',OutputRes,'.nc']);
            ncid = create_nc(file, 'NETCDF4');
            % [Velement_chlo,Velement] = rmfields_key_from_struct(Velement,{'Casfco2','Zp_std','Zp_sgm','Zp_avg','Pp_std','Pp_sgm','Pp_avg','Sand_std','Sand_sgm','Sand_avg'});
            [Velement_chlo,Velement] = getfields_key_from_struct(Velement,{'Chlo_std','Chlo_sgm','Chlo_avg'});
            netcdf_fvcom.wrnc_chlo_ersem(ncid,Lon,Lat,Delement,time,Velement_chlo,GA_start_date,'conf',para_conf);
            clear Velement_chlo ncid file
        end
        if SWITCH.casfco2
            file = fullfile(OutputDir.casfco2,['casfco2',OutputRes,'.nc']);
            ncid = create_nc(file, 'NETCDF4');
            % [Velement_casfco2,Velement] = rmfields_key_from_struct(Velement,{'Zp_std','Zp_sgm','Zp_avg','Pp_std','Pp_sgm','Pp_avg','Sand_std','Sand_sgm','Sand_avg'});
            [Velement_casfco2,Velement] = getfields_key_from_struct(Velement,{'Casfco2'});
            netcdf_fvcom.wrnc_casfco2_ersem(ncid,Lon,Lat,time,Velement_casfco2.Casfco2,GA_start_date,'conf',para_conf);
            clear Velement_casfco2 ncid file
        end
        if SWITCH.zp
            file = fullfile(OutputDir.zp,['zooplankton',OutputRes,'.nc']);
            ncid = create_nc(file, 'NETCDF4');
            % [Velement_zp,Velement] = rmfields_key_from_struct(Velement,{'Pp_std','Pp_sgm','Pp_avg','Sand_std','Sand_sgm','Sand_avg'});
            [Velement_zp,Velement] = getfields_key_from_struct(Velement,{'Zp_std','Zp_sgm','Zp_avg'});
            netcdf_fvcom.wrnc_zp_nemuro(ncid,Lon,Lat,Delement,time,Velement_zp,GA_start_date,'conf',para_conf);
            clear Velement_zp ncid file
        end
        if SWITCH.pp
            file = fullfile(OutputDir.pp,['phytoplankton',OutputRes,'.nc']);
            ncid = create_nc(file, 'NETCDF4');
            % [Velement_pp,Velement] = rmfields_key_from_struct(Velement,{'Sand_std','Sand_sgm','Sand_avg'});
            [Velement_pp,Velement] = getfields_key_from_struct(Velement,{'Pp_std','Pp_sgm','Pp_avg'});
            netcdf_fvcom.wrnc_pp_nemuro(ncid,Lon,Lat,Delement,time,Velement_pp,GA_start_date,'conf',para_conf);
            clear Velement_pp ncid file
        end
        if SWITCH.sand
            file = fullfile(OutputDir.sand,['sand',OutputRes,'.nc']);
            ncid = create_nc(file, 'NETCDF4');
            % [Velement_sand,Velement] = rmfields_key_from_struct(Velement,{''});
            [Velement_sand,Velement] = getfields_key_from_struct(Velement,{'Pp_std','Pp_sgm','Pp_avg'});
            netcdf_fvcom.wrnc_sand_nemuro(ncid,Lon,Lat,Delement,time,Velement_sand,GA_start_date,'conf',para_conf);
            clear Velement_csand ncid file
        end

        clear Lon Lat Depth time TIME TIME_* Ttimes Velement
        clear time_filename
        clear OutputDir_*
        clear GA_start_date
    end

    clear dr1 Length % 循环天数
    clear lon_dst lat_dst Level_sgm Depth_std Delement % 网格信息 变量
    clear Avg_depth
    clear *path *Dir % 路径 文件名 信息等
    clear OutputRes  % suffix
    clear f_nc     % f_load_grid.struct
    clear conf_file para_conf SWITCH  % 配置
    clear Method_interpn % 插值方法
    clear file_Mcasename
    clear varargin
    clear Ecology_model
    osprint2('INFO', [pad(['GivenDate ',char(getdate),' interval ',interval,' costs '], Text_len,'right'),'--> ', num2str(toc(tt1)),' s'])
    clear getdate interval tt1 Text_len % 基准天 间隔  计时 字符长度
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

function SWITCH = read_switch(structIn)
    % 从structIn中读取以SWITCH_开头的变量，将变量写入到SWITCH结构体中
    % eg: 将structIn中的Switch_erosion写入到SWITCH.erosion中
    SWITCH = struct();
    key = fieldnames(structIn);
    for i = 1 : length(key)
        if ~isempty(regexp(key{i},'^Switch_','once'))
            SWITCH.(key{i}(8:end)) = structIn.(key{i});
        end
    end
end

function [Struct1,Struct2,dimsMax] = separate_var_gt_nd(structIn, ndim)
    % 将维度最多的变量写入到Struct1中，其余变量写入到Struct2中
    Struct1 = struct; Struct2 = struct;
    if exist("ndim","var")
        dimsMax = ndim;
    else
        dimsMax = max(cellfun(@ndims,struct2cell(structIn)));
    end
    key = fieldnames(structIn);
    for i = 1 : length(key)
        if ndims(structIn.(key{i})) >= dimsMax
            Struct1.(key{i}) = structIn.(key{i});
        else
            Struct2.(key{i}) = structIn.(key{i});
        end
    end
end

function [Struct1,Struct2] = separate_var_gt_nd_old(structIn,ndim)
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

function [Struct1,Struct2] = separate_var_by_name(structIn, txt)
    % 从struct中分离含有txt的键值对，将含有txt的键值对写入到Struct1中，其余写入到Struct2中
    Struct1 = struct();
    Struct2 = struct();

    % 直接遍历并检查字段名是否包含 '_std'
    for field = fieldnames(structIn)'
        if contains(field{1}, txt)
            Struct1.(field{1}) = structIn.(field{1});
        else
            Struct2.(field{1}) = structIn.(field{1});
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

function [Struct1,Struct2] = getfields_key_from_struct(structIn,keysIn)
    % Struct1 --> 从struct中保留指定key的变量 | Struct2 --> 从struct中删除指定key的变量 
    Struct1 = struct();
    Struct2 = struct();
    key = fieldnames(structIn);
    for i = 1 : length(key)
        if any(strcmp(key{i},keysIn))
            Struct1.(key{i}) = structIn.(key{i});
        else
            Struct2.(key{i}) = structIn.(key{i});
        end
    end
end

function matStr = warningText(Avg_depth)
    [rows, cols] = size(Avg_depth);  % 获取矩阵的大小
    matStr = '[';  % 初始化字符串
    for i = 1 : rows  % 遍历矩阵并构建字符串
        for j = 1 : cols
            matStr = [matStr, num2str(Avg_depth(i, j))];  %#ok<AGROW>
            if j < cols
                matStr = [matStr, ','];  %#ok<AGROW>
            end
        end
        if i < rows
            matStr = [matStr, ';'];  %#ok<AGROW>
        end
    end
    matStr = [matStr, ']'];  % 关闭字符串
end
