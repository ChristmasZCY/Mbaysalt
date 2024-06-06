clm noclose

V(1) = calc_V('现状网格.mesh',"潮位数据.xlsx","现状高潮");
V(2) = calc_V('现状网格.mesh',"潮位数据.xlsx","现状低潮");
V(3) = calc_V('工程后加深网格.mesh',"潮位数据.xlsx","工况后加深高潮");
V(4) = calc_V('工程后加深网格.mesh',"潮位数据.xlsx","工程后加深低潮");
V(5) = calc_V('工程后网格.mesh',"潮位数据.xlsx","工程后高潮");
V(6) = calc_V('工程后网格.mesh',"潮位数据.xlsx","工程后低潮");
V'

function V = calc_V(fin,tideFile,Sheet)
    f = f_load_grid(fin);

    T_a = readtable(tideFile,"Sheet",Sheet);

    % Calculate triangular area
    S = calc_area(f.x(f.nv), f.y(f.nv));

    % fprintf('第26547个三角形中心对应的 x坐标%f y坐标%f \n',f.xc(26547), f.yc(26547))
    % fprintf('excel文件中26547     的 x坐标%f y坐标%f \n ',T_high.Var3(1),T_high.Var4(1))

    % Adjust tri-id and calculate h
    h_get = zeros(length(T_a.Var3),1);
    S_get = zeros(length(T_a.Var3),1);
    for ii = 1 : length(T_a.Var3)
        [~,F] = min(abs(f.xc-T_a.Var3(ii)));
        T_a.Var1(ii) = F;
        h_get(ii) = -f.hc(F) + T_a.Var2(ii);
        S_get(ii) = S(F);
    end
    h_get(h_get<0) = 0;
    V = sum(S_get.*h_get);

    disp(V)
end
