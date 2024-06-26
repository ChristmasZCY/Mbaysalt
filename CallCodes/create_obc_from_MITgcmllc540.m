function create_obc_from_MITgcmllc540(conf_file, yyyymmdd)
    %       Create open boundary condition from MITgcmllc540
    % =================================================================================================================
    % Parameters:
    %       conf_file:      configuration file              || required: False|| type: Text || example: './Post_gcmSCS.conf'
    %       yyyymmdd:       date                            || required: False|| type: Float|| example: 20240402
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Updates:
    %       2024-**-**:     Created, by Christmas;
    % =================================================================================================================
    % Examples:
    %       create_obc_from_MITgcmllc540('./Post_gcmSCS.conf', 20240402)
    % =================================================================================================================


  arguments(Input)
        conf_file {mustBeFile} = './Post_gcmSCS.conf';
        yyyymmdd {mustBeFloat}  = 20240402;
    end

    para_conf = read_conf(conf_file);
    Method_interpn = para_conf.Method_interpn;  % 'Siqi_interp' or 'knnsearch' 插值方法
    GCMll540_grid = para_conf.NestingGridFile_1;  % Nesting grid file
%    XCF.ile = para_conf.XCFile;  % GCMSCS grid file
%    YCFile = para_conf.YCFile;  % GCMSCS grid file
    RCFile = para_conf.RCFile;  % GCMSCS grid file
    Inputpath = para_conf.NestingDir_1;  % Nesting输入文件路径
    Outputpath = fullfile(para_conf.ModelDir, 'obcs');  % 输出文件路径

    ddt = datetime(num2str(yyyymmdd),'InputFormat','yyyyMMdd');
    ddt.Format = 'yyyyMMdd';
    
    %% Read grid
    GridNesting_1 = load(GCMll540_grid).GCM_grid;
    XCNesting_1 = GridNesting_1.XC;
    YCNesting_1 = GridNesting_1.YC;
    RCNesting_1 = GridNesting_1.RC;
    AngleCSNesting_1 = GridNesting_1.AngleCS;
    AngleSNNesting_1 = GridNesting_1.AngleSN;

    XC_dst = calc_grid(para_conf.xStart, fORC(para_conf.dxFile));
    YC_dst = calc_grid(para_conf.yStart, fORC(para_conf.dyFile));
    [YC_dst, XC_dst] = meshgrid(YC_dst, XC_dst);
