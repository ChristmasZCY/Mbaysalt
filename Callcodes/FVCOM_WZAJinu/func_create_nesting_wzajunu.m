%==========================================================================
% Function of creating nesting forcing from the large domain results
%
% Input:
%   fnest_nc  --- nest nc file
%   indir     --- input data path
%   fout      --- output file path and name
%   ymd_start --- starting day in 'yyyymmdd'
%   ymd_end   --- ending day in 'yyyymmdd'
%
%
% Siqi Li
% 2022-09-28
%
% Updates:
%           2022-09-28  Created(nesting and initial from EAMS),                 by Siqi Li
%           2024-02-20  Modified(nesting and initial from FVCOM_Global_v2),     by Christmas
%           2024-12-18  Changed(nesting for FVCOM_WZAJinu from FVCOM_WZtide3),  by Christmas;
%
%==========================================================================
function func_create_nesting_wzajunu(fnest_nc, indir, fout, ymd_start, ymd_end)
    
    % test =================================
    % fnest_nc = '/home/ocean/ForecastSystem/FVCOM_WZAJinu/Control/data/fnesting_wzajinu_grid_exp.nc';
    % indir = '/home/ocean/ForecastSystem/FVCOM_WZtide3/Run/';
    % fout = '/home/ocean/ForecastSystem/FVCOM_WZAJinu/Data/fvcom_wzajinu_nesting_forecast/fvcom_wzajinu_nesting_20241218.nc';
    % ymd_start = '20241218';
    % ymd_end = '20241220';
    % test =================================
    
    din = fullfile(indir, ymd_start, 'output');
    f1 = f_load_grid(fullfile(din, 'forecast_0001.nc'),'Coordinate','geo');
    fn = f_load_grid(fnest_nc,"Coordinate","geo"); clear fnest_nc
    weight_node = interp_2d_calc_weight('TRI',f1.x,f1.y,f1.nv,fn.x,fn.y);
    weight_nele = interp_2d_calc_weight('TRI',f1.x,f1.y,f1.nv,fn.xc,fn.yc);
    
    day1 = datenum(ymd_start, 'yyyymmdd');
    day2 = datenum(ymd_end, 'yyyymmdd');
    time1 = datenum(ymd_start, 'yyyymmdd') - datenum(1858, 11, 17);
    time2 = datenum(ymd_end, 'yyyymmdd') - datenum(1858, 11, 17);
    
    % Create the nesting file
    ncid = netcdf.create(fout, 'CLOBBER');
    
    % Define global attributes
    netcdf.putAtt(ncid, -1, 'source', 'FVCOM');
    netcdf.putAtt(ncid, -1, 'CoordinateSystem', 'Cartesian');
    
    % Define dimensions
    time_dimid = netcdf.defDim(ncid, 'time', 0);
    node_dimid = netcdf.defDim(ncid, 'node', fn.node);
    nele_dimid = netcdf.defDim(ncid, 'nele', fn.nele);
    siglay_dimid = netcdf.defDim(ncid, 'siglay', fn.kbm1);
    siglev_dimid = netcdf.defDim(ncid, 'siglev', fn.kb);
    three_dimid = netcdf.defDim(ncid, 'three', 3);
    DateStrLen_dimid = netcdf.defDim(ncid, 'DateStrLen', 26);
    
    % Define variables
    % x
    x_varid = netcdf.defVar(ncid, 'x', 'float', node_dimid);
    netcdf.putAtt(ncid, x_varid, 'long_name', 'nodal x-coordinate');
    netcdf.putAtt(ncid, x_varid, 'units', 'm');
    % y
    y_varid = netcdf.defVar(ncid, 'y', 'float', node_dimid);
    netcdf.putAtt(ncid, y_varid, 'long_name', 'nodal y-coordinate');
    netcdf.putAtt(ncid, y_varid, 'units', 'm');
    % xc
    xc_varid = netcdf.defVar(ncid, 'xc', 'float', nele_dimid);
    netcdf.putAtt(ncid, xc_varid, 'long_name', 'zonal x-coordinate');
    netcdf.putAtt(ncid, xc_varid, 'units', 'm');
    % yc
    yc_varid = netcdf.defVar(ncid, 'yc', 'float', nele_dimid);
    netcdf.putAtt(ncid, yc_varid, 'long_name', 'zonal y-coordinate');
    netcdf.putAtt(ncid, yc_varid, 'units', 'm');
    % nv
    nv_varid = netcdf.defVar(ncid, 'nv', 'int', [nele_dimid three_dimid]);
    netcdf.putAtt(ncid, nv_varid, 'long_name', 'znodes surrounding element');
    % lon
    lon_varid = netcdf.defVar(ncid, 'lon', 'float', node_dimid);
    netcdf.putAtt(ncid, lon_varid, 'long_name', 'nodal longitude');
    netcdf.putAtt(ncid, lon_varid, 'units', 'degree_east');
    % lat
    lat_varid = netcdf.defVar(ncid, 'lat', 'float', node_dimid);
    netcdf.putAtt(ncid, lat_varid, 'long_name', 'nodal latgitude');
    netcdf.putAtt(ncid, lat_varid, 'units', 'degree_north');
    % lonc
    lonc_varid = netcdf.defVar(ncid, 'lonc', 'float', nele_dimid);
    netcdf.putAtt(ncid, lonc_varid, 'long_name', 'zonal longitude');
    netcdf.putAtt(ncid, lonc_varid, 'units', 'degree_east');
    % latc
    latc_varid = netcdf.defVar(ncid, 'latc', 'float', nele_dimid);
    netcdf.putAtt(ncid, latc_varid, 'long_name', 'zonal latgitude');
    netcdf.putAtt(ncid, latc_varid, 'units', 'degree_north');
    % siglay
    siglay_varid = netcdf.defVar(ncid, 'siglay', 'float', [node_dimid siglay_dimid]);
    netcdf.putAtt(ncid, siglay_varid, 'long_name', 'Sigma Layers');
    % siglev
    siglev_varid = netcdf.defVar(ncid, 'siglev', 'float', [node_dimid siglev_dimid]);
    netcdf.putAtt(ncid, siglev_varid, 'long_name', 'Sigma Levels');
    % siglay_center
    siglay_center_varid = netcdf.defVar(ncid, 'siglay_center', 'float', [nele_dimid,siglay_dimid]);
    netcdf.putAtt(ncid, siglay_center_varid, 'long_name', 'Sigma Layers');
    % siglev_center
    siglev_center_varid = netcdf.defVar(ncid, 'siglev_center', 'float', [nele_dimid,siglev_dimid]);
    netcdf.putAtt(ncid, siglev_center_varid, 'long_name', 'Sigma Levels');
    % h
    h_varid = netcdf.defVar(ncid, 'h', 'float', node_dimid);
    netcdf.putAtt(ncid, h_varid, 'long_name', 'Bathymetry');
    netcdf.putAtt(ncid, h_varid, 'units', 'm');
    % hc
    hc_varid = netcdf.defVar(ncid, 'hc', 'float', nele_dimid);
    netcdf.putAtt(ncid, hc_varid, 'long_name', 'Bathymetry');
    netcdf.putAtt(ncid, hc_varid, 'units', 'm');
    % h_center
    h_center_varid = netcdf.defVar(ncid, 'h_center', 'float', nele_dimid);
    netcdf.putAtt(ncid, h_center_varid, 'long_name', 'Bathymetry');
    netcdf.putAtt(ncid, h_center_varid, 'units', 'm');
    % time
    time_varid = netcdf.defVar(ncid, 'time', 'float', time_dimid);
    netcdf.putAtt(ncid, time_varid, 'units', 'days since 1858-11-17 00:00:00');
    netcdf.putAtt(ncid, time_varid, 'format', 'modified julian day (MJD)');
    netcdf.putAtt(ncid, time_varid, 'time_zone', 'UTC');
    % Itime
    Itime_varid = netcdf.defVar(ncid, 'Itime', 'int', time_dimid);
    netcdf.putAtt(ncid, Itime_varid, 'units', 'days since 1858-11-17 00:00:00');
    netcdf.putAtt(ncid, Itime_varid, 'format', 'modified julian day (MJD)');
    netcdf.putAtt(ncid, Itime_varid, 'time_zone', 'UTC');
    % Itime2
    Itime2_varid = netcdf.defVar(ncid, 'Itime2', 'int', time_dimid);
    netcdf.putAtt(ncid, Itime2_varid, 'units', 'msec since 00:00:00');
    netcdf.putAtt(ncid, Itime2_varid, 'time_zone', 'UTC');
    % Times
    Times_varid = netcdf.defVar(ncid, 'Times', 'char', [DateStrLen_dimid time_dimid]);
    netcdf.putAtt(ncid, Times_varid, 'format', 'yyyy-mm-ddTHH:MM:SS.000000');
    netcdf.putAtt(ncid, Times_varid, 'time_zone', 'UTC');
    % zeta
    zeta_varid = netcdf.defVar(ncid, 'zeta', 'float', [node_dimid time_dimid]);
    netcdf.putAtt(ncid, zeta_varid, 'long_name', 'Water Surface Elevation');
    netcdf.putAtt(ncid, zeta_varid, 'units', 'm');
    % u
    u_varid = netcdf.defVar(ncid, 'u', 'float', [nele_dimid siglay_dimid time_dimid]);
    netcdf.putAtt(ncid, u_varid, 'long_name', 'Eastward Water Velocity');
    netcdf.putAtt(ncid, u_varid, 'units', 'm/s');
    % ua
    ua_varid = netcdf.defVar(ncid, 'ua', 'float', [nele_dimid time_dimid]);
    netcdf.putAtt(ncid, ua_varid, 'long_name', 'Vertically Averaged x-velocity');
    netcdf.putAtt(ncid, ua_varid, 'units', 'm/s');
    % v
    v_varid = netcdf.defVar(ncid, 'v', 'float', [nele_dimid siglay_dimid time_dimid]);
    netcdf.putAtt(ncid, v_varid, 'long_name', 'Northward Water Velocity');
    netcdf.putAtt(ncid, v_varid, 'units', 'm/s');
    % va
    va_varid = netcdf.defVar(ncid, 'va', 'float', [nele_dimid time_dimid]);
    netcdf.putAtt(ncid, va_varid, 'long_name', 'Vertically Averaged y-velocity');
    netcdf.putAtt(ncid, va_varid, 'units', 'm/s');
    % temperature
    temp_varid = netcdf.defVar(ncid, 'temp', 'float', [node_dimid siglay_dimid time_dimid]);
    netcdf.putAtt(ncid, temp_varid, 'long_name', 'temperature');
    netcdf.putAtt(ncid, temp_varid, 'units', 'degrees_C');
    % salinity
    salinity_varid = netcdf.defVar(ncid, 'salinity', 'float', [node_dimid siglay_dimid time_dimid]);
    netcdf.putAtt(ncid, salinity_varid, 'long_name', 'salinity');
    netcdf.putAtt(ncid, salinity_varid, 'units', '1e-3');
    % hyw
    hyw_varid = netcdf.defVar(ncid, 'hyw', 'float', [node_dimid siglev_dimid time_dimid]);
    netcdf.putAtt(ncid, hyw_varid, 'long_name', 'hydrostatic vertical velocity');
    netcdf.putAtt(ncid, hyw_varid, 'units', 'm/s');
    
    % End define mode
    netcdf.endDef(ncid);
    
    % Write data
    netcdf.putVar(ncid, x_varid, fn.x);
    netcdf.putVar(ncid, y_varid, fn.y);
    netcdf.putVar(ncid, xc_varid, fn.xc);
    netcdf.putVar(ncid, yc_varid, fn.yc);
    netcdf.putVar(ncid, nv_varid, fn.nv);
    netcdf.putVar(ncid, h_varid, fn.h);
    netcdf.putVar(ncid, lon_varid, fn.LON);
    netcdf.putVar(ncid, lat_varid, fn.LAT);
    netcdf.putVar(ncid, lonc_varid, mean(fn.LON(fn.nv), 2));
    netcdf.putVar(ncid, latc_varid, mean(fn.LAT(fn.nv), 2));
    netcdf.putVar(ncid, siglay_varid, fn.siglay);
    netcdf.putVar(ncid, siglev_varid, fn.siglev);
    netcdf.putVar(ncid, h_center_varid, fn.hc);
    netcdf.putVar(ncid, siglay_center_varid, fn.siglayc);
    netcdf.putVar(ncid, siglev_center_varid, fn.siglevc);
    
    dzc = -diff(fn.siglevc, 1, 2);
    irec = 0;
    ifile = 0;
    for day = day1 : day2
    
        % Read data from large domain file
        fin = [din '/forecast_' num2str(ifile+1,'%04d') '.nc'];
        if day ~= day2
            nt = 24;

            Times0 = ncread(fin, 'Times', [1 1], [Inf,nt])';
            zeta0 = ncread(fin, 'zeta', [1 1], [Inf nt]);
            temp0 = ncread(fin, 'temp', [1 1 1], [Inf Inf nt]);
            salt0 = ncread(fin, 'salinity', [1 1 1], [Inf Inf nt]);
            u0 = ncread(fin, 'u', [1 1 1], [Inf Inf nt]);
            v0 = ncread(fin, 'v', [1 1 1], [Inf Inf nt]);
        elseif day == day2
            nt = 1;
            Times0 = ncread(fin, 'Times', [1 1], [Inf, 1])';
            zeta0 = ncread(fin, 'zeta', [1 1], [Inf 1]);
            temp0 = ncread(fin, 'temp', [1 1 1], [Inf Inf 1]);
            salt0 = ncread(fin, 'salinity', [1 1 1], [Inf Inf 1]);
            u0 = ncread(fin, 'u', [1 1 1], [Inf Inf 1]);
            v0 = ncread(fin, 'v', [1 1 1], [Inf Inf 1]);
        end

        for it = 1 : nt

            Times = Times0(it, :);
            time = datenum(Times, 'yyyy-mm-ddTHH:MM:SS.000000') - datenum(1858, 11, 17);
            Itime = floor(time);
            Itime2 = (time - Itime)*24*3600 * 1000;
            disp(['--->' Times])
            if (time<time1 || time>time2)
                continue
            end
    
            zeta = interp_2d_via_weight(zeta0(:,it), weight_node);
            temp = interp_2d_via_weight(temp0(:,:,it), weight_node);
            salt = interp_2d_via_weight(salt0(:,:,it), weight_node);
            u = interp_2d_via_weight(u0(:,:,it), weight_nele);
            v = interp_2d_via_weight(v0(:,:,it), weight_nele);
    
            ua = sum(u.*dzc, 2);
            va = sum(v.*dzc, 2);
            hyw = zeros(fn.node, fn.kb);
    
            disp(['---Writing data for time: ' Times])
            netcdf.putVar(ncid, time_varid, irec, 1, time);
            netcdf.putVar(ncid, Itime_varid, irec, 1, Itime);
            netcdf.putVar(ncid, Itime2_varid, irec, 1, Itime2);
            netcdf.putVar(ncid, Times_varid, [0 irec], [length(Times) 1], Times);
            netcdf.putVar(ncid, zeta_varid, [0 irec], [fn.node 1], zeta);
            netcdf.putVar(ncid, temp_varid, [0 0 irec], [fn.node fn.kbm1 1], temp);
            netcdf.putVar(ncid, salinity_varid, [0 0 irec], [fn.node fn.kbm1 1], salt);
            netcdf.putVar(ncid, u_varid, [0 0 irec], [fn.nele fn.kbm1 1], u);
            netcdf.putVar(ncid, ua_varid, [0 irec], [fn.nele 1], ua);
            netcdf.putVar(ncid, v_varid, [0 0 irec], [fn.nele fn.kbm1 1], v);
            netcdf.putVar(ncid, va_varid, [0 irec], [fn.nele 1], va);
            netcdf.putVar(ncid, hyw_varid, [0 0 irec], [fn.node fn.kb 1], hyw);
            irec = irec + 1;
        end
        ifile = ifile + 1;
    
    end
    % Close the nesting file
    netcdf.close(ncid);

end
