function [t,varargout]=devide_parameters(observations,options)
% Divide parametres
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
Np=length(find(size(x)~=1));

switch options.devide_param
    case 'unif'
        switch Np
            case 1
                t=linspace(0,1,length(x));
            case 2
                s=linspace(0,1,size(x,1));
                t=linspace(0,1,size(x,2));
            case 3
                r=linspace(0,1,size(x,1));
                s=linspace(0,1,size(x,2));
                t=linspace(0,1,size(x,3));
            otherwise
                error('dimension too high')
        end
    case 'dist'
        switch Np
            case 1
                if dim==2
                    distance=sqrt(diff(x).^2+diff(y).^2);
                elseif dim==3
                    distance=sqrt(diff(x).^2+diff(y).^2+diff(z).^2);
                end
                distance=distance/sum(distance);
                t=0;
                for i=1:length(distance)
                    t=[t sum(distance(1:i))];
                end
            case 2
                if dim==2
                    distance1=sqrt(mean(diff(x,1,1).^2+diff(y,1,1).^2,2));
                    distance2=sqrt(mean(diff(x,1,2).^2+diff(y,1,2).^2,1));
                elseif dim==3
                    distance1=sqrt(mean(diff(x,1,1).^2+diff(y,1,1).^2+diff(z,1,1).^2,2));
                    distance2=sqrt(mean(diff(x,1,2).^2+diff(y,1,2).^2+diff(z,1,2).^2,1));
                end
                distance1=distance1/sum(distance1);
                distance2=distance2/sum(distance2);
                t=0;s=0;
                for i=1:length(distance1)
                    s=[s sum(distance1(1:i))];
                end
                for i=1:length(distance2)
                    t=[t sum(distance2(1:i))];
                end
            case 3
                if dim==2
                    distance1=sqrt(mean(mean(diff(x,1,1).^2+diff(y,1,1).^2,2),3));
                    distance2=sqrt(mean(mean(diff(x,1,2).^2+diff(y,1,2).^2,1),3));
                    distance3=sqrt(mean(mean(diff(x,1,3).^2+diff(y,1,3).^2,1),2));
                elseif dim==3
                    distance1=sqrt(mean(mean(diff(x,1,1).^2+diff(y,1,1).^2+diff(z,1,1).^2,2),3));
                    distance2=sqrt(mean(mean(diff(x,1,2).^2+diff(y,1,2).^2+diff(z,1,2).^2,1),3));
                    distance3=sqrt(mean(mean(diff(x,1,3).^2+diff(y,1,3).^2+diff(z,1,3).^2,1),2));
                end
                distance1=distance1/sum(distance1);
                distance2=distance2/sum(distance2);
                distance3=distance3/sum(distance3);
                t=0;s=0;r=0;
                for i=1:length(distance1)
                    r=[s sum(distance1(1:i))];
                end
                for i=1:length(distance2)
                    s=[s sum(distance2(1:i))];
                end
                for i=1:length(distance3)
                    t=[t sum(distance3(1:i))];
                end
            otherwise
                error('dimension too high')
        end
    case 'user'
        switch size(defaut_options.devide_param,2)
            case 1
                t=options.devide_param(:,1);
            case 2
                t=options.devide_param(:,2);
                s=options.devide_param(:,1);
            case 3
                t=options.devide_param(:,3);
                s=options.devide_param(:,2);
                r=options.devide_param(:,1);
        end
end
if exist('s','var')
    varargout{1}=s;
end
if exist('r','var')
    varargout{2}=r;
end
