function Tt = calc_model_time_step(fmin, lon, lat, varargin)
    %   Calculate mode time step
    % =================================================================================================================
    % Parameters:
    %       fmin:   frequency min       || required: True|| type: double || format: 0.0418 or 0.0373
    %       lon:    longitude           || required: True|| type: double || format: 1D matrix
    %       lat:    latitude            || required: True|| type: double || format: 1D matrix
    %       varargin:       optional parameters      
    % =================================================================================================================
    % Returns:
    %       Tt
    %           .global     || type: double || example: [1018.3155 2036.6309]
    %           .xy         || type: double || example: 509.1577
    %           .k          || type: double || example: [509.1577 1018.3155]
    %           .source     || type: double || format:  [5 15]
    % =================================================================================================================
    % Updates:
    %       2024-05-08:     Created, by Christmas;
    % =================================================================================================================
    % Examples:
    %       Tt = calc_model_time_step(0.0418, -180:.2:180, -85:.2:60);
    % =================================================================================================================
    % References:
    %       Cc = Cgmax*t/min(x,y) Cc越小越好， >1不稳定
    %       WW3——6.07手册 公式A.1
    %       最大群速 = 深水群速*1.15
    %       C0 = gT/(2pi)
    %       C0是指深水情况下波浪的相速度
    %       深水情况下波浪的群速Cg = C0/2
    %
    %       全局时间步长为2-4倍的CFL
    %       xy timestep CFL
    %       k time step 全局时间步长的一半
    %       source time step
    % =================================================================================================================

    arguments(Input)
        fmin(:,1) {mustBeMember(fmin,[0.0418,0.0373])}
        lon (:,1)
        lat (:,1)
    end

    arguments (Input,Repeating)
        varargin
    end

    T = 1/fmin;
    c0 = 9.81*T/(2*pi); % m/s
    cg = c0/2;
    cgmax = cg*1.15;
    % 纬度相同，经度差1°：lat=30; d=111*10^3*cosd(lat);  cos(弧度)
    % 经度相同，纬度差1°：111km =111*10^3;
    d = 111*10^3*cosd(max(lat))*mean(diff(lat)); % mean(diff(lat)) --> dy

    t = d/cgmax;

    Tt.global = [2*t 4*t];
    Tt.xy     = t;
    Tt.k      = Tt.global/2;
    Tt.source = [5 15];

end

