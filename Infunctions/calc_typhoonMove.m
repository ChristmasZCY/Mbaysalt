function [UV_center, uE, vN] = calc_typhoonMove(Lon_tyCenter, Lat_tyCenter, ddt_time, varargin)
    %       Calculate typhoon moving vector velocity
    % =================================================================================================================
    % Parameters:
    %        Lon_tyCenter:    typhoon center longitude    || required: True  || type: double    || format: 1D-array(time)
    %        Lat_tyCenter:    typhoon center latitude     || required: True  || type: double    || format: 1D-array(time)
    %        ddt_time:        time(datetime)              || required: True  || type: datetime  || format: 1D-array(time)
    %       varargin: (optional)  
    %            FillNan_off:  whether fill NaN           || required: False || type: flag      || format: 'FillNan_off' 
    % =================================================================================================================
    % Returns:
    %        UV_center:       typhoon center windSpeed   || type: double    || format: 1D-array(time)
    %        P0_tyCenter:     typhoon center pressure    || type: double    || format: 1D-array(time)
    %        uE:              typhoon move velocity (E)  || type: double    || format: 1D-array(time)
    %        vN:              typhoon move velocity (N)  || type: double    || format: 1D-array(time)
    % =================================================================================================================
    % Updates:
    %       2024-05-11:     Created, by Christmas;
    % =================================================================================================================
    % Examples:
    %       [UV_center, uE, vN] = calc_typhoonMove(Lon_tyCenter, Lat_tyCenter, ddt_time);
    %       [UV_center, uE, vN] = calc_typhoonMove(Lon_tyCenter, Lat_tyCenter, ddt_time, 'FillNan_off');
    % =================================================================================================================
    % References:
    % =================================================================================================================

    varargin = read_varargin2(varargin, {'FillNan_off'});

    [d,d_east,d_north]= calc_geodistance(Lon_tyCenter(1:end-1),Lat_tyCenter(1:end-1),Lon_tyCenter(2:end),Lat_tyCenter(2:end));
    time_diff= seconds(diff(ddt_time));
    UV_center = d./time_diff;
    uE = d_east./time_diff;
    vN = d_north./time_diff;

    UV_center(end+1) = UV_center(end); 
    uE(end+1) = uE(end); 
    vN(end+1) = vN(end);

    if ~isempty(FillNan_off)
        UV_center(isnan(UV_center))=0;
        uE(isnan(uE))=0;
        vN(isnan(vN))=0;
    end
end


function [lon, lat, Ttimes, pres] = read_tcdata_typhoon(fin) %#ok<*DEFNU>
    data0=importdata(fin);
    t0=num2str(data0(:,1));
    Ttimes = Mdatetime(t0,"fmt",'yyyyMMddHH');
    lon = data0(:,4)/10;
    lat = data0(:,3)/10;
    pres =data0(:,5);
end
