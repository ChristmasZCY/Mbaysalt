function [u]=plotting_krigeage1(a,b,c,observations,options)
% plotter un courbe krigé
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

Normalisation;

if strcmp(options.param,'on')
    ti=devide_parameters(observations,options);
    if dim==2
        N=length(x);
        switch options.derive
            case 'const'
                str1='xt=@(t)a(1,1)';
                str2='yt=@(t)a(1,2)';
            case 'lin'
                str1='xt=@(t)a(1,1)+a(2,1)*t';
                str2='yt=@(t)a(1,2)+a(2,2)*t';
            case 'quad'
                str1='xt=@(t)a(1,1)+a(2,1)*t+a(3,1)*t.^2';
                str2='yt=@(t)a(1,2)+a(2,2)*t+a(3,2)*t.^2';
            case 'cubic'
                str1='xt=@(t)a(1,1)+a(2,1)*t+a(3,1)*t.^2+a(4,1)*t.^3';
                str2='yt=@(t)a(1,2)+a(2,2)*t+a(3,2)*t.^2+a(4,2)*t.^3';
            case 'sin'
                str1='xt=@(t)a(1,1)+a(2,1)*cos(options.omega(2)*t)+a(3,1)*sin(options.omega(2)*t)';
                str2='yt=@(t)a(1,2)+a(2,2)*cos(options.omega(2)*t)+a(3,2)*sin(options.omega(2)*t)';
            case 'user'
                str1=['xt=@(t)'];str2=['yt=@(t)'];
                for i=1:length(options.user_derive)
                    Ks{i}=options.user_derive{i};
                    var_name{i}=Ks{i}(3);
                    Ks{i}=strrep(Ks{i},var_name{i},'t');
                    Ks{i}(1:4)=[];
                    str1=[str1 'a(' num2str(i) ',1)*' Ks{i} '+'];str2=['a(' num2str(i) ',2)*' Ks{i} '+'];
                end
                str1(end)=[];
        end
        
        
        switch options.covariance
            case 'lin'
                for j=1:N
                    str1=[str1 '+b(' num2str(j) ',1)*abs(t-ti(' num2str(j) '))'];
                    str2=[str2 '+b(' num2str(j) ',2)*abs(t-ti(' num2str(j) '))'];
                end
            case 'log'
                for j=1:N
                    str1=[str1 '+b(' num2str(j) ',1)*abs(t-ti(' num2str(j) ')).^2.*log(abs(t-ti(' num2str(j) ')+1e-9))'];
                    str2=[str2 '+b(' num2str(j) ',2)*abs(t-ti(' num2str(j) ')).^2.*log(abs(t-ti(' num2str(j) ')+1e-9))'];
                end
            case 'cubic'
                for j=1:N
                    str1=[str1 '+b(' num2str(j) ',1)*abs(t-ti(' num2str(j) ')).^3'];
                    str2=[str2 '+b(' num2str(j) ',2)*abs(t-ti(' num2str(j) ')).^3'];
                end
            case 'sin'
                for j=1:N
                    str1=[str1 '+b(' num2str(j) ',1)*sin(options.omega(1)*abs(t-ti(' num2str(j) ')))'];
                    str2=[str2 '+b(' num2str(j) ',2)*sin(options.omega(1)*abs(t-ti(' num2str(j) ')))'];
                end
            otherwise
                Ks=options.covariance;
                var_name=Ks(3);
                Ks=strrep(Ks,var_name,'t');
                Ks(1:4)=[];
                for j=1:N
                    Ks_abs=strrep(Ks,'t',['abs(t-ti(' num2str(j) '))']);
                    str1=[str1 '+b(' num2str(j) ',1)*' Ks_abs];str2=[str2 '+b(' num2str(j) ',2)*' Ks_abs];
                end
        end
        if strcmp(options.closeloop,'yes')
            switch options.covariance
                case 'lin'
                    str1=[str1 '+c(1)*2'];
                    str2=[str2 '+c(2)*2'];
                case 'log'
                    str1=[str1 '+c(1)*(2*(1-t).*log(1-t+1e-9)+(1-t)+2*t.*log(t+1e-9)+t)'];
                    str2=[str2 '+c(2)*(2*(1-t).*log(1-t+1e-9)+(1-t)+2*t.*log(t+1e-9)+t)'];
                case 'cubic'
                    str1=[str1 '+c(1)*(3*(1-t).^2+3*t.^2)'];
                    str2=[str2 '+c(2)*(3*(1-t).^2+3*t.^2)'];
                case 'sin'
                    str1=[str1 '+c(1)*(options.omega(1)*(cos(options.omega(1)*(1-t))+cos(options.omega(1)*t))'];
                    str2=[str2 '+c(2)*(options.omega(1)*(cos(options.omega(1)*(1-t))+cos(options.omega(1)*t))'];
                otherwise
                    syms t
                    eval(['Ksym=' Ks ';']);
                    Kp=matlabFunction(diff(Ksym));
                    Ksp=func2str(Kp);
                    Ksp(1:4)=[];
                    str1=[str1 '+c(1)*(' strrep(Ksp,'t','(1-t)') '+' Ksp ')'];
                    str2=[str2 '+c(2)*(' strrep(Ksp,'t','(1-t)') '+' Ksp ')'];
            end
        end
        str1=[str1 ';'];
        str2=[str2 ';'];
        eval(str1);eval(str2);
        u={xt,yt};
        tii=linspace(0,1,options.resolution);
        switch options.normalisation
            case 'axial'
                yti=yt(tii)*(max(observations.y)-min(observations.y))+min(observations.y);
                xti=xt(tii)*(max(observations.x)-min(observations.x))+min(observations.x);
                str=num2str(sum([(yt(ti)-y)*(max(observations.y)-min(observations.y)) (xt(ti)-x)*(max(observations.x)-min(observations.x))]));
                x=x*(max(observations.x)-min(observations.x))+min(observations.x);
                y=y*(max(observations.y)-min(observations.y))+min(observations.y);
            case 'global'
                yti=yt(tii)*C+min(observations.y);
                xti=xt(tii)*C+min(observations.x);
                str=num2str(sum([yt(ti)-y xt(ti)-x]*C));
                x=x*C+min(observations.x);
                y=y*C+min(observations.y);
            case 'off'
                xti=xt(tii);
                yti=yt(tii);
                str=num2str(sum([yt(ti)-y xt(ti)-x]));
            otherwise
                error('error choice of the normalisation option')
        end
        plot(xti,yti)
        hold on
        plot(x,y,'ro')
        title('fitting result')
        legend('krigeage fitting','observation','Location','best')
        xlabel('x')
        ylabel('$f_1(x)$')
        annotation('textbox',[0.3 0.5 0.3 0.3],'String',['somme d''écart=' str],'FitBoxToText','on');
    elseif dim==3
        N=length(x);
        switch options.derive
            case 'const'
                str1='xt=@(t)a(1,1)';
                str2='yt=@(t)a(1,2)';
                str3='zt=@(t)a(1,3)';
            case 'lin'
                str1='xt=@(t)a(1,1)+a(2,1)*t';
                str2='yt=@(t)a(1,2)+a(2,2)*t';
                str3='zt=@(t)a(1,3)+a(2,3)*t';
            case 'quad'
                str1='xt=@(t)a(1,1)+a(2,1)*t+a(3,1)*t.^2';
                str2='yt=@(t)a(1,2)+a(2,2)*t+a(3,2)*t.^2';
                str3='zt=@(t)a(1,3)+a(2,3)*t+a(3,3)*t.^2';
            case 'cubic'
                str1='xt=@(t)a(1,1)+a(2,1)*t+a(3,1)*t.^2+a(4,1)*t.^3';
                str2='yt=@(t)a(1,2)+a(2,2)*t+a(3,2)*t.^2+a(4,2)*t.^3';
                str3='zt=@(t)a(1,3)+a(2,3)*t+a(3,3)*t.^2+a(4,3)*t.^3';
            case 'sin'
                str1='xt=@(t)a(1,1)+a(2,1)*sin(options.omega(1,?))+a(3,1)*cos(options.omega(1,?))';
                str2='yt=@(t)a(1,2)+a(2,2)*sin(options.omega(1,?))+a(3,2)*cos(options.omega(1,?))';
                str3='zt=@(t)a(1,3)+a(2,3)*sin(options.omega(1,?))+a(3,3)*cos(options.omega(1,?))';
            case 'user'
                str1=['xt=@(t)'];str2=['yt=@(t)'];str3=['zt=@(t)'];
                for i=1:length(options.user_derive)
                    Ks{i}=options.user_derive{i};
                    var_name{i}=Ks{i}(3);
                    Ks{i}=strrep(Ks{i},var_name{i},'t');
                    Ks{i}(1:4)=[];
                    str1=[str1 'a(' num2str(i) ',1)*' Ks{i} '+'];str2=['a(' num2str(i) ',2)*' Ks{i} '+'];str3=['a(' num2str(i) ',3)*' Ks{i} '+'];
                end
                str1(end)=[];
        end
        
        switch options.covariance
            case 'lin'
                for j=1:N
                    str1=[str1 '+b(' num2str(j) ',1)*abs(t-ti(' num2str(j) '))'];
                    str2=[str2 '+b(' num2str(j) ',2)*abs(t-ti(' num2str(j) '))'];
                    str3=[str3 '+b(' num2str(j) ',3)*abs(t-ti(' num2str(j) '))'];
                end
            case 'log'
                for j=1:N
                    str1=[str1 '+b(' num2str(j) ',1)*abs(t-ti(' num2str(j) ')).^2.*log(abs(t-ti(' num2str(j) ')+1e-9))'];
                    str2=[str2 '+b(' num2str(j) ',2)*abs(t-ti(' num2str(j) ')).^2.*log(abs(t-ti(' num2str(j) ')+1e-9))'];
                    str3=[str3 '+b(' num2str(j) ',3)*abs(t-ti(' num2str(j) ')).^2.*log(abs(t-ti(' num2str(j) ')+1e-9))'];
                end
            case 'cubic'
                for j=1:N
                    str1=[str1 '+b(' num2str(j) ',1)*abs(t-ti(' num2str(j) ')).^3'];
                    str2=[str2 '+b(' num2str(j) ',2)*abs(t-ti(' num2str(j) ')).^3'];
                    str3=[str3 '+b(' num2str(j) ',3)*abs(t-ti(' num2str(j) ')).^3'];
                end
            case 'sin'
                for j=1:N
                    str1=[str1 '+b(' num2str(j) ',1)*sin(abs(t-ti(' num2str(j) ')))'];
                    str2=[str2 '+b(' num2str(j) ',2)*sin(abs(t-ti(' num2str(j) ')))'];
                    str3=[str3 '+b(' num2str(j) ',3)*sin(abs(t-ti(' num2str(j) ')))'];
                end
            otherwise
                Ks=options.covariance;
                var_name=Ks(3);
                Ks=strrep(Ks,var_name,'t');
                Ks(1:4)=[];
                for j=1:N
                    Ks_abs=strrep(Ks,'t',['abs(t-ti(' num2str(j) '))']);
                    str1=[str1 '+b(' num2str(j) ',1)*' Ks_abs];str2=[str2 '+b(' num2str(j) ',2)*' Ks_abs];str3=[str3 '+b(' num2str(j) ',3)*' Ks_abs];
                end
        end
        str1=[str1 ';'];
        str2=[str2 ';'];
        str3=[str3 ';'];
        eval(str1);eval(str2);eval(str3);
        u={xt,yt,zt};
        tii=linspace(ti(1),ti(end),options.resolution);
        switch options.normalisation
            case 'axial'
                yti=double(yt(tii))*(max(observations.y)-min(observations.y))+min(observations.y);
                xti=double(xt(tii))*(max(observations.x)-min(observations.x))+min(observations.x);
                zti=double(zt(tii))*(max(observations.z)-min(observations.z))+min(observations.z);
                erreur_x=(double(xt(ti))-x)*(max(observations.x)-min(observations.x));
                erreur_y=(double(yt(ti))-y)*(max(observations.y)-min(observations.y));
                erreur_z=(double(zt(ti))-z)*(max(observations.z)-min(observations.z));
                str=num2str(sum(erreur_x+erreur_y+erreur_z));
                x=x*(max(observations.x)-min(observations.x))+min(observations.x);
                y=y*(max(observations.y)-min(observations.y))+min(observations.y);
                z=z*(max(observations.z)-min(observations.z))+min(observations.z);
            case 'global'
                yti=double(yt(tii))*C+min(observations.y);
                xti=double(xt(tii))*C+min(observations.x);
                zti=double(zt(tii))*C+min(observations.z);
                erreur_x=(double(xt(ti))-x)*C;
                erreur_y=(double(yt(ti))-y)*C;
                erreur_z=(double(zt(ti))-z)*C;
                str=num2str(sum(erreur_x+erreur_y+erreur_z));
                x=x*C+min(observations.x);
                y=y*C+min(observations.y);
                z=z*C+min(observations.z);
            case 'off'
                xti=double(xt(tii));
                yti=double(yt(tii));
                zti=double(zt(tii));
                erreur_x=(double(xt(ti))-x);
                erreur_y=(double(yt(ti))-y);
                erreur_z=(double(zt(ti))-z);
                str=num2str(sum(erreur_x+erreur_y+erreur_z));
            otherwise
                error('error choice of the normalisation option')
        end
        plot3(xti,yti,zti)
        hold on
        plot3(x,y,z,'ro')
        title('fitting result')
        legend('krigeage fitting','observation','Location','best')
        xlabel('x')
        ylabel('y')
        zlabel('z')
        text(mean(x),mean(y),max(z),['   somme d''écart=' str],'HorizontalAlignment','left','FontSize',8);
    end
    
