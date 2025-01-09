function plot_markerTY(x0, y0, R, colors, rX, rY, angle)
    %       draw typhoon icon
    % =================================================================================================================
    % Parameters:
    %       x0:     中心位置坐标                    || required: True || type: double 
    %       x0:     中心位置坐标                    || required: True || type: double 
    %       R:      中心圆半径。                    || required: True || type: double 
    %       colors: 颜色（RGB数组）                 || required: True || type: double 
    %       rX:     对marker在x, y方向上的伸缩比     || required: True || type: double 
    %       rY:     中心位置坐标                    || required: True || type: double 
    %       angle:  两个尖角所指的方向               || required: True || type: double 
    %       x0:     中心位置坐标                    || required: True || type: double 
    %       varargin:   (options)   as follow:
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Updates:
    %       2021-12-11: Created, by OUC cgchen;
    %       2025-01-09: Changed, by Christmas;
    % =================================================================================================================
    % Examples:
    %       plot_markerTY(10, 0, 0.1, [0.8 0.8 0.8], 0.5, 0.5,30)
    %       plot_markerTY(20, 0, 0.1, [0.8 0.8 0.8], 5.0, 0.3,0)
    % =================================================================================================================
    % Notes:
    %       rX, rY : 对marker在x, y方向上的伸缩比率，对于不同图形，都应进行调整
    %       angle  :调节两个尖角所指的方向,单位为度。0度表示两个尖角指向左右（东西方），90度表示两个尖角指向上下（南北方）
    %       当rX不等于rY时候，angle只能是0度，否则会画出错误的图形来
    % =================================================================================================================

    if ~ isequal(rX, rY)
        angle = 0;
    end

    %% 为将得到的台风logo图绕B旋转angle度，先计算仿射变换矩阵，
    B = [x0, y0]; 
    rotateMatrix = [cosd(angle), -sind(angle), 0;...
                    sind(angle), cosd(angle), 0;...
                    0 0 1]; 
    M1 = [1, 0, B(1, 1);...
          0, 1, B(1, 2);...
          0, 0, 1;];
    M2 = [1, 0, -B(1, 1);...
          0, 1, -B(1, 2);...
          0, 0, 1;];
    M = M1*rotateMatrix*M2;
    %% 仿射变换矩阵结束
    
    theta_arc = [pi:-pi/100:pi/5];
    rho_arc = R + R./theta_arc;
    [x_arc, y_arc] = pol2cart(theta_arc, rho_arc);
    
    theta_ring = [0:pi/100:2*pi];
    rho_ring = rho_arc(1)*ones(size(theta_ring));
    [x_ring, y_ring] = pol2cart(theta_ring,rho_ring);

    theta_line = [pi/4, theta_arc(end)];
    rho_line = [rho_ring(1), rho_arc(end)];
    [x_line, y_line] = pol2cart(theta_line, rho_line);
    
    theta_arc2 = [2*pi:-pi/100:6*pi/5];
    rho_arc2 = R + R./theta_arc;
    [x_arc2, y_arc2] = pol2cart(theta_arc2, rho_arc2);
    
    theta_line2 = [5*pi/4, theta_arc2(end)];
    rho_line2 = [rho_ring(1), rho_arc(end)];
    [x_line2, y_line2] = pol2cart(theta_line2, rho_line2);
    
    theta_ring2 = [0:pi/100:2*pi];
    rho_ring2 = rho_arc(1)/6*ones(size(theta_ring));
    [x_ring2, y_ring2] = pol2cart(theta_ring2, rho_ring2);

    hold on
    %% 第1瓣坐标(x,y),以及旋转angle度后(xx,yy)的坐标
    x=[x0+x_arc.*rX];
    y=[y0+y_arc.*rY];
    xx=zeros(length(x),1);
    yy=zeros(length(x),1);
    for k=1:length(x)
        A(1,1)=x(k);
        A(1,2)=y(k);
        A_new_ = M*[A, 1]';
        A_new = A_new_(1:2)';
        xx(k)=A_new(1);
        yy(k)=A_new(2);
    end
    patch(xx, yy, colors)
    
    %% 第二瓣坐标(x,y),以及旋转angle度后(xx,yy)的坐标
    x=[x0+x_arc2.*rX];
    y=[y0+y_arc2.*rY];
    xx=zeros(length(x),1);
    yy=zeros(length(x),1);
    for k=1:length(x)
        A(1,1)=x(k);
        A(1,2)=y(k);
        A_new_ = M*[A, 1]';
        A_new = A_new_(1:2)';
        xx(k)=A_new(1);
        yy(k)=A_new(2);
    end
    patch(xx, yy, colors)
    
    %% 画中间的圆形
    patch(x0+x_ring.*rX, y0+y_ring.*rY, colors, 'LineStyle', 'none')
    patch(x0+x_ring2.*rX*2, y0+y_ring2.*rY*2, 'w')
    
    % axis equal;
    % box on;
    hold off
end

