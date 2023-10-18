% Mbaysalt_toolbox (Author: Christmas, Dovelet, Qidi Ma)
% Version 0.1  2023-03-01
% Version 1.0  2023-10-18
%
% This toolbox is used to postpocess model data and draw pictures.
% The model data is from original FVCOM, original NEMURO, Standard WAVE WATCH III, Standard WRF, and so on.
% Data annotation is written by Christmas Z. and Other baysalt members.
%
% Toolbox contents
%
%    Contents.m                          -  This file
%
%
%                           Infunctions  -  Internal functions for drawing pictures
% =================================================================================================================
%    cell_del_empty.m                    -  Delete empty cell
%    char_to_logical.m                   -  Convert char to logical
%    del_quotation.m                     -  Delete quotation from a string
%    grep.m                              -  Grep something from a file
%    input_yn.m                          -  Check input yes or no
%    is_number.m                         -  Check if a string is a number with regexp
%    isexist_var.m                       -  Check whether assigned variable, if not, assign default value
%    json_load.m                         -  Load json file with matlab builtin function or jsonlab
%    json_to_struct.m                    -  Convert json to struct
%    KeyValue2Struct.m                   -  Convert key-value to struct
%    list_to_cell.m                      -  Convert list to cell
%    makedirs.m                          -  Check and make directories
%    nr.m                                -  Read netcdf, the same as ncread
%    osprint.m                           -  YYYY-MM-DD HH:MM:SS --> string
%    osprints.m                          -  YYYY-MM-DD HH:MM:SS --> INFO: string
%    read_conf.m                         -  Read config file from Configfiles
%    replace_para.m                      -  Replace parameters in a string or struct
%    rmfiles.m                           -  Delete files or directories
%    split_dir.m                         -  Split directory from a file
%    split_path.m                        -  Delete the last '/' from a path
%
%
%                          Prefunctions  -  Prefunctions for drawing pictures
% =================================================================================================================
%    interp_colormap.m                   -  Interpolate colormap || By Jiaqi Dou
%    ll_to_ll_180.m                      -  Convert lat/lon to lat/lon -180-180
%    ll_to_ll_360.m                      -  Convert lat/lon to lat/lon 0-360
%    ll_to_ll.m                          -  Convert lat/lon to lat/lon 0-360/-180-180, auto select
%    make_colormap.m                     -  Make colormap for drawing
%    make_typhoon_warningline.m          -  Make typhoon warning line
%    region_cutout.m                     -  Cutout region from a matrix
%    select_proj_s_ll.m                  -  Select projection/lat/lon
%
%
%                          Picfunctions  -  Functions for drawing pictures
% =================================================================================================================
%                              Atmosphere pictures
%    Pic_draw_wind.m                     -  Draw wind vector picture
%    Pic_draw_precipitation.m            -  Draw precipitation picture
%
%                                    Wave pictures
%    Pic_draw_swh.m                      -  Draw significant wave height picture
%    Pic_draw_mwp.m                      -  Draw mean wave period picture
%
%                                 Current pictures
%    Pic_draw_current.m                  -  Draw current vector picture daily/hourly
%
%
%                            Post_fvcom  -  Functions for handling FVCOM triangle data
% =================================================================================================================
%    make_mask_depth_data.m              -  Make mask to mask the data which is deeper than the grid depth(for 'mask_depth_data.m')
%    mask_depth_data.m                   -  mask the data with the Standard_depth_mask(from the function of "make_mask_depth_data.m")
%    make_maskmat.m                      -  make mask mat file from gebco nc file(for 'mask2data.m')
%    mask2data.m                         -  mask the data with the mask(from the function of "mask_maskmat,m")
%    Postprocess_fvcom_old.m             -  Read and postprocess fvcom triangle data, contains daily/hourly (not recommend)
%    Postprocess_fvcom.m                 -  Read and postprocess fvcom triangle data, contains daily/hourly
%    Postprocess_nemuro.m                -  Read and postprocess nemuro triangle data, contains daily/hourly
%    read_conf_fvcom.m                   -  Read config file for Post_fvcom (not recommend)
%    siglay_to_3d.m                      -  Convert sigma layer to 3d depth for fvcom
%    standard_filename.m                 -  Standard filename from variable matrix
%    time_to_TIME.m                      -  To get TIME from time
%    +griddata_fvcom                     -  Packages of functions for handling FVCOM griddata by Christmas
%       griddata_current_uv.m            -  Griddata current triangle data, contains u/v
%       griddata_current_uvw.m           -  Griddata current triangle data, contains u/v/w
%       griddata_current.m               -  Griddata current triangle data, auto select u/v/w or u/v
%       griddata_nele.m                  -  Griddata nele triangle data
%       griddata_node.m                  -  Griddata several kinds of node triangle data without zeta
%       griddata_tsz.m                   -  Griddata temperature/salinity/zeta triangle data
%
%
%                            Post_ww3    -  Functions for handling ww3 data
% =================================================================================================================
%    erosion_coast_cal_id.m              -  Calculate the erosion of the coast id
%    erosion_coast_via_id.m              -  Erosion of the coast via id
%    read_msh.m                          -  Read msh file for ww3
%    write_msh.m                         -  Write msh file for ww3
%
%
%                            Post_tpxo   -  Functions for handling tpxo data
% =================================================================================================================
%    get_tpxo_filepath.m                 -  Get the tpxo filepath json file
%    make_tide_from_tpxo.m               -  Make tide current u/v/h from TPXO9-atlas, and write to nc file.
%    make_tpxo_fixed_coordinate.m        -  Fixed the coordinate of TPX09_atlas to lon_u, lat_u
%    preuvh.m                            -  Predict the tide u/v/h with tpxo and t_tide
%    tpxo_file.json                      -  Json file for tpxo file path
%    tpxo.conf                           -  Config file for tpxo
%    uvhap.m                             -  Calculate the u/v of the tidal harmonic analysis
%
%
%                      Post_wrf2fvcom    -  Functions for handling wrf2fvcom data
% =================================================================================================================
%    Postprocess_wrf2fvcom_domain.m      -  Read and postprocess wrf2fvcom data to standard format
%    make_domain_ll.m                    -  Read and make grid from wrf2fvcom domain file
%
%
%                         Mainfunctions  -  Functions for drawing pictures
% =================================================================================================================
%    Mainpath.m                          -  Set main path for toolbox
%
%
%                         Gridfunctions  -  Functions for model grid
% =================================================================================================================
%    read_GMT_to_cst.m                   -  Transform GMT/ACSII Coastline data imported by GEODAS to SMS's cst format
%    read_2dm_to_msh.m                   -  Read 2dm mesh to msh format for Wave Watch III
%    read_2dm_to_website.m               -  Read 2dm mesh to website format for www.iocean.cn
%    read_gebco_to_sms.m                 -  Read gebco bathymetry to sms format
%
%
%                         Readfunctions  -  Functions for reading data
% =================================================================================================================
%    ncread_llt_v.m                      -  Read netcdf file contains lat/lon/time, several variables
%    ncread_lltd_v.m                     -  Read netcdf file contains lat/lon/time/depth, several variables
%    read_ncfile_lldtv.m                 -  Read netcdf file contains lat/lon/time/depth/variable
%
%
%                            Ncfunctions  -  Functions for netcdf
% =================================================================================================================
%       create_nc.m                      -  Create NETCDF file as input
%    +netcdf_fvcom                       -  Packages of functions for handling FVCOM netcdf file
%       wrnc_adt.m                       -  Write adt netcdf file
%       wrnc_current.m                   -  Write current netcdf file at standard level or sigma level
%       wrnc_ice.m                       -  Write ice netcdf file
%       wrnc_salt.m                      -  Write sea salinity netcdf file at standard level or sigma level
%       wrnc_temp.m                      -  Write sea temperature netcdf file at standard level or sigma level
%       wrnc_chlo_ersem.m                -  Write chlorophyll netcdf file from ERSEM
%       wrnc_ph_ersem.m                  -  Write pH netcdf file from ERSEM
%       wrnc_no3_ersem.m                 -  Write nitrate netcdf file from ERSEM
%       wrnc_pco2_ersem.m                -  Write pCO2 netcdf file from ERSEM
%
%    +netcdf_nemuro                      -  Packages of functions for handling NEMURO netcdf file
%       wrnc_chlorophyll.m               -  Write numuro chlorophyll netcdf file
%       wrnc_no3.m                       -  Write numuro NO3 netcdf file
%       wrnc_phytoplankton.m             -  Write numuro phytoplankton netcdf file
%       wrnc_sand.m                      -  Write numuro sand netcdf file
%       wrnc_zooplankton.m               -  Write numuro zooplankton netcdf file
%    +netcdf_tpxo                        -  Packages of functions for handling TPXO netcdf file
%       wrnc_tpxo.m                      -  Write tpxo netcdf file
%    +netcdf_wrf                         -  Packages of functions for handling WRF netcdf file
%       wrnc_t2m.m                       -  Write WRF t2m netcdf file
%       wrnc_wind10m.m                   -  Write WRF wind10m netcdf file
%
%
%                            Inputfiles  -  Input files for toolbox
% =================================================================================================================
%    color_precipitation.mat             -  Color matrix for precipitation
%
%
%                           Configfiles  -  Config files for toolbox
% =================================================================================================================
%    Dimensions.conf                     -  Config file for Matesetfunctions/+Mateset/get_Dimensions_from_nc
%    Grid_functions.conf                 -  Config file for Gridfunctions
%    Pic_draw.conf                       -  Config file for Picfunctions
%    Post_fvcom.conf                     -  Config file for Post_fvcom/Postprocess_fvcom
%    Post_fvcom_old.conf                 -  Config file for Post_fvcom/Postprocess_fvcom_old (not recommend)
%    Post_nemuro.conf                    -  Config file for Post_fvcom/Postprocess_nemuro
%    Read_file.conf                      -  Config file for Readfunctions/read_ncfile_lltdv
%
%
%                              Examples  -  Examples for toolbox
% =================================================================================================================
%    Example_erosion                     -  Example for erosion coast cal id
%    Example_matFigure.m                 -  Example for matFigure
%    Example_matFVCOM_interp_ESMF.m      -  Example for matFVCOM interp ESMF
%    Example_matFVCOM_interp_MATLAB.m    -  Example for matFVCOM interp MATLAB
%    Example_read_nc_lldtv.m             -  Example for read nc lldtv
%
%
%                      Matesetfunctions  -  Functions for Mateset
% =================================================================================================================
%    Mateset.m                           -  Mateset class
%    +Mateset:
%       Mdatetime.m                      -  Mateset datetime class
%       get_Dimensions_from_nc.m         -  Get dimensions from nc file
%       get_Variables_from_nc.m          -  Get variables from nc file
%
%
%                           Exfunctions  -  External functions for toolbox
% =================================================================================================================
%    git_clone.sh                        -  Clone git repository
%    cprintf                             -  Color printf                      ||  https://www.mathworks.com/matlabcentral/fileexchange/24093-cprintf-display-formatted-colored-text-in-the-command-window
%    INI                                 -  INI toolbox                       ||  https://ww2.mathworks.cn/matlabcentral/fileexchange/55766-ini
%    iniconfig                           -  INI Config toolbox                ||  https://ww2.mathworks.cn/matlabcentral/fileexchange/24992-ini-config
%    inifile                             -  INFILE toolbox                    ||  https://ww2.mathworks.cn/matlabcentral/fileexchange/2976-inifile
%    matFigure                           -  Figure toolbox                    ||  https://github.com/SiqiLiOcean/matFigure
%    matFVCOM                            -  FVCOM toolbox                     ||  https://github.com/SiqiLiOcean/matFVCOM
%    matNC                               -  NetCDF toolbox                    ||  https://github.com/SiqiLiOcean/matNC
%    matWRF                              -  WRF toolbox                       ||  https://github.com/SiqiLiOcean/matWRF
%    struct2ini                          -  struct2ini toolbox                ||  https://ww2.mathworks.cn/matlabcentral/fileexchange/22079-struct2ini
%    m_map                               -  m_map toolbox                     ||  https://www.eoas.ubc.ca/~rich/map.html
%    CDT                                 -  Climate Data Toolbox              ||  https://github.com/chadagreene/CDT
%    t_tide                              -  T_Tide Harmonic Analysis Toolbox  || https://www.eoas.ubc.ca/~rich/#T_Tide
%
%                                  Extend  Exfunctions
%    matWRF                               -  Extend matWRF toolbox
%        calc_rh2.m                       -  Calculate relative humidity from temperature and dew point at 2m
%                            
%
%
%                                    Py  -  Python scripts for toolbox
% =================================================================================================================
%    Postprocess_fvcom.py                -  Postprocess fvcom triangle data, contains daily/hourly
%
%
%
% Author        :  Christmas, Dovelet, Qidi Ma
% Organization  :  Ocean University of China, Qingdao, China 
% Email         :  273519355@qq.com
% Website       :  https://www.iocean.cn  (visualization)
%                  https://data.iocean.cn (database)

