%exercices
clearvars
close all
clc
[Path, ~, ~] = fileparts(which(mfilename));
cd(Path)
addpath('./functions')

%% 3.3
clear variables

observations.x=[0 1 2];
observations.y=[0 1 0];
options.param='off';
try
    options.covariance='@(t)t.^2';
    figure('Name','3.3')
    krigeage(observations,options);
catch MessageErreur
    if strcmp(MessageErreur.message,'Matrice Krigeage non-inversible!')
        disp('Avec covariance carré, la matrice Krigeage est non-inversible!')
    end
end
options.covariance='cubic';
krigeage(observations,options);

%% 3.4
clear variables
clc
observations.x=[0 1 2];
observations.y=[0 1 0];
options.param='off';
options.derive='user';
options.user_derive={'@(x)1','@(x)x.^2'};
figure('Name','3.4-1')
krigeage(observations,options);
options.derive='const';
figure('Name','3.4-2')
krigeage(observations,options);
%% 3.5
clear variables
clc
observations.x=[0 0.25 0.75 1];
observations.y=[0 1 1 0];
options.param='off';
figure('Name','3.5')
krigeage(observations,options);

%% 3.7
clear variables
clc
observations.x=[0 0.25 0.5 0.75 1];
observations.y=[0 0.5 0.25 0.5 0];
options.param='off';
figure('Name','3.7')
krigeage(observations,options);

%% 4.1
clear variables
clc
observations.x=[1 0 0];
observations.y=[0 1 0];
observations.z=[0 0 1];
options.param='off';
figure('Name','4.1')
krigeage(observations,options);
view(75,30)
zlim([0 1])

%% 6.1
clear variables
clc
observations.x=[1 0 -1 0 1];
observations.y=[0 1 0 -1 0];
    
options.param='on';
options.derive='sin';
options.covariance='sin';
options.normalisation='off';
options.omega=[2*pi;2*pi];
figure('Name','6.1')
krigeage(observations,options);
axis equal

%% 7.1
clear variables
clc
%plan 2D
observations.x=[0.5 0 -0.5;1 0 -1]';
observations.y=[0 0.5 0;0 1 0]';

options.param='on';
options.derive={'quad','const'};
options.covariance={'cubic','lin'};
options.normalisation='off';
figure('Name','7.1-1')
krigeage(observations,options);
axis equal

options.derive={'sin','const'};
options.covariance={'sin','lin'};
options.normalisation='off';
options.omega=[pi pi;pi pi];
figure('Name','7.1-2')
krigeage(observations,options);
axis equal

%% 7.2
clear variables
clc
%rotation complete
observations.x=[0 1 1/2 1 1 0;0 0 0 0 0 0;0 -1 -1/2 -1 -1 0;0 0 0 0 0 0;0 1 1/2 1 1 0]';
observations.y=[0 0 0 0 0 0;0 -1 -1/2 -1 -1 0;0 0 0 0 0 0;0 1 1/2 1 1 0;0 0 0 0 0 0]';
observations.z=[0 0 3/4 7/8 1 1;0 0 3/4 7/8 1 1;0 0 3/4 7/8 1 1;0 0 3/4 7/8 1 1;0 0 3/4 7/8 1 1]';

options.param='on';
options.derive={'const','sin'};
options.covariance={'lin','sin'};
options.normalisation='off';
options.omega=[pi*2 pi*2;pi*2 pi*2];
options.devide_param='dist';
figure('Name','7.2-1')
krigeage(observations,options);

%rotation 90 degrees
observations.x=[0 1 1/2 1 1 0;0 0 0 0 0 0]';
observations.y=[0 0 0 0 0 0;0 -1 -1/2 -1 -1 0]';
observations.z=[0 0 3/4 7/8 1 1;0 0 3/4 7/8 1 1]';

options.param='on';
options.derive={'const','sin'};
options.covariance={'lin','sin'};
options.normalisation='off';
options.omega=[pi/2 pi/2;pi/2 pi/2];
options.devide_param='dist';
figure('Name','7.1-2')
krigeage(observations,options);

%% 9.1
clear variables
clc
observations.x=[0 1];
observations.y=[0 0];
    
options.param='off';
options.derive='const';
options.covariance='@(x)x.^4.*log(x+1e-9)';
options.grad=[0 1];
figure('Name','9.1')
krigeage(observations,options);
axis equal

%% 9.2
observations.x=[0 1];
observations.y=[0 0];
    
options.param='off';
options.derive='const';
options.covariance='cubic';
options.grad=[0 1;1 -1];
figure('Name','9.2')
krigeage(observations,options);

