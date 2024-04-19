function FCO2 = calc_casfco2(windSpeed, SST, SSS, Dpco2)
    %       To calculate casfco2, thr windSpeed SST SSS, teached by Lijun Song.
    % =================================================================================================================
    % Parameters:
    %       windSpeed:      windSpeed                           || required: True || type: double || example: 10
    %       SST:            sea surface temperature(Celsius)    || required: True || type: double || example: 15
    %       SSS:            sea surface salinity(psu)           || required: True || type: double || example: 35
    %       Dpco2:          diff between time tick(ppm)         || required: True || type: double || example: 2.83
    %       varargin:       optional parameters      
    %           None
    % =================================================================================================================
    % Returns:
    %       FCO2:           flux between seawater and atmosphere(mmol·m^-2·d^-1) --> 海-气二氧化碳交换通量 单位时间单位面积上海水与大气C02的净交换量
    % =================================================================================================================
    % Updates:
    %       2024-04-18:     Created, by Christmas;
    % =================================================================================================================
    % Examples:
    %       FCO2 = calc_casfco2(windSpeed, SST, SSS);
    % =================================================================================================================
    % Reference:
    %       Dpco2(t) = pco2(t) - pco2(t+1);
    % =================================================================================================================

    arguments
        windSpeed {mustBeFloat}
        SST {mustBeFloat}
        SSS {mustBeFloat}
        Dpco2 {mustBeFloat}
    end

    if SST > 273.15
        error('SST must be Celsius(°C)')
    end

    SST_C = SST; clear SST
    SST_K = 273.15 + SST_C;
    
    lns = -60.2409 + 93.4517 * 100/(SST_K) + 23.3585 * log((SST_K)/100) + SSS * (0.023517 - 0.023656 * (SST_K)/100 + 0.0047036 * (SST_K)^2/10000);
    s = exp(lns);
    SC = 2073.1 - 125.62*SST_C + 3.6276*SST_C^2 - 0.043219*SST_C^3;
    Kw = 0.27*windSpeed^2*(SC/660)^(-0.5);
    FCO2 = Kw*s*Dpco2;

end


