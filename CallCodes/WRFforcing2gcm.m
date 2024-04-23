function WRFforcing2gcm(conf_file, yyyymmdd)
    %       Convert WRF forcing to GCM forcing
    % =================================================================================================================
    % Parameters:
    %       conf_file:      configuration file              || required: False|| type: Text || example: './Post_gcmSCS.conf'
    %       yyyymmdd:       date                            || required: False|| type: Float|| example: 20240402
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Updates:
    %       2024-**-**:     Created, by Christmas;
    % =================================================================================================================
    % Examples:
    %       WRFforcing2gcm('./Post_gcmSCS.conf', 20240402)
    % =================================================================================================================
    % Reference:
    %                     WRF2FVCOM       GCM_llc540    GCM_SA
    % precipfile    :   Precipitation       .TRUE.      .TRUE.
    % atempfile     :   T2                  .TRUE.      .TRUE.
    % swfluxfile    :   Shortwave           .TRUE.      .TRUE.
    % lwfluxfile    :   Longwave            .TRUE.      .TRUE.
    % uwindfile     :   U10                 .TRUE.      .TRUE.
    % vwindfile     :   V10                 .TRUE.      .TRUE.
    % apressurefile :   air_pressure        .TRUE.      .TRUE.
    % evapfile      :   Evaporation         .TRUE.      .TRUE.
    % hfluxfile     :   Net_Heat            .TRUE.      .FALSE.
    % aqhfile       :   SPQ                 .FALSE.     .TRUE.
    % =================================================================================================================

    arguments(Input)
        conf_file {mustBeFile} = './Post_gcmSCS.conf';
        yyyymmdd {mustBeFloat} = 20240402
    end

    para_conf = read_conf(conf_file);
    lon_s = para_conf.Lon_source';
    lat_s = para_conf.Lat_source';
    Indir = para_conf.ForcingDir;
    Outdir = fullfile(para_conf.ModelDir, 'forcing');
    makedirs(Outdir)
    ddt = datetime(num2str(yyyymmdd),"Format","yyyyMMdd");
    fin = fullfile(Indir, char(ddt), 'globalforcing.nc');
    lon_g = double(nr(fin, 'XLONG')); lon_g = unique(lon_g);
    lat_g = double(nr(fin, 'XLAT')); lat_g = unique(lat_g);

    prec_0  = double(nr(fin, 'Precipitation'));
    t2m_0   = double(nr(fin, 'T2'));
    sw_0    = double(nr(fin, 'Shortwave'));
    lw_0    = double(nr(fin, 'Longwave'));
    u10_0   = double(nr(fin, 'U10'));
    v10_0   = double(nr(fin, 'V10'));
    slp_0   = double(nr(fin, 'SLP'));
    evap_0  = double(nr(fin, 'Evaporation'));
    nh_0    = double(nr(fin, 'Net_Heat'));
    spq_0   = double(nr(fin, 'SPQ'));

    prec_1  = interpn(lon_g, lat_g, 1:size(u10_0, 3), prec_0, lon_s, lat_s, (1:size(u10_0, 3)));
    t2m_1   = interpn(lon_g, lat_g, 1:size(u10_0, 3), t2m_0,  lon_s, lat_s, (1:size(u10_0, 3)));
    sw_1    = interpn(lon_g, lat_g, 1:size(u10_0, 3), sw_0,   lon_s, lat_s, (1:size(u10_0, 3)));
    lw_1    = interpn(lon_g, lat_g, 1:size(u10_0, 3), lw_0,   lon_s, lat_s, (1:size(u10_0, 3)));
    u10_1   = interpn(lon_g, lat_g, 1:size(u10_0, 3), u10_0,  lon_s, lat_s, (1:size(u10_0, 3)));
    v10_1   = interpn(lon_g, lat_g, 1:size(u10_0, 3), v10_0,  lon_s, lat_s, (1:size(u10_0, 3)));
    slp_1   = interpn(lon_g, lat_g, 1:size(u10_0, 3), slp_0,  lon_s, lat_s, (1:size(u10_0, 3)));
    evap_1  = interpn(lon_g, lat_g, 1:size(u10_0, 3), evap_0, lon_s, lat_s, (1:size(u10_0, 3)));
    nh_1    = interpn(lon_g, lat_g, 1:size(u10_0, 3), nh_0,   lon_s, lat_s, (1:size(u10_0, 3)));
    spq_1   = interpn(lon_g, lat_g, 1:size(u10_0, 3), spq_0,  lon_s, lat_s, (1:size(u10_0, 3)));

    write_bin(fullfile(Outdir,'Precipitation'),  prec_1, 'w', 'b', 'float32')
    write_bin(fullfile(Outdir,'T2'),             t2m_1,  'w', 'b', 'float32')
    write_bin(fullfile(Outdir,'Shortwave'),     -sw_1,   'w', 'b', 'float32')
    write_bin(fullfile(Outdir,'Longwave'),      -lw_1,   'w', 'b', 'float32')
    write_bin(fullfile(Outdir,'U10'),            u10_1,  'w', 'b', 'float32')
    write_bin(fullfile(Outdir,'V10'),            v10_1,  'w', 'b', 'float32')
    write_bin(fullfile(Outdir,'SLP'),            slp_1,  'w', 'b', 'float32')
    write_bin(fullfile(Outdir,'Evaporation'),    evap_1, 'w', 'b', 'float32')
    write_bin(fullfile(Outdir,'Net_Heat'),       nh_1,   'w', 'b', 'float32')
    write_bin(fullfile(Outdir,'SPQ'),            spq_1,  'w', 'b', 'float32')

    osprint2('INFO', '"U10 V10 T2 SLP Shortwave Longwave Precipitation SPQ Net_Heat Evaporation" have been interpolated and written to')
    osprint2('INFO', sprintf('Outdir:  %s', Outdir))
end


function write_bin(filename, var, mode, machinefmt, precision)

    fid=fopen(filename, mode, machinefmt);
    fwrite(fid, var, precision);
    fclose(fid);

    % fid=fopen('prec_global_intp', 'w', 'b');
    % fwrite(fid,prec_new, 'float32');
    % fclose(fid);
    
end

