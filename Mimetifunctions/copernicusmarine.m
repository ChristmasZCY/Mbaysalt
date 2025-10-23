function status = copernicusmarine(command, varargin)
    %       Copernicus Marine Toolbox CLI(mimic of the command line interface)
    %       copernicusmarine subset --dataset-id  dataset-duacs-nrt-global-merged-allsat-phy-l4 -t 2024-03-04 -T 2024-03-04 --username * --password * -f /home/ocean/ForecastSystem/FVCOM_Global_v2/Data/SSH/SSH_NRT_0p25_20240304.nc --force-download
    % =================================================================================================================
    % Parameters:
    %       varargin:       optional parameters      
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Updates:
    %       2024-03-12:     Created,        by Christmas;
    %       2024-11-05:     Added GLORYS,   by Christmas;
    % =================================================================================================================
    % Examples:
    %       copernicusmarine
    % =================================================================================================================
    % Explains: 
    %       Description of cmd : https://help.marine.copernicus.eu/en/articles/7972861-copernicus-marine-toolbox-cli-subset#h_93a57c2332
    %       Url of product     : https://data.marine.copernicus.eu/product/${product_id}
    %       FTP path           : nrt.cmems-du.eu    /Core/${product_id}/${dataset-id}
    % =================================================================================================================
    % Examples of cmd:
    %        Info of product : copernicusmarine describe -c ${dataset-id} 
    %        Download        : copernicusmarine subset --dataset-id ${dataset-id} -t 2024-03-14 -T 2024-03-14 -f x.nc
    % =================================================================================================================
    % In common use:                        product_id                                          dataset-id                                                      DOI                                 DATE
    %       SSH(OLD)                : SEALEVEL_GLO_PHY_L4_NRT_OBSERVATIONS_008_046      dataset-duacs-nrt-global-merged-allsat-phy-l4               https://doi.org/10.48670/moi-00149  
    %       SSH(equivalent-0.25)    : SEALEVEL_GLO_PHY_L4_NRT_008_046                   cmems_obs-sl_glo_phy-ssh_nrt_allsat-l4-duacs-0.25deg_P1D    https://doi.org/10.48670/moi-00149  
    %       SSH(new-0.125)          : SEALEVEL_GLO_PHY_L4_NRT_008_046                   cmems_obs-sl_glo_phy-ssh_nrt_allsat-l4-duacs-0.125deg_P1D   https://doi.org/10.48670/moi-00149  
    %       ADT                     : SEALEVEL_GLO_PHY_L4_MY_008_047                    cmems_obs-sl_glo_phy-ssh_my_allsat-l4-duacs-0.25deg_P1D     https://doi.org/10.48670/moi-00148  
    %       SST(FVCOM_SCS)          : SST_GLO_SST_L4_NRT_OBSERVATIONS_010_001           METOFFICE-GLO-SST-L4-NRT-OBS-SST-V2                         https://doi.org/10.48670/moi-00165  
    %       SST(0.1)                : SST_GLO_PHY_L4_NRT_010_043                        cmems_obs-sst_glo_phy_nrt_l4_P1D-m                          https://doi.org/10.48670/mds-00321  
    %       GLORYS(nesting-curr)    : GLOBAL_ANALYSISFORECAST_PHY_001_024               cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m                   https://doi.org/10.48670/moi-00016  
    %       GLORYS(nesting-salt)    : GLOBAL_ANALYSISFORECAST_PHY_001_024               cmems_mod_glo_phy-so_anfc_0.083deg_P1D-m                    https://doi.org/10.48670/moi-00016  
    %       GLORYS(nesting-temp)    : GLOBAL_ANALYSISFORECAST_PHY_001_024               cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m                https://doi.org/10.48670/moi-00016  
    %       GLORYS(nesting-zeta)    : GLOBAL_ANALYSISFORECAST_PHY_001_024               cmems_mod_glo_phy_anfc_0.083deg_P1D-m                       https://doi.org/10.48670/moi-00016  
    %       GLORYS(ice)             : GLOBAL_ANALYSISFORECAST_PHY_001_024               cmems_mod_glo_phy_anfc_0.083deg_P1D-m                       https://doi.org/10.48670/moi-00016  
    %       GOBAF(biogeochemistry)  : GLOBAL_ANALYSISFORECAST_BGC_001_028                                                                           https://doi.org/10.48670/moi-00015  
    %       GLORYS12V1(nesting-all) : GLOBAL_MULTIYEAR_PHY_001_030                      cmems_mod_glo_phy_my_0.083deg_P1D-m(daily)                  https://doi.org/10.48670/moi-00021      1993-01-01 2021-06-30
    % =================================================================================================================
    
    arguments(Input)
        command
    end
    arguments(Input,Repeating)
        varargin
    end

    varargin = read_varargin(varargin, {'exe'}, {'/Users/christmas/Library/Software/miniforge3/bin/copernicusmarine'});

    switch command
        case 'describe'  % Print Copernicus Marine catalog as JSON.
            cmd = sprintf('%s describe', exe);

        case 'subset'  % Download subsets of datasets as NetCDF files or Zarr stores.
            cmd = sprintf('%s subset', exe);

        case 'get'  % Download originally produced data files.
            cmd = sprintf('%s get', exe);

        case 'login'  %  Create a configuration file with your Copernicus Marine credentials.
            cmd = sprintf('%s login', exe);
        
        case {'help', 'h', '--help'}  % Show the version and exit.
            cmd = sprintf('%s --help', exe);

        case {'v', 'V', '--version'}  % Show this message and exit.
            cmd = sprintf('%s --version', exe);
 
        otherwise
            error(" Try 'copernicusmarine help' for help. \n" + ...
                  " Error: No such command '%s'", command);
    end

    status = system(cmd);

end

function example()
    %https://help.marine.copernicus.eu/en/articles/6761892-how-to-subset-and-download-copernicus-marine-data-via-motu-in-matlab
    out_dir = './data';
    username = input('Enter your username: ', "s");
    password = input('Enter your password: ', "s");
    serviceId = 'GLOBAL_ANALYSISFORECAST_PHY_001_024';
    productId = 'cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m';
    variables = ["--variable thetao"];
    date_start = '2022-01-01 12:00:00';
    date_end = '2022-01-07 12:00:00';
    lon = [-15.26, 5.04]; % lon_min, lon_max
    lat = [35.57, 51.03]; % lat_min, lat_max
    depth = ["0", "100"];  % depth_min, depth_max 
    filename = 'global_20220101_2022_01_07.nc';
    motu_line = sprintf("python -m motuclient --motu https://nrt.cmems-du.eu/motu_web/Motu", ...
        " --service-id ", serviceID, "-TDS --product-id ", productID, ...
        "--longitude-min ", lon(1), "--longitude-max ", lon(2), ...
        "--latitude-min ", lat(1), "--latitude-max ", lat(2), ...
        " --date-min ",date_start," --date-max ",date_end, ...
        " --depth-min ", depth(1), " --depth-max ", depth(2), ...
        variables(1), ...
        " --out-dir ", out_dir, " --out-name ", filename, ...
        " --user ", username, " --pwd ", password);
    
    disp(motu_line)
    
    system(motu_line)
end
