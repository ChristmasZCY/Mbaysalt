function [a,b,c]=krigeage2(observations,options)
%krigeage 3D pour une fonction explicite(non-parametrique)
dim=length(fieldnames(observations));
x=observations.x;
y=observations.y;
z=observations.z;

Normalisation;
A=MKdual2(x,y,options.covariance,options.derive,options.sigma,options.omega);
N=length(x);



M=size(A,1)-N;
u=[z';zeros(M,1)];
solu=A\u;
b=solu(1:N);
a=solu(N+1:end);
c=[];
