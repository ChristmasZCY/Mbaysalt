function Tt = calc_timeStepWW3(fmin, lon, lat, varargin)
    %   Calculate WW3 time step
    % =================================================================================================================
    % Parameters:
    %       fmin:       frequency min           || required: True  || type: double || format:  0.0418 or 0.0373
    %       lon:        longitude               || required: True  || type: double || format:  1D matrix
    %       lat:        latitude                || required: True  || type: double || format:  1D matrix
    %       varargin: (optional)
    %           nv:     triangle connectivity   || required: False || type: double || format:  (:,3)
    %           h:      depth                   || required: False || type: double || format:  scalar
    %           ns:     nesting                 || required: False || type:  cell  || example: {{1,2,3},{55,66}}
    %           figOn:  figure switch           || required: False || type:  flag  || example: 'figOn'
    % =================================================================================================================
    % Returns:
    %       Tt
    %           .global     全局时间步长  || type: double || example: [1018.3155 2036.6309]
    %           .xy         平流时间步长  || type: double || example: 509.1577
    %           .k          k空间时间步长 || type: double || example: [509.1577 1018.3155]
    %           .source     源项时间步长  || type: double || format:  [5 15]
    % =================================================================================================================
    % Updates:
    %       2024-05-08:     Created,                by Christmas;
    %       2024-05-14:     Added for tri-mesh,     by Christmas;
    % =================================================================================================================
    % Examples:
    %       Tt = calc_timeStepWW3(0.0418, -180:.2:180, -85:.2:60);  % Structured
    %       Tt = calc_timeStepWW3(0.0418, x, y, nv, h, ns);  % Unstructured
    %       Tt = calc_timeStepWW3(0.0418, x, y, nv, h, ns, 'figOn');  % Unstructured
    % =================================================================================================================
    % References:
    %   
    %       --------- Structured grid ---------
    %       Cc = Cgmax*t/min(x,y) Cc越小越好， >1不稳定
    %       WW3——6.07手册 公式A.1
    %       最大群速 = 深水群速*1.15
    %       C0 = gT/(2pi)
    %       C0是指深水情况下波浪的相速度
    %       深水情况下波浪的群速Cg = C0/2
    %       --------- Unstructured grid ---------
    %
    %       See also CALC_WAVESPEED
    %       ---------------------------------------------
    %       全局时间步长为2-4倍的CFL
    %       Tt.xy/timestep --> CFL
    %       Tt.k/timestep --> 全局时间步长的一半
    %       Tt.source/timestep
    % =================================================================================================================

    arguments(Input)
        fmin(:,1) {mustBeMember(fmin,[0.0418,0.0373])}
        lon (:,1)
        lat (:,1)
    end
    arguments (Input,Repeating)
        varargin
    end
 
    if ~isempty(varargin) && size(varargin{1},2) == 3 && length(varargin{2}) == numel(lon)
        Tt = calc_timeStepWW3_tri(fmin, lon, lat, varargin{:});
        Tt.type = 'TRI';
    else
        Tt = calc_timeStepWW3_grid(fmin, lon, lat, varargin{:});
        Tt.type = 'GRID';
    end

end


function Tt = calc_timeStepWW3_grid(fmin, lon, lat, varargin)
    
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


