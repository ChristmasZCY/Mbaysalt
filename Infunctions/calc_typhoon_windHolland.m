function [Uh, Vh, c] = calc_typhoon_windHolland(Lon_grid, Lat_grid, Lon_tyCenter, Lat_tyCenter, UV_tyCenter, P0_tyCenter, uE, vN, varargin)
    %       Calculate Holland typhoon model wind
    % =================================================================================================================
    % Parameters:
    %        Lon_grid:        Grid longitude              || required: True  || type: double    || format: 2D/3D matrix
    %        Lat_grid:        Grid latitude               || required: True  || type: double    || format: 2D/3D matrix
    %        Lon_tyCenter:    typhoon center longitude    || required: True  || type: double    || format: 1D-array(time)
    %        Lat_tyCenter:    typhoon center latitude     || required: True  || type: double    || format: 1D-array(time)
    %        UV_tyCenter:       typhoon center windSpeed  || required: True  || type: double    || format: 1D-array(time)
    %        P0_tyCenter:     typhoon center pressure     || required: True  || type: double    || format: 1D-array(time)
    %        uE:              typhoon move velocity (E)   || required: True  || type: double    || format: 1D-array(time)
    %        vN:              typhoon move velocity (N)   || required: True  || type: double    || format: 1D-array(time)
    %        varargin: (optional)  
    %            omiga:        Coriolis force parameter   || required: False || type: namevalue || default: 'omiga',7.292e-5
    %            P:            Atmospheric pressure       || required: False || type: namevalue || default: 'P',1013
    %            rou_a:        Air density                || required: False || type: namevalue || default: 'rou_a',1.2
    %            C1:           Correction factor 1        || required: False || type: namevalue || default: 'C1',1.0
    %            C2:           Correction factor 2        || required: False || type: namevalue || default: 'C2',0.71
    %            betaa:        Inflow Angle               || required: False || type: namevalue || default: 'betaa',20 
    %            INFO:         whether run osprint2       || required: False || type: namevalue || default: 'INFO','none'
    % =================================================================================================================
    % Returns:
    %        Uc:    Holland windSpeed U
    %        Vc:    Holland windSpeed V
    %        c:     For calc_overlayWind
    % =================================================================================================================
    % Updates:
    %       2024-05-11:     Created, by Christmas;
    % =================================================================================================================
    % Examples:
    %       [Uh, Vh, c] = calc_typhoon_windHolland(Lon_grid, Lat_grid, Lon_tyCenter, Lat_tyCenter, UV_tyCenter, P0_tyCenter, uE, vN);
    % =================================================================================================================
    % References:
    %    强台风作用下近岸海域波浪-风暴潮耦合数值模拟
    %    <a href="matlab: matlab.desktop.editor.openAndGoToLine(which('calc_typhoon_windHolland_readme.mlx'), 2^31-1); ">see Picture</a>
    %    <a href="matlab: open(which('Holland_deduce.pdf')) ">see PDF</a>
    % =================================================================================================================

    arguments(Input)
        Lon_grid (:,:)
        Lat_grid (:,:)
        Lon_tyCenter (:,1)
        Lat_tyCenter (:,1)
        UV_tyCenter (:,1)
        P0_tyCenter (:,1)
        uE (:,1)
        vN (:,1)
    end

    arguments(Input,Repeating)
        varargin
    end

    varargin = read_varargin(varargin,{'omiga'}, {7.292e-5});  % 计算科氏力
    varargin = read_varargin(varargin,{'P'}, {1013});          % 台风外围气压 1013hPa
    varargin = read_varargin(varargin,{'rou_a'}, {1.2});       % 空气密度
    varargin = read_varargin(varargin,{'C1'}, {1.0});          % 修正系数
    varargin = read_varargin(varargin,{'C2'}, {0.71});         % 修正系数
    varargin = read_varargin(varargin,{'betaa'}, {20});        % 流入角
    varargin = read_varargin(varargin,{'INFO'}, {'none'});
    
    Ug = 0 * Lon_grid;
    Vg = 0 * Lon_grid;
    c = 0 * Lon_grid;
    Um = 0 * Lon_grid;
    Vm = 0 * Lon_grid;

    for it = 1 : length(UV_tyCenter)
        uv_center = UV_tyCenter(it);   % 台风中心风速
        p0_cnter = P0_tyCenter(it);  % 台风中心气压
        lon_center = Lon_tyCenter(it);  % 台风中心 lon
        lat_center = Lat_tyCenter(it);  % 台风中心 lat

        B = 1.5+(980-p0_cnter)/120;  % 参数B 台风的形状系数
        Rmax = (28.52*tanh(0.0873*(lat_center-28))+12.22*exp((p0_cnter-1013.2)/33.86)+0.2*uv_center+37.2)*1000;  % 单位:m
        switch INFO
        case {'cprintf','osprint2'}
            osprint2("INFO",sprintf('Step -- %04d, B -- %3.2f, R_max -- %8.3f', it, B, Rmax));
        case {'disp','fprintf','sprintf'}
            fprintf('Step -- %04d, B -- %3.2f, R_max -- %8.3f\n', it, B, Rmax);
        end

        f = 2 * omiga * sind(Lat_grid);  % 科氏力参数
        r = calc_geodistance(lon_center, lat_center, Lon_grid, Lat_grid);  % 点到台风中心的距离
        UVg = sqrt(((B/rou_a)*[(Rmax./r).^B]*(P-p0_cnter)*100).*[exp(-(Rmax./r).^B)]+(r.*f/2).^2)-(r.*f)/2;  % 梯度风速  核实这里P-P0的单位要转成pa
        [Ug(:,:,it), Vg(:,:,it)] = calc_adjust_winddir(Lon_grid,Lat_grid,lon_center,lat_center,UVg,'betaa',betaa,'C2',C2);  % Adjusted gradient wind UV

        c(:,:,it)  = r/(10*Rmax);  % n为常数，一般为9或10
        Um(:,:,it) = exp(-pi.*r./50000)*uE(it);  % Move wind U
        Vm(:,:,it) = exp(-pi.*r./50000)*vN(it);  % Move wind V
    end
    Uh = C1*Um + Ug;  % Holland wind U
    Vh = C1*Vm + Vg;  % Holland wind V

end
