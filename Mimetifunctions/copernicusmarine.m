function status = copernicusmarine(command, varargin)
    %       Mainpath is a function to add all path of this package
    %       copernicusmarine subset --dataset-id  dataset-duacs-nrt-global-merged-allsat-phy-l4 -t 2024-03-04 -T 2024-03-04 --username sli12 --password 123qweASDF -f /home/ocean/ForecastSystem/FVCOM_Global_v2/Data/SSH/SSH_NRT_0p25_20240304.nc --force-download
    % =================================================================================================================
    % Parameters:
    %       varargin:       optional parameters      
    % =================================================================================================================
    % Returns:
    %       None
    % =================================================================================================================
    % Updates:
    %       2024-03-12:     Created, by Christmas;
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
    % In common use:                product_id                                          dataset-id                                                      DOI
    %       SSH(OLD)        : SEALEVEL_GLO_PHY_L4_NRT_OBSERVATIONS_008_046      dataset-duacs-nrt-global-merged-allsat-phy-l4              https://doi.org/10.48670/moi-00149
    %       SSH(equivalent) : SEALEVEL_GLO_PHY_L4_NRT_008_046                   cmems_obs-sl_glo_phy-ssh_nrt_allsat-l4-duacs-0.25deg_P1D   https://doi.org/10.48670/moi-00149
    %       ADT             : SEALEVEL_GLO_PHY_L4_MY_008_047                    cmems_obs-sl_glo_phy-ssh_my_allsat-l4-duacs-0.25deg_P1D    https://doi.org/10.48670/moi-00148
    %       SST(FVCOM_SCS)  : SST_GLO_SST_L4_NRT_OBSERVATIONS_010_001           METOFFICE-GLO-SST-L4-NRT-OBS-SST-V2                        https://doi.org/10.48670/moi-00165
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
    