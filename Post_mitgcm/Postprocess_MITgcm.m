function Postprocess_MITgcm(conf_file, interval, yyyymmdd, day_length, varargin)
    %       This function is used to postprocess the MITgcm output data&meta files.
    % =================================================================================================================
    % Parameters:
    %       conf_file: configure file                 || required: True || type: text    || example: 'Post_mitgcm.conf'
    %       interval: interval                        || reauired: True || type: text    || example: 'daily','hourly'
    %       yyyymmdd: date                            || required: True || type: double  || example: 20221110
    %       day_length: length of date                || required: True || type: double  || example: 5
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Update:
    %       2024-03-26:     Created,                                        by Christmas;
    %       2024-04-15:     Added AngleSN,AngleCS for u v,                  by Christmas;
    %       2024-04-15:     Changed SWITCH.u SWITCH.v to SWITCH.uv,         by Christmas;
    %       2024-08-28:     Changed judge erosion condition to conf file,   by Christmas；
    % =================================================================================================================
    % Example:
    %       Postprocess_MITgcm('Post_mitgcm.conf', 'hourly', 20240401, 1)
    %       Postprocess_MITgcm('Post_mitgcm.conf', 'daily', 20240401, 1)
    % =================================================================================================================
    % Reference:
    %       https://github.com/MITgcm/MITgcm/blob/master/utils/matlab/cs_grid/rotate_uv2uvEN.m (line 146 to end)
    % =================================================================================================================


    arguments(Input)
        conf_file {mustBeFile}
        interval {mustBeMember(interval,{'daily','hourly'})}
        yyyymmdd {mustBeFloat}
        day_length {mustBeFloat}
    end
    
    arguments(Repeating)
        varargin
    end

    %% 读取
    tt1 = tic; % 计时开始

    para_conf       = read_conf(conf_file);             % 读取配置文件
    Inputpath       = para_conf.ModelOutputDir;         % 输入路径  --> '/home/ocean/ForecastSystem/Output/GCM_output'
    Outputpath      = para_conf.StandardDir;            % 输出路径  --> '/home/ocean/ForecastSystem/Output/Standard'
    OutputRes       = para_conf.OutputRes;              % 生成文件的后缀  --> _gcm_llc540_6
    Method_interpn  = para_conf.Method_interpn;         % 插值方法  --> 'Siqi_interp'
    Method_read     = para_conf.Method_read;            % 读取方法  --> 'rdmds', 'fopen', 'ncread', 'gluemncbig', 'rdmnc'
    lon_dst         = para_conf.Lon_destination;        % 模型的经度范围  --> [-180,180]
    lat_dst         = para_conf.Lat_destination;        % 模型的纬度范围  --> [20,30]
    Text_len        = para_conf.Text_len;               % 打印字符的对齐长度
    steps           = para_conf.OutStack;               % 输出步数
    SWITCH          = read_switch(para_conf);           % 读取开关

    if SWITCH.warningtext;warning('on');else; warning('off');end  % 是否显示警告信息

    if SWITCH.out_std_level  % 标准层
        Depth_std = para_conf.Depth_std;
    end

    osprint2('INFO',[pad('Output standard depth ',Text_len,'right'),'--> ', logical_to_char(SWITCH.out_std_level)])

    getdate = datetime(num2str(yyyymmdd),"format","yyyyMMdd"); clear yyyymmdd
    Length = day_length;clear day_length;% 当天开始向后处理的天数

    osprint2('INFO', [pad('Date parameter ',Text_len,'right'),'--> ', char(getdate)])               % 输出处理的日期信息
    osprint2('INFO', [pad('Total transfor ',Text_len,'right'),'--> ', num2str(Length),' days'])     % 输出处理的日期信息
    osprint2('INFO', [pad('Interp Method ',Text_len,'right'),'--> ', Method_interpn])                      % 输出插值方法
    osprint2('INFO', [pad('Read Method ',Text_len,'right'),'--> ', Method_read])                    % 输出读取方法
    osprint2('INFO', [pad(['Transfor ',interval,' variable '],Text_len,'right'), '-->', repmat(' temp',SWITCH.temp),repmat(' salt',SWITCH.salt) ...
        repmat(' adt',SWITCH.adt),repmat(' uv',SWITCH.uv), repmat(' w',SWITCH.w)])  % 打印处理的变量

    for dr = 1 : Length
        dr1 = dr-1;
        deal_date_dt = dateshift(getdate,'start','day',dr1);
        deal_date = char(datetime(deal_date_dt,"format","yyyyMMdd"));

        OutputDir.curr = fullfile(Outputpath,'current',interval,deal_date);             % current输出路径
        OutputDir.salt = fullfile(Outputpath,'sea_salinity',interval,deal_date);        % salinity输出路径
        OutputDir.temp = fullfile(Outputpath,'sea_temperature',interval,deal_date);     % temperature输出路径
        OutputDir.adt = fullfile(Outputpath,'adt',interval,deal_date);                  % adt输出路径
        if SWITCH.DEBUG  % 如果打开DEBUG模式,则OutputDir中的值都为'./'
            Fun_new_dir = @(x) './';
            OutputDir = structfun(Fun_new_dir,OutputDir,'UniformOutput',false);
            clear Fun_new_dir
        end
        structfun(@(x) makedirs(x),OutputDir); % 创建文件夹

        %                    unloaded(s)    117-mitgcmuv(s)
        % rdmds				324.390431      1218.884205
        % fopen				287.991462		652.899055
        % only ncread		61.405180		128.456105
        % gluemncbig ncread					548.311748
        % rdmnc			 					
        %   GCM_grid.XC     -->     m*1
        %   GCM_grid.YC     -->     m*1
        %   GCM_grid.RC     -->     z1*1
        %   time            -->     t*1
        %   temp            -->     m*z1*t
        %   salt            -->     m*z1*t
        %   u               -->     m*z1*t
        %   v               -->     m*z1*t
        %   w               -->     m*z1*t
        %   zeta            -->     m*t
  
        switch Method_read
        case 'rdmds'
            if dr == 1 % 只有第一次需要读取经纬度
                GCMgridFile = para_conf.GCMgridFile; % 经纬度文件  --> 'XCYCRC.mat'
                if SWITCH.read_ll_from_dmeta
                    XC = rdmds(para_conf.XCFile);
                    YC = rdmds(para_conf.YCFile);
                    AngleCS = rdmds(para_conf.AngleCSFile);
                    AngleSN = rdmds(para_conf.AngleSNFile);
                    GCM_grid.XC = XC(:);
                    GCM_grid.YC = YC(:);
                    GCM_grid.RC = squeeze(rdmds(para_conf.RCFile));
                    GCM_grid.AngleCS = AngleCS;
                    GCM_grid.AngleSN = AngleSN;
                    GCM_grid.Bathy = fORC(para_conf.BathyFile);
                    makedirs(fileparts(GCMgridFile));
                    save(GCMgridFile, 'GCM_grid', '-v7.3', '-nocompression');
                    clear XC YC
                else
                    GCM_grid = load(GCMgridFile).GCM_grid;
                end
                clear GCMgridFile SWITCH.read_ll_from_dmeta
            end

            Times = NaT(steps,1);
            Times.Format = 'yyyyMMddHH';
            dmfile = struct();
            if SWITCH.temp
                temp = zeros(numel(GCM_grid.XC), length(GCM_grid.RC), steps);
            end
            if SWITCH.salt
                salt = zeros(numel(GCM_grid.XC), length(GCM_grid.RC), steps);
            end
            if SWITCH.uv2698
                u    = zeros(numel(GCM_grid.XC), length(GCM_grid.RC), steps);
                v    = zeros(numel(GCM_grid.XC), length(GCM_grid.RC), steps);
            end
            if SWITCH.w
                w    = zeros(numel(GCM_grid.XC), length(GCM_grid.RC), steps);
            end
            if SWITCH.adt
                zeta = zeros(numel(GCM_grid.XC), steps);
            end
            AngleCS = repmat(GCM_grid.AngleCS, [1,length(GCM_grid.RC),steps]);
            AngleSN = repmat(GCM_grid.AngleSN, [1,length(GCM_grid.RC),steps]);

            for ih = 1 : steps
                Times(ih) = deal_date_dt + hours(ih-1);
                if SWITCH.temp
                    dmfile(ih).T = fullfile(Inputpath,[char(deal_date),'/T.',char(Times(ih))]); % 输入文件
                    t_1 = rdmds(dmfile(ih).T);
                    temp(:,:,ih) = reshape(t_1,numel(GCM_grid.XC),length(GCM_grid.RC)); clear t_1
                end
                if SWITCH.salt
                    dmfile(ih).S = fullfile(Inputpath,[char(deal_date),'/S.',char(Times(ih))]); % 输入文件
                    s_1 = rdmds(dmfile(ih).S);
                    salt(:,:,ih) = reshape(s_1,numel(GCM_grid.XC),length(GCM_grid.RC)); clear s_1
                end
                if SWITCH.uv
                    dmfile(ih).U = fullfile(Inputpath,[char(deal_date),'/U.',char(Times(ih))]); % 输入文件
                    dmfile(ih).V = fullfile(Inputpath,[char(deal_date),'/V.',char(Times(ih))]); % 输入文件
                    u_xyz = rdmds(dmfile(ih).U); 
                    v_xyz = rdmds(dmfile(ih).V);
                    u_nz = reshape(u_xyz,numel(GCM_grid.XC),length(GCM_grid.RC)); clear u_xyz
                    v_nz = reshape(v_xyz,numel(GCM_grid.XC),length(GCM_grid.RC)); clear v_xyz
                    u_nz_ll = AngleCS.*u_nz - AngleSN.*v_nz;
                    v_nz_ll = AngleSN.*u_nz + AngleCS.*v_nz;
                    u(:,:,ih) = u_nz_ll; clear u_nz_ll u_nz
                    v(:,:,ih) = v_nz_ll; clear v_nz_ll v_nz
                end
                if SWITCH.w
                    dmfile(ih).W = fullfile(Inputpath,[char(deal_date),'/W.',char(Times(ih))]); % 输入文件
                    w_1 = rdmds(dmfile(ih).W);
                    w(:,:,ih) = reshape(w_1,numel(GCM_grid.XC),length(GCM_grid.RC)); clear w_1
                end
                if SWITCH.adt
                    dmfile(ih).E = fullfile(Inputpath,[char(deal_date),'/Eta.',char(Times(ih))]); % 输入文件
                    z_1 = rdmds(dmfile(ih).E);
                    zeta(:,ih) = z_1(:); clear z_1
                end
            end
            clear ih clear AngleCS AngleSN
        case 'fopen'
            if dr == 1 % 只有第一次需要读取经纬度
                GCMgridFile = para_conf.GCMgridFile; % 经纬度文件  --> 'XCYCRC.mat'
                if SWITCH.read_ll_from_dmeta
                    GCM_grid.XC = fORC([para_conf.XCFile, '.data']);
                    GCM_grid.YC = fORC([para_conf.YCFile, '.data']);
                    GCM_grid.RC = fORC([para_conf.RCFile, '.data']);
                    GCM_grid.AngleCS = fORC([para_conf.AngleCSFile, '.data']);
                    GCM_grid.AngleSN = fORC([para_conf.AngleSNFile, '.data']);
                    GCM_grid.Bathy = fORC(para_conf.BathyFile);
                    makedirs(fileparts(GCMgridFile));
                    save(GCMgridFile, 'GCM_grid', '-v7.3', '-nocompression');
                else
                    GCM_grid = load(GCMgridFile).GCM_grid;
                end
                clear GCMgridFile SWITCH.read_ll_from_dmeta
            end

            Times = NaT(steps,1);
            Times.Format = 'yyyyMMddHH';
            dmfile = struct();
            if SWITCH.temp
                temp = zeros(numel(GCM_grid.XC), length(GCM_grid.RC), steps);
            end
            if SWITCH.salt
                salt = zeros(numel(GCM_grid.XC), length(GCM_grid.RC), steps);
            end
            if SWITCH.uv
                u    = zeros(numel(GCM_grid.XC), length(GCM_grid.RC), steps);
                v    = zeros(numel(GCM_grid.XC), length(GCM_grid.RC), steps);
            end
            if SWITCH.w
                w    = zeros(numel(GCM_grid.XC), length(GCM_grid.RC), steps);
            end
            if SWITCH.adt
                zeta = zeros(numel(GCM_grid.XC), steps);
            end
            AngleCS = repmat(GCM_grid.AngleCS, [1,length(GCM_grid.RC),steps]);
            AngleSN = repmat(GCM_grid.AngleSN, [1,length(GCM_grid.RC),steps]);
            
            for ih = 1 : steps
                Times(ih) = deal_date_dt + hours(ih-1);
                if SWITCH.temp
                    dmfile(ih).T = fullfile(Inputpath,[char(deal_date),'/T.',char(Times(ih))]); % 输入文件
                    t_1 = fORC([dmfile(ih).T '.data']);
                    temp(:,:,ih) = reshape(t_1,numel(GCM_grid.XC),length(GCM_grid.RC)); clear t_1
                end
                if SWITCH.salt
                    dmfile(ih).S = fullfile(Inputpath,[char(deal_date),'/S.',char(Times(ih))]); % 输入文件
                    s_1 = fORC([dmfile(ih).S '.data']);
                    salt(:,:,ih) = reshape(s_1,numel(GCM_grid.XC),length(GCM_grid.RC)); clear s_1
                end
                if SWITCH.uv
                    dmfile(ih).U = fullfile(Inputpath,[char(deal_date),'/U.',char(Times(ih))]); % 输入文件
                    dmfile(ih).V = fullfile(Inputpath,[char(deal_date),'/V.',char(Times(ih))]); % 输入文件
                    u_1 = fORC([dmfile(ih).U '.data']);
                    v_1 = fORC([dmfile(ih).V '.data']);
                    u_nz = reshape(u_1,numel(GCM_grid.XC),length(GCM_grid.RC)); clear u_1
                    v_nz = reshape(v_1,numel(GCM_grid.XC),length(GCM_grid.RC)); clear v_1
                    u_nz_ll = AngleCS.*u_nz - AngleSN.*v_nz;
                    v_nz_ll = AngleSN.*u_nz + AngleCS.*v_nz;
                    u(:,:,ih) = u_nz_ll; clear u_nz_ll u_nz
                    v(:,:,ih) = v_nz_ll; clear v_nz_ll v_nz
                end
                if SWITCH.w
                    dmfile(ih).W = fullfile(Inputpath,[char(deal_date),'/W.',char(Times(ih))]); % 输入文件
                    w_1 = fORC([dmfile(ih).W '.data']);
                    w(:,:,ih) = reshape(w_1,numel(GCM_grid.XC),length(GCM_grid.RC)); clear w_1
                end
                if SWITCH.adt
                    dmfile(ih).E = fullfile(Inputpath,[char(deal_date),'/Eta.',char(Times(ih))]); % 输入文件
                    z_1 = fORC([dmfile(ih).E '.data']);
                    zeta(:,ih) = z_1(:); clear z_1
                end
            end
            clear ih AngleCS AngleSN
        case {'gluemncbig', 'ncread'}
            error('not completed!')
            system('cd /home/ocean/ForecastSystem/GCM_Global/Model/verification/llc_540_auto/run/mncall/ && ./gluemncbig -o X.nc state*.nc -2');
            temp = ncread('/home/ocean/ForecastSystem/GCM_Global/Model/verification/llc_540_auto/run/mncall/X.nc','Temp');
            salt = ncread('/home/ocean/ForecastSystem/GCM_Global/Model/verification/llc_540_auto/run/mncall/X.nc','S');
            u = ncread('/home/ocean/ForecastSystem/GCM_Global/Model/verification/llc_540_auto/run/mncall/X.nc','U');
            v = ncread('/home/ocean/ForecastSystem/GCM_Global/Model/verification/llc_540_auto/run/mncall/X.nc','V');
            w = ncread('/home/ocean/ForecastSystem/GCM_Global/Model/verification/llc_540_auto/run/mncall/X.nc','W');
            zeta = ncread('/home/ocean/ForecastSystem/GCM_Global/Model/verification/llc_540_auto/run/mncall/X.nc','Eta');
        case {'rdmnc'}
            error('Too slow, not completed!')
            % S = rdmnc('/home/ocean/ForecastSystem/GCM_Global/Model/verification/llc_540_auto/run/mncall/state.*','XC','YC','XG','YG','Z','Zl','U','V','T','W','Temp','S','Eta');
            S = rdmnc('/home/ocean/ForecastSystem/GCM_Global/Model/verification/llc_540_auto/run/mncall/state.*','S');
        otherwise
            error("Method_read must be one of 'rdmnc', 'ncread', 'gluemncbig', 'fopen', 'rdmds' !")
        end
        clear dr1 dr
        clear deal_date_dt deal_date % 日期处理中间变量

        %% time
        Ttimes = Mdatetime(Times);
        clear TIME Times
        time = Ttimes.time; % POSIX时间 1970 01 01 shell的date +%s

        % temp salt zeta u v w 

        switch Method_interpn
            case 'Siqi_interp'

                % weight
                file_weight = para_conf.WeightFile_Siqi_interp;
                if SWITCH.make_weight
                    [Lat_mesh, Lon_mesh] = meshgrid(lat_dst, lon_dst);
                    tt2 = tic;
                    Weight_2d = interp_2d_calc_weight('ID',GCM_grid.XC,GCM_grid.YC,Lon_mesh, Lat_mesh);
                    rmfiles(file_weight)
                    save(file_weight,'Weight_2d','-v7.3','-nocompression');
                    osprint2('INFO', [pad('Calculate 2d weight costs ',Text_len,'right'),'--> ', num2str(toc(tt2)),' s'])
                    clear Lon_mesh Lat_mesh tt2
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
                if SWITCH.uv
                    U = interp_2d_via_weight(u,Weight_2d);
                    V = interp_2d_via_weight(v,Weight_2d);
                end
                if SWITCH.w
                    W = interp_2d_via_weight(w,Weight_2d);
                end
                Bathy = interp_2d_via_weight(GCM_grid.Bathy,Weight_2d);

                clear temp salt zeta u v w
                clear file_weight Weight_2d

            otherwise
                error('Method_interpn must be Siqi_interp !')
        end
        switch interval
        case 'daily'
            if SWITCH.temp
                Temp = mean(Temp,4);
            end
            if SWITCH.salt
                Salt = mean(Salt,4);
            end
            if SWITCH.uv
                U = mean(U,4);
                V = mean(V,4);
            end
            if SWITCH.w
                W = mean(W,4);
            end
            if SWITCH.adt
                Zeta = mean(Zeta,3);
            end
        case 'hourly'
        otherwise
            error("interval must be 'daily' or 'hourly' !")
        end
        % lon_dst                  --> 1*m                                   --- wrnc(function) lon
        % lat_dst                  --> 1*n                                   --- wrnc(function) lat
        % GCM_grid.RC              --> z1*1                                  
        % Ttimes                   --> 1*t                                  
        % Temp                     --> m*n*z1*t                              
        % Salt                     --> m*n*z1*t                              
        % U                        --> m*n*z1*t                              
        % V                        --> m*n*z1*t                              
        % W                        --> m*n*z1*t                              
        % Zeta                     --> m*n*t                                 
        % Depth_std                --> 1*z2                                 
        % Bathy                    --> m*n                                   --- wrnc(function) bathy

        if SWITCH.out_std_level  % 是否转换到标准层
            switch Method_interpn 
                case {'Siqi_interp', 'Siqi_ESMF'}
                    %weight
                    file_weight_vertical = para_conf.WeightFile_vertical;

                    if SWITCH.make_weight
                        tt3 = tic;
                        Weight_vertical = interp_vertical_calc_weight(-GCM_grid.RC', Depth_std);
                        fields = fieldnames(Weight_vertical);
                         for i = 1: length(fields)
                            Weight_vertical.(fields{i}) = repmat(Weight_vertical.(fields{i}),length(lon_dst)*length(lat_dst)*steps,1);
                        end
                        rmfiles(file_weight_vertical);
                        save(file_weight_vertical, 'Weight_vertical','-v7.3','-nocompression');
                        osprint2('INFO', [pad('Calculate vertical weight costs ',Text_len,'right'),'--> ', num2str(toc(tt3)),' s'])
                    else
                        Weight_vertical = load(file_weight_vertical).Weight_vertical;
                    end
                    clear file_weight_vertical tt3 i fields

                    % Vertical interpolation
                    if SWITCH.temp
                        Temp_mntz = permute(Temp,[1,2,4,3]);  % m*n*t*z
                        Temp_linear = reshape(Temp_mntz, [length(lon_dst)*length(lat_dst)*steps, size(Temp_mntz,4)]);  % m*n*t*z --> [m*n*t]*z
                        Temp_linear_std = interp_vertical_via_weight(Temp_linear, Weight_vertical);
                        Temp_std_mntz = reshape(Temp_linear_std, [length(lon_dst), length(lat_dst), steps, length(Depth_std)]);  % [m*n*t]*z --> m*n*t*z
                        Temp_std = permute(Temp_std_mntz, [1,2,4,3]);  % m*n*z*t
                        clear Temp_mntz Temp_linear Temp_linear_std Temp_std_mntz Temp
                        Temp = Temp_std; clear Temp_std
                    end
                    if SWITCH.salt
                        Salt_mntz = permute(Salt,[1,2,4,3]);
                        Salt_linear = reshape(Salt_mntz, [length(lon_dst)*length(lat_dst)*steps, size(Salt_mntz,4)]);
                        Salt_linear_std = interp_vertical_via_weight(Salt_linear, Weight_vertical);
                        Salt_std_mntz = reshape(Salt_linear_std, [length(lon_dst), length(lat_dst), steps, length(Depth_std)]);
                        Salt_std = permute(Salt_std_mntz, [1,2,4,3]);
                        clear Salt_mntz Salt_linear Salt_linear_std Salt_std_mntz Salt
                        Salt = Salt_std; clear Salt_std
                    end
                    if SWITCH.uv
                        U_mntz = permute(U,[1,2,4,3]);
                        U_linear = reshape(U_mntz, [length(lon_dst)*length(lat_dst)*steps, size(U_mntz,4)]);
                        U_linear_std = interp_vertical_via_weight(U_linear, Weight_vertical);
                        U_std_mntz = reshape(U_linear_std, [length(lon_dst), length(lat_dst), steps, length(Depth_std)]);
                        U_std = permute(U_std_mntz, [1,2,4,3]);
                        clear U_mntz U_linear U_linear_std U_std_mntz U
                        U = U_std; clear U_std

                        V_mntz = permute(V,[1,2,4,3]);
                        V_linear = reshape(V_mntz, [length(lon_dst)*length(lat_dst)*steps, size(V_mntz,4)]);
                        V_linear_std = interp_vertical_via_weight(V_linear, Weight_vertical);
                        V_std_mntz = reshape(V_linear_std, [length(lon_dst), length(lat_dst), steps, length(Depth_std)]);
                        V_std = permute(V_std_mntz, [1,2,4,3]);
                        clear V_mntz V_linear V_linear_std V_std_mntz V
                        V = V_std; clear V_std
                    end
                    if SWITCH.w
                        W_mntz = permute(W,[1,2,4,3]);
                        W_linear = reshape(W_mntz, [length(lon_dst)*length(lat_dst)*steps, size(W_mntz,4)]);
                        W_linear_std = interp_vertical_via_weight(W_linear, Weight_vertical);
                        W_std_mntz = reshape(W_linear_std, [length(lon_dst), length(lat_dst), steps, length(Depth_std)]);
                        W_std = permute(W_std_mntz, [1,2,4,3]);
                        clear W_mntz W_linear W_linear_std W_std_mntz W
                        W = W_std; clear W_std
                    end
                    
                    clear Weight_vertical
            end
        end

        % lon_dst                  --> 1*m                                   --- wrnc(function) lon
        % lat_dst                  --> 1*n                                   --- wrnc(function) lat
        % Depth_std                --> 1*z2                                 
        % Ttimes                   --> 1*t                                  
        % Temp                     --> m*n*z2*t                              --- wrnc(function) temp
        % Salt                     --> m*n*z2*t                              --- wrnc(function) salt
        % U                        --> m*n*z2*t                              --- wrnc(function) u
        % V                        --> m*n*z2*t                              --- wrnc(function) v
        % W                        --> m*n*z2*t                              --- wrnc(function) w
        % Zeta                     --> m*n*t                                 --- wrnc(function) adt

        % -----> std_level
        if SWITCH.out_std_level
            if SWITCH.temp
                Velement.Temp_std = Temp; 
            end
            if SWITCH.salt
                Velement.Salt_std = Salt;
            end
            if SWITCH.uv
                Velement.U_std = U; 
                Velement.V_std = V;
            end
            if SWITCH.w
                Velement.W_std = W; 
            end
        end
        Velement.Zeta = Zeta;
        if SWITCH.out_std_level
            Delement.Depth_std = Depth_std;
        end
        clear Temp Salt U V W Zeta
        % <----- std_level
        
        clear dmfile

        %% mask vertical data
        if SWITCH.out_std_level
            file_mask = para_conf.MaskVerticalmatFile;
            if SWITCH.make_mask
                tt4 = tic;
                Standard_depth_mask = make_mask_depth_data(-Bathy, Delement.Depth_std); 
                rmfiles(file_mask)
                save(file_mask,'Standard_depth_mask','-v7.3','-nocompression');
                osprint2('INFO', [pad('Calculate depth mask costs ',Text_len,'right'),'--> ', num2str(toc(tt4)),' s'])
            else
                Standard_depth_mask = load(file_mask).Standard_depth_mask;
            end
            clear file_mask tt4
            if SWITCH.vertical_mask
                [VAelement,Velement] = separate_var_gt_nd(Velement);
                VAelement = structfun(@(x) mask_depth_data(Standard_depth_mask, x), VAelement, 'UniformOutput', false);
                Velement = merge_struct(Velement,VAelement);
                clear VAelement 
                clear Standard_depth_mask
            end
            osprint2('INFO',[pad('Masking depth of data greater than bathy ',Text_len,'right'),'--> ', logical_to_char(SWITCH.vertical_mask)])
        end

        %% mask zeta land data, because mitgcm's data does not have NaN
        Velement.Zeta(Bathy>0) = NaN;
        clear Bathy

        %% 岸线侵蚀
        if SWITCH.erosion
            file_erosion = para_conf.ErosionFile;
            num_erosion = para_conf.Erosion_num;
            Erosion_judge = para_conf.Erosion_judge;
            osprint2('INFO',[pad('Erosion coastline ',Text_len,'right'),'--> ', logical_to_char(SWITCH.erosion)]);
            osprint2('INFO',[pad('Erosion coastline total frequency ',Text_len,'right'),'--> ', num2str(num_erosion)]);

            im = 0;
            while im < num_erosion
                osprint2('INFO',[pad('Erosion coastline counts ',Text_len,'right'),'--> ', num2str(im+1)]);
                if SWITCH.make_erosion
                    fields_Velement = fieldnames(Velement);
                    if im == 0
                        I_D_1 = erosion_coast_cal_id(lon_dst, lat_dst, Velement.(fields_Velement{1}), Erosion_judge(1), Erosion_judge(2));
                        rmfiles(file_erosion);
                        save(file_erosion, 'I_D_1', '-v7.3','-nocompression');
                    else
                        % I_D_2 = erosion_coast_cal_id(lon_dst, lat_dst, Velement.(fields_Velement{1}), 16, 5);
                        eval(['I_D_',num2str(im+1),' = erosion_coast_cal_id(lon_dst, lat_dst, Velement.',fields_Velement{1},', ', num2str(Erosion_judge(1)), ', ' ,num2str(Erosion_judge(2)), ');']);
                        % save(file_erosion, 'I_D_2', '-append','-nocompression');
                        eval(['save(file_erosion, ''I_D_',num2str(im+1),''', ''-append'',''-nocompression'');']);
                    end
                else
                    % I_D_1 = load(file_erosion).I_D_1;
                    eval(['I_D_',num2str(im+1),' = load(file_erosion).I_D_',num2str(im+1),';']);
                end
                [VAelement,Velement, dimsMax] = separate_var_gt_nd(Velement);
                % VAelement = structfun(@(x) erosion_coast_via_id(I_D_1, x,'cycle_dim',4), VAelement, 'UniformOutput', false);
                eval(['VAelement = structfun(@(x) erosion_coast_via_id(I_D_',num2str(im+1),', x,''cycle_dim'',',num2str(dimsMax),'), VAelement, ''UniformOutput'', false);']);
                Velement = merge_struct(Velement,VAelement); clear VAelement
                im = im+1;
            end
            clear I_D_* file_erosion fields_Velement im Erosion_judge

        end

        %% global attribute start date
        GA_start_date = [char(datetime("now","Format","yyyy-MM-dd")), '_00:00:00'];
        
        if SWITCH.DEBUG
            osprint2('WARNING','DEBUG mode is on, the output file will be saved in the current directory!')
            osprint2('WARNING','Stopping writing netcdf file!')
            keyboard
        end

        %% 写入
        if SWITCH.uv || SWITCH.w
            file = fullfile(OutputDir.curr,['current',OutputRes,'.nc']);
            ncid = create_nc(file, 'NETCDF4');
            [Velement_current,Velement] = rmfields_key_from_struct(Velement,{'Temp_std','Salt_std','Zeta'});
            netcdf_fvcom.wrnc_current(ncid,lon_dst,lat_dst,Delement,time,Velement_current,GA_start_date,'conf',para_conf);
            clear Velement_current ncid file
        end

        if SWITCH.temp
            file = fullfile(OutputDir.temp,['temperature',OutputRes,'.nc']);
            ncid = create_nc(file, 'NETCDF4');
            [Velement_temperature,Velement] = rmfields_key_from_struct(Velement,{'Salt_std','Zeta'});
            netcdf_fvcom.wrnc_temp(ncid,lon_dst,lat_dst,Delement,time,Velement_temperature,GA_start_date,'conf',para_conf)
            clear Velement_temperature ncid file
        end

        if SWITCH.salt
            file = fullfile(OutputDir.salt,['salinity',OutputRes,'.nc']);
            ncid = create_nc(file, 'NETCDF4');
            [Velement_salt,Velement] = rmfields_key_from_struct(Velement,{'Zeta'});
            netcdf_fvcom.wrnc_salt(ncid,lon_dst,lat_dst,Delement,time,Velement_salt,GA_start_date,'conf',para_conf);
            clear Velement_salt ncid file
        end

        if SWITCH.adt
            file = fullfile(OutputDir.adt,['adt',OutputRes,'.nc']);
            ncid = create_nc(file, 'NETCDF4');
            [Velement_adt,Velement] = rmfields_key_from_struct(Velement,{''}); %#ok<ASGLU>
            netcdf_fvcom.wrnc_adt(ncid,lon_dst,lat_dst,time,Velement_adt.Zeta,GA_start_date,'conf',para_conf);
            clear Velement_adt ncid file
        end

        clear Lon Lat Depth time TIME TIME_* Ttimes Velement
        clear time_filename
        clear OutputDir_*
        clear GA_start_date
    end

    clear Depth_std  % 标准层
    clear dr1 Length % 循环天数
    clear lon_dst lat_dst Level_sgm Depth_std Delement % 经纬度信息 变量
    clear *path *Dir % 路径 文件名 信息等
    clear OutputRes  % suffix
    clear GCM_grid   % 网格信息
    clear conf_file para_conf SWITCH  % 配置
    clear Method_interpn % 插值方法
    clear Method_read   % 读取方法
    clear file_Mcasename steps  % 文件名 步长
    clear varargin
    osprint2('INFO', [pad(['GivenDate ',char(getdate),' interval ',interval,' costs '], Text_len,'right'),'--> ', num2str(toc(tt1)),' s'])
    clear getdate interval tt1 Text_len % 基准天 间隔 时间 字符长度
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

function out = fORC(fin)
    fid = fopen(fin);
    if fid == -1
        error(['File not found: ',fin])
    end
    out = fread(fid, inf, 'float32','b');
    fclose(fid);
end