function Tt = calc_timeStepWW3_tri(fmin, x, y, nv, h, ns, varargin)
    
    arguments (Input)
        fmin (:,1)
        x (:,1)
        y (:,1)
        nv (:,3)
        h (:,1)
        ns {cell}
    end
    
    arguments (Input,Repeating)
        varargin 
    end
    
    % --------- define settings --------- 
    method_bound = 'OU';  % 'OU' or 'ALL'
    method_waveSpd = 2;   % 1 or 2 or 3
    % --------- define settings --------- 
    
    varargin = read_varargin2(varargin,{'figOn'});
    
    fgrid = f_load_grid(x,y,nv,h,'Nodisp');
    
    z = h;
    lines = unique(fgrid.lines, 'rows'); % 找出所有三角形的边（去除共享的边）
       
    ns1 = [];
    for i = 1:length(ns)
        ns1 = [ns1;ns{i}];
    end
    ns = unique(ns1); clear ns1 % 排除边界边 OceanMesh2D中定义的边界点可能有重复，所以要去重
    
    switch method_bound
        % 计算线段的方法
        % OU  会返回 open boundary lines and unopen boundary lines
        % ALL 会返回 open boundary lines and all boundary lines
    case 'OU'
        bd_N = 0;
        for i = 1:length(ns)
            bd_N = bd_N+double(lines==ns(i));
        end
        bd_N = sum(bd_N==1,2);
        lines_ob = lines(bd_N==2,:);
        lines_ub = lines(bd_N<2,:);
        lines_all = lines;
    
    case 'ALL'
        lines_ob = [];
        for s = 1:length(fgrid.ns)
            ns_s = fgrid.ns{s};
            for i = 1:length(ns_s)-1
                lines_ob = cat(1, lines_ob,[ns_s(i),ns_s(i+1)]);
            end
        end
        lines_ub = lines;
        lines_all = lines;
    end
    
    % 计算非边界边的长度（m）及中点水深
    dist_line = calc_geodistance(x(lines_ub(:,1)),y(lines_ub(:,1)),x(lines_ub(:,2)),y(lines_ub(:,2)),"method","MATLAB");
    % dist_line = calc_distance(x(lines_ub(:,1)),y(lines_ub(:,1)),x(lines_ub(:,2)),y(lines_ub(:,2)));
    z_line = mean([z(lines_ub(:,1)),z(lines_ub(:,2))],2);
    
    % 计算各条边的群速及传播历时
    switch method_waveSpd
    case 2
        [~ ,Cg, ~] = calc_waveSpeed(fmin,z_line,'method',2);
    case 1
        Cg = zeros(length(z_line),1);
        for i=1:length(z_line)
            [~, Cg(i), ~] = calc_waveSpeed(fmin,z_line(i),'method',1);
        end
    end
    [t,pos_t] = min(dist_line./Cg);  % 这里的t就是临界时间步长
    
    %% draw
    if ~isempty(figOn)
        % draw mesh and open boundary
        figure('color','w','units','normalized','pos',[0.1,0.1,0.6,0.7],'name','Mesh with open boundary')
        clf; hold on
        h = patch('Vertices',[x,y], 'Faces',nv, 'FaceColor','k','FaceAlpha',0, 'EdgeColor', [50 205 50]./255);
        h1 = line([x(lines_ub(1,1)),x(lines_ub(1,2))]',[y(lines_ub(1,1)),y(lines_ub(1,2))]','color',[50 205 50]./255);
        h2 = line([x(lines_ob(:,1)) x(lines_ob(:,2))]',[y(lines_ob(:,1)) y(lines_ob(:,2))]','color','r');
        h_lgd1=legend([h1(1),h2(1)],{'非边界','边界'});
        set(h_lgd1,'fontsize',18)
        axis padded % tight
        box on
        title('Mesh with open boundary','fontsize',16)
    
        % draw min time step line 画出传播历时最小的边，该边的传播时长作为整个网格的临界时间步长
        figure('color','w','units','normalized','pos',[0.1,0.1,0.6,0.7],'name','Minimum time step')
        clf; hold on
        h3 = patch('Vertices',[x,y], 'Faces',nv, 'FaceColor','k','FaceAlpha',0, 'EdgeColor', [135 206 235]./255);
        % h3 = line([x(cnct2(:,1)) x(cnct2(:,2))]',[y(cnct2(:,1)) y(cnct2(:,2))]','color',[135 206 235]./255);
        pos1 = lines_ub(pos_t,1); pos2 = lines_ub(pos_t,2);
        x1=x(pos1); x2=x(pos2); 
        y1=y(pos1); y2=y(pos2);
        z1=z(pos1); z2=z(pos2);
        h4 = plot([x1,x2],[y1,y2],'color','k');
        h5 = scatter(x1,y1,10,'markerfacecolor','r','markeredgecolor','r');
        h6 = scatter(x2,y2,10,'markerfacecolor','b','markeredgecolor','b');
        dist_12 = calc_geodistance(x1,y1,x2,y2,"method","common");
        z_mean = (z(pos1)+z(pos2))/2;
        h_lgd2=legend([h4,h5,h6],{ ...
            sprintf('   d:   %7.3fm          middle-dep: %7.3f',dist_12,z_mean);
            sprintf(' lon: %8.3f^o   lat: %7.3f^o   dep: %7.3f',x1,y1,z1);
            sprintf(' lon: %8.3f^o   lat: %7.3f^o   dep: %7.3f',x2,y2,z2);
            });
        set(h_lgd2,'fontsize',16,'fontname','times new roman')
        axis padded
        box on
        title(sprintf('Wave min frequency: %.4fHz', fmin), sprintf('Min time step: %.1f', t),'fontsize',18)
    end
    
    Tt.global = [2*t 4*t];
    Tt.xy     = t;
    Tt.k      = Tt.global/2;
    Tt.source = [5 15];

end
