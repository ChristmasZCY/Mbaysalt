function [a,b,c]=krigeage1(observations,options)
%krigeage 2D pour une fonction explicite(non-parametrique)
x=observations.x;
y=observations.y;
dim=length(fieldnames(observations)); % dimension
Normalisation;
A=MKdual(x,options.covariance,options.derive,options.user_derive,options.omega,options);
N=length(x);

if ~isempty(options.grad)
    xd=options.grad(:,1);
    D=length(xd);
    M=size(A,1)-N-D;
    u=[y';options.grad(:,2);zeros(M,1)];
    solu=A\u;
    b=solu(1:N);
    c=solu(N+1:N+D);
    a=solu(N+D+1:end);
else
    M=size(A,1)-N;
    u=[y';zeros(M,1)];
    solu=A\u;
    b=solu(1:N);
    a=solu(N+1:end);
    c=[];
end