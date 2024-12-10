
%% f_smooth
clm
f = f_load_grid('/Users/christmas/Documents/Code/Project/Server_Program/ModelGrid/北部湾/v4-2d/bbw4_geo.2dm');
figure(1)
f_2d_image(f,f.h);
figure(2)
f.h = f_smooth(f, f.h);
f_2d_image(f,f.h);

%% smoothdata 
%% smooth 
clm
f = f_load_grid('/Users/christmas/Documents/Code/Project/Server_Program/ModelGrid/北部湾/v4-2d/bbw4_geo.2dm');
figure(1)
f_2d_image(f,f.h);
figure(2)
D = pwd;
cd([matlabroot '/toolbox/curvefit/curvefit'])
f.h = smooth(f.h);
cd(D)
f_2d_image(f,f.h);

%% conv2 --> https://blog.csdn.net/island_chenyanyu/article/details/118407737
%{
1、小核足以对仅包含少数频率分量的数据进行平滑处理。较大的核可以更精确地对频率响应进行调整，从而得到更平滑的输出。
2、其中，‘same’ 能使得输出数组与输入的大小相同。
   还有 ‘full’ 和‘valid’ ，具体参考help
%}
clm
f = f_load_grid('/Users/christmas/Desktop/项目/网格/北部湾/v4/bbw4_geo.2dm');
figure(1)
f_2d_image(f,f.h);
figure(2)
k = 1/9*ones(3);  % 用于降噪的核。个人理解类似于9点平均
f.h = conv2( f.h , k , 'same' );
f_2d_image(f,f.h);




