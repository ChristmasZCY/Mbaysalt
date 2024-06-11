% Normalisation
if strcmp(options.normalisation,'axial')
    switch dim
        case 2
            C=sqrt((max(x(:))-min(x(:)))^2+(max(y(:))-min(y(:)))^2);
            x=(x-min(x(:)))/(max(x(:))-min(x(:)));
            y=(y-min(y(:)))/(max(y(:))-min(y(:)));
        case 3
            C=sqrt((max(x(:))-min(x(:)))^2+(max(y(:))-min(y(:)))^2+(max(z(:))-min(z(:)))^2);
            x=(x-min(x(:)))/(max(x(:))-min(x(:)));
            y=(y-min(y(:)))/(max(y(:))-min(y(:)));
            z=(z-min(z(:)))/(max(z(:))-min(z(:)));
    end
elseif strcmp(options.normalisation,'global')
    switch dim
        case 2
            C=sqrt((max(x(:))-min(x(:)))^2+(max(y(:))-min(y(:)))^2);
            x=(x-min(x(:)))/C;
            y=(y-min(y(:)))/C;
        case 3
            C=sqrt((max(x(:))-min(x(:)))^2+(max(y(:))-min(y(:)))^2+(max(z(:))-min(z(:)))^2);
            x=(x-min(x(:)))/C;
            y=(y-min(y(:)))/C;
            z=(z-min(z(:)))/C;
    end
elseif strcmp(options.normalisation,'off')
    C=1;
else
    error('error at choice of the normalisation option')
end
options.sigma=options.sigma/C^2;