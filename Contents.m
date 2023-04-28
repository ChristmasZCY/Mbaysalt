% Mbaysalt_toolbox (Author: Christmas, Dovelet, Qidi Ma)
% Version 0.1  Mar-2023
%
% This toolbox is used to postpocess model data and draw pictures.
% The model data is from original FVCOM, original NEMURO, Standard WAVE WATCH III, Standard WRF.
% Data annotation is written by Christmas Z. and Other baysalt members.
%
% Toolbox contents
%
%    Contents.m                          -  This file
%
%
%                           Infunctions  -  Internal functions for drawing pictures
% =================================================================================================================
%    grep.m                              -  Grep something from a file
%    split_dir.m                         -  Split directory from a file
%    makedirs.m                          -  Check and make directories
%    rmfiles.m                           -  Delete files or directories
%    char_to_logical.m                   -  Convert char to logical
%    osprint.m                           -  YYYY-MM-DD HH:MM:SS --> string
%    osprints.m                          -  YYYY-MM-DD HH:MM:SS --> INFO: string
%    read_conf.m                         -  Read config file from Configfiles
%    json_to_struct.m                    -  Convert json to struct
%    KeyValue2Struct.m                   -  Convert key-value to struct
%    list_to_cell.m                      -  Convert list to cell
%    cell_del_empty.m                    -  Delete empty cell
%    json_load.m                         -  Load json file with matlab builtin function or jsonlab
%    del_quotation.m                     -  Delete quotation from a string
%    is_number.m                         -  Check if a string is a number with regexp
%    split_path.m                        -  Delete the last '/' from a path
%    nr.m                                -  Read netcdf, the same as ncread
%    isexist_var.m                       -  Check whether assigned variable, if not, assign default value
%    replacd_para.m                      -  Replace parameters in a string or struct
%
%
%                          Prefunctions  -  Prefunctions for drawing pictures
% =================================================================================================================
%    make_colormap.m                     -  Make colormap for drawing
%    make_typhoon_warningline.m          -  Make typhoon warning line
%    ncread_llt_v.m                      -  Read netcdf file contains lat/lon/time, several variables
%    ncread_lltd_v.m                     -  Read netcdf file contains lat/lon/time/depth, several variables
%    region_cutout.m                     -  Cutout region from a matrix
%    select_proj_s_ll.m                  -  Select projection/lat/lon
%    ll_to_ll.m                          -  Convert lat/lon to lat/lon 0-360/-180-180, auto select
%    ll_to_ll_180.m                      -  Convert lat/lon to lat/lon -180-180
%    ll_to_ll_360.m                      -  Convert lat/lon to lat/lon 0-360
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
%    Postprocess_fvcom.m                 -  Read and postprocess fvcom triangle data, contains daily/hourly
%    Postprocess_nemuro.m                -  Read and postprocess nemuro triangle data, contains daily/hourly
%    +griddata_fvcom                     -  Packages of functions for handling FVCOM griddata by Christmas
%       griddata_node.m                  -  Griddata node triangle data
%       griddata_nele.m                  -  Griddata nele triangle data
%       griddata_current.m               -  Griddata current triangle data, auto select u/v/w or u/v
%       griddata_current_uvw.m           -  Griddata current triangle data, contains u/v/w
%       griddata_current_uv.m            -  Griddata current triangle data, contains u/v
%       griddata_node.m                  -  Griddata several kinds of node triangle data without zeta
%       griddata_tsz.m                   -  Griddata temperature/salinity/zeta triangle data
%    read_conf_fvcom.m                   -  Read config file for Post_fvcom (not recommend)
%    make_maskmat.m                      -  Make mask matrix for griddata land
%    mask2data.m                         -  Mask the data with the mask
%    standard_filename.m                 -  Standard filename from variable matrix
%    time_to_TIME.m                      -  To get TIME from time
%    siglay_to_3d.m                      -  Convert sigma layer to 3d depth for fvcom
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
%    uvhap.m                             -  Calculate the u/v of the tidal harmonic analysis
%    preuvh.m                            -  Predict the tide u/v/h with tpxo and t_tide
%    make_tpxo_fixed_coordinate.m        -  Fixed the coordinate of TPX09_atlas to lon_u, lat_u
%    get_tpxo_filepath.m                 -  Get the tpxo filepath json file
%
%
%                         Mainfunctions  -  Functions for drawing pictures
% =================================================================================================================
%    Mainpath.m                          -  Set main path for toolbox
%
%
%                         Gridfunctions  -  Functions for model grid
% =================================================================================================================
%    read_gebco_to_sms.m                 -  Read gebco bathymetry to sms format
%    read_2dm_to_msh.m                   -  Read 2dm mesh to msh format for Wave Watch III
%    read_2dm_to_website.m               -  Read 2dm mesh to website format for www.iocean.cn
%
%
%                         Readfunctions  -  Functions for reading data
% =================================================================================================================
%     read_ncfile.m                      -  Read netcdf file
%     read_ncfile_lltdv.m                -  Read netcdf file contains lat/lon/time/depth, several variables
    %     read_ncfile_att.m                  -  Read netcdf file attributes
