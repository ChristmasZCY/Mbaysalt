function defaut_options=defaut_optionset(Np)
% definir options par défaut
defaut_options.param='on';
switch Np
    case 1
        defaut_options.covariance='cubic';
        defaut_options.derive='lin';
        defaut_options.user_derive='';
        defaut_options.resolution=100;
    case 2
        defaut_options.covariance={'cubic','cubic'};
        defaut_options.derive={'lin','lin'};
        defaut_options.user_derive={'',''};
        defaut_options.resolution=[100 100];
    case 3
        defaut_options.covariance={'cubic','cubic','cubic'};
        defaut_options.derive={'lin','lin','lin'};
        defaut_options.user_derive={'','',''};
        defaut_options.resolution=[100 100 100];
end
defaut_options.normalisation='off';
defaut_options.omega=repmat(2*pi,2,Np);
defaut_options.sigma=0;
defaut_options.devide_param='unif';
defaut_options.grad=[];
defaut_options.closeloop='no';
