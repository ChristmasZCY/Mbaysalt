function Q=krigeage2_param(s,t,observations,options)
%krigeage pour une surface 2D ou 3D (2 parametre)
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
Normalisation;

S=MKdual(s,options.covariance{1},options.derive{1},options.user_derive{1},options.omega(:,1),options);
Ms=size(S,1)-size(observations.x,1);
T=MKdual(t,options.covariance{2},options.derive{2},options.user_derive{2},options.omega(:,2),options);
Mt=size(T,1)-size(observations.x,2);

Q=nan(size(S,1),size(T,1),dim);
switch dim
    case 2
        Px=[x zeros(size(x,1),Mt);zeros(Ms,size(x,2)) zeros(Ms,Mt)];
        Py=[y zeros(size(y,1),Mt);zeros(Ms,size(y,2)) zeros(Ms,Mt)];
        Q(:,:,1)=S\Px/T;
        Q(:,:,2)=S\Py/T;
    case 3
        Px=[x zeros(size(x,1),Mt);zeros(Ms,size(x,2)) zeros(Ms,Mt)];
        Py=[y zeros(size(y,1),Mt);zeros(Ms,size(y,2)) zeros(Ms,Mt)];
        Pz=[z zeros(size(z,1),Mt);zeros(Ms,size(z,2)) zeros(Ms,Mt)];
        Q(:,:,1)=S\Px/T;
        Q(:,:,2)=S\Py/T;
        Q(:,:,3)=S\Pz/T;
    otherwise
        error('error input in krigeage: observations')
end


