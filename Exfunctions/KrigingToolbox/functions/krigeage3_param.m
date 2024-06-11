function Q=krigeage3_param(r,s,t,observations,options)
%krigeage pour un solid 3D (3 parametre)
dim=length(fieldnames(observations));
if dim~=3
    error('input must be 3d matrix for a solid kriging')
end
x=observations.x;
y=observations.y;
z=observations.z;

Normalisation;

R=MKdual(r,options.covariance{1},options.derive{1},options.user_derive{1},options.omega(:,1),options);
S=MKdual(s,options.covariance{2},options.derive{2},options.user_derive{2},options.omega(:,2),options);
T=MKdual(t,options.covariance{3},options.derive{3},options.user_derive{3},options.omega(:,3),options);
Ri=inv(R);
Si=inv(S);
Ti=inv(T);

Q=nan(size(R,1),size(S,1),size(T,1),dim);
Px=zeros(size(R,1),size(S,1),size(T,1));Py=zeros(size(Px));Pz=zeros(size(Px));

Px(1:size(x,1),1:size(x,2),1:size(x,3))=x;
Py(1:size(y,1),1:size(y,2),1:size(y,3))=y;
Pz(1:size(z,1),1:size(z,2),1:size(z,3))=z;
for i=1:size(R,1)
    for j=1:size(S,1)
        for k=1:size(T,1)
            Q(i,j,k,1)=0;Q(i,j,k,2)=0;Q(i,j,k,3)=0;
            for l=1:size(R,1)
                for m=1:size(S,1)
                    for n=1:size(T,1)
                        Q(i,j,k,1)=Q(i,j,k,1)+Px(l,m,n)*Ri(l,i)*Si(m,j)*Ti(n,k);
                        Q(i,j,k,2)=Q(i,j,k,2)+Py(l,m,n)*Ri(l,i)*Si(m,j)*Ti(n,k);
                        Q(i,j,k,3)=Q(i,j,k,3)+Pz(l,m,n)*Ri(l,i)*Si(m,j)*Ti(n,k);
                    end
                end
            end
        end
    end
end


