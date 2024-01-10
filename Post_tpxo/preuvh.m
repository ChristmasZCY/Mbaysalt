function [preu,prev,preh] = preuvh(ua, up, va, vp, ha, hp, lat, time, varargin)
    %       Predict the tidal current velocity or elevation at a given time
    % =================================================================================================================
    % Parameter:
    %       ua: u amplitude                    || required: True || type: double || format: matrix
    %       up: u phase                        || required: True || type: double || format: matrix
    %       va: v amplitude                    || required: True || type: double || format: matrix
    %       vp: v phase                        || required: True || type: double || format: matrix
    %       ha: h amplitude                    || required: True || type: double || format: matrix
    %       hp: h phase                        || required: True || type: double || format: matrix
    %       lat: latitude                      || required: True || type: double || format: matrix
    %       time: time                         || required: True || type: double || format: matrix
    %       varargin:                          || required: False|| as follow:
    %           Cdisp: display process         || required: False|| type: char   || format: 'Cdisp'
    %           tidecon: tidecon file          || required: False|| type: char   || format: 'tidecon-name-freq-12-atlas.mat'
    %       preu: u predict                    || required: True || type: double || format: matrix
    %       prev: v predict                    || required: True || type: double || format: matrix
    %       preh: h predict                    || required: True || type: double || format: matrix
    % =================================================================================================================
    % Example:
    %       [preu,prev,preh] = preuvh(ua,up,va,vp,ha,hp,lat,time, varargin)
    %       [preu,prev,preh] = preuvh(ua,up,va,vp,ha,hp,lat,time, 'Cdisp')
    %       [preu,prev,preh] = preuvh(ua,up,va,vp,ha,hp,lat,time, 'Cdisp', 'tidecon', 'tidecon-name-freq-12-atlas.mat');
    % =================================================================================================================

    varargin = read_varargin2(varargin, {'Cdisp'});
    varargin = read_varargin(varargin,{'tidecon'},{'../tidecon-name-freq-12-atlas.mat'});

    [~,lat_num,lon_num] = size(ua);
    load(tidecon, 'FREQ', 'NAME')

    preu = zeros(lat_num,lon_num, length(time));
    prev = preu; preh = preu;

    for i = 1:lat_num
        for j = 1:lon_num
            Tidecon_u(:,1) = ua(:,i,j);
            Tidecon_u(:,2) = 100;
            Tidecon_u(:,3) = up(:,i,j);
            Tidecon_u(:,4) = 100;
            preu(j,i,:)=t_predic(time,NAME,FREQ,Tidecon_u,lat(i));

            Tidecon_v(:,1) = va(:,i,j);
            Tidecon_v(:,2) = 100;
            Tidecon_v(:,3) = vp(:,i,j);
            Tidecon_v(:,4) = 100;
            prev(j,i,:)=t_predic(time,NAME,FREQ,Tidecon_v,lat(i));

            Tidecon_h(:,1) = ha(:,i,j);
            Tidecon_h(:,2) = 100;
            Tidecon_h(:,3) = hp(:,i,j);
            Tidecon_h(:,4) = 100;
            preh(j,i,:)=t_predic(time,NAME,FREQ,Tidecon_h,lat(i));
        end

        if ~isempty(Cdisp)
            d_num = length(num2str(lat_num));
            D_num = ['%',num2str(d_num),'d'];
            osprint2('INFO',[sprintf(D_num,i),'/',sprintf(D_num,lat_num)])
        end

    end

end

