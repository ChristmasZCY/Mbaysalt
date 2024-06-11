function [u]=plotting_krigeage2(Q,observations,options)
% plotter une surface krigé
dim=length(fieldnames(observations));
switch dim
    case 2
        x=observations.x;
        y=observations.y;
        if min(size(x))~=min(size(y))
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

Normalisation;

[ti,si]=devide_parameters(observations,options);
if dim==2
    tii=linspace(0,1,options.resolution(1));
    sii=linspace(0,1,options.resolution(2));
    Qx=Q(:,:,1);Qy=Q(:,:,2);
    [M,N]=size(Qx);
    switch options.covariance{1}
        case 'lin'
            K1=@(s)s;
        case 'log'
            K1=@(s)s.^2.*log(s+1e-9);
        case 'cubic'
            K1=@(s)s.^3;
        case 'sin'
            K1=@(s)sin(options.omega(1,1)*s);
        otherwise
            var_name=options.covariance{1}(3);
            options.covariance{1}=strrep(options.covariance{1},var_name,'t');
            eval(['K1=' options.covariance{1} ';']);
    end
    switch options.covariance{2}
        case 'lin'
            K2=@(t)t;
        case 'log'
            K2=@(t)t.^2.*log(t+1e-9);
        case 'cubic'
            K2=@(t)t.^3;
        case 'sin'
            K2=@(t)sin(options.omega(1,2)*t);
        otherwise
            var_name=options.covariance{2}(3);
            options.covariance{2}=strrep(options.covariance{2},var_name,'t');
            eval(['K1=' options.covariance{2} ';']);
    end
    clear k1 k2
    for i=1:size(observations.x,1)
        k1{i}=['K1(abs(s-si(' num2str(i) ')))'];
    end
    for j=1:size(observations.x,2)
        k2{j}=['K2(abs(t-ti(' num2str(j) ')))'];
    end
    switch options.derive{1}
        case 'const'
            k1{end+1}='1';
        case 'lin'
            k1{end+1}='1';
            k1{end+1}='s';
        case 'quad'
            k1{end+1}='1';
            k1{end+1}='s';
            k1{end+1}='s.^2';
        case 'cubic'
            k1{end+1}='1';
            k1{end+1}='s';
            k1{end+1}='s.^2';
            k1{end+1}='s.^3';
        case 'sin'
            k1{end+1}='1';
            k1{end+1}='cos(options.omega(2,1)*s)';
            k1{end+1}='sin(options.omega(2,1)*s)';
        case 'user'
            for i=1:length(options.user_derive{1})
                Ks{i}=options.user_derive{1}{i};
                var_name{i}=Ks{i}(3);
                Ks{i}=strrep(Ks{i},var_name{i},'s');
                Ks{i}(1:4)=[];
                k1{end+1}=Ks{i};
            end
    end
    switch options.derive{2}
        case 'const'
            k2{end+1}='1';
        case 'lin'
            k2{end+1}='1';
            k2{end+1}='t';
        case 'quad'
            k2{end+1}='1';
            k2{end+1}='t';
            k2{end+1}='t.^2';
        case 'cubic'
            k2{end+1}='1';
            k2{end+1}='t';
            k2{end+1}='t.^2';
            k2{end+1}='t.^3';
        case 'sin'
            k2{end+1}=1;
            k2{end+1}='cos(options.omega(2,2)*t)';
            k2{end+1}='sin(options.omega(2,2)*t)';
        case 'user'
            for i=1:length(options.user_derive{2})
                Ks{i}=options.user_derive{2}{i};
                var_name{i}=Ks{i}(3);
                Ks{i}=strrep(Ks{i},var_name{i},'s');
                Ks{i}(1:4)=[];
                k1{end+1}=Ks{i};
            end
    end
    xst='xstf=@(s,t)';yst='ystf=@(s,t)';
    for i=1:M
        for j=1:N
            xst=[xst 'Qx(' num2str(i) ',' num2str(j) ')*' k1{i} '.*' k2{j} '+'];
            yst=[yst 'Qy(' num2str(i) ',' num2str(j) ')*' k1{i} '.*' k2{j} '+'];
        end
    end
    xst(end)=';';yst(end)=';';
    eval(xst);eval(yst);
    u={xstf,ystf};
    
    [Sii,Tii]=meshgrid(sii,tii);  
    xst=double(xstf(Sii,Tii))';
    yst=double(ystf(Sii,Tii))';
    [Si,Ti]=meshgrid(si,ti);  
    switch options.normalisation
        case 'axial'
            erreur_x=(double(xstf(Si,Ti))'-x)*(max(observations.x(:))-min(observations.x(:)));
            erreur_y=(double(ystf(Si,Ti))'-y)*(max(observations.y(:))-min(observations.y(:)));
            yst=yst*(max(observations.y(:))-min(observations.y(:)))+min(observations.y(:));
            xst=xst*(max(observations.x(:))-min(observations.x(:)))+min(observations.x(:));
            x=x*(max(observations.x(:))-min(observations.x(:)))+min(observations.x(:));
            y=y*(max(observations.y(:))-min(observations.y(:)))+min(observations.y(:));
        case 'global'
            erreur_x=(double(xstf(Si,Ti))'-x)*C;
            erreur_y=(double(ystf(Si,Ti))'-y)*C;
            yst=yst*C+min(observations.y(:));
            xst=xst*C+min(observations.x(:));
            x=x*C+min(observations.x(:));
            y=y*C+min(observations.y(:));
        case 'off'
            erreur_x=(double(xstf(Si,Ti))'-x);
            erreur_y=(double(ystf(Si,Ti))'-y);
        otherwise
            error('error choice of the normalisation option')
    end
    erreur=sum(sum(erreur_x+erreur_y));
    zst=zeros(size(xst));
    mesh(xst,yst,zst)
    hold on
    plot(x,y,'ro')
    view(2)
    title('fitting result')
    legend('krigeage fitting','observation','Location','best')
    xlabel('x')
    ylabel('y')
    zlabel('z')
    text(min(x(:)),mean(y(:)),0,['somme d''écart=' num2str(erreur)],'HorizontalAlignment','left','FontSize',16);
    
elseif dim==3
    tii=linspace(0,1,options.resolution(1));
    sii=linspace(0,1,options.resolution(2));
    Qx=Q(:,:,1);Qy=Q(:,:,2);Qz=Q(:,:,3); 
    [M,N]=size(Qx);
    switch options.covariance{1}
        case 'lin'
            K1=@(s)s;
        case 'log'
            K1=@(s)s.^2.*log(s+1e-9);
        case 'cubic'
            K1=@(s)s.^3;
        case 'sin'
            K1=@(s)sin(options.omega(1,1)*s);
        otherwise
            var_name=options.covariance{1}(3);
            options.covariance{1}=strrep(options.covariance{1},var_name,'t');
            eval(['K1=' options.covariance{1} ';']);
    end
    switch options.covariance{2}
        case 'lin'
            K2=@(t)t;
        case 'log'
            K2=@(t)t.^2.*log(t+1e-9);
        case 'cubic'
            K2=@(t)t.^3;
        case 'sin'
            K2=@(t)sin(options.omega(1,2)*t);
        otherwise
            var_name=options.covariance{2}(3);
            options.covariance{2}=strrep(options.covariance{2},var_name,'t');
            eval(['K2=' options.covariance{2} ';']);
    end
    clear k1 k2
    for i=1:size(observations.x,1)
        k1{i}=['K1(abs(s-si(' num2str(i) ')))'];
    end
    for j=1:size(observations.x,2)
        k2{j}=['K2(abs(t-ti(' num2str(j) ')))'];
    end
    switch options.derive{1}
        case 'const'
            k1{end+1}='1';
        case 'lin'
            k1{end+1}='1';
            k1{end+1}='s';
        case 'quad'
            k1{end+1}='1';
            k1{end+1}='s';
            k1{end+1}='s.^2';
        case 'cubic'
            k1{end+1}='1';
            k1{end+1}='s';
            k1{end+1}='s.^2';
            k1{end+1}='s.^3';
        case 'sin'
            k1{end+1}='1';
            k1{end+1}='cos(options.omega(2,1)*s)';
            k1{end+1}='sin(options.omega(2,1)*s)';
        case 'user'
            for i=1:length(options.user_derive{1})
                Ks{i}=options.user_derive{1}{i};
                var_name{i}=Ks{i}(3);
                Ks{i}=strrep(Ks{i},var_name{i},'s');
                Ks{i}(1:4)=[];
                k1{end+1}=Ks{i};
            end
    end
    switch options.derive{2}
        case 'const'
            k2{end+1}='1';
        case 'lin'
            k2{end+1}='1';
            k2{end+1}='t';
        case 'quad'
            k2{end+1}='1';
            k2{end+1}='t';
            k2{end+1}='t.^2';
        case 'cubic'
            k2{end+1}='1';
            k2{end+1}='t';
            k2{end+1}='t.^2';
            k2{end+1}='t.^3';
        case 'sin'
            k2{end+1}='1';
            k2{end+1}='cos(options.omega(2,2)*t)';
            k2{end+1}='sin(options.omega(2,2)*t)';
        case 'user'
            for i=1:length(options.user_derive{2})
                Ks{i}=options.user_derive{2}{i};
                var_name{i}=Ks{i}(3);
                Ks{i}=strrep(Ks{i},var_name{i},'s');
                Ks{i}(1:4)=[];
                k1{end+1}=Ks{i};
            end
    end
    xst='xstf=@(s,t)';yst='ystf=@(s,t)';zst='zstf=@(s,t)';
    for i=1:M
        for j=1:N
            xst=[xst 'Qx(' num2str(i) ',' num2str(j) ')*' k1{i} '.*' k2{j} '+'];
            yst=[yst 'Qy(' num2str(i) ',' num2str(j) ')*' k1{i} '.*' k2{j} '+'];
            zst=[zst 'Qz(' num2str(i) ',' num2str(j) ')*' k1{i} '.*' k2{j} '+'];
        end
    end
    xst(end)=';';yst(end)=';';zst(end)=';';
    eval(xst);eval(yst);eval(zst);
    u={xstf,ystf,zstf};
    
    [Sii,Tii]=meshgrid(sii,tii);  
    xst=double(xstf(Sii,Tii))';
    yst=double(ystf(Sii,Tii))';
    zst=double(zstf(Sii,Tii))';
    [Si,Ti]=meshgrid(si,ti);  
    switch options.normalisation
        case 'axial'
            erreur_x=(double(xstf(Si,Ti))'-x)*(max(observations.x(:))-min(observations.x(:)));
            erreur_y=(double(ystf(Si,Ti))'-y)*(max(observations.y(:))-min(observations.y(:)));
            erreur_z=(double(zstf(Si,Ti))'-z)*(max(observations.z(:))-min(observations.z(:)));
            zst=zst*(max(observations.z(:))-min(observations.z(:)))+min(observations.z(:));
            yst=yst*(max(observations.y(:))-min(observations.y(:)))+min(observations.y(:));
            xst=xst*(max(observations.x(:))-min(observations.x(:)))+min(observations.x(:));
            x=x*(max(observations.x(:))-min(observations.x(:)))+min(observations.x(:));
            y=y*(max(observations.y(:))-min(observations.y(:)))+min(observations.y(:));
            z=z*(max(observations.z(:))-min(observations.z(:)))+min(observations.z(:));
        case 'global'
            erreur_x=(double(xstf(Si,Ti))'-x)*C;
            erreur_y=(double(ystf(Si,Ti))'-y)*C;
            erreur_z=(double(zstf(Si,Ti))'-z)*C;
            zst=zst*C+min(observations.z(:));
            yst=yst*C+min(observations.y(:));
            xst=xst*C+min(observations.x(:));
            x=x*C+min(observations.x(:));
            y=y*C+min(observations.y(:));
            z=z*C+min(observations.z(:));
        case 'off'
            erreur_x=(double(xstf(Si,Ti))'-x);
            erreur_y=(double(ystf(Si,Ti))'-y);
            erreur_z=(double(zstf(Si,Ti))'-z);
        otherwise
            error('error choice of the normalisation option')
    end
    erreur=sum(sum(erreur_x+erreur_y+erreur_z));
    mesh(xst,yst,zst)
    hold on
    plot3(x,y,z,'ro')
    title('fitting result')
    legend('krigeage fitting','observation','Location','best')
    xlabel('x')
    ylabel('y')
    zlabel('z')
    warning('off','all');
    text(min(x(:)),mean(y(:)),max(z(:)),sprintf('somme d''écart= %e',erreur),'HorizontalAlignment','left','FontSize',24);
end