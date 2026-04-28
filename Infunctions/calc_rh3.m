function RH = calc_rh3(T, Td, varargin)
    %       Calculates relative humidity (RH) from temperature (T) and dew point (Td) using the Tetens formula.
    % =================================================================================================================
    % Parameters:
    %       T:     Temperature in degrees Celsius.                         || required: True  || type: numeric  || example: 25
    %       Td:    Dew point temperature in degrees Celsius.                || required: True  || type: numeric  || example: 18
    %       varargin: (optional)
    % =================================================================================================================
    % Returns:
    %       RH:    Relative humidity in percentage (%).
    % =================================================================================================================
    % Updates:
    %       2026-04-28:     Created, by Christmas;
    % =================================================================================================================
    % Examples:
    %       RH = calc_rh2(25, 18);
    % =================================================================================================================
    % Reference:
    %   See also CALC_RH2
    %   <a href="matlab: matlab.desktop.editor.openAndGoToLine(which('calc_rh2.m'), 2); ">see Description</a>
    %   Tetens formula: RH = (e / es) * 100, where es is the saturation vapor pressure and e is the actual vapor pressure.
    % =================================================================================================================

    arguments (Input)
        T (1, 1) {mustBeNumeric, mustBeReal} % Temperature in degrees Celsius
        Td (1, 1) {mustBeNumeric, mustBeReal} % Dew point temperature in degrees Celsius
    end

    arguments (Input, Repeating)
        varargin
    end

    % 检查输入的温度和露点温度是否是摄氏度，如果不是，则抛出错误
    if any(abs([T, Td]) > 100) % 绝对零度约为-273.15°C，因此温度不应超过100°C
        error('Temperature and dew point should be in degrees Celsius and within a reasonable range.');
    end

    es = 0.61078 * exp((17.27 * T) ./ (T + 237.3)); % 饱和水汽压
    e = 0.61078 * exp((17.27 * Td) ./ (Td + 237.3)); % 实际水汽压
    RH = (e ./ es) * 100; % 相对湿度 %

    RH = max(0, min(100, RH)); % 将RH限制在0到100之间
end