%    XC_dst = rdmds(XCFile);
%    YC_dst = rdmds(YCFile);
    RC_dst = squeeze(rdmds(RCFile));

    dmfile = struct();
    steps = 25;
    Times = NaT(steps,1);
    Times.Format = 'yyyyMMddHH';
    T1 = zeros(numel(XCNesting_1), length(RCNesting_1), steps);
    S1 = zeros(numel(XCNesting_1), length(RCNesting_1), steps);
    U1 = zeros(numel(XCNesting_1), length(RCNesting_1), steps);
    V1 = zeros(numel(XCNesting_1), length(RCNesting_1), steps);
    AngleCS = repmat(AngleCSNesting_1, [1,length(RCNesting_1)]);
    AngleSN = repmat(AngleSNNesting_1, [1,length(RCNesting_1)]);

    for ih = 1 : steps
        Times(ih) = ddt + hours(ih-1);
        disp(['Reading data at time: ', char(Times(ih))])
        dmfile(ih).T = fullfile(Inputpath,[char(ddt),'/T.',char(Times(ih))]); % 输入文件
        t1 = fORC([dmfile(ih).T '.data']);
        T1(:,:,ih) = reshape(t1,numel(XCNesting_1),length(RCNesting_1)); clear t1

        dmfile(ih).S = fullfile(Inputpath,[char(ddt),'/S.',char(Times(ih))]); % 输入文件
        s1 = fORC([dmfile(ih).S '.data']);
        S1(:,:,ih) = reshape(s1,numel(XCNesting_1),length(RCNesting_1)); clear s1

        dmfile(ih).U = fullfile(Inputpath,[char(ddt),'/U.',char(Times(ih))]); % 输入文件
        dmfile(ih).V = fullfile(Inputpath,[char(ddt),'/V.',char(Times(ih))]); % 输入文件
        u_1 = fORC([dmfile(ih).U '.data']);
        v_1 = fORC([dmfile(ih).V '.data']);
        u_nz = reshape(u_1,numel(XCNesting_1),length(RCNesting_1)); clear u_1
        v_nz = reshape(v_1,numel(XCNesting_1),length(RCNesting_1)); clear v_1
        u_nz_ll = AngleCS.*u_nz - AngleSN.*v_nz;
        v_nz_ll = AngleSN.*u_nz + AngleCS.*v_nz;
        U1(:,:,ih) = u_nz_ll; clear u_nz_ll u_nz
        V1(:,:,ih) = v_nz_ll; clear v_nz_ll v_nz
    end
    clear ih

    U1_ntz = permute(U1,[1,3,2]);
    V1_ntz = permute(V1,[1,3,2]);
    T1_ntz = permute(T1,[1,3,2]);
    S1_ntz = permute(S1,[1,3,2]);

    % select region --> START
    U1_ntz(XCNesting_1<min(XC_dst(:))-1 | XCNesting_1>max(XC_dst(:))+1,:,:) = [];
    V1_ntz(XCNesting_1<min(XC_dst(:))-1 | XCNesting_1>max(XC_dst(:))+1,:,:) = [];
    T1_ntz(XCNesting_1<min(XC_dst(:))-1 | XCNesting_1>max(XC_dst(:))+1,:,:) = [];
    S1_ntz(XCNesting_1<min(XC_dst(:))-1 | XCNesting_1>max(XC_dst(:))+1,:,:) = [];
    YCNesting_1(XCNesting_1<min(XC_dst(:))-1 | XCNesting_1>max(XC_dst(:))+1) = [];
    XCNesting_1(XCNesting_1<min(XC_dst(:))-1 | XCNesting_1>max(XC_dst(:))+1) = [];
    
    U1_ntz(YCNesting_1<min(YC_dst(:))-1 | YCNesting_1>max(YC_dst(:))+1,:,:) = [];
    V1_ntz(YCNesting_1<min(YC_dst(:))-1 | YCNesting_1>max(YC_dst(:))+1,:,:) = [];
    T1_ntz(YCNesting_1<min(YC_dst(:))-1 | YCNesting_1>max(YC_dst(:))+1,:,:) = [];
    S1_ntz(YCNesting_1<min(YC_dst(:))-1 | YCNesting_1>max(YC_dst(:))+1,:,:) = [];
    XCNesting_1(YCNesting_1<min(YC_dst(:))-1 | YCNesting_1>max(YC_dst(:))+1) = [];
    YCNesting_1(YCNesting_1<min(YC_dst(:))-1 | YCNesting_1>max(YC_dst(:))+1) = [];
    
    U1_ntz_linear = reshape(U1_ntz, [], length(RCNesting_1));
    V1_ntz_linear = reshape(V1_ntz, [], length(RCNesting_1));
    T1_ntz_linear = reshape(T1_ntz, [], length(RCNesting_1));
    S1_ntz_linear = reshape(S1_ntz, [], length(RCNesting_1));
    % END <-- select region
    
    %% Vertical interp weigth
    tic
    % weight_v = interp_vertical_calc_weight(repmat(RC_1',length(U_1_linear),1), repmat(RC_2',length(U_1_linear),1));
    weight_v = interp_vertical_calc_weight(RCNesting_1', RC_dst');
    fields = fieldnames(weight_v);
    for i = 1: length(fields)
        weight_v.(fields{i}) = repmat(weight_v.(fields{i}),length(U1_ntz_linear),1);
        % weight_v2.id1 = repmat(weight_v2.id1,length(U_1_linear),1);
    end
    U2_ntz_linear = interp_vertical_via_weight(U1_ntz_linear, weight_v);
    V2_ntz_linear = interp_vertical_via_weight(V1_ntz_linear, weight_v);
    T2_ntz_linear = interp_vertical_via_weight(T1_ntz_linear, weight_v);
    S2_ntz_linear = interp_vertical_via_weight(S1_ntz_linear, weight_v);
    toc

    U2_ntz = reshape(U2_ntz_linear, length(XCNesting_1), steps, length(RC_dst));
    V2_ntz = reshape(V2_ntz_linear, length(XCNesting_1), steps, length(RC_dst));
    T2_ntz = reshape(T2_ntz_linear, length(XCNesting_1), steps, length(RC_dst));
    S2_ntz = reshape(S2_ntz_linear, length(XCNesting_1), steps, length(RC_dst));

    %% Gird interp weigth
    switch Method_interpn
    case 'Siqi_interp'
        tic
        weight_C = interp_2d_calc_weight('ID', XCNesting_1(:),YCNesting_1(:),XC_dst(:),YC_dst(:));
        U3_ntz = interp_2d_via_weight(U2_ntz, weight_C);
        V3_ntz = interp_2d_via_weight(V2_ntz, weight_C);
        T3_ntz = interp_2d_via_weight(T2_ntz, weight_C);
        S3_ntz = interp_2d_via_weight(S2_ntz, weight_C);
        toc
    case 'knnsearch'
        [idx_C,~] = knnsearch([XCNesting_1(:),YCNesting_1(:)],[XC_dst(:),YC_dst(:)]);
        tic
        U3_ntz = zeros([numel(XC_dst),size(U2_ntz,[2,3])]);
        V3_ntz = zeros([numel(XC_dst),size(V2_ntz,[2,3])]);
        T3_ntz = zeros([numel(XC_dst),size(T2_ntz,[2,3])]);
        S3_ntz = zeros([numel(XC_dst),size(S2_ntz,[2,3])]);
        for it = 1: size(U2_ntz,2)
            for iz = 1: size(U2_ntz,3)
                U3_ntz(:,it,iz) = U2_ntz(idx_C,it,iz);
                V3_ntz(:,it,iz) = V2_ntz(idx_C,it,iz);
                T3_ntz(:,it,iz) = T2_ntz(idx_C,it,iz);
                S3_ntz(:,it,iz) = S2_ntz(idx_C,it,iz);
            end
        end
        toc
    end

    U3_nzt = permute(U3_ntz,[1,3,2]);
    V3_nzt = permute(V3_ntz,[1,3,2]);
    T3_nzt = permute(T3_ntz,[1,3,2]);
    S3_nzt = permute(S3_ntz,[1,3,2]);

    U3_xytz = reshape(U3_nzt,[size(XC_dst), length(RC_dst), steps]);
    V3_xytz = reshape(V3_nzt,[size(XC_dst), length(RC_dst), steps]);
    T3_xytz = reshape(T3_nzt,[size(XC_dst), length(RC_dst), steps]);
    S3_xytz = reshape(S3_nzt,[size(XC_dst), length(RC_dst), steps]);

    U3_xytz = cat(4,U3_xytz,U3_xytz(:,:,:,1));
    V3_xytz = cat(4,V3_xytz,V3_xytz(:,:,:,1));
    T3_xytz = cat(4,T3_xytz,T3_xytz(:,:,:,1));
    S3_xytz = cat(4,S3_xytz,S3_xytz(:,:,:,1));


    U_obs = get_obc_from_region(U3_xytz);
    V_obs = get_obc_from_region(V3_xytz);
    T_obs = get_obc_from_region(T3_xytz);
    S_obs = get_obc_from_region(S3_xytz);
    write_obc(U_obs, 'U_obc_llc', 'pathdir', Outputpath);
    write_obc(V_obs, 'V_obc_llc', 'pathdir', Outputpath);
    write_obc(T_obs, 'T_obc_llc', 'pathdir', Outputpath);
    write_obc(S_obs, 'S_obc_llc', 'pathdir', Outputpath);

    clear XCNesting_1 YCNesting_1 RCNesting_1
