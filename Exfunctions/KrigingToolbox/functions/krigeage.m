function [u]=krigeage(observations,options)
%krigeage 2 ou 3 D pour une fonction explicite(directe) ou implicite(parametrique)
%[erreur]=[a,b]=kringeage(observations,options)
%
%Inputs:
%observations: structure des observations
%champs dans observation:
%x,y(2D) ou x,y,z(3D)
%
%options: structure des options
%champs dans options:
%covariance
%derive
%omega (pour une covariance(ligne1) ou de d�rive(ligne2) trigonom�trique; Ncolomn=Nparametres)
%param ('on'(d�faut),'off')
%normalisation ('axial','global','off'(d�faut))
%sigma: effet p�pite (1 ou N valeur, sinon invalide, d�faut 0)
%devide_param: la methode pour diviser les parametres
%grad: gradience ([x ux' y uy' z uz'])
%resolution (Nb de segment selon chaque dimension, defaut 100)
%closeloop ('yes'(applicable quand et seulement quand le 1er point est superpos� sur le derniere point) 'no'(defaut))
%
%choix de covariance
%'lin': lin�aire
%'log': carr�-logarithmique
%'cubic': cubique (d�faut)
%'sin': trigonom�trique, omega requi ou 2*pi par d�faut
%'user': poign�e de fonction d�fini par utilisateur, en forme d'une string
%commence par @(nom_var), il faut evider le nom_var apparaitre dans un
%autre nom de fonction, p.ex nom_var=s et fonction abs(), nom_var est
%oblige d'etre un lettre single
%
%choix de derive
%'const': constante
%'lin': lin�aire (d�faut)
%'quad': quadratique
%'cubic': cubique
%'sin': trigonom�trique, omega requi ou 2*pi par d�faut
%'user': poign�e de fonction d�fini par utilisateur, en forme d'une serie
%des strings commence par @(nom_var)
%
%choix de divide_param:
%'unif': uniform�ment (d�faut)
%'dist': selon distance
%'user': defini par utilisateur
%
%Output:
%u: la(les) fonction(s) krig�e(s)


dim=length(fieldnames(observations)); % dimension

Np=length(find(size(observations.x)~=1)); % nombre des parametres

defaut_options=defaut_optionset(Np); % d�finir des options par defaut

% Remplacer les champs vides dans options par options par d�faut
Opt_names=fieldnames(defaut_options);
Nopt=length(Opt_names);
OptSet=[];
Nset=1;
if isa(options,'struct')
    for i=1:Nopt
        if ~isfield(options,Opt_names(i)) || isempty(eval(['options.' Opt_names{i} ';']))
            OptSet(Nset)=i;
            Nset=Nset+1;
        end
    end
else
    error('options should be a structure');
end
for i=OptSet
    eval(['options.' Opt_names{i} '=defaut_options.' Opt_names{i} ';']);
end

% Main
if strcmp(options.param,'on') % utiliser �quations parametriques
    switch Np
        case 1 % courbe
            t=devide_parameters(observations,options);
            [a,b,c]=krigeage1_param(t,observations,options);
            u=plotting_krigeage1(a,b,c,observations,options);
        case 2 % surface
            [t,s]=devide_parameters(observations,options);
            [Q]=krigeage2_param(s,t,observations,options);
            u=plotting_krigeage2(Q,observations,options);
        case 3 % solide
            [t,s,r]=devide_parameters(observations,options);
            [Q]=krigeage3_param(r,s,t,observations,options);
            u=plotting_krigeage3(Q,observations,options);
        otherwise
            error('dimension too high')
    end
    
elseif strcmp(options.param,'off') % utiliser �quations explicites
    if dim==2
        [a,b,c]=krigeage1(observations,options);
        u=plotting_krigeage1(a,b,c,observations,options);
    elseif dim==3
        [a,b,c]=krigeage2(observations,options);
        u=plotting_krigeage1(a,b,c,observations,options);
    end
else
    error('invalid input for krigeage: param should be ''on'' or ''off''');
end

if ~strcmp(options.normalisation,'off')
    if exist('a','var')
        u=regress(u,observations,options,a,b,c);
    elseif exist('Q','var')
        u=regress(u,observations,options,Q);
    end
end