function [Depth,varargout]=griddata_node(lon,lat,time,h,siglay,slon,slat,varargin)
    % =================================================================================================================
    % discription:
    %       griddata_node is used to griddata the 3-D of the triangle grid to the rectangle grid, such as temperature/chlorophyll
    % =================================================================================================================
    % parameter:
    %       lon: longitude of the triangle grid         || required: True || type: double, v*1*1   || format: [120:.1:130]
    %       lat: latitude of the triangle grid          || required: True || type: double, v*1*1   || format: [20:.1:30]
    %       time: time of the triangle grid             || required: True || type: double, t*1*1   || format: posixtime
    %       h: bathymetry of the triangle grid          || required: True || type: double, v*1*1   || format: rand(10,1)
    %       siglay: sigma layer of the triangle grid    || required: True || type: double, s*1*1   || format: rand(10,1)
    %       slon: longitude of the rectangle grid       || required: True || type: double, m*1*1   || format: [120:.1:130]
    %       slat: latitude of the rectangle grid        || required: True || type: double, n*2*1   || format: [20:.1:30]
    %       varargin{n}: values of the triangle grid    || required: True || type: double, v*s*t   || format: rand(10,1)
    %       Depth: depth of the rectangle grid          || required: True || type: double, m*n*s   || format: rand(10,1)
    %       varargout{n}: values of the rectangle grid  || required: True || type: double, m*n*s*t || format: rand(10,1)
    % =================================================================================================================
    % example:
    %       [Temp,Salt,Depth]=griddata_fvcom.griddata_node(lon,lat,time,temp,salt,h,siglay,slon,slat)
    % =================================================================================================================

    disp(['handled with ' , num2str(length(varargin)) , ' * 3-D values Depth'])

    value_k = zeros(length(slat), length(slon),length(siglay),length(time));
    Depth = zeros(length(slat), length(slon),length(siglay));

    H = griddata(lon,lat,h,slon,slat');
    
    for i = 1: length(slat)

        for j = 1: length(slon)
            Depth(i,j,:) = H(i,j) * siglay;
        end

    end

    for k = 1: length(varargin)
        value_k1 = varargin{k};
        varargout{k} = zeros(size(value_k));
        for i = 1: length(time)
            parfor j = 1: length(siglay)
                value_k(:,:,j,i) = griddata(lon,lat,value_k1(:,j,i),slon,slat');
            end

    %         if mod(round(i/length(time)*100),10) == 0
    %             disp(['Process:', num2str((i/length(time)*100), '%02.0f'), '%'])
    %         end

        end

            varargout{k} = permute(value_k,[2,1,3,4]);

    end

    Depth = permute(Depth,[2,1,3]);

end
