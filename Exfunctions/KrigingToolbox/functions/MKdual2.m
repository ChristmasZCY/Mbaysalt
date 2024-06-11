function A=MKdual2(x,y,covariance,derive,sigma,omega)

N=length(x);
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
for i=1:N
    for j=1:N
        A1(i,j)=K(sqrt((x(i)-x(j))^2+(y(i)-y(j))^2));
    end
end
% Effet Pepite
if length(sigma)==1
    sigma=sigma*ones(1,N);
elseif length(sigma)~=1 && length(sigma)~=N
    error('error input for sigma')
end
for i=1:N
    A1(i,i)=A1(i,i)+sigma(i);
end

% Choix de derive1
switch derive
    case 'const'
        M=1;
        A2=nan(N,M);
        for i=1:N
            A2(i,:)=1;
        end
    case 'lin'
        M=3;
        A2=nan(N,M);
        for i=1:N
            A2(i,:)=[1 x(i) y(i)];
        end
    case 'quad'
        M=5;
        A2=nan(N,M);
        for i=1:N
            A2(i,:)=[1 x(i) y(i) x(i)^2 y(i)^2];
        end
    case 'cubic'
        M=7;
        A2=nan(N,M);
        for i=1:N
            A2(i,:)=[1 x(i) y(i) x(i)^2 y(i)^2 x(i)^3 y(i)^3];
        end
    case 'sin'
        M=5;
        A2=nan(N,M);
        for i=1:N
            A2(i,:)=[1 cos(omega(2)*x(i)) sin(omega(2)*x(i)) cos(omega(2)*y(i)) sin(omega(2)*y(i))];
        end
    otherwise
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


A=[A1 A2;A2' zeros(M)];

if det(A)==0
    error('Matrice Krigeage non-inversible!')
end