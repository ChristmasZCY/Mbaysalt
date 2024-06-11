function u_out=regress(u,observations,options,a,b,c)
% regression
if nargin==4
    Q=a;
elseif nargin==6
else
    error('sth wrong')
end
dim=length(fieldnames(observations)); % dimension
Np=length(find(size(observations.x)~=1)); % nombre des parametres
switch dim
    case 2
        x=observations.x;
        y=observations.y;
        X(:,1)=observations.x(:);
        X(:,2)=observations.y(:);
    case 3
        x=observations.x;
        y=observations.y;
        z=observations.z;
        X(:,1)=observations.x(:);
        X(:,2)=observations.y(:);
        X(:,3)=observations.z(:);
    otherwise
        error('error input in krigeage: observations')
end
Normalisation;

if strcmp(options.param,'on') % utiliser équations parametriques
    for i=1:length(u)
        switch options.normalisation
            case 'axial'
                switch Np
                    case 1
                        u_out{i}=@(t)u{i}(t)*(max(X(:,i))-min(X(:,i)))+min(X(:,i));
                    case 2
                        u_out{i}=@(s,t)u{i}(s,t)*(max(X(:,i))-min(X(:,i)))+min(X(:,i));
                    case 3
                        u_out{i}=@(r,s,t)u{i}(r,s,t)*(max(X(:,i))-min(X(:,i)))+min(X(:,i));
                end
            case 'global'
                switch Np
                    case 1
                        u_out{i}=@(t)u{i}(t)*C+min(X(:,i));
                    case 2
                        u_out{i}=@(s,t)u{i}(s,t)*C+min(X(:,i));
                    case 3
                        u_out{i}=@(r,s,t)u{i}(r,s,t)*C+min(X(:,i));
                end
        end
    end
elseif strcmp(options.param,'off') % utiliser équations explicites
    syms s t
    ustr=func2str(u{1});
    pright=strfind(ustr,')');
    pright(2:end)=[];
    ustr(1:pright)=[];
    eval(['usym=' ustr ';']);
    
    if dim==2
        switch options.normalisation
            case 'axial'
                usym=subs(usym,t,(t-min(X(:,1)))/(max(X(:,1))-min(X(:,1))));
                u_x=matlabFunction(usym);
                u_out=@(t)(u_x(t)*(max(X(:,2))-min(X(:,2)))+min(X(:,2)));
            case 'global'
                usym=subs(usym,t,(t-min(X(:,1)))/C);
                u_x=matlabFunction(usym);
                u_out=@(t)(u_x(t)*C+min(X(:,2)));
        end
        
    elseif dim==3
        switch options.normalisation
            case 'axial'
                usym=subs(usym,s,(s-min(X(:,1)))/(max(X(:,1))-min(X(:,1))));
                usym=subs(usym,t,(t-min(X(:,2)))/(max(X(:,2))-min(X(:,2))));
                u_x=matlabFunction(usym);
                u_out=@(s,t)(u_x(s,t)*(max(X(:,3))-min(X(:,3)))+min(X(:,3)));
            case 'global'
                usym=subs(usym,s,(s-min(X(:,1)))/C);
                usym=subs(usym,t,(t-min(X(:,2)))/C);
                u_x=matlabFunction(usym);
                u_out=@(s,t)(u_x(s,t)*C+min(X(:,3)));
        end
    end
    u_out={u_out};
end