%
%
%                            Ncfunctions  -  Functions for netcdf
% =================================================================================================================
%    +netcdf_fvcom                       -  Packages of functions for handling FVCOM netcdf file
%       create_nc.m                      -  Create NETCDF4 file
%       wrnc_current.m                   -  Write current netcdf file, auto select u/v/w or u/v
%       wrnc_current_uvw.m               -  Write current netcdf file u/v/w
%       wrnc_current_uv.m                -  Write current netcdf file u/v
%       wrnc_temp.m                      -  Write sea temperature netcdf file
%       wrnc_salt.m                      -  Write sea salinity netcdf file
%       wrnc_adt.m                       -  Write adt netcdf file
%    +netcdf_nemuro                      -  Packages of functions for handling NEMURO netcdf file
%       wrnc_chlorophyll.m               -  Write numuro chlorophyll netcdf file
%       wrnc_no3.m                       -  Write numuro NO3 netcdf file
%       wrnc_phytoplankton.m             -  Write numuro phytoplankton netcdf file
%       wrnc_zooplankton.m               -  Write numuro zooplankton netcdf file
%       wrnc_sand.m                      -  Write numuro sand netcdf file
%    +netcdf_tpxo                        -  Packages of functions for handling TPXO netcdf file
%       wrnc_tpxo.m                      -  Write tpxo netcdf file
%
%
%                            Inputfiles  -  Input files for toolbox
% =================================================================================================================
%    color_precipitation.mat             -  Color matrix for precipitation
%
%
%                           Configfiles  -  Config files for toolbox
% =================================================================================================================
%    Pic_draw.conf                       -  Config file for Picfunctions
%    Post_fvcom.conf                     -  Config file for Post_fvcom/Postprocess_fvcom
%    Post_nemuro.conf                    -  Config file for Post_fvcom/Postprocess_nemuro
%    Grid_functions.conf                 -  Config file for Gridfunctions
%
%
%                              Examples  -  Examples for toolbox
% =================================================================================================================
%    Example_matFVCOM_interp_ESMF.m      -  Example for matFVCOM interp ESMF
%    Example_matFVCOM_interp_MATLAB.m    -  Example for matFVCOM interp MATLAB
%    Example_matFigure.m                 -  Example for matFigure
%
%
%                           Exfunctions  -  External functions for toolbox
% =================================================================================================================
%    git_clone.sh                        -  Clone git repository
%    m_map                               -  Mapping toolbox       ||  https://www.eoas.ubc.ca/~rich/map.html
%    cprintf                             -  Color printf          ||  https://www.mathworks.com/matlabcentral/fileexchange/24093-cprintf-display-formatted-colored-text-in-the-command-window
%    matFVCOM                            -  FVCOM toolbox         ||  https://github.com/SiqiLiOcean/matFVCOM
%    matFigure                           -  Figure toolbox        ||  https://github.com/SiqiLiOcean/matFigure
%    CDT                                 -  Climate Data Toolbox  ||  https://github.com/chadagreene/CDT
%
%                                  Extend  Exfunctions
%    matFVCOM                            -  Extend FVCOM toolbox  
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

