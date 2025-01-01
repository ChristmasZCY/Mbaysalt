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
    %       2023-**-**:     Created,                                                            by Christmas;
    %       2023-**-**:     Adjusted method of calculate to rectangule grid,                    by Christmas;
    %       2023-**-**:     Added vertical mask,                                                by Christmas;
    %       2023-**-**:     Added out sgm level and std level,                                  by Christmas;
    %       2023-**-**:     Added switch of output each value,                                  by Christmas;
    %       2023-12-29:     Added average depth output,                                         by Christmas;
    %       2023-12-29:     Added output casfco2,                                               by Christmas;
    %       2024-01-03:     Fixed aligning of osprint2,                                         by Christmas;
    %       2024-01-03:     Added Avg_depth wrong warning,                                      by Christmas;
    %       2024-01-07:     Added nemuro output(chlo,no3,zp,pp,sand),                           by Christmas;
    %       2024-01-25:     Added limit for ecological element(ph, no3, pco2, chlo, casfco2),   by Christmas;
    %       2024-04-01:     Fixed separate var to vertical mask,                                by Christmas;
    %       2024-04-01:     Added two parameters at conf file,                                  by Christmas;
    %       2024-04-04:     Added ua va,                                                        by Christmas;
    %       2024-04-08:     Fixed 'struct()' to struct(''),                                     by Christmas;
    %       2024-05-12:     Added check isempty(fncValue_nzt) in Siqi_interp,                   by Christmas;
    %       2024-05-12:     Fixed 'f_nc.x,f_nc.x' to 'f_nc.x,f_nc.y',                           by Christmas;
    %       2024-05-12:     Added disp info,                                                    by Christmas;
    %       2024-05-21:     Changed read_switch to read_start,                                  by Christmas;
    %       2024-05-21:     Added extrapolation for Siqi_interp and ESMF,                       by Christmas;
    %       2024-07-25:     Added postprocess tri-WW3,                                          by Christmas;
    %       2024-12-10:     Changed Switch name,                                                by Christmas;
    %       2024-12-10:     Added Tice,                                                         by Christmas;
    %       2024-12-10:     Added check_conf,                                                   by Christmas;
    %       2024-12-24:     Added output zeta with depth,                                       by Christmas;
    %       2024-12-24:     Changed 'Switch_zeta_with_depth' to Switch_zeta_wet_dry,            by Christmas;
    % =================================================================================================================
    % Example:
    %       Postprocess_fvcom('Post_fvcom.conf','hourly',20241227,1)
    %       Postprocess_fvcom('Post_fvcom.conf','daily', 20241227,1)
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

    para_conf       = check_conf(conf_file);            % 读取配置文件, 检查conf是否缺少参数
    Inputpath       = para_conf.ModelOutputDir;         % 输入路径          --> '/home/ocean/ForecastSystem/FVCOM_Global/Run/'
    Outputpath      = para_conf.StandardDir;            % 输出路径          --> '/home/ocean/ForecastSystem/Output/Standard/'
    file_Mcasename  = para_conf.ModelCasename;          % fvcom的casename  --> 'forecast'
    OutputRes       = para_conf.OutputRes;              % 生成文件的后缀     --> _global_5
    Method_interpn  = para_conf.Method_interpn;         % 插值方法          --> 'Siqi_interp'
    lon_dst         = para_conf.Lon_destination;        % 模型的经度范围     --> [-180,180]
    lat_dst         = para_conf.Lat_destination;        % 模型的纬度范围     --> [20,30]
    Ecology_model   = para_conf.Ecology_model;          % 生态模型          --> '.ERSEM.' or '.NEMURO.' or '.NONE.'
    Model_name      = para_conf.Model_name;             % 模型名称          --> '.FVCOM.' or  '.WW3.'   or '.NONE.'
    Text_len        = para_conf.Text_len;               % 打印字符的对齐长度
    SWITCH          = read_start(para_conf, 'Switch');  % 读取开关

    if ~SWITCH.out_std_level && ~SWITCH.out_sgm_level && ~SWITCH.out_avg_level && ~SWITCH.vel_average && ~SWITCH.wave && ~SWITCH.zeta  % 至少输出一种层
        error('At least one of the three output levels or ''vel_average'' or ''wave'' or ''zeta'' must be selected !')
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
                warning("Wrong set Avg_depth in '%s' line %d, with '%s' \n " + ...
                        "Maybe you want to set %s", conf_file, line_id(1), list_content{1}, warningText(Avg_depth))
            end
        end
    end

    getdate = datetime(num2str(yyyymmdd),"format","yyyyMMdd"); clear yyyymmdd
    Length = day_length;clear day_length;  % 当天开始向后处理的天数

    osprint2('INFO', [pad('Inputpath ',             Text_len,'right'),'--> ', Inputpath]);
    osprint2('INFO', [pad('Output standard depth ', Text_len,'right'),'--> ', logical_to_char(SWITCH.out_std_level)]);     % 输出是否输出标准层
    osprint2('INFO', [pad('Output sigma levels ',   Text_len,'right'),'--> ', logical_to_char(SWITCH.out_sgm_level)]);     % 输出是否输出sigma层
    osprint2('INFO', [pad('Output average depth ',  Text_len,'right'),'--> ', logical_to_char(SWITCH.out_avg_level)]);     % 输出是否输出垂向平均层

    osprint2('INFO', [pad('Date parameter ',Text_len,'right'),'--> ', sprintf('%s + %s days',char(getdate), num2str(Length))]); % 输出处理的日期信息
    osprint2('INFO', [pad('Interp Method ', Text_len,'right'),'--> ', Method_interpn]);                                         % 输出插值方法
    osprint2('INFO', [pad('Switch Extrap ', Text_len,'right'),'--> ', logical_to_char(SWITCH.extrap)]);                         % 输出是否外插

    osprint2('INFO', [pad(['Transfor ',interval,' variable '],Text_len,'right'), '-->', ...
        repmat(' temp',SWITCH.temp), repmat(' salt',SWITCH.salt), repmat(' zeta',SWITCH.zeta), ...
        repmat(' wet_dry',SWITCH.zeta_wet_dry), ...
        repmat(' u v',SWITCH.vel_all), repmat(' w',SWITCH.vel_vertical), ...
        repmat(' ua va',SWITCH.vel_average), repmat(' ice',SWITCH.ice), ...
        repmat(' ph',SWITCH.ph), repmat(' no3',SWITCH.no3), repmat(' pco2',SWITCH.pco2), ...
        repmat(' chlo',SWITCH.chlo), repmat(' casfco2',SWITCH.casfco2), repmat(' zp',SWITCH.zp), ...
        repmat(' pp',SWITCH.pp), repmat(' sand',SWITCH.sand), ...
        repmat(' swh',SWITCH.swh),   repmat(' mwd',SWITCH.mwd),   repmat(' mwp',SWITCH.mwp), ...
        repmat(' shww',SWITCH.shww), repmat(' mdww',SWITCH.mdww), repmat(' mpww',SWITCH.mpww), ...
        repmat(' shts',SWITCH.shts), repmat(' mdts',SWITCH.mdts), repmat(' mpts',SWITCH.mpts)])  % 打印处理的变量

    for dr = 1 : Length
        dr1 = dr-1;
        deal_date_dt = dateshift(getdate,'start','day',dr1);
        deal_date = char(datetime(deal_date_dt,"format","yyyyMMdd"));
        ModelOUTD = para_conf.ModelOUTD;
        if strcmp(interval,"daily")
            ncfile = fullfile(Inputpath,[char(getdate),filesep, ModelOUTD, filesep, file_Mcasename,'_avg_',num2str(dr,'%04d'),'.nc']); % 输入文件
        elseif strcmp(interval,"hourly")
            switch Model_name
            case {'.FVCOM.', '.ERSEM.', '.NEMURO.'}
                ncfile = fullfile(Inputpath,[char(getdate),     filesep, ModelOUTD, filesep, file_Mcasename,'_',num2str(dr,'%04d'),'.nc']); % 输入文件
            case '.WW3.'
                ncfile = fullfile(Inputpath,[char(deal_date_dt),filesep, ModelOUTD, filesep, file_Mcasename,'.',char(deal_date_dt),'.nc']); % 输入文件
            end
            
        end
        clear ModelOUTD

        if dr == 1 % 只有第一次需要读取经纬度
            SWITCH.read_ll_from_nc = para_conf.Switch_read_ll_from_nc; % 是否从nc文件中读取经纬度  --> True
            ll_file = para_conf.LLFile; % 经纬度文件  --> 'll.mat'
            if SWITCH.read_ll_from_nc
                f_nc = f_load_grid(ncfile,'Coordinate',para_conf.Load_Coordinate,'MaxLon',para_conf.MaxLon,'Nodisp');  % read grid
                makedirs(fileparts(ll_file));
                save(ll_file, 'f_nc', '-v7.3', '-nocompression');
            else
                f_nc = load(ll_file).f_nc;
            end
            clear ll_file SWITCH.read_ll_from_nc

            format_fmt = format;
            format('longG');
            f_res = minmax(f_calc_resolution(f_nc,para_conf.Load_Coordinate,'Nodisp'));

            osprint2('INFO', [pad('Model name ',               Text_len,'right'),'--> ', sprintf('%s',     Model_name)]);
            osprint2('INFO', [pad('Ecology model ',            Text_len,'right'),'--> ', sprintf('%s',     Ecology_model)]);
            osprint2('INFO', [pad('Ori lon range ',            Text_len,'right'),'--> ', sprintf('[%f %f]',(minmax(f_nc.x)))]);
            osprint2('INFO', [pad('Ori lat range ',            Text_len,'right'),'--> ', sprintf('[%f %f]',(minmax(f_nc.y)))]);
            osprint2('INFO', [pad('Ori res range (m) ',        Text_len,'right'),'--> ', sprintf('[%f %f]',(minmax(f_res)))]);
            osprint2('INFO', [pad('Dst lon range ',            Text_len,'right'),'--> ', sprintf('[%f %f]',(minmax(lon_dst)))]);
            osprint2('INFO', [pad('Dst lat range ',            Text_len,'right'),'--> ', sprintf('[%f %f]',(minmax(lat_dst)))]);
            osprint2('INFO', [pad('Dst res range (lon) (°)  ', Text_len,'right'),'--> ', sprintf('[%f %f]',(minmax(diff(lon_dst))))]);
            osprint2('INFO', [pad('Dst res range (lat) (°)  ', Text_len,'right'),'--> ', sprintf('[%f %f]',(minmax(diff(lat_dst))))]);
            format(format_fmt);
            clear f_res format_fmt
        end
        clear dr

        osprint2('INFO', [pad('Reading from ', Text_len,'right'),'--> ', ncfile]);

        Lon = lon_dst;
        Lat = lat_dst;

        % read nc file
        if SWITCH.temp
            fncValue_nzt.temp = double(ncread(ncfile,'temp'));
            OutputDir.temp = fullfile(Outputpath,'sea_temperature',interval,deal_date);  % temperature输出路径
        end
        if SWITCH.salt
            fncValue_nzt.salt = double(ncread(ncfile,'salinity'));
            OutputDir.salt = fullfile(Outputpath,'sea_salinity',interval,deal_date);  % salinity输出路径
        end
        if SWITCH.vel_all
            u = double(ncread(ncfile, 'u'));
            v = double(ncread(ncfile, 'v'));
        end
        if SWITCH.vel_vertical; w = double(ncread(ncfile, 'ww')); end
        if SWITCH.zeta
            fncValue_nt.zeta = double(ncread(ncfile,'zeta'));
            if SWITCH.zeta_wet_dry
                fncValue_nt.wet_nodes = double(ncread(ncfile,'wet_nodes'));
            end
            OutputDir.zeta = fullfile(Outputpath,'adt',interval,deal_date);  % adt输出路径
        end
        if SWITCH.vel_average
            ua = double(ncread(ncfile,'ua'));
            va = double(ncread(ncfile,'va'));
        end
        if SWITCH.ice % 是否包含海冰密集度  
            fncValue_nt.aice = double(ncread(ncfile,'aice'));  % a是密集度
            fncValue_nt.tice = double(ncread(ncfile,'vice'))./fncValue_nt.aice;  % 厚度是v/a
            OutputDir.ice = fullfile(Outputpath,'ice',interval,deal_date);  % ice输出路径
        end
        if SWITCH.ph % 是否包含ph
            if strcmpi(Ecology_model, '.ERSEM.')
                ph = double(ncread(ncfile,'O3_pH'));
            end
            fncValue_nzt.ph = limit_var(ph, [0,14]);
            clear ph
            OutputDir.ph = fullfile(Outputpath,'ph',interval,deal_date);  % ph输出路径
        end
        if SWITCH.no3 % 是否包含no3
            if strcmpi(Ecology_model, '.ERSEM.')
                no3 = double(ncread(ncfile,'N3_n'));
            elseif strcmpi(Ecology_model, '.NEMURO.')
                no3 = double(ncread(ncfile,'NO3')); % NO3 氮氧化物
            end
            fncValue_nzt.no3 = limit_var(no3, [0,400]);
            clear no3
            OutputDir.no3 = fullfile(Outputpath,'no3',interval,deal_date);  % no3输出路径
        end
        if SWITCH.pco2 % 是否包含pco2
            if strcmpi(Ecology_model, '.ERSEM.')
                pco2 = double(ncread(ncfile,'O3_pCO2'));
            end
            fncValue_nzt.pco2 = limit_var(pco2, [0,10000]);
            clear pco2
            OutputDir.pco2 = fullfile(Outputpath,'pco2',interval,deal_date);  % pco2输出路径
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
                % chlo = 1.38 * pp;  % Chunlin Yang
                chlo = 1.59 * pp;  % Haiqing Yu
                clear ps pl pp
            end
            fncValue_nzt.chlo = limit_var(chlo, [0,100]);
            clear chlo
            OutputDir.chlo = fullfile(Outputpath,'chlorophyll',interval,deal_date);  % chlorophyll输出路径
        end
        if SWITCH.casfco2 % 是否包含海气二氧化碳通量
            if strcmpi(Ecology_model, '.ERSEM.')
                casfco2 = double(ncread(ncfile,'O3_fair'));
            end
            fncValue_nt.casfco2 = limit_var(casfco2, [-300, 300]);
            clear casfco2
            OutputDir.casfco2 = fullfile(Outputpath,'casfco2',interval,deal_date);  % casfco2输出路径
        end
        if SWITCH.zp  % zooplankton zp 浮游动物
            if strcmpi(Ecology_model, '.NEMURO.')
                zp = double(ncread(ncfile,'ZP')); % ZP 食肉浮游动物
                zs = double(ncread(ncfile,'ZS')); % ZS 小型浮游动物
                zl = double(ncread(ncfile,'ZL')); % ZL 大型浮游动物
                fncValue_nzt.zp = zp+zs+zl;        % zooplankton zp 浮游动物
                clear zs zl zp
            end
            OutputDir.zp = fullfile(Outputpath,'zooplankton',interval,deal_date);  % zooplankton输出路径
        end
        if SWITCH.pp  % phytoplankton pp 浮游植物
            if strcmpi(Ecology_model, '.NEMURO.')
                ps = double(ncread(ncfile,'PS')); % PS 小型浮游植物
                pl = double(ncread(ncfile,'PL')); % PL 大型浮游植物
                fncValue_nzt.pp = ps+pl; % phytoplankton pp 浮游植物
                clear ps pl pp
            end
            OutputDir.pp = fullfile(Outputpath,'phytoplankton',interval,deal_date);  % phytoplankton输出路径
        end
        if SWITCH.sand  % 沙质
            if strcmpi(Ecology_model, '.NEMURO.')
                cs = double(ncread(ncfile,'coarse_sand')); % cs 粗沙
                ms = double(ncread(ncfile,'medium_sand')); % ms 中沙
                fs = double(ncread(ncfile,'fine_sand')); % fs 细沙
                fncValue_nzt.sand = cs+ms+fs; % 沙质
                clear cs ms fs
            end
            OutputDir.sand = fullfile(Outputpath,'sand',interval,deal_date);  % sand输出路径
        end
        if SWITCH.wave  % wave
            if strcmpi(Model_name, '.WW3.')
                % all
                if SWITCH.swh; fncValue_nt.swh = double(ncread(ncfile,'hs'));  end % swh
                if SWITCH.mwd; fncValue_nt.mwd = double(ncread(ncfile,'dir')); end % mwd
                if SWITCH.mwp; fncValue_nt.mwp = double(ncread(ncfile,'t02')); end % mwp
                % wind wave
                if SWITCH.shww; fncValue_nt.shww = double(ncread(ncfile,'phs0'));  end % shww
                if SWITCH.mdww; fncValue_nt.mdww = double(ncread(ncfile,'pdir0')); end % mdww 
                if SWITCH.mpww; fncValue_nt.mpww = double(ncread(ncfile,'ptp0'));  end % mpww 
                % swell wave
                if SWITCH.shts; fncValue_nt.shts = double(ncread(ncfile,'phs1'));  end % shts
                if SWITCH.mdts; fncValue_nt.mdts = double(ncread(ncfile,'pdir1')); end % mdts
                if SWITCH.mpts; fncValue_nt.mpts = double(ncread(ncfile,'ptp1'));  end % mpts
            end
            OutputDir.wave = fullfile(Outputpath,'wave',interval,deal_date);  % wave输出路径
        end

        if SWITCH.vel_all || SWITCH.vel_vertical || SWITCH.vel_average
            OutputDir.curr = fullfile(Outputpath,'current',interval,deal_date);  % current输出路径
        end

        if SWITCH.DEBUG  % 如果打开DEBUG模式,则OutputDir中的值都为'./'
            Fun_new_dir = @(x) './';
            OutputDir = structfun(Fun_new_dir,OutputDir,'UniformOutput',false);
            clear Fun_new_dir
        end
        structfun(@(x) makedirs(x),OutputDir); % 创建文件夹

        clear deal_date_dt deal_date % 日期处理中间变量

        %% time
        switch Model_name
        case {'.FVCOM.', '.ERSEM.', '.NEMURO.'}
            % TIME = datetime(1858,11,17)+ hours(Itime*24 + Itime2/(3600*1000));
            TIME = ncread(ncfile, 'Times')';
            if strcmp(interval,"daily")
                Times = datetime(TIME,'Format','yyyy-MM-dd''T''HH:mm:ssSSSSSS') - double(SWITCH.daily_1hour);
            elseif strcmp(interval,"hourly")
                Times = datetime(TIME,'Format','yyyy-MM-dd''T''HH:mm:ssSSSSSS');
            end
        case '.WW3.'
            Times = ncdateread(ncfile, 'time');
        end

        Ttimes = Mdatetime(Times);
        clear TIME Times
        time = Ttimes.time; % POSIX时间 1970 01 01 shell的date +%s

        if SWITCH.vel_all
            fncValue_nzt.u_int = f_interp_cell2node(f_nc, u);
            fncValue_nzt.v_int = f_interp_cell2node(f_nc, v);
        end
        if SWITCH.vel_vertical 
            fncValue_nzt.w_int = f_interp_cell2node(f_nc, w);
        end
        if SWITCH.vel_average
            fncValue_nt.ua_int = f_interp_cell2node(f_nc, ua);
            fncValue_nt.va_int = f_interp_cell2node(f_nc, va);
        end

        clear u v w ua va

        if ~exist("fncValue_nt", "var") ; fncValue_nt = struct('');  end
        if ~exist("fncValue_nzt", "var"); fncValue_nzt = struct(''); end

        % Lon                    --> x*1
        % Lat                    --> y*1
        % Ttimes                 --> t*1
        % fncValue_nzt.temp      --> node*sgm*t
        % fncValue_nzt.salt      --> node*sgm*t   
        % fncValue_nzt.u_int     --> node*sgm*t
        % fncValue_nzt.v_int     --> node*sgm*t
        % fncValue_nzt.w_int     --> node*sgm*t
        % fncValue_nzt.zp        --> node*sgm*t
        % fncValue_nzt.pp        --> node*sgm*t
        % fncValue_nzt.sand      --> node*sgm*t
        % fncValue_nzt.ph        --> node*sgm*t
        % fncValue_nzt.no3       --> node*sgm*t
        % fncValue_nzt.pco2      --> node*sgm*t
        % fncValue_nzt.chlo      --> node*sgm*t
        % fncValue_nt.zeta       --> node*t
        % fncValue_nt.casfco2    --> node*t
        % fncValue_nt.ua         --> node*t
        % fncValue_nt.va         --> node*t
        % fncValue_nt.aice       --> node*t
        % fncValue_nt.swh        --> node*t
        % fncValue_nt.mwd        --> node*t
        % fncValue_nt.mwp        --> node*t
        % fncValue_nt.shww       --> node*t
        % fncValue_nt.mdww       --> node*t
        % fncValue_nt.mpww       --> node*t
        % fncValue_nt.shts       --> node*t
        % fncValue_nt.mdts       --> node*t
        % fncValue_nt.mpts       --> node*t
        % fncValue_nt.wet_nodes  --> node*t

        switch Method_interpn
            case 'Siqi_interp'
                % weight
                file_weight = para_conf.WeightFile_Siqi_interp;
                if SWITCH.make_weight && dr1 ==0
                    [Lat_m,Lon_m] = meshgrid(Lat,Lon);
                    tt2 = tic;
                    if SWITCH.extrap
                        Weight_2d = interp_2d_calc_weight('TRI',f_nc.x,f_nc.y,f_nc.nv,Lon_m,Lat_m,'Extrap');
                    else
                        Weight_2d = interp_2d_calc_weight('TRI',f_nc.x,f_nc.y,f_nc.nv,Lon_m,Lat_m);
                    end
                    makedirs(fileparts(file_weight)); rmfiles(file_weight)
                    save(file_weight,'Weight_2d','-v7.3','-nocompression');
                    osprint2('INFO', [pad('Calculate 2d weight costs ',Text_len,'right'),'--> ', num2str(toc(tt2)),' s'])
                    clear Lon_m Lat_m tt2
                else
                    Weight_2d = load(file_weight).Weight_2d;
                end

                % Temp = interp_2d_via_weight(temp,Weight_2d);
                if ~isempty(fncValue_nt)
                    wncValue_xyt  = structfun(@(field) interp_2d_via_weight(field, Weight_2d), fncValue_nt, 'UniformOutput', false);
                end
                if ~isempty(fncValue_nzt)
                    wncValue_xyzt = structfun(@(field) interp_2d_via_weight(field, Weight_2d), fncValue_nzt, 'UniformOutput', false);
                end
                Depth_xy =  interp_2d_via_weight(f_nc.h,Weight_2d);
                % SWITCH
                if SWITCH.out_avg_level
                    Deplev = interp_2d_via_weight(f_nc.deplevc,Weight_2d);  % each sigma level depth(31) node
                end
                if SWITCH.out_std_level
                    Deplay = interp_2d_via_weight(f_nc.deplay,Weight_2d);   % each sigma layer depth(30) node
                end
                if SWITCH.out_sgm_level
                    Siglay = interp_2d_via_weight(f_nc.siglay,Weight_2d);
                end

                clear fncValue_nt fncValue_nzt
                clear file_weight Weight_2d

            case 'Siqi_ESMF'
                file_weight = para_conf.WeightFile_Siqi_ESMF;
                if SWITCH.make_weight && dr1 ==0
                    ESMF_conf = read_start(para_conf,'ESMF');
                    ESMF_default = make_DEFAULT_struct('ESMF');
                    ESMF = get_S1_key_from_S2_value(ESMF_default, ESMF_conf);
                    clear ESMF_conf ESMF_default
                    % ESMFMKFILE = ESMF.MKFILE;
                    GridFile_fvcom = para_conf.GridFile_fvcom;
                    GridFile_wrf = para_conf.GridFile_wrf;
                    [Lat_m,Lon_m] = meshgrid(Lat,Lon);  % 注意: Lat放在前面
                    tt3 = tic;
                    esmf_write_grid(GridFile_fvcom , 'FVCOM', f_nc.x,f_nc.y,f_nc.nv);
                    esmf_write_grid(GridFile_wrf,    'WRF',   Lon_m,Lat_m);
                    if SWITCH.extrap
                        esmf_regrid_weight(GridFile_fvcom, GridFile_wrf, ESMF.NCweightfile, ...
                            'exe', ESMF.exe, 'Src_loc', 'corner', 'Method', ESMF.RegridMethod,'Extrap',ESMF.ExtrapMethod); % temperature corner
                    else
                        esmf_regrid_weight(GridFile_fvcom, GridFile_wrf, ESMF.NCweightfile, ...
                            'exe', ESMF.exe, 'Src_loc', 'corner', 'Method', ESMF.RegridMethod); % temperature corner
                    end
                    Weight_2d = esmf_read_weight(ESMF.NCweightfile);

                    clear ans
                    makedirs(fileparts(file_weight)); rmfiles(file_weight)
                    save(file_weight,'Weight_2d','-v7.3','-nocompression');
                    clear Lon_m Lat_m
                    osprint2('INFO', [pad('Calculate 2d weight costs ',Text_len,'right'),'--> ', num2str(toc(tt3)),' s']);
                else
                    Weight_2d = load(file_weight).Weight_2d;
                end
                clear GridFile_fvcom GridFile_wrf file_weight tt3

                for it = 1 : length(time)  % for it = 1: size(temp,3) % time
                    for iz = 1 : f_nc.kbm1  % for iz = 1 : size(temp,2) % depth
                        % Temp(:,:,iz,it) =  esmf_regrid(temp(:,iz,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                        fields = fieldnames(fncValue_nzt);
                        for i = 1 : length(fields)
                            fieldName = fields{i}; % 当前字段名
                            wncValue_xyzt.(fieldName)(:,:,iz,it) = esmf_regrid(fncValue_nzt.(fieldName)(:, iz, it), Weight_2d, 'Dims',[length(Lon),length(Lat)]);
                        end
                        clear i fields fieldName

                        if it == 1  % 不随time变化，只需要计算一次
                            if SWITCH.out_std_level
                                Deplay(:,:,iz) =  esmf_regrid(f_nc.deplay(:,iz),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                            end
                            if SWITCH.out_sgm_level
                                Siglay(:,:,iz) =  esmf_regrid(f_nc.siglay(:,iz),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                            end
                        end
                    end
                    if SWITCH.out_avg_level
                        for iz = 1: f_nc.kb
                            Deplev(:,:,iz) =  esmf_regrid(f_nc.deplev(:,iz),Weight_2d,'Dims',[length(Lon),length(Lat)]); % each sigma level depth(31) node
                        end
                    end
                    % 不随深度变化
                    % Zeta(:,:,it) =  esmf_regrid(zeta(:,it),Weight_2d,'Dims',[length(Lon),length(Lat)]);
                    fields = fieldnames(fncValue_nt);
                    for i = 1 : length(fields)
                        fieldName = fields{i}; % 当前字段名
                        wncValue_xyt.(fieldName)(:,:,it) = esmf_regrid(fncValue_nt.(fieldName)(:,it), Weight_2d, 'Dims',[length(Lon),length(Lat)]);
                    end
                    clear i fieldName
                end
                Depth_xy = esmf_regrid(f_nc.h,Weight_2d,'Dims',[length(Lon),length(Lat)]); % depth of WRF grid
                clear fncValue_nt fncValue_nzt it iz
                clear Weight_2d
            otherwise
                error('Method_interpn must be Siqi_interp or Siqi_ESMF!')
        end

        % -----> Store
        Store_coor.Lon           = Lon;                   % --> x*1
        Store_coor.Lat           = Lat;                   % --> y*1
        Store_coor.Depth_xy      = Depth_xy;              % --> x*y             Depth Grid(Bathy)
        Store_coor.Ttimes        = Ttimes;                % --> t*1
        if SWITCH.out_std_level
            Store_coor.Depth_std = Depth_std;             % --> 1*level         (standard depth)
        end
        if SWITCH.out_avg_level
            Store_coor.Deplev    = Deplev;                % --> x*y*sgv         each sigma level depth(31) node
        end
        if SWITCH.out_std_level
            Store_coor.Deplay    = Deplay;                % --> x*y*sgm         each sigma layer depth(30) node
        end
        if SWITCH.out_sgm_level
            Store_coor.Siglay    = Siglay;                % --> x*y*sgm         each sigma layer   %  (30) node
        end
        if SWITCH.temp 
            Store_xyzt.Temp_sgm  = wncValue_xyzt.temp;    % --> x*y*sgm*t
        end
        if SWITCH.salt
            Store_xyzt.Salt_sgm  = wncValue_xyzt.salt;    % --> x*y*sgm*t
        end
        if SWITCH.vel_all
            Store_xyzt.U_sgm     = wncValue_xyzt.u_int;   % --> x*y*sgm*t
            Store_xyzt.V_sgm     = wncValue_xyzt.v_int;   % --> x*y*sgm*t
        end
        if SWITCH.vel_vertical
            Store_xyzt.W_sgm     = wncValue_xyzt.w_int;   % --> x*y*sgm*t
        end
        if SWITCH.ph
            Store_xyzt.Ph_sgm    = wncValue_xyzt.ph;      % --> x*y*sgm*t
        end
        if SWITCH.no3
            Store_xyzt.No3_sgm   = wncValue_xyzt.no3;     % --> x*y*sgm*t
        end
        if SWITCH.pco2
            Store_xyzt.Pco2_sgm  = wncValue_xyzt.pco2;    % --> x*y*sgm*t
        end
        if SWITCH.chlo
            Store_xyzt.Chlo_sgm  = wncValue_xyzt.chlo;    % --> x*y*sgm*t
        end
        if SWITCH.zp
            Store_xyzt.Zp_sgm   = wncValue_xyzt.zp;       % --> x*y*sgm*t
        end
        if SWITCH.pp
            Store_xyzt.Pp_sgm   = wncValue_xyzt.pp;       % --> x*y*sgm*t
        end
        if SWITCH.sand
            Store_xyzt.Sand_sgm = wncValue_xyzt.sand;     % --> x*y*sgm*t
        end
        if SWITCH.zeta
            Store_xyt.Zeta      = wncValue_xyt.zeta;      % --> x*y*t
        end
        if SWITCH.zeta_wet_dry
            Store_xyt.Wet_nodes = wncValue_xyt.wet_nodes; % --> x*y*t
        end
        if SWITCH.vel_average
            Store_xyt.Ua        = wncValue_xyt.ua_int;    % --> x*y*t
            Store_xyt.Va        = wncValue_xyt.va_int;    % --> x*y*t
        end
        if SWITCH.ice
            Store_xyt.Aice      = wncValue_xyt.aice;      % --> x*y*t
            Store_xyt.Tice      = wncValue_xyt.tice;      % --> x*y*t
        end
        if SWITCH.casfco2
            Store_xyt.Casfco2   = wncValue_xyt.casfco2;   % --> x*y*t
        end
        if SWITCH.swh
            Store_xyt.Swh       = wncValue_xyt.swh;       % --> x*y*t
        end
        if SWITCH.mwd
            Store_xyt.Mwd       = wncValue_xyt.mwd;       % --> x*y*t
        end
        if SWITCH.mwp
            Store_xyt.Mwp       = wncValue_xyt.mwp;       % --> x*y*t
        end
        if SWITCH.shww
            Store_xyt.Shww      = wncValue_xyt.shww;      % --> x*y*t
        end
        if SWITCH.mdww
            Store_xyt.Mdww      = wncValue_xyt.mdww;      % --> x*y*t
        end
        if SWITCH.mpww
            Store_xyt.Mpww      = wncValue_xyt.mpww;      % --> x*y*t
        end
        if SWITCH.shts
            Store_xyt.Shts      = wncValue_xyt.shts;      % --> x*y*t
        end
        if SWITCH.mdts
            Store_xyt.Mdts      = wncValue_xyt.mdts;      % --> x*y*t
        end
        if SWITCH.mpts
            Store_xyt.Mpts      = wncValue_xyt.mpts;      % --> x*y*t
        end
        clear Depth_xy
        clear Siglay Deplev Deplay
        clear wncValue_xyt wncValue_xyzt

        if ~exist("Store_xyzt","var")
            Store_xyzt = struct('');
        end
        if ~exist("Store_xyt","var")
            Store_xyt = struct('');
        end
        % <----- Store

        % -----> 2D
        if SWITCH.vel_average
            OutValue_xyt.Ua = Store_xyt.Ua;
            OutValue_xyt.Va = Store_xyt.Va;
        end
        if SWITCH.ice
            OutValue_xyt.Aice = Store_xyt.Aice;
            OutValue_xyt.Tice = Store_xyt.Tice;
        end
        if SWITCH.zeta;         OutValue_xyt.Zeta       = Store_xyt.Zeta;       end
        if SWITCH.zeta_wet_dry; OutValue_xyt.Wet_nodes  = Store_xyt.Wet_nodes;  end
        if SWITCH.casfco2;      OutValue_xyt.Casfco2    = Store_xyt.Casfco2;    end
        if SWITCH.swh;          OutValue_xyt.Swh        = Store_xyt.Swh;        end
        if SWITCH.mwd;          OutValue_xyt.Mwd        = Store_xyt.Mwd;        end
        if SWITCH.mwp;          OutValue_xyt.Mwp        = Store_xyt.Mwp;        end
        if SWITCH.shww;         OutValue_xyt.Shww       = Store_xyt.Shww;       end
        if SWITCH.mdww;         OutValue_xyt.Mdww       = Store_xyt.Mdww;       end
        if SWITCH.mpww;         OutValue_xyt.Mpww       = Store_xyt.Mpww;       end
        if SWITCH.shts;         OutValue_xyt.Shts       = Store_xyt.Shts;       end
        if SWITCH.mdts;         OutValue_xyt.Mdts       = Store_xyt.Mdts;       end
        if SWITCH.mpts;         OutValue_xyt.Mpts       = Store_xyt.Mpts;       end
        % <----- 2D

        % -----> sgm_level
        if SWITCH.out_sgm_level 
            Level_sgm  = int64(Level_sgm);
            if min(Level_sgm) < 1 || max(Level_sgm) > f_nc.kbm1
                error('Level_sgm exceed the range of sigma level')
            end
            % OutValue.Temp_sgm = Store_coor.Temp_sgm(:,:,Level_sgm,:);
            OutValue_xyzt = structfun(@(field) field(:,:,Level_sgm,:), Store_xyzt, 'UniformOutput', false);
            Delement.Siglay = Store_coor.Siglay(:,:,Level_sgm);
            Delement.Bathy  = Store_coor.Depth_xy;
        end
        % <----- sgm_level
        % -----> std_level
        if SWITCH.out_std_level  % 是否转换到标准层
            file_weight_vertical = para_conf.WeightFile_vertical;
            size_2d_to_1d_ll = size(Store_coor.Deplay,1)*size(Store_coor.Deplay,2);  % num of lon*lat

            if SWITCH.make_weight && dr1 ==0
                tt4 = tic;
                % Weight_vertical = interp_vertical_calc_weight(f_nc.deplay,repmat(Depth_std,f_nc.node,1));
                depth_2d_to_1d = reshape(Store_coor.Deplay,size_2d_to_1d_ll,[]);
                F_noNaN = find(~isnan(depth_2d_to_1d(:,1)),1);  % 找到第一个不是NaN的数字，否则interp_vertical_calc_weight会报错
                if isempty(F_noNaN)
                    osprint2('ERROR', 'Depth is all NaN'); error('Depth is all NaN')
                elseif F_noNaN ~= 1
                    depth_2d_to_1d = [depth_2d_to_1d(F_noNaN:end,:); depth_2d_to_1d(1:F_noNaN-1,:)];
                end
                Weight_vertical = interp_vertical_calc_weight(depth_2d_to_1d,repmat(Store_coor.Depth_std,size_2d_to_1d_ll,1)); 
                Weight_vertical = structfun(@(x) flip2_to_recover(x,F_noNaN), Weight_vertical, 'UniformOutput', false);  % 顺序转换回去
                makedirs(fileparts(file_weight_vertical));rmfiles(file_weight_vertical); clear F_noNaN depth_2d_to_1d
                save(file_weight_vertical, 'Weight_vertical','-v7.3','-nocompression');
                osprint2('INFO', [pad('Calculate vertical weight costs ',Text_len,'right'),'--> ', num2str(toc(tt4)),' s'])
            else
                Weight_vertical = load(file_weight_vertical).Weight_vertical;
            end
            clear file_weight_vertical size_2d_to_1d_ll tt4

            fields = fieldnames(Weight_vertical);
            for i = 1: length(fields)
                Weight_vertical.(fields{i}) = repmat(Weight_vertical.(fields{i}),length(Ttimes.time),1);
                % Weight_vertical.id1 = repmat(Weight_vertical.id1,length(?),1);
            end
            clear fields i

            fields = fieldnames(Store_xyzt);
            for i = 1 : length(fields)
                fieldName_sgm = fields{i}; % 当前字段名
                fieldName_std = [fieldName_sgm(1:end-4) '_std'];
                V_xytz1 = permute(Store_xyzt.(fieldName_sgm),[1,2,4,3]);
                V_xytz_l1 = reshape(V_xytz1,[],size(V_xytz1,4));
                V_xytz_l2 = interp_vertical_via_weight(V_xytz_l1,Weight_vertical);
                V_xytz2 = reshape(V_xytz_l2,[length(Lon),length(Lat),length(Ttimes.time),length(Depth_std)]); %#ok<NASGU>
                evalc(['OutValue_xyzt.' fieldName_std ' = permute(V_xytz2,[1,2,4,3]);']);
                clear V_xytz* V_xytz_l* fieldName_sgm fieldName_std ans
            end

            % Temp_xytz1 = permute(Store_xyz.Temp_sgm,[1,2,4,3]);
            % Temp_xytz_l1 = reshape(Temp_xytz1,[],size(Temp_xytz1,4));
            % Temp_xytz_l2 = interp_vertical_via_weight(Temp_xytz_l1,Weight_vertical);
            % Temp_xytz2 = reshape(Temp_xytz_l2,[length(Lon),length(Lat),length(Ttimes.time),length(Depth_std)]);
            % OutValue_xyzt.Temp_std = permute(Temp_xytz2,[1,2,4,3]); clear Temp_xytz* Temp_xytz_l*

            clear Weight_vertical i
            Delement.Depth_std  = Store_coor.Depth_std;
        end
        % <----- std_level
        % Temp Salt U V W Zeta ua va Depth Aice Ph No3 Pco2 Chlo Casfco2 Zp Pp Sand --> std_level
        % -----> avg_level
        if SWITCH.out_avg_level
            for idep = 1: size(Avg_depth,1)
                Deplev_use = Store_coor.Deplev;
                Deplev_use(Deplev_use < min(Avg_depth(idep,:))) = NaN;
                Deplev_use(Deplev_use > max(Avg_depth(idep,:))) = NaN;
                Deplev_interval = Deplev_use(:,:,2:end) - Deplev_use(:,:,1:end-1);  % 两层的差，每层的厚度
                sum_depth_avg = sum(Deplev_interval,3,"omitnan");
                coefficient = Deplev_interval./sum_depth_avg;
                % Store_xyzt为原始sgm层数，OutValue_xyzt中是输出的
                fields = fieldnames(Store_xyzt);
                for i = 1 : length(fields)
                    fieldName_sgm = fields{i}; % 当前字段名
                    fieldName_avg = [fieldName_sgm(1:end-4) '_avg'];
                    V_avg = zeros(length(Store_coor.Lon), length(Store_coor.Lat), size(Avg_depth,1), length(Store_coor.Ttimes));
                    V_avg(:,:,idep,:)= sum(coefficient.*Store_xyzt.(fieldName_sgm),3,"omitnan");
                    land_mask = isnan(Store_xyzt.(fieldName_sgm)(:,:,1,:));  % 1800*3600*1*24
                    land_mask = repmat(land_mask,[1,1,size(V_avg,3),1]);  % 1800*3600*2*24
                    V_avg(land_mask) = NaN; %#ok<NASGU>
                    evalc(['OutValue_xyzt.' fieldName_avg '= V_avg;']);
                    clear fieldName_sgm fieldName_avg V_avg land_mask ans
                end
                % OutValue.Temp_avg(:,:,idep,:)= sum(coefficient.*Store_xyzt.Temp_sgm,3,"omitnan");
                % land_mask = isnan(Store_xyzt.Temp_sgm(:,:,1,:));  % 1800*3600*1*24
                % land_mask = repmat(land_mask,[1,1,size(OutValue.Temp_avg,3),1]);  % 1800*3600*2*24
                % OutValue.Temp_avg(land_mask) = NaN;

                clear Deplev_use Deplev_interval sum_depth_avg coefficient idep i
            end
            Delement.Depth_avg = Avg_depth;
        end
        % <----- avg_level
        clear ncfile
        % Store_coor --> Lon Lat Depth_xy Ttimes Depth_std Deplev Deplay  Siglay
        % OutValue_xyzt --> *_sgm *_std *_avg
        % OutValue_xyt -->  Zeta Ua Va Aice Casfco2 Swh Mwd Mwp Shww Mdww Mpww Shts Mdts Mpts

        if ~exist("OutValue_xyt", "var");  OutValue_xyt = struct('');  end
        if ~exist("OutValue_xyzt", "var"); OutValue_xyzt = struct(''); end


        %% mask vertical data
        if SWITCH.out_std_level
            osprint2('INFO',[pad('Masking depth of data greater than bathy ',Text_len,'right'),'--> ', logical_to_char(SWITCH.vertical_mask)])
            file_mask = para_conf.MaskVerticalmatFile;
            if SWITCH.make_mask && dr1 ==0
                tt5 = tic;
                Standard_depth_mask = make_mask_depth_data(Store_coor.Depth_xy, Store_coor.Depth_std); 
                makedirs(fileparts(file_mask)); rmfiles(file_mask)
                save(file_mask,'Standard_depth_mask','-v7.3','-nocompression');
                osprint2('INFO', [pad('Calculate depth mask costs ',Text_len,'right'),'--> ', num2str(toc(tt5)),' s'])
            else
                Standard_depth_mask = load(file_mask).Standard_depth_mask;
            end
            clear file_mask tt5
            if SWITCH.vertical_mask
                if ~isempty(OutValue_xyzt)
                    [OutValue_std,OutValue_other] = separate_var_by_name(OutValue_xyzt,'_std');clear OutValue
                    OutValue_std = structfun(@(x) mask_depth_data(Standard_depth_mask, x), OutValue_std, 'UniformOutput', false);
                    OutValue_xyzt = merge_struct(OutValue_std, OutValue_other);
                    clear OutValue_std OutValue_other
                    clear Standard_depth_mask
                end
            end
        end

        %% 岸线侵蚀
        if SWITCH.erosion
            file_erosion = para_conf.ErosionFile;
            num_erosion = para_conf.Erosion_num;
            Erosion_judge = para_conf.Erosion_judge;
            osprint2('INFO',[pad('Erosion coastline ',                Text_len,'right'),'--> ', logical_to_char(SWITCH.erosion)]);
            osprint2('INFO',[pad('Erosion coastline total frequency ',Text_len,'right'),'--> ', num2str(num_erosion)]);
            
            im = 0;
            while im < num_erosion
                if SWITCH.make_erosion
                    if ~isempty(OutValue_xyzt)
                        fields = fieldnames(OutValue_xyzt);
                    else
                        osprint2('WARNING',[pad('Erosion coastline error1-1 ',Text_len-3,'right'),'--> ', 'No need to Erosion: No xyzt value']);
                        osprint2('WARNING',[pad('Erosion coastline error1-2 ',Text_len-3,'right'),'--> ', sprintf('Please set %s:Switch_erosion to ''.FALSE.''', conf_file)]);
                        break
                    end
                    osprint2('INFO',[pad('Erosion coastline counts ',Text_len,'right'),'--> ', num2str(im+1)]);
                    if im == 0
                        % I_D_1 = erosion_coast_cal_id(Lon, Lat, OutValue_xyzt.Temp_sgm, 16, 5);
                        I_D_1 = erosion_coast_cal_id(lon_dst, lat_dst, OutValue_xyzt.(fields{1}), Erosion_judge(1), Erosion_judge(2));
                        rmfiles(file_erosion);
                        save(file_erosion, 'I_D_1', '-v7.3','-nocompression');
                    else
                        % I_D_2 = erosion_coast_cal_id(lon_dst, lat_dst, OutValue_xyzt.(fields{1}), 16, 5);
                        evalc( ['I_D_',num2str(im+1),' = erosion_coast_cal_id(lon_dst, lat_dst, OutValue_xyzt.',fields{1},', ', num2str(Erosion_judge(1)), ', ' ,num2str(Erosion_judge(2)), ');']);
                        % save(file_erosion, 'I_D_2', '-append','-nocompression');
                        eval(['save(file_erosion, ''I_D_',num2str(im+1),''', ''-append'',''-nocompression'');']);
                    end
                else
                    % I_D_1 = load(file_erosion).I_D_1;
                    evalc(['I_D_',num2str(im+1),' = load(file_erosion).I_D_',num2str(im+1),';']);
                end
                Erosion_judge = eval(['I_D_',num2str(im+1),'.judgeNum']);  % 从文件中读取,防止更改判定值但没有打开制作的开关
                osprint2('INFO',[pad('Erosion coastline judge ',Text_len,'right'),'--> ', num2str(Erosion_judge)]);
                % [OutValue_more_dim,OutValue_less_dim,dimsMax] = separate_var_gt_nd(OutValue_xyzt); clear OutValue_xyzt
                % OutValue = structfun(@(x) erosion_coast_via_id(I_D_1, x,'cycle_dim',dimsMax), OutValue_xyzt, 'UniformOutput', false);
                dimsMax = max(cellfun(@ndims,struct2cell(OutValue_xyzt)));
                if dimsMax <= 2
                    dimsMax = 3;
                end
                eval(['OutValue_xyzt = structfun(@(x) erosion_coast_via_id(I_D_',num2str(im+1),', x,''cycle_dim'',',num2str(dimsMax),'), OutValue_xyzt, ''UniformOutput'', false);']);
                im = im+1;
            end
            clear I_D_* file_erosion fields dimsMax im num_erosion ans
        end
        % Store_coor --> Lon Lat Depth_xy Ttimes Depth_std Deplev Deplay Siglay
        % OutValue_xyzt --> *_sgm *_std *_avg
        % OutValue_xyt -->  Zeta Ua Va Aice Casfco2 Swh Mwd Mwp Shww Mdww Mpww Shts Mdts Mpts
        OutValue = merge_struct(OutValue_xyt, OutValue_xyzt);
        clear Store_xyt Store_xyzt OutValue_xyt OutValue_xyzt

        %% global attribute start date
        GA_start_date = [char(datetime("now","Format","yyyy-MM-dd")), '_00:00:00'];
        para_conf.NC_start = GA_start_date;
        
        if SWITCH.DEBUG
            osprint2('WARNING','DEBUG mode is on, the output file will be saved in the current directory!')
            osprint2('WARNING','Stopping writing netcdf file!')
            keyboard
        end

        if ~exist('Delement','var'); Delement = struct(''); end  % 当至输出ua va

        %% 写入
        if SWITCH.vel_all || SWITCH.vel_vertical || SWITCH.vel_average
            file = fullfile(OutputDir.curr,['current',OutputRes,'.nc']);
            ncid = create_nc(file, 'NETCDF4');
            [current_Struct,OutValue] = getfields_key_from_struct(OutValue,{'U_std','U_sgm','U_avg','V_std','V_sgm','V_avg','W_std','W_sgm','W_avg','Ua','Va'});
            netcdf_fvcom.wrnc_current(ncid,Lon,Lat,Delement,time,current_Struct,'conf',para_conf,'INFO','Text_len',Text_len);
            clear current_Struct ncid file
        end

        if SWITCH.temp
            file = fullfile(OutputDir.temp,['temperature',OutputRes,'.nc']);
            ncid = create_nc(file, 'NETCDF4');
            [temperature_Struct,OutValue] = getfields_key_from_struct(OutValue,{'Temp_std','Temp_sgm','Temp_avg'});
            netcdf_fvcom.wrnc_temp(ncid,Lon,Lat,Delement,time,temperature_Struct,'conf',para_conf,'INFO','Text_len',Text_len);
            clear temperature_Struct ncid file
        end

        if SWITCH.salt
            file = fullfile(OutputDir.salt,['salinity',OutputRes,'.nc']);
            ncid = create_nc(file, 'NETCDF4');
            [salt_Struct,OutValue] = getfields_key_from_struct(OutValue,{'Salt_std','Salt_sgm','Salt_avg'});
            netcdf_fvcom.wrnc_salt(ncid,Lon,Lat,Delement,time,salt_Struct,'conf',para_conf,'INFO','Text_len',Text_len);
            clear salt_Struct ncid file
        end

        if SWITCH.zeta
            file = fullfile(OutputDir.zeta,['adt',OutputRes,'.nc']);
            ncid = create_nc(file, 'NETCDF4');
            [zeta_Struct,OutValue] = getfields_key_from_struct(OutValue,{'Zeta','Wet_nodes'});
            if SWITCH.zeta_wet_dry
                netcdf_fvcom.wrnc_adt(ncid,Lon,Lat,time,zeta_Struct.Zeta,'conf',para_conf,'INFO','Text_len',Text_len,'Wet_nodes',int32(zeta_Struct.Wet_nodes),'Bathy',Store_coor.Depth_xy);  % Store_coor.Depth_xy <==> Delement.Bathy
            else
                netcdf_fvcom.wrnc_adt(ncid,Lon,Lat,time,zeta_Struct.Zeta,'conf',para_conf,'INFO','Text_len',Text_len);
            end
            clear zeta_Struct ncid file
        end

        if SWITCH.ice
            file = fullfile(OutputDir.ice,['ice',OutputRes,'.nc']);
            ncid = create_nc(file, 'NETCDF4');
            [aice_Struct,OutValue] = getfields_key_from_struct(OutValue,{'Aice','Tice'});
            netcdf_fvcom.wrnc_ice(ncid,Lon,Lat,time,aice_Struct,'conf',para_conf,'INFO','Text_len',Text_len);
            clear aice_Struct ncid file
        end

        if SWITCH.ph
            file = fullfile(OutputDir.ph,['ph',OutputRes,'.nc']);
            ncid = create_nc(file, 'NETCDF4');
            [ph_Struct,OutValue] = getfields_key_from_struct(OutValue,{'Ph_std','Ph_sgm','Ph_avg'});
            netcdf_fvcom.wrnc_ph_ersem(ncid,Lon,Lat,Delement,time,ph_Struct,'conf',para_conf,'INFO','Text_len',Text_len);
            clear ph_Struct ncid file
        end
        if SWITCH.no3
            file = fullfile(OutputDir.no3,['no3',OutputRes,'.nc']);
            ncid = create_nc(file, 'NETCDF4');
            [no3_Struct,OutValue] = getfields_key_from_struct(OutValue,{'No3_std','No3_sgm','No3_avg'});
            netcdf_fvcom.wrnc_no3_ersem(ncid,Lon,Lat,Delement,time,no3_Struct,'conf',para_conf,'INFO','Text_len',Text_len);
            clear no3_Struct ncid file
        end
        if SWITCH.pco2
            file = fullfile(OutputDir.pco2,['pco2',OutputRes,'.nc']);
            ncid = create_nc(file, 'NETCDF4');
            [pco2_Struct,OutValue] = getfields_key_from_struct(OutValue,{'Pco2_std','Pco2_sgm','Pco2_avg'});
            netcdf_fvcom.wrnc_pco2_ersem(ncid,Lon,Lat,Delement,time,pco2_Struct,'conf',para_conf,'INFO','Text_len',Text_len);
            clear pco2_Struct ncid file
        end
        if SWITCH.chlo
            file = fullfile(OutputDir.chlo,['chlorophyll',OutputRes,'.nc']);
            ncid = create_nc(file, 'NETCDF4');
            [chlo_Struct,OutValue] = getfields_key_from_struct(OutValue,{'Chlo_std','Chlo_sgm','Chlo_avg'});
            netcdf_fvcom.wrnc_chlo_ersem(ncid,Lon,Lat,Delement,time,chlo_Struct,'conf',para_conf,'INFO','Text_len',Text_len);
            clear chlo_Struct ncid file
        end
        if SWITCH.casfco2
            file = fullfile(OutputDir.casfco2,['casfco2',OutputRes,'.nc']);
            ncid = create_nc(file, 'NETCDF4');
            [casfco2_Struct,OutValue] = getfields_key_from_struct(OutValue,{'Casfco2'});
            netcdf_fvcom.wrnc_casfco2_ersem(ncid,Lon,Lat,time,casfco2_Struct.Casfco2,'conf',para_conf,'INFO','Text_len',Text_len);
            clear casfco2_Struct ncid file
        end
        if SWITCH.zp
            file = fullfile(OutputDir.zp,['zooplankton',OutputRes,'.nc']);
            ncid = create_nc(file, 'NETCDF4');
            [zp_Struct,OutValue] = getfields_key_from_struct(OutValue,{'Zp_std','Zp_sgm','Zp_avg'});
            netcdf_fvcom.wrnc_zp_nemuro(ncid,Lon,Lat,Delement,time,zp_Struct,'conf',para_conf,'INFO','Text_len',Text_len);
            clear zp_Struct ncid file
        end
        if SWITCH.pp
            file = fullfile(OutputDir.pp,['phytoplankton',OutputRes,'.nc']);
            ncid = create_nc(file, 'NETCDF4');
            [pp_struct,OutValue] = getfields_key_from_struct(OutValue,{'Pp_std','Pp_sgm','Pp_avg'});
            netcdf_fvcom.wrnc_pp_nemuro(ncid,Lon,Lat,Delement,time,pp_struct,'conf',para_conf,'INFO','Text_len',Text_len);
            clear pp_struct ncid file
        end
        if SWITCH.sand
            file = fullfile(OutputDir.sand,['sand',OutputRes,'.nc']);
            ncid = create_nc(file, 'NETCDF4');
            [sand_Struct,OutValue] = getfields_key_from_struct(OutValue,{'Sand_std','Sand_sgm','Sand_avg'});
            netcdf_fvcom.wrnc_sand_nemuro(ncid,Lon,Lat,Delement,time,sand_Struct,'conf',para_conf,'INFO','Text_len',Text_len);
            clear sand_Struct ncid file
        end
        if SWITCH.wave
            file = fullfile(OutputDir.wave,['wave',OutputRes,'.nc']);
            ncid = create_nc(file, 'NETCDF4');
            [wave_Struct,OutValue] = getfields_key_from_struct(OutValue,{'Swh','Mwd','Mwp','Swh','Mwd','Mwp','Shww','Mdww','Mpww','Shts','Mdts','Mpts'});
            netcdf_ww3.wrnc_wave(ncid,Lon,Lat,time,wave_Struct,'conf',para_conf,'INFO','Text_len',Text_len);
            clear Velement_csand ncid file
        end

        para_conf = rmfield(para_conf,'NC_start');
        clear Store_coor
        clear Lon Lat Deplay time Ttimes OutValue
        clear OutputDir
        clear GA_start_date
        clear Delement
    end

    clear lon_dst lat_dst
    clear dr1 Length % 循环天数
    clear Level_sgm Depth_std % 网格信息 变量
    clear Avg_depth
    clear Inputpath Outputpath
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
    % 从structIn中读取以Switch_开头的变量，将变量写入到SWITCH结构体中
    % eg: 将structIn中的Switch_erosion写入到SWITCH.erosion中
    warning('Abandon, please use ''read_start(%s,''Switch'')'' instead.', inputname(1))
    SWITCH = struct('');
    key = fieldnames(structIn);
    for i = 1 : length(key)
        if ~isempty(regexp(key{i},'^Switch_','once'))
            SWITCH(1).(key{i}(8:end)) = structIn.(key{i});
        end
    end
end

function S2 = read_start(structIn, prefix)
    % 从struct中读取以prefix_开头的变量，将变量写入到PATH结构体中
    % eg: 将struct中的Git_path写入到Git.path中
    S2 = struct('');
    key = fieldnames(structIn);
    pattern = sprintf('^%s_', prefix);  % ^Git_ | ^Switch_
    for i = 1 : length(key)
        if ~isempty(regexp(key{i},pattern,'once'))
            S2(1).(key{i}(length(pattern):end)) = structIn.(key{i});
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
            Struct1(1).(key{i}) = structIn.(key{i});
        else
            Struct2(1).(key{i}) = structIn.(key{i});
        end
    end
end

function [Struct1,Struct2] = separate_var_gt_nd_old(structIn,ndim)
    % 从struct中读取以维度>=ndim的变量，将变量写入到Struct1结构体中,其余变量写入到Struct2中
    Struct1 = struct(''); Struct2 = struct('');
    key = fieldnames(structIn);
    for i = 1 : length(key)
        if length(size(structIn.(key{i}))) >= ndim && ~isvector(structIn.(key{i}))
            Struct1(1).(key{i}) = structIn.(key{i});
        else
            Struct2(1).(key{i}) = structIn.(key{i});
        end
    end
end

function [Struct1,Struct2] = separate_var_by_name(structIn, txt)
    % 从struct中分离含有txt的键值对，将含有txt的键值对写入到Struct1中，其余写入到Struct2中
    Struct1 = struct('');
    Struct2 = struct('');

    % 直接遍历并检查字段名是否包含 'txt'
    for field = fieldnames(structIn)'
        if contains(field{1}, txt)
            Struct1(1).(field{1}) = structIn.(field{1});
        else
            Struct2(1).(field{1}) = structIn.(field{1});
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
    Struct1 = struct('');
    Struct2 = struct('');
    key = fieldnames(structIn);
    for i = 1 : length(key)
        if any(strcmp(key{i},keysIn))
            Struct1(1).(key{i}) = structIn.(key{i});
        else
            Struct2(1).(key{i}) = structIn.(key{i});
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

function S = make_DEFAULT_struct(field)
    switch upper(field)
    case 'ESMF'
        S(1).exe = 'none';
        S(1).NCweightfile  = 'none';
        S(1).MKFILE        = 'none';
        S(1).RegridMethod  = 'none';
        S(1).ExtrapMethod  = 'none';
    case ''
    otherwise
        error('%s is not definied!', field);
    end

end

function S = get_S1_key_from_S2_value(S1, S2)
    % S = get_S1_key_from_S2_value(ESMF_DEFAULT, ESMF_conf);
    S = struct('');
    fields = fieldnames(S1);
    for i = 1 : length(fields)
       field = fields{i};
        if isfield(S2, field)
            S(1).(field) = S2.(field);
        else
            S(1).(field) = S1.(field);
        end
    end

end

function CONF = gen_conf_DAFAULT()
    PATH.basepath = fileparts(fileparts(mfilename("fullpath")));
    Cfile = fullfile(PATH.basepath,'Configurefiles/Post_fvcom.conf');
    CONF = read_conf(Cfile);
end

function conf_OUTPUT = check_conf(conf_file)
    conf_INPUT     = read_conf(conf_file);  % 读取配置文件
    conf_DEFAULT   = gen_conf_DAFAULT();    % 读取默认配置文件
    fields_default = fieldnames(conf_DEFAULT);
    if ~isfield(conf_INPUT,'Method_interpn')
        error('''%s'' is not definied at ''%s'' !', 'Method_interpn', conf_INPUT.FILEPATH);
    end

    if strcmp(conf_INPUT.Method_interpn, 'Siqi_interp')  % Siqi_interp 不需要以下参数
        no_need_args = cellstr(["GridFile_fvcom","GridFile_wrf","WeightFile_Siqi_ESMF","ESMF_exe","ESMF_NCweightfile","ESMF_MKFILE","ESMF_RegridMethod","ESMF_ExtrapMethod"]);
        option_args = [conf_DEFAULT.OPTION_args, no_need_args];
    elseif strcmp(conf_INPUT.Method_interpn, 'Siqi_ESMF')  % Siqi_ESMF 不需要以下参数
        no_need_args = cellstr(["WeightFile_Siqi_interp"]);
        option_args = [conf_DEFAULT.OPTION_args, no_need_args];
    end
    clear no_need_args

    LACK_args = cell(0);
    icount = 1;

    for field = fields_default'
        if isfield(conf_INPUT,field{1})
            conf_OUTPUT = conf_INPUT.(field{1});
        else
            if ~ismember(field, option_args)
                LACK_args{icount} = field{1};
                icount = icount+1;
            end
        end
    end
    if ~isempty(LACK_args)
        error('''%s'' is not definied at ''%s'' !', strjoin(LACK_args,' & '), conf_INPUT.FILEPATH);
    end
    if double(conf_INPUT.VERSION_conf) < 3               % VERSION_conf 版本必须 >= 3
        [list_content, line_id] = grep(conf_file, 'VERSION_conf');
        error(['VERSION_conf must >= 3. !\n ' ...
               'But you set %s in ''%s'' line %d !'], string(list_content), conf_file, line_id)
    end
    if isfield(conf_INPUT, 'Ecology_model') && ~ismember(conf_INPUT.Ecology_model, {'.NEMURO.', '.ERSEM.', '.NONE.'})
        [list_content, line_id] = grep(conf_file, 'Ecology_model');
        error(['Ecology_model must be one of ''.NEMURO.'' or ''.ERSEM.'' or ''.NONE.'' !\n ' ...
               'But you set %s in ''%s'' line %d !'], string(list_content), conf_file, line_id)
    end
    if isfield(conf_INPUT, 'Model_name') && ~ismember(conf_INPUT.Model_name, {'.FVCOM.', '.ERSEM.', '.NEMURO.', '.WW3.', '.NONE.'})
        [list_content, line_id] = grep(conf_file, 'Model_name');
        error(['Model_name must be one of ''.FVCOM.'' or ''.ERSEM.'' or ''.NEMURO.'' or ''.WW3.'' or ''.NONE.'' !\n ' ...
               'But you set %s in ''%s'' line %d !'], string(list_content), conf_file, line_id)
    end
end