elseif strcmp(options.param,'off')
    if dim==2
        N=length(x);
        switch options.derive
            case 'const'
                str='u=@(t)a(1)';
            case 'lin'
                str='u=@(t)a(1)+a(2)*t';
            case 'quad'
                str='u=@(t)a(1)+a(2)*t+a(3)*t.^2';
            case 'cubic'
                str='u=@(t)a(1)+a(2)*t+a(3)*t.^2+a(4)*t.^3';
            case 'sin'
                str='u=@(t)a(1)+a(2)*sin(options.omega(2,1)*t)+a(3)*cos(options.omega(2,1)*t)';
            case 'user'
                str=['u=@(t)'];
                for i=1:length(options.user_derive)
                    Ks{i}=options.user_derive{i};
                    var_name{i}=Ks{i}(3);
                    Ks{i}=strrep(Ks{i},var_name{i},'t');
                    Ks{i}(1:4)=[];
                    str=[str 'a(' num2str(i) ')*' Ks{i} '+'];
                end
                str(end)=[];
        end
        
        
        switch options.covariance
            case 'lin'
                for j=1:N
                    str=[str '+b(' num2str(j) ')*abs(t-x(' num2str(j) '))'];
                end
            case 'log'
                for j=1:N
                    str=[str '+b(' num2str(j) ')*abs(t-x(' num2str(j) ')).^2.*log(abs(t-x(' num2str(j) ')+1e-9))'];
                end
            case 'cubic'
                for j=1:N
                    str=[str '+b(' num2str(j) ')*abs(t-x(' num2str(j) ')).^3'];
                end
            case 'sin'
                for j=1:N
                    str=[str '+b(' num2str(j) ')*sin(options.omega(1,1)*abs(t-x(' num2str(j) ')))'];
                end
            otherwise
                Ks=options.covariance;
                var_name=Ks(3);
                Ks=strrep(Ks,var_name,'t');
                Ks(1:4)=[];
                for j=1:N
                    Ks_abs=strrep(Ks,'t',['abs(t-x(' num2str(j) '))']);
                    str=[str '+b(' num2str(j) ')*' Ks_abs];
                end
        end
        if ~isempty(options.grad)
            xd=options.grad(:,1);
            switch options.covariance
                case 'lin'
                    for j=1:length(xd)
                        str=[str '+c(' num2str(j) ')*sign(xd(' num2str(j) ')-t)*1'];
                    end
                case 'log'
                    for j=1:length(xd)
                        str=[str '+c(' num2str(j) ')*sign(xd(' num2str(j) ')-t).*(2*abs(t-xd(' num2str(j) ')).*log(abs(t-xd(' num2str(j) ')+1e-9))+abs(t-xd(' num2str(j) ')))'];
                    end
                case 'cubic'
                    for j=1:length(xd)
                        str=[str '+c(' num2str(j) ')*sign(xd(' num2str(j) ')-t)*3.*abs(t-xd(' num2str(j) ')).^2'];
                    end
                case 'sin'
                    for j=1:length(xd)
                        str=[str '+c(' num2str(j) ')*sign(xd(' num2str(j) ')-t).*options.omega(1,1)*cos(options.omega(1,1)*abs(t-xd(' num2str(j) ')))'];
                    end
                otherwise
                    syms t
                    eval(['Ksym=' Ks ';']);
                    Kp=matlabFunction(diff(Ksym));
                    Ksp=func2str(Kp);
                    Ksp(1:4)=[];
                    for j=1:length(xd)
                        Ks_abs=strrep(Ks,'t',['abs(t-xd(' num2str(j) '))']);
                        str=[str '+c(' num2str(j) ')*sign(xd(' num2str(j) ')-t).*' Ks_abs];
                    end
            end
        end
        str=[str ';'];
        eval(str)
        xi=linspace(min(x),max(x),options.resolution);
        switch options.normalisation
            case 'axial'
                ui=double(u(xi))*(max(observations.y)-min(observations.y))+min(observations.y);
                xi=xi*(max(observations.x)-min(observations.x))+min(observations.x);
                str=num2str(sum(double(u(x))-y)*(max(observations.y)-min(observations.y)));
                x=x*(max(observations.x)-min(observations.x))+min(observations.x);
                y=y*(max(observations.y)-min(observations.y))+min(observations.y);
            case 'global'
                ui=double(u(xi))*C+min(observations.y);
                xi=xi*C+min(observations.x);
                str=num2str(sum((double(u(x))-y)*C));
                x=x*C+min(observations.x);
                y=y*C+min(observations.y);
            case 'off'
                ui=double(u(xi));
                str=num2str(sum((double(u(x))-y)));
            otherwise
                error('error choice of the normalisation option')
        end
        u={u};
        plot(xi,ui)
        hold on
        plot(x,y,'ro')
        title('fitting result')
        legend('krigeage fitting','observation','Location','best')
        xlabel('x')
        ylabel('$u_1(x)$')
        annotation('textbox',[0.3 0.5 0 0],'String',['somme d''écart=' str],'FitBoxToText','on');
    elseif dim==3
        N=length(x);
        switch options.derive
            case 'const'
                str='u=@(s,t)a(1)';
            case 'lin'
                str='u=@(s,t)a(1)+a(2)*s+a(3)*t';
            case 'quad'
                str='u=@(s,t)a(1)+a(2)*s+a(3)*t+a(4)*s.^2+a(5)*t.^2';
            case 'cubic'
                str='u=@(s,t)a(1)+a(2)*s+a(3)*t+a(4)*s.^2+a(5)*t.^2+a(6)*s.^3+a(7)*t.^3';
            case 'sin'
                str='u=@(s,t)a(1)+a(2)*sin(options.omega(2,1)*s)+a(3)*cos(options.omega(2,1)*s)+a(4)*sin(options.omega(2,1)*t)+a(5)*cos(options.omega(2,1)*t)';
            case 'user'
                str=['u=@(s,t)('];
                for i=1:length(options.user_derive)
                    Ks{i}=options.user_derive{i};
                    var_name{i}=Ks{i}(3);
                    if cmpstr(var_name{i},'x')
                        Ks{i}=strrep(Ks{i},var_name{i},'s');
                    else
                        Ks{i}=strrep(Ks{i},var_name{i},'t');
                    end
                    Ks{i}(1:4)=[];
                    str=[str 'a(' num2str(i) ')*' Ks{i} '+'];
                end
                str(end)=[];
        end
        
        switch options.covariance
            case 'lin'
                for j=1:N
                    str=[str '+b(' num2str(j) ')*sqrt((s-x(' num2str(j) ')).^2+(t-y(' num2str(j) ')).^2)'];
                end
            case 'log'
                for j=1:N
                    str=[str '+b(' num2str(j) ')*((s-x(' num2str(j) ')).^2+(t-y(' num2str(j) ')).^2).*log(sqrt((s-x(' num2str(j) ')).^2+(t-y(' num2str(j) ')).^2)+1e-9)'];
                end
            case 'cubic'
                for j=1:N
                    str=[str '+b(' num2str(j) ')*sqrt((s-x(' num2str(j) ')).^2+(t-y(' num2str(j) ')).^2).^3'];
                end
            case 'sin'
                for j=1:N
                    str=[str '+b(' num2str(j) ')*sin(options.omega(1,1)*sqrt((s-x(' num2str(j) ')).^2+(t-y(' num2str(j) ')).^2)'];
                end
            otherwise
                Ks=options.covariance;
                var_name=Ks(3);
                Ks(1:4)=[];
                for j=1:N
                    Ks_abs=strrep(Ks,var_name,['sqrt((s-x(' num2str(j) ')).^2+(t-y(' num2str(j) ')).^2)']);
                    str=[str '+b(' num2str(j) ')*' Ks_abs];
                end
        end
        str=[str ';'];
        eval(str)
        xi=linspace(min(x),max(x),options.resolution(1));yi=linspace(min(y),max(y),options.resolution(2));
        [Xi,Yi]=meshgrid(xi,yi);
        Zi=double(u(Xi,Yi));
        for i=1:N
            erreur(i)=u(x(i),y(i))-z(i);
        end
        switch options.normalisation
            case 'axial'
                Zi=Zi*(max(observations.z)-min(observations.z))+min(observations.z);
                yi=yi*(max(observations.y)-min(observations.y))+min(observations.y);
                xi=xi*(max(observations.x)-min(observations.x))+min(observations.x);
                str=num2str(sum(erreur)*(max(observations.y)-min(observations.y)));
                x=x*(max(observations.x)-min(observations.x))+min(observations.x);
                y=y*(max(observations.y)-min(observations.y))+min(observations.y);
                z=z*(max(observations.z)-min(observations.z))+min(observations.z);
            case 'global'
                Zi=Zi*C+min(observations.z);
                yi=yi*C+min(observations.y);
                xi=xi*C+min(observations.x);
                str=num2str(sum(erreur*C));
                x=x*C+min(observations.x);
                y=y*C+min(observations.y);
                z=z*C+min(observations.z);
            case 'off'
                str=num2str(sum(erreur));
            otherwise
                error('error choice of the normalisation option')
        end
        u={u};
        mesh(xi,yi,Zi)
        hold on
        plot3(x,y,z,'ro')
        title('fitting result')
        legend('krigeage fitting','observation','Location','best')
        xlabel('x')
        ylabel('y')
        zlabel('z')
        annotation('textbox',[0.3 0.5 0 0],'String',['somme d''écart=' str],'FitBoxToText','on');
    end
else
    error('invalid input for krigeage: param should be ''on'' or ''off''');
end
