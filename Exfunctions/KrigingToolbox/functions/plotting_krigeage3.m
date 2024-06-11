function [u]=plotting_krigeage3(Q,observations,options)
% plotter une surface krig?
dim=length(fieldnames(observations));
if dim~=3
    error('input must be 3d matrix for a solid kriging')
end
x=observations.x;
y=observations.y;
z=observations.z;

Normalisation;

[ti,si,ri]=devide_parameters(observations,options);
rii=linspace(0,1,options.resolution(1));
tii=linspace(0,1,options.resolution(2));
sii=linspace(0,1,options.resolution(3));
Qx=Q(:,:,:,1);Qy=Q(:,:,:,2);Qz=Q(:,:,:,3);
[L,M,N]=size(Qx);
switch options.covariance{1}
    case 'lin'
        K1=@(r)r;
    case 'log'
        K1=@(r)r.^2.*log(r+1e-9);
    case 'cubic'
        K1=@(r)r.^3;
    case 'sin'
        K1=@(r)sin(options.omega(1,1)*r);
    otherwise
        var_name=options.covariance{1}(3);
        options.covariance{1}=strrep(options.covariance{1},var_name,'t');
        eval(['K1=' options.covariance{1} ';']);
end
switch options.covariance{2}
    case 'lin'
        K2=@(s)s;
    case 'log'
        K2=@(s)s.^2.*log(s+1e-9);
    case 'cubic'
        K2=@(s)s.^3;
    case 'sin'
        K2=@(s)sin(options.omega(1,2)*s);
    otherwise
        var_name=options.covariance{2}(3);
        options.covariance{2}=strrep(options.covariance{2},var_name,'t');
        eval(['K1=' options.covariance{2} ';']);
end
switch options.covariance{3}
    case 'lin'
        K3=@(t)t;
    case 'log'
        K3=@(t)t.^2.*log(t+1e-9);
    case 'cubic'
        K3=@(t)t.^3;
    case 'sin'
        K3=@(t)sin(options.omega(1,2)*t);
    otherwise
        var_name=options.covariance{3}(3);
        options.covariance{3}=strrep(options.covariance{3},var_name,'t');
        eval(['K1=' options.covariance{3} ';']);
end
clear k1 k2 k3
for i=1:size(x,1)
    k1{i}=['K1(abs(r-ri(' num2str(i) ')))'];
end
for i=1:size(x,2)
    k2{i}=['K2(abs(s-si(' num2str(i) ')))'];
end
for i=1:size(x,3)
    k3{i}=['K3(abs(t-ti(' num2str(i) ')))'];
end
switch options.derive{1}
    case 'const'
        k1{end+1}='1';
    case 'lin'
        k1{end+1}='1';
        k1{end+1}='r';
    case 'quad'
        k1{end+1}='1';
        k1{end+1}='r';
        k1{end+1}='r.^2';
    case 'cubic'
        k1{end+1}='1';
        k1{end+1}='r';
        k1{end+1}='r.^2';
        k1{end+1}='r.^3';
    case 'sin'
        k1{end+1}='1';
        k1{end+1}='cos(options.omega(2,1)*r)';
        k1{end+1}='sin(options.omega(2,1)*r)';
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
        k2{end+1}='s';
    case 'quad'
        k2{end+1}='1';
        k2{end+1}='s';
        k2{end+1}='s.^2';
    case 'cubic'
        k2{end+1}='1';
        k2{end+1}='s';
        k2{end+1}='s.^2';
        k2{end+1}='s.^3';
    case 'sin'
        k2{end+1}='1';
        k2{end+1}='cos(options.omega(2,2)*s)';
        k2{end+1}='sin(options.omega(2,2)*s)';
    case 'user'
        for i=1:length(options.user_derive{2})
            Ks{i}=options.user_derive{2}{i};
            var_name{i}=Ks{i}(3);
            Ks{i}=strrep(Ks{i},var_name{i},'s');
            Ks{i}(1:4)=[];
            k1{end+1}=Ks{i};
        end
end
switch options.derive{3}
    case 'const'
        k3{end+1}='1';
    case 'lin'
        k3{end+1}='1';
        k3{end+1}='t';
    case 'quad'
        k3{end+1}='1';
        k3{end+1}='t';
        k3{end+1}='t.^2';
    case 'cubic'
        k3{end+1}='1';
        k3{end+1}='t';
        k3{end+1}='t.^2';
        k3{end+1}='t.^3';
    case 'sin'
        k3{end+1}='1';
        k3{end+1}='cos(options.omega(2,2)*t)';
        k3{end+1}='sin(options.omega(2,2)*t)';
    case 'user'
        for i=1:length(options.user_derive{3})
            Ks{i}=options.user_derive{3}{i};
            var_name{i}=Ks{i}(3);
            Ks{i}=strrep(Ks{i},var_name{i},'s');
            Ks{i}(1:4)=[];
            k1{end+1}=Ks{i};
        end
