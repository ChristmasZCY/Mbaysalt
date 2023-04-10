function [U,V,W]=griddata_current_uvw(lon,lat,siglay,time,u,v,w,slon,slat)
    % =================================================================================================================
    % discription:
    %       griddata_current is used to griddata the current data from the triangle grid to the rectangle grid
    % =================================================================================================================
    % parameter:
    %       lon: longitude of the triangle grid       || required: True || type: double, v*1*1   || format: [120:.1:130]
    %       lat: latitude of the triangle grid        || required: True || type: double, v*1*1   || format: [20:.1:30]
    %       siglay: sigma layer of the triangle grid  || required: True || type: double, s*1*1   || format: [.02:1/40:.98]
    %       time: time of the triangle grid           || required: True || type: double, t*1*1   || format: posixtime
    %       u: u current of the triangle grid         || required: True || type: double, v*s*t   || format: rand(10,1)
    %       v: v current of the triangle grid         || required: True || type: double, v*s*t   || format: rand(10,1)
    %       w: w current of the triangle grid         || required: True || type: double, v*s*t   || format: rand(10,1)
    %       slon: longitude of the rectangle grid     || required: True || type: double, m*1*1   || format: [120:.1:130]
    %       slat: latitude of the rectangle grid      || required: True || type: double, n*2*1   || format: [20:.1:30]
    %       U: u current of the rectangle grid        || required: True || type: double, m*n*s*t || format: rand(10,1)
    %       V: v current of the rectangle grid        || required: True || type: double, m*n*s*t || format: rand(10,1)
    %       W: w current of the rectangle grid        || required: True || type: double, m*n*s*t || format: rand(10,1)
    % =================================================================================================================
    % example:
    %       [U,V,W]=griddata_current_uvw(lon,lat,siglay,time,u,v,w,slon,slat)
    % =================================================================================================================
    
    disp('handled with U V W')

    U =zeros(length(slat),length(slon),length(siglay),length(time));
    V =zeros(length(slat),length(slon),length(siglay),length(time));
    W =zeros(length(slat),length(slon),length(siglay),length(time));
    
    for i = 1:length(time)

        parfor j = 1:length(siglay)
        
            U(:,:,j,i) = griddata(lon, lat, u(:,j,i), slon, slat', 'linear');
            V(:,:,j,i) = griddata(lon, lat, v(:,j,i), slon, slat', 'linear');
            W(:,:,j,i) = griddata(lon, lat, w(:,j,i), slon, slat', 'linear');
        
        end

%         if mod(round(i/length(time)*100),10) == 0
%             disp(['Process:', num2str((i/length(time)*100), '%02.0f'), '%'])
%         end
    
    end
    U = permute(U,[2,1,3,4]);
    V = permute(V,[2,1,3,4]);
    W = permute(W,[2,1,3,4]);
end