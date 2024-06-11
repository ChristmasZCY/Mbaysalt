function [a,b,c]=krigeage1_param(t,observations,options)
%krigeage pour une courbe 2D ou 3D (1 parametre)

dim=length(fieldnames(observations));
switch dim
    case 2
        x=observations.x;
        y=observations.y;
        if size(x)~=size(y)
            error('error input in krigeage: observations')
        end
    case 3
        x=observations.x;
        y=observations.y;
        z=observations.z;
        if min(size(x)~=size(y)) || min(size(x)~=size(z))
            error('error input in krigeage: observations')
        end
    otherwise
        error('error input in krigeage: observations')
end
N=length(t);

switch dim
    case 2
        x=observations.x;
        y=observations.y;
    case 3
        x=observations.x;
        y=observations.y;
        z=observations.z;
    otherwise
        error('error input in krigeage: observations')
end
Normalisation;

A=MKdual(t,options.covariance,options.derive,options.user_derive,options.omega,options);
M=size(A,1)-N;
switch dim
    case 2
        u=[x' y';zeros(M,dim)];
    case 3
        u=[x' y' z';zeros(M,dim)];
    otherwise
        error('error input in krigeage: observations')
end

solu=A\u;

b=solu(1:N,:);
if strcmp(options.closeloop,'yes')
    c=solu(N+1,:);
    a=solu(N+2:end,:);
else
    c=[];
    a=solu(N+1:end,:);
end