%% dace
clm
load data1.mat;
theta = [10 10]; lob = [1E-1 1E-1]; upb = [20 20];
[dmodel, perf] = dacefit(S, Y, @regpoly0, @corrgauss, theta, lob, upb);

X = gridsamp([0 0;100 100], 40);
[YX, MSE] = predictor(X, dmodel);

X1 = reshape(X(:,1),40,40); X2 = reshape(X(:,2),40,40);
YX = reshape(YX, size(X1));

figure(1); mesh(X1, X2, YX);
hold on;
plot3(S(:,1),S(:,2),Y,'.k', 'MarkerSize',10);
hold off;

%% KrigingToolbox-1
clc
clear variables
load('data1.mat')

observations.x=S(:,1)';
observations.y=S(:,2)';
observations.z=Y';
options.param='off';
options.resolution=[40];
options.covariance='@(y)1/10/sqrt(2*pi)*exp(-y.^2/2/10^2)';
figure
u=krigeage(observations,options);

%% KrigingToolbox-2
clear variables
clc

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