%% 9.3
clear variables
clc
observations.x=[0 1];
observations.y=[0 0];
    
options.param='off';
options.derive='const';
options.covariance='cubic';
options.grad=[0.5 0];
figure('Name','9.3')
krigeage(observations,options);

%% 9.4
clear variables
clc
observations.x=[0 1 2];
observations.y=[0 0.5 0];
    
options.param='off';
options.derive='const';
options.covariance='cubic';
options.grad=[0 0;2 0];
figure('Name','9.4')
krigeage(observations,options);

%% 10.2
clear variables
clc
observations.x=[2 0 -2 0 2];
observations.y=[0 1 0 -1 0];
options.param='on';
options.derive='const';
options.covariance='cubic';
figure('Name','10.2')
krigeage(observations,options);
hold on

observations.x=[0 2 0 -2 0 2 0];
observations.y=[-1 0 1 0 -1 0 1];
krigeage(observations,options);

observations.x=[2 0 -2 0 2];
observations.y=[0 1 0 -1 0];
options.closeloop='yes';
krigeage(observations,options);

t=0:0.001:2*pi;
plot(2*cos(t),sin(t),'LineWidth',0.5)
legend('method 1','','method 2','','method 3','','ellipse standard')

%% 12.6
clear variables
clc
observations.x=[1 0.5 2.5 4 3 2];
observations.y=[1 2 4 3 1 2];
observations.z=[0 0 0 0 0 1];
options.param='off';
figure('Name','12.6')
krigeage(observations,options);
view(2)

%% examin
clear variables
clc
observations.x=nan(2,3,3);observations.y=nan(2,3,3);observations.z=nan(2,3,3);
observations.x(:,:,1)=[0.5 sqrt(2)/4 0;1 sqrt(2)/2 0];
observations.x(:,:,2)=[0.5 sqrt(2)/4 0;1 sqrt(2)/2 0];
observations.x(:,:,3)=[0.5 sqrt(2)/4 0;1 sqrt(2)/2 0];
observations.y(:,:,1)=[0 sqrt(2)/4 0.5;0 sqrt(2)/2 1];
observations.y(:,:,2)=[0 sqrt(2)/4 0.5;0 sqrt(2)/2 1];
observations.y(:,:,3)=[0 sqrt(2)/4 0.5;0 sqrt(2)/2 1];
observations.z(:,:,1)=[0 0 0;0 0 0];
observations.z(:,:,2)=[0.5 0.6 0.7;0.6 0.7 0.85];
observations.z(:,:,3)=[1 1.1 1.2;1.2 1.3 1.5];
figure('Name','examin')
options.param='on';
options.resolution=[10 20 15];
options.derive={'const','quad','const'};
options.covariance={'lin','sin','lin'};
options.omega=[1 1 pi/2;1 1 1];
u=krigeage(observations,options);
view(3)
grid on

%% comparaison avec toolbox DACE
clear variables
clc
addpath('./dace')
load('data1.mat')
tic
observations.x=S(:,1)';
observations.y=S(:,2)';
observations.z=Y';
options.param='off';
options.resolution=[40];
figure
u=krigeage(observations,options);
toc


tic
theta=[10 10];
lob=[0.1 0.1];upb=[20 20];
[dmodel,perf]=dacefit(S,Y,@regpoly0,@corrgauss,theta,lob,upb);
X=gridsamp([0 0;100 100],40);
[YX,MSE]=predictor(X,dmodel);
X1=reshape(X(:,1),40,40);X2=reshape(X(:,2),40,40);
YX=reshape(YX,size(X1));
figure
mesh(X1,X2,YX)
toc
hold on
plot3(S(:,1),S(:,2),Y,'ro')

%% gausse function
clear variables
clc
addpath('./dace')
load('data1.mat')

observations.x=S(:,1)';
observations.y=S(:,2)';
observations.z=Y';
options.param='off';
options.resolution=[40];
options.covariance='@(y)1/10/sqrt(2*pi)*exp(-y.^2/2/10^2)';
figure
u=krigeage(observations,options);

theta=[10 10];
lob=[0.1 0.1];upb=[20 20];
[dmodel,perf]=dacefit(S,Y,@regpoly0,@corrgauss,theta,lob,upb);
X=gridsamp([0 0;100 100],40);
[YX,MSE]=predictor(X,dmodel);
X1=reshape(X(:,1),40,40);X2=reshape(X(:,2),40,40);
YX=reshape(YX,size(X1));
figure
mesh(X1,X2,YX)
hold on
plot3(S(:,1),S(:,2),Y,'ro')

clc