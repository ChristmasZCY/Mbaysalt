function [Temp,Salt,Zeta,Depth]=griddata_tsz(lon,lat,time,temp,salt,zeta,h,siglay,slon,slat)
    % =================================================================================================================
    % discription:
    %       griddata_tsz is used to griddata the temperature/salinity/zeta/depth of the triangle grid to the rectangle grid
    % =================================================================================================================
    % parameter:
    %       lon: longitude of the triangle grid       || required: True || type: double, v*1*1   || format: [120:.1:130]
    %       lat: latitude of the triangle grid        || required: True || type: double, v*1*1   || format: [20:.1:30]
    %       time: time of the triangle grid           || required: True || type: double, t*1*1   || format: posixtime
    %       temp: temperature of the triangle grid    || required: True || type: double, v*s*t   || format: rand(10,1)
    %       salt: salinity of the triangle grid       || required: True || type: double, v*s*t   || format: rand(10,1)
    %       zeta: zeta of the triangle grid           || required: True || type: double, v*t     || format: rand(10,1)
    %       h: bathymetry of the triangle grid        || required: True || type: double, v*1*1   || format: rand(10,1)
    %       siglay: sigma layer of the triangle grid  || required: True || type: double, s*1*1   || format: rand(10,1)
    %       slon: longitude of the rectangle grid     || required: True || type: double, m*1*1   || format: [120:.1:130]
    %       slat: latitude of the rectangle grid      || required: True || type: double, n*2*1   || format: [20:.1:30]
    %       Temp: temperature of the rectangle grid   || required: True || type: double, m*n*s*t || format: rand(10,1)
    %       Salt: salinity of the rectangle grid      || required: True || type: double, m*n*s*t || format: rand(10,1)
    %       Zeta: zeta of the rectangle grid          || required: True || type: double, m*n*t   || format: rand(10,1)
    %       Depth: depth of the rectangle grid        || required: True || type: double, m*n*s   || format: rand(10,1)
    % =================================================================================================================
    % example:
    %       [Temp,Salt,Zeta,Depth]=griddata_tsz(lon,lat,time,temp,salt,zeta,h,siglay,slon,slat)
    % =================================================================================================================

    disp('handled with Temp Salt Zeta Depth')

    Temp = zeros(length(slat), length(slon),length(siglay),length(time));
    Salt = zeros(length(slat), length(slon),length(siglay),length(time));
    Zeta = zeros(length(slat), length(slon),length(time));
    Depth = zeros(length(slat), length(slon),length(siglay));

    H = griddata(lon,lat,h,slon,slat');
    
    for i = 1: length(slat)

        for j = 1: length(slon)
            Depth(i,j,:) = H(i,j) * siglay;
        end

    end

    for i = 1: length(time)
        
        Zeta(:,:,i) = griddata(lon,lat,zeta(:,i),slon,slat');
        
        parfor j = 1: length(siglay)
            Temp(:,:,j,i) = griddata(lon,lat,temp(:,j,i),slon,slat');
            Salt(:,:,j,i) = griddata(lon,lat,salt(:,j,i),slon,slat');
        end

%         if mod(round(i/length(time)*100),10) == 0
%             disp(['Process:', num2str((i/length(time)*100), '%02.0f'), '%'])
%         end

    end

    Temp = permute(Temp,[2,1,3,4]);
    Salt = permute(Salt,[2,1,3,4]);
    Zeta = permute(Zeta,[2,1,3]);
    Depth = permute(Depth,[2,1,3]);


end