end

function Var = get_obc_from_region(var)
    Var.W = squeeze(var(1,:,:,:));
    Var.E = squeeze(var(end,:,:,:));
    Var.S = squeeze(var(:,1,:,:));
    Var.N = squeeze(var(:,end,:,:));
end


function write_bin(filename, var, mode, machinefmt, precision)
    rmfiles(filename);
    fid=fopen(filename, mode, machinefmt);
    if fid == -1
        error(['File not found: ',filename])
    end
    fwrite(fid, var, precision);
    fclose(fid);
   
    % fid=fopen('U_obc_llcE.bin', 'w', 'b');
    % fwrite(fid, U_obs.N, 'float32');
    % fclose(fid);
end

function files = write_obc(S_var, file_prefix, varargin)
    read_varargin(varargin, {'pathdir'}, {'./'});
    fields = fieldnames(S_var);
    files = cell(length(fields),1);
    for i = 1: length(fields)
        files{i} = fullfile(pathdir,[file_prefix, fields{i}, '.bin']);
        write_bin(files{i} , S_var.(fields{i}), 'w', 'b', 'float32');
    end
    % write_bin('U_obc_llcN.bin', U_obs.N, 'w', 'b', 'float32')
end

function out = fORC(fin)
    fid = fopen(fin);
    if fid == -1
        error(['File not found: ',fin])
    end
    out = fread(fid, inf, 'float32','b');
    fclose(fid);
end

function pS = calc_grid(pStrat, dd)
    % 根据起始点pointStart和每两个点的间距dd，计算网格点
    % pStrat: 起始点 为一个数值
    % dd: 间距 为一个1D数组
    % 返回值：网格点 为一个1D数组
    pS = pStrat + cumsum(dd);
    return

end
