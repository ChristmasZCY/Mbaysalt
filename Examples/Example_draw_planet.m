clm 
figure(1)
% 先画一个hot渐变色的球
[a,b,c]=sphere(99);
surf(a,b,c);
colormap hot  % cool
hold on

% 在球面外生成一些随机点
% 进行三角剖分后
% 设置成半透明冷色
% 一些透明三角形交错叠加形成炫酷星球
x=randn(3,999);       
x=1.01*x./vecnorm(x);
p=delaunay(x');
h=patch('faces',p,'vertices',x','FaceVertexCData',cool(size(p,1)),'FaceAlpha',.25);
% 设置坐标区域比例
axis equal off
% 设置背景色
set(gcf,'color','k')
set(gcf,'InvertHardCopy','off')
% 平滑星球表面配色
shading flat

% 在星球外生成一些随机点当作星星
r=@()rand(1,3e2);
scatter(r()*10-5,r()*10-5,r().^2*200,'.w');
camva(2)