end
xrst='xrstf=@(r,s,t)';yrst='yrstf=@(r,s,t)';zrst='zrstf=@(r,s,t)';
for i=1:L
    for j=1:M
        for k=1:N
            xrst=[xrst 'Qx(' num2str(i) ',' num2str(j) ',' num2str(k) ')*' k1{i} '.*' k2{j} '.*' k3{k} '+'];
            yrst=[yrst 'Qy(' num2str(i) ',' num2str(j) ',' num2str(k) ')*' k1{i} '.*' k2{j} '.*' k3{k} '+'];
            zrst=[zrst 'Qz(' num2str(i) ',' num2str(j) ',' num2str(k) ')*' k1{i} '.*' k2{j} '.*' k3{k} '+'];
        end
    end
end
xrst(end)=';';yrst(end)=';';zrst(end)=';';
eval(xrst);eval(yrst);eval(zrst);
u={xrstf,yrstf,zrstf};

[Riitp,Siitp,Tiitp]=meshgrid(rii,sii,tii);
[Ritp,Sitp,Titp]=meshgrid(ri,si,ti);
for i=1:size(Ritp,3)
    Ri(:,:,i)=Ritp(:,:,i)';Si(:,:,i)=Sitp(:,:,i)';Ti(:,:,i)=Titp(:,:,i)';
end
for i=1:size(Riitp,3)
    Rii(:,:,i)=Riitp(:,:,i)';Sii(:,:,i)=Siitp(:,:,i)';Tii(:,:,i)=Tiitp(:,:,i)';
end
xrst=double(xrstf(Rii,Sii,Tii));
yrst=double(yrstf(Rii,Sii,Tii));
zrst=double(zrstf(Rii,Sii,Tii));
switch options.normalisation
    case 'axial'
        erreur_x=(double(xrstf(Ri,Si,Ti))-x)*(max(observations.x(:))-min(observations.x(:)));
        erreur_y=(double(yrstf(Ri,Si,Ti))-y)*(max(observations.y(:))-min(observations.y(:)));
        erreur_z=(double(zrstf(Ri,Si,Ti))-z)*(max(observations.z(:))-min(observations.z(:)));
        zrst=zrst*(max(observations.z(:))-min(observations.z(:)))+min(observations.z(:));
        yrst=yrst*(max(observations.y(:))-min(observations.y(:)))+min(observations.y(:));
        xrst=xrst*(max(observations.x(:))-min(observations.x(:)))+min(observations.x(:));
        x=x*(max(observations.x(:))-min(observations.x(:)))+min(observations.x(:));
        y=y*(max(observations.y(:))-min(observations.y(:)))+min(observations.y(:));
        z=z*(max(observations.z(:))-min(observations.z(:)))+min(observations.z(:));
    case 'global'
        erreur_x=(double(xrstf(Ri,Si,Ti))-x)*C;
        erreur_y=(double(yrstf(Ri,Si,Ti))-y)*C;
        erreur_z=(double(zrstf(Ri,Si,Ti))-z)*C;
        zrst=zrst*C+min(observations.z(:));
        yrst=yrst*C+min(observations.y(:));
        xrst=xrst*C+min(observations.x(:));
        x=x*C+min(observations.x(:));
        y=y*C+min(observations.y(:));
        z=z*C+min(observations.z(:));
    case 'off'
        erreur_x=(double(xrstf(Ri,Si,Ti))-x);
        erreur_y=(double(yrstf(Ri,Si,Ti))-y);
        erreur_z=(double(zrstf(Ri,Si,Ti))-z);
    otherwise
        error('error choice of the normalisation option')
end
erreur=sum(sum(sum(erreur_x+erreur_y+erreur_z)));
hold on
surf(squeeze(xrst(1,:,:)),squeeze(yrst(1,:,:)),squeeze(zrst(1,:,:)),0.5*ones(size(squeeze(yrst(1,:,:)))))
surf(squeeze(xrst(end,:,:)),squeeze(yrst(end,:,:)),squeeze(zrst(end,:,:)),0.5*ones(size(squeeze(yrst(1,:,:)))))
surf(squeeze(xrst(:,1,:)),squeeze(yrst(:,1,:)),squeeze(zrst(:,1,:)),0.5*ones(size(squeeze(yrst(:,1,:)))))
surf(squeeze(xrst(:,end,:)),squeeze(yrst(:,end,:)),squeeze(zrst(:,end,:)),0.5*ones(size(squeeze(yrst(:,1,:)))))
surf(squeeze(xrst(:,:,1)),squeeze(yrst(:,:,1)),squeeze(zrst(:,:,1)),0.5*ones(size(squeeze(yrst(:,:,1)))))
h1=surf(squeeze(xrst(:,:,end)),squeeze(yrst(:,:,end)),squeeze(zrst(:,:,end)),0.5*ones(size(squeeze(yrst(:,:,1)))));

h2=scatter3(x(:),y(:),z(:),'ro');
title('fitting result')
legend([h1,h2],{'krigeage fitting','observation'},'Location','best')
xlabel('x')
ylabel('y')
zlabel('z')
text(min(x(:)),mean(y(:)),max(z(:)),['somme d''écart=' num2str(erreur)],'HorizontalAlignment','left','FontSize',8);
