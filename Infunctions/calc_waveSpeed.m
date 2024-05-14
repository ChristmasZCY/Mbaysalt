function [C, Cg, L] = calc_waveSpeed(f, h, varargin)
    %   Calculate phase velocity and group velocity from frequency and depth. --> 给定频率和水深，计算波浪相速度和群速
    % =================================================================================================================
    % Parameters:
    %       f:  frequency                || required: True  || type: double || format: 0.0418 or 0.0373
    %       h:  depth                    || required: True  || type: double || format: matrix
    %       varargin: (optional)
    %           method: calculate method || required: False || type: double || default: 2
    % =================================================================================================================
    % Returns:
    %       C:  phase velocity 相速度     || type: double
    %       Cg: group velocity 群速度     || type: double
    %       L:  wave length              || type: double
    % =================================================================================================================
    % Updates:
    %       2024-05-14:     Created, by Christmas;
    % =================================================================================================================
    % Examples:
    %       [C, Cg, L] = calc_waveSpeed(f, h);
    %       [C, Cg, L] = calc_waveSpeed(f, h, 'method', 2);
    %       [C, Cg, L] = calc_waveSpeed(0.0418, 20, 'method', 2);
    % =================================================================================================================
    % References:
    %
    %       L = g*T^2/(2*pi)*tanh(2*pi*d/L);  % kh = 2*pi*d/L;
    %       C0 = L0/T;
    %       ===============
    %       Method -----3-----
    %       L0 = T*sqrt(g*h);   % h/l<=0.05 浅水波长
    %       L0 = g*T^2/(2*pi);  % h/l>=0.5  深水波长 g/2pi=1.56 -> L = 1.56T^2
    %       L0 = g*T^2/(2*pi)*tanh(2*pi*d/L0); % 0.05<h/l<0.5 有限水深波 d为水深，需要解方程
    %       ===============
    %       Method -----2-----
    %       L0 = g*T^2/(2*pi); h>l/2 深水波 tanh(kh) = 1
    %       L0 = sqrt(g*d)*T; h<l/2 浅水波 tanh(2*pi*d/L) = 2*pi*d/L
    %       ===============
    %       Method -----1-----
    %       L0 = g*T^2/(2*pi);
    %       ===============
    % =================================================================================================================

    varargin = read_varargin(varargin,{'method'},{2});

    g = 9.81;
    T = 1/f;
    switch method
    case {3,1}
        if numel(h) > 1
            error(['  Method 1 or 3 only supports point, \n' ...
                   '  If you want to calculate matrix, please set mothod 2. \n' ...
                   '  You set method %d'], method)
        end
    case 2
    end
    
    switch method
    case 3
        l1 = T*sqrt(g*h);  % 浅水波
        l2 = g*T^2/(2*pi); % 深水波
        if h/l1<=0.05
            L = l1;
        elseif h/l2>=0.5 
            L = l2;
        else
            syms l3
            q = l3-g*T^2/(2*pi)*tanh(2*pi*h/l3)==0;  % 构建x和y的公式
            w = vpasolve(q,l3,[0 Inf]);   %解函数q，关于x的解析解
            w = double(w);
            L = w;
        end
    case 2
        l1 = sqrt(g*h)*T;    % 浅水波
        l2 = g*T^2/(2*pi); % 深水波
        L = nan(size(h));
        L(h./l1<=0.5) = l1(h./l1<=0.5);
        L(h./l2>0.5)  = l2(h./l2>0.5);
    case 1
        L0 = (g*T^2)/(2*pi);
        L_g = L0;  % 以给定T和d下的深水波波长作为初始猜测值
        L = (g*T^2)/(2*pi)*tanh((2*pi)*(h/L_g));
        diff = abs(L-L_g);
        while true  % 迭代计算，当误差小于0.1时终止
            if diff <= 0.1
                break
            end
            diff = abs(L-L_g);
            L_g = L + (0.5*diff);
            L = (g*T^2)/(2*pi)*tanh((2*pi)*(h/L_g));
        end
    
    otherwise
        error('Not supported method --> ''%s''',method);
    end
    
    C = L/T;
    k = (2*pi)/L;
    n = (1+2*k*h/sinh(2*k*h))/2;
    Cg = C*n;
end
