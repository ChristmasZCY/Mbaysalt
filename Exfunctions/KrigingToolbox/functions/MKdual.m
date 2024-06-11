function A=MKdual(t,covariance,derive,user_derive,omega,options)
sigma=options.sigma;
grad=options.grad;
closeloop=options.closeloop;
N=length(t);
%choix de covariance1
A1=nan(N);
syms s
switch covariance
    case 'lin'
        Ks=s;
    case 'log'
        Ks=s^2.*log(s+1e-9);
    case 'cubic'
        Ks=s^3;
    case 'sin'
        Ks=sin(omega(1)*s);
    otherwise
        if isa(covariance,'char')
            Kc=covariance;
            var_name=Kc(3);
            Kc=strrep(Kc,var_name,'s');
            Kc(1:4)=[];
            eval(['Ks=' Kc ';']);
        else
            error('input invalide pour la covariance dans krigeage');
        end
end
K=matlabFunction(Ks);
Kp=matlabFunction(diff(Ks));
strKp=func2str(Kp);
if strcmp(strKp(4:6),'1.0')
    Kp=@(s)1;
end
Kpp=matlabFunction(diff(Ks,2));
strKpp=func2str(Kpp);
if strcmp(strKpp(4:6),'0.0')
    Kpp=@(s)0;
end
for i=1:N
    for j=1:N
        A1(i,j)=K(abs(t(i)-t(j)));
    end
end
% Effet Pepite
if length(sigma)==1
    sigma=sigma*ones(size(t));
elseif length(sigma)~=1 && length(sigma)~=N
    error('Input invalide pour l''effet pepit sigma')
end
for i=1:N
    A1(i,i)=A1(i,i)+sigma(i);
end

clear Ks
% Choix de derive
switch derive
    case 'const'
        M=1;
        A2=nan(N,M);
        for i=1:N
            A2(i,:)=1;
        end
    case 'lin'
        M=2;
        A2=nan(N,M);
        for i=1:N
            A2(i,:)=[1 t(i)];
        end
    case 'quad'
        M=3;
        A2=nan(N,M);
        for i=1:N
            A2(i,:)=[1 t(i) t(i)^2];
        end
    case 'cubic'
        M=4;
        A2=nan(N,M);
        for i=1:N
            A2(i,:)=[1 t(i) t(i)^2 t(i)^3];
        end
    case 'sin'
        M=3;
        A2=nan(N,M);
        for i=1:N
            A2(i,:)=[1 cos(omega(2)*t(i)) sin(omega(2)*t(i))];
        end
    case 'user'
        A2=[];
        M=length(user_derive);
        for i=1:M
            if isa(user_derive{i},'char')
                Kd{i}=user_derive{i};
                var_name=Kd{i}(3);
                Kd{i}=strrep(Kd{i},var_name,'s');
                Kd{i}(1:4)=[];
                eval(['Ks{i}=' Kd{i} ';']);
                A2=[A2 subs(Ks{i},t(1:end)')];
            else
                error('input invalide pour la dérive dans krigeage');
            end
        end
end

% Ajout de la tangente
if ~isempty(grad)
    xd=grad(:,1);
    for i=1:length(t)
        for j=1:length(xd)
            C1(i,j)=sign(xd(j)-t(i))*Kp(abs(xd(j)-t(i)));
        end
    end
    for i=1:length(xd)
        for j=1:length(xd)
            C2(i,j)=-Kpp(abs(xd(j)-xd(i)));
        end
    end
    A22=nan(length(xd),M);
    switch derive
        case 'const'
            for i=1:length(xd)
                A22(i,:)=0;
            end
        case 'lin'
            for i=1:length(xd)
                A22(i,:)=[0 1];
            end
        case 'quad'
            for i=1:length(xd)
                A22(i,:)=[0 1 2*t(i)];
            end
        case 'cubic'
            for i=1:length(xd)
                A22(i,:)=[0 1 2*t(i) 3*t(i)^2];
            end
        case 'sin'
            for i=1:length(xd)
                A22(i,:)=[0 omega(2)*sin(omega(2)*t(i)) omega(2)*cos(omega(2)*t(i))];
            end
        case 'user'
            A22=[];
            for i=1:length(derive)
                Ksp{i}=diff(Ks{i});
                A22=[A22 subs(Ks{i},t(i))];
            end
    end
else
    C1=[];C2=[];A22=[];xd=[];
end

%Ajout de la condition de contraint
if strcmp(closeloop,'yes')
    for i=1:length(t)
        D1(i,1)=Kp(1-t(i))+Kp(t(i));
    end
    D2=2*(Kpp(1)-Kpp(0));
    A222=zeros(1,M);
else
    D1=[];D2=[];A222=[];
end

%Former la matrice A
A=[A1 C1 D1 A2;C1' C2 zeros(length(xd),strcmp(options.closeloop,'yes')) A22;D1' zeros(strcmp(options.closeloop,'yes'),length(xd)) D2 A222;A2' A22' A222' zeros(M)];

%Final check
if det(A)==0
    error('Matrice Krigeage non-inversible!')
end