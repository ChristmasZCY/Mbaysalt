%% Extract coastline from FVCOM grid
% .2dm .grd .nc and so on

f = f_load_grid('/Users/christmas/Desktop/项目/网格/ECS/ECS_9/ECS_9(msl).2dm');
a = [];
b = [];
for i = 1:length(f.bdy_x)
    a = [a,f.bdy_x{i},NaN];
    b = [b,f.bdy_y{i},NaN];
end

% a = [f.bdy_x{:}];
% b = [f.bdy_y{:}];
% plot(a,b)
write_cst('/Users/christmas/Desktop/bohai_from_ECS9.cst', a,b)
