function [Uc, Vc] = calc_typhoon_overlayWind(Uh, Vh, Ug, Vg, c, varargin)
    %       Overlay wind by Model windSpeed and Grid windSpeed (such as Holland and ERA5)
    % =================================================================================================================
    % Parameters:
    %       Uh:              U_holland                || required: True  || type: double    || format: matrix
    %       Vh:              V_holland                || required: True  || type: double    || format: matrix
    %       Ug:              U_grid                   || required: True  || type: double    || format: matrix
    %       Vg:              V_grid                   || required: True  || type: double    || format: matrix
    %       c:               See calc_windHolland     || required: True  || type: double    || format: matrix
    %       varargin: (optional)  
    %            method:     calculate method         || required: False || type: namevalue || default: 'method','0814' 
    % =================================================================================================================
    % Returns:
    %        Uc:    Superimposed windSpeed U
    %        Vc:    Superimposed windSpeed V
    % =================================================================================================================
    % Updates:
    %       2024-05-11:     Created, by Christmas;
    % =================================================================================================================
    % Examples:
    %       [Uc, Vc] = calc_typhoon_overlayWind(Uh, Vh, Ug, Vg, c);
    %       [Uc, Vc] = calc_typhoon_overlayWind(Uh, Vh, Ug, Vg, c, 'method', '0814');
    % =================================================================================================================
    % References:
    %    强台风作用下近岸海域波浪-风暴潮耦合数值模拟
    %    Surge model caused by 0814 Typhoon and mold wind field established
    %    <a href="matlab: matlab.desktop.editor.openAndGoToLine(which('calc_typhoon_overlayWind_readme.mlx'), 2^31-1); ">see Picture</a>
    % =================================================================================================================
    
    varargin = read_varargin(varargin,{'method'}, {'0814'});

    switch method
    case '0814'
        e = c.^4./(1+c.^4);
        Uc = (1-e).*Uh + e.*Ug;  % Superimposed wind U
        Vc = (1-e).*Vh + e.*Vg;  % Superimposed wind V
    otherwise
        error('Error method --> %s',inputname(7));
    end
end
