clm

%% WW3-grid
Tt = calc_timeStepWW3(0.0418, -180:.2:180, -85:.2:60);

%% WW3-tri
% msh='multi_new.14';
msh='/Users/christmas/Documents/Code/Project/Server_Program/区域海浪/ww3_djk/qd_rz.msh'; % 要读取的ww3格式的三角文件名
f = c_load_model(msh,'Coordinate','geo');
Tt = calc_timeStepWW3(0.0418, f.x, f.y, f.nv, f.h, f.ns);
Tt = calc_timeStepWW3(0.0418, f.x, f.y, f.nv, f.h, f.ns, 'figOn');

