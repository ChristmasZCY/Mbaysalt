function varargout = griddata_nele(lon,lat,siglay,time,slon,slat,varargin)
    % =================================================================================================================
    % discription:
    %       griddata_current is used to griddata the current data from the triangle grid to the rectangle grid
    % =================================================================================================================
    % parameter:
    %       lon: longitude of the triangle grid       || required: True || type: double, v*1*1   || format: [120:.1:130]
    %       lat: latitude of the triangle grid        || required: True || type: double, v*1*1   || format: [20:.1:30]
    %       siglay: sigma layer of the triangle grid  || required: True || type: double, s*1*1   || format: [.02:1/40:.98]
    %       time: time of the triangle grid           || required: True || type: double, t*1*1   || format: posixtime
    %       slon: longitude of the rectangle grid     || required: True || type: double, m*1*1   || format: [120:.1:130]
    %       slat: latitude of the rectangle grid      || required: True || type: double, n*2*1   || format: [20:.1:30]
    %       varargin: u and v of the triangle grid    || required: True || type: double, v*s*t   || format: matrix
    %       U: u current of the rectangle grid        || required: True || type: double, m*n*s*t || format: matrix
    %       V: v current of the rectangle grid        || required: True || type: double, m*n*s*t || format: matrix
    % =================================================================================================================
    % example:
    %       [U,V]=griddata_fvcom.griddata_nele(lon,lat,siglay,time,slon,slat,u,v)
    %       [U,V,W]=griddata_fvcom.griddata_nele(lon,lat,siglay,time,slon,slat,u,v,w)
    % =================================================================================================================
    
    disp(['handled with ' , num2str(length(varargin)) , ' * 3-D values'])

    value_k = zeros(length(slat), length(slon),length(siglay),length(time));

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

end