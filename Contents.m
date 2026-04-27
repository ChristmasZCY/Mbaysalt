% Mbaysalt Toolbox
% Version 2.6.0 (R2025b) 2026-04-01
% =================================================================================================================
% Version 0.1   (R2023b) 2023-03-01   (Created by Christmas, Dovelet, Qidi Ma)
% Version 1.0   (R2023b) 2023-10-18   (Fixed by Christmas)
% Version 2.0   (R2023b) 2023-11-22   (Fixed by Christmas)    --->  Release: <https://github.com/ChristmasZCY/Mbaysalt/releases/tag/release-v2.0>
% Version 2.1   (R2023b) 2023-12-27   (Modified by Christmas)
% Version 2.2   (R2023b) 2024-01-31   (Modified by Christmas) --->  Release: <https://github.com/ChristmasZCY/Mbaysalt/releases/tag/release-v2.2>
% Version 2.3   (R2024a) 2024-04-04   (Modified by Christmas) --->  Release: <https://github.com/ChristmasZCY/Mbaysalt/releases/tag/release-v2.3>
% Version 2.4   (R2024a) 2024-07-26   (Modified by Christmas) --->  Release: <https://github.com/ChristmasZCY/Mbaysalt/releases/tag/release-v2.4>
% Version 2.5   (R2024b) 2024-12-09   (Modified by Christmas) --->  Release: <https://github.com/ChristmasZCY/Mbaysalt/releases/tag/v2.5>
% Version 2.6.0 (R2025b) 2026-04-01   (Modified by Christmas) --->  Release: <https://github.com/ChristmasZCY/Mbaysalt/releases/tag/v2.6.0>
%
% This toolbox is used to postpocess model data and draw pictures.
% The model data is from FVCOM, NEMURO, ERSEM, WAVE WATCH III, WRF, MITgcm and so on.
% Data annotation is written by Christmas Z. and other baysalt members.
%
% =================================================================================================================
%
% Toolbox contents
%
%   install.sh                                  -  Install the toolbox
%   Contents.m                                  -  This file
%   ST_Mbaysalt.m                               -  Set toolbox path
%   Mainpath.m                                  -  Set main path for toolbox (not recommend)
%   README.md                                   -  README file
%   README_zh.md                                -  README file in Chinese
%   functionSignatures.json                     -  Function signatures for toolbox
%
%
%                                  Infunctions  -  Internal functions for toolbox
% -----------------------------------------------------------------------------------------------------------------
%   functionSignatures.json                     -  Function signatures for this folder
%   calc_barrierlayer.m                         -  Calculate the barrier layer thickness and depth
%   calc_casfco2.m                              -  Calculate the casfco2, thr windSpeed SST SSS, teached by Lijun Song
%   calc_contour_area.m                         -  Calculate the area of the contour
%   calc_geodistance.m                          -  Calculate the geodistance between arrays of lon/lat
%   calc_geodistance_readme.mlx                 -  README for Calculate the geodistance between arrays of lon/lat
%   calc_nearest_node.m                         -  Calculate the nearest node and distance from FVCOM grid
%   calc_scale_offset.m                         -  Calculate the scale and offset for netcdf variable
%   calc_sd2uv                                  -  Calculate speed and direction to vector velocity
%   calc_sound_speed.m                          -  Calculate sound speed using Del Grosso (1974) empirical formula
%   calc_thermocline.m                          -  Calculate the thermocline strength, thickness, upper bound, lower bound
%   calc_timeStepFVCOM.m                        -  Calculate FVCOM time step
%   calc_timeStepWW3.m                          -  Calculate WW3 time step
%   calc_tri_area.m                             -  Calculate triangle area by length of side
%   calc_typhoon_adjust_winddir.m               -  Adjust the wind direction at typhoon
%   calc_typhoon_adjust_winddir_readme.mlx      -  README for Adjust the wind direction at typhoon
%   calc_typhoon_overlayWind.m                  -  Overlay wind by Model windSpeed and Grid windSpeed (such as Holland and ERA5)
%   calc_typhoon_overlayWind_readme.mlx         -  README for Overlay wind by Model windSpeed and Grid windSpeed (such as Holland and ERA5)
%   calc_typhoon_windHolland.m                  -  Calculate the wind by Holland model
%   calc_typhoon_windHolland_readme.mlx         -  README for ACalculate the wind by Holland model
%   calc_typhoonMove.m                          -  Calculate the typhoon move
%   calc_uv2sd                                  -  Calculate velocity to speed and direction
%   calc_validation.m                           -  Calculate the validation of the model
%   calc_waveSpeed.m                            -  Calculate wave speed and length
%   calc_weather_front.m                        -  Calculate the weather front from temperature and salinity
%   checkOS.m                                   -  Check the system OS
%   clm.m                                       -  Clear clc clf close all
%   closefile.m                                 -  Close all opened files
%   cm_disp2.m                                  -  Display the MATLAB colormap
%   convert_avi2mp4.m                           -  Convert avi to mp4
%   convert_png2gif.m                           -  Convert pngs to gif
%   convert_png2mp4.m                           -  Convert pngs to mp4
%   create_timeRange.m                          -  Create datetime type time-Range
%   cutout_xy.m                                 -  Cutout small region from a large region
%   del_filesep.m                               -  Delete the last filesep from a path
%   del_quotation.m                             -  Delete quotation from a string
%   erosion_coast_cal_id.m                      -  Calculate the erosion of the coast id
%   erosion_coast_via_id.m                      -  Erosion of the coast via id
%   figcopy.m                                   -  Copy the figure to the clipboard
%   FVCOMTOOLS.m                                -  FVCOM tools functions
%   genNaNlegend.m                              -  Generate NaN legend
%   getGitHash.m                                -  Get git hash of the current code
%   getHome.m                                   -  Get home path
%   getPath.m                                   -  Get the path of file or folder
%   grep.m                                      -  Grep something from a file (not recommend)
%   input_yn.m                                  -  Check input yes or no
%   is_number.m                                 -  Check if a string is a number with regexp
%   isaequal.m                                  -  Approximate equality A, B(not support NaN)
%   json_load.m                                 -  Load json file with matlab builtin function or jsonlab
%   json_to_struct.m                            -  Convert json to struct
%   KeyValue2Struct.m                           -  Convert key-value to struct
%   len.m                                       -  As length
%   limit_var.m                                 -  Limit the variable in a range
%   listStr_to_cell.m                           -  Convert list str to cell
%   ll.m                                        -  Simulated ll command in linux
%   ln.m                                        -  Simulate the ln command in linux
%   lodadata.m                                  -  Load data from a file
%   c_load_model.m                              -  Load model data
%   m_mesh.m                                    -  Draw mesh at m_map
%   makedepends.m                               -  Make depends for a function
%   makedirs.m                                  -  Check and make directories
%   Mncload.m                                   -  Read netcdf, the same as ncload
%   nr.m                                        -  Read netcdf, the same as ncread
%   osprint.m                                   -  YYYY-MM-DD HH:MM:SS --> string
%   osprint2.m                                  -  YYYY-MM-DD HH:MM:SS --> INFO: string
%   parfor_pgb.m                                -  parfor progress bar
%   plot_markerTY.m                             -  Plot marker for typhoon
%   read_conf.m                                 -  Read config file from Configfiles
%   read_nml_fvcom.m                            -  Read FVCOM NML file
%   readlink.m                                  -  Simulation of unix command "readlink"
%   replace_para.m                              -  Replace parameters in a string or struct
%   rmfiles.m                                   -  Delete files or directories
%   set_proxy.m                                 -  Set proxy by system command
%   write_nml_fvcom.m                           -  Write FVCOM NML file
%   zoom_ploygon.m                              -  Zoom the polygon
%
%
%                                 Prefunctions  -  Prefunctions for drawing pictures
% -----------------------------------------------------------------------------------------------------------------
%   functionSignatures.json                     -  Function signatures for this folder
%   interp_colormap.m                           -  Interpolate colormap || By Jiaqi Dou
%   make_colormap.m                             -  Make colormap for drawing
%   make_typhoon_warningline.m                  -  Make typhoon warning line
%   region_cutout.m                             -  Cutout region from a matrix
%   select_proj_s_ll.m                          -  Select projection/lat/lon
%
%
%                                 Mapfunctions  -  Functions for dealing with map
% -----------------------------------------------------------------------------------------------------------------
%   functionSignatures.json                     -  Function signatures for this folder
%   ecef_distance.m                             -  Calculate cartesian ECEF offset between geodetic coordinates
%   geo_ecef.m                                  -  Transform geocentric Earth-centered Earth-fixed coordinates to geodetic or reverse
%   geo_xy.m                                    -  Convert lat/lon to x/y or x/y to lat/lon
%   ll_to_ll.m                                  -  Convert lat/lon to lat/lon 0-360/-180-180, auto select
%   ll_to_ll_180.m                              -  Convert lat/lon to lat/lon -180-180
%   ll_to_ll_360.m                              -  Convert lat/lon to lat/lon 0-360
%
%
%                                 Picfunctions  -  Functions for drawing pictures
% -----------------------------------------------------------------------------------------------------------------
%   functionSignatures.json                     -  Function signatures for this folder
%   Pic_draw_current.m                          -  Draw current vector picture daily/hourly
%   Pic_draw_mwp.m                              -  Draw mean wave period picture
%   Pic_draw_precipitation.m                    -  Draw precipitation picture
%   Pic_draw_slp.m                              -  Draw sea level pressure picture
%   Pic_draw_swh.m                              -  Draw significant wave height picture
%   Pic_draw_wind.m                             -  Draw wind vector picture
%   Pic_draw_wind_10m                           -  Draw wind velocity at 10m picture
%
%
%                                   Post_fvcom  -  Functions for handling FVCOM triangle data
% -----------------------------------------------------------------------------------------------------------------
%   functionSignatures.json                     -  Function signatures for this folder
%   make_mask_depth_data.m                      -  Make mask to mask the data which is deeper than the grid depth(for 'mask_depth_data.m')
%   mask2data.m                                 -  mask the data with the mask(from the function of "mask_maskmat,m")
%   mask_depth_data.m                           -  mask the data with the Standard_depth_mask(from the function of "make_mask_depth_data.m")
%   Postprocess_fvcom.m                         -  Read and postprocess fvcom triangle data, contains daily/hourly
%   standard_filename.m                         -  Standard filename from variable matrix
%   time_to_TIME.m                              -  To get TIME from time
%
%
%                                    Post_tpxo  -  Functions for handling tpxo data
% -----------------------------------------------------------------------------------------------------------------
%   functionSignatures.json                     -  Function signatures for this folder
%   preuvh2.m                                   -  Predict the tidal current velocity or elevation at a given time
%   ABANDON
%       functionSignatures.json                 -  Function signatures for this folder
%       get_tpxo_filepath.m                     -  Get the tpxo filepath json file
%       make_tide_from_tpxo.m                   -  Make tide current u/v/h from TPXO9-atlas, and write to nc file.
%       make_tpxo_fixed_coordinate.m            -  Fixed the coordinate of TPX09_atlas to lon_u, lat_u
%       preuvh.m                                -  Predict the tide u/v/h with tpxo and t_tide
%       tpxo.conf                               -  Config file for tpxo
%       tpxo_file.json                          -  Json file for tpxo file path
%       uvhap.m                                 -  Calculate the u/v of the tidal harmonic analysis
%
%
%                               Post_wrf2fvcom  -  Functions for handling wrf2fvcom data
% -----------------------------------------------------------------------------------------------------------------
%   functionSignatures.json                     -  Function signatures for this folder
%   make_domain_ll.m                            -  Read and make grid from wrf2fvcom domain file
%   Postprocess_wrf2fvcom_domain.m              -  Read and postprocess wrf2fvcom data to standard format
%
%
%                                   Post_mitgcm -  Functions for handling mitgcm data
% -----------------------------------------------------------------------------------------------------------------
%   functionSignatures.json                     -  Function signatures for this folder
%   Postprocess_MITgcm.m                        -  Read and postprocess mitgcm data to standard format
%
%
%                                Gridfunctions  -  Functions for model grid
% -----------------------------------------------------------------------------------------------------------------
%   functionSignatures.json                     -  Function signatures for this folder
%   convert_dat22dm.m                           -  Convert FVCOM dat to 2dm
%   convert_shp2cst.m                           -  Convert shapefile to cst file, contains merging polygons
%   gshhs2.m                                    -  Fixed gshhs only for [-180 195], gshhs2 for [-540 540]
%   gshhsb2cst.m                                -  Convert GSHHS binary to cst, producingOriginalFormat() by Siqi Li
%   merge_cst.m                                 -  Merge cst files  --> convert_shp2cst.m
%   merge_polygon.m                             -  Merge polygons   --> convert_shp2cst.m
%   read_2dm_to_website.m                       -  Read 2dm mesh to website format for www.iocean.cn
%   read_gebco_to_sms.m                         -  Read gebco bathymetry to sms format
%   read_GMT_to_cst.m                           -  Transform GMT/ACSII Coastline data imported by GEODAS to SMS's cst format
%   read_mike_mesh.m                            -  Read MIKE21 mesh file
%   read_msh.m                                  -  Read msh file for WW3
%   read_sms_grd.m                              -  Read sms grd file
%   read_vtk.m                                  -  Read vtk file
%   write_mike_mesh.m                           -  Write MIKE21 mesh file
%   write_msh.m                                 -  Write msh file for ww3
%   write_sms_grd.m                             -  Write sms grd file
%   write_vtk.m                                 -  Write vtk file
%
%
%                                Readfunctions  -  Functions for reading data
% -----------------------------------------------------------------------------------------------------------------
%   functionSignatures.json                     -  Function signatures for this folder
%   ncread_llt_v.m                              -  Read netcdf file contains lat/lon/time, several variables
%   ncread_lltd_v.m                             -  Read netcdf file contains lat/lon/time/depth, several variables
%   read_ncfile_lldtv.m                         -  Read netcdf file contains lat/lon/time/depth/variable
%
%
%                                  Ncfunctions  -  Functions for netcdf
% -----------------------------------------------------------------------------------------------------------------
%   functionSignatures.json                     -  Function signatures for this folder
%   calc_dtype.m                                -  Calculate the data type for netcdf variable
%   calc_fillvalue.m                            -  Calculate the fill value for netcdf variable
%   create_nc.m                                 -  Create NETCDF file as input
%   isNetcdfFile.m                              -  Check if a file is a netcdf file
%   nc_attrName_exist.m                         -  Check if a netcdf file has a str at Attribute Name
%   nc_attrValue_exist.m                        -  Check if a netcdf file has a str at Attribute Value
%   nc_rename_var.m                             -  Rename variable in netcdf file
%   nc_var_exist.m                              -  Check if the variable exists in the nc file
%   +netcdf_fvcom                               -  Packages of functions for handling FVCOM netcdf file
%      attrs.json                               -  Attributes for tpxo netcdf file
%      write_met_mexcdf.m                       -  Write met netcdf file with mexcdf(Not test)
%      write_nesting_mexcdf.m                   -  Write nesting netcdf file with mexcdf
%      wrnc_adt.m                               -  Write adt netcdf file
%      wrnc_casfco2_ersem.m                     -  Write casfco2 netcdf file from ERSEM
%      wrnc_chlo_ersem.m                        -  Write chlorophyll netcdf file from ERSEM
%      wrnc_current.m                           -  Write current netcdf file at standard level or sigma level
%      wrnc_ice.m                               -  Write ice netcdf file
%      wrnc_no3_ersem.m                         -  Write nitrate netcdf file from ERSEM
%      wrnc_pco2_ersem.m                        -  Write pCO2 netcdf file from ERSEM
%      wrnc_ph_ersem.m                          -  Write pH netcdf file from ERSEM
%      wrnc_pp_nemuro.m                         -  Write phytoplankton netcdf file from NEMURO
%      wrnc_salt.m                              -  Write sea salinity netcdf file at standard level or sigma level
%      wrnc_sand_nemuro.m                       -  Write sand netcdf file from NEMURO
%      wrnc_temp.m                              -  Write sea temperature netcdf file at standard level or sigma level
%      wrnc_zp_nemuro.m                         -  Write zooplankton netcdf file from NEMURO
%   +netcdf_nemuro                              -  Packages of functions for handling NEMURO netcdf file(Not recommend, use netcdf_fvcom instead)
%      wrnc_chlorophyll.m                       -  Write numuro chlorophyll netcdf file
%      wrnc_no3.m                               -  Write numuro NO3 netcdf file
%      wrnc_phytoplankton.m                     -  Write numuro phytoplankton netcdf file
%      wrnc_sand.m                              -  Write numuro sand netcdf file
%      wrnc_zooplankton.m                       -  Write numuro zooplankton netcdf file
%   +netcdf_tpxo                                -  Packages of functions for handling TPXO netcdf file
%      attrs.json                               -  Attributes for tpxo netcdf file
%      wrnc_tpxo.m                              -  Write tpxo netcdf file
%   +netcdf_wrf                                 -  Packages of functions for handling WRF netcdf file
%      attrs.json                               -  Attributes for wrf netcdf file
%      wrnc_t2m.m                               -  Write WRF t2m netcdf file
%      wrnc_wind10m.m                           -  Write WRF wind10m netcdf file
%   +netcdf_ww3                                 -  Packages of functions for handling WW3 netcdf file
%      attrs.json                               -  Attributes for ww3 netcdf file
%      wrnc_wave.m                              -  Write wave netcdf file
%
%
%                               Mimetifunctions -  Functions to mimic other languages commands
% -----------------------------------------------------------------------------------------------------------------
%   functionSignatures.json                     -  Function signatures for this folder
%   copernicusmarine.m                          -  Copernicus Marine data download(mimic copernicusmarine)
%   gitc.m                                      -  Git command(mimic git)
%   touch.m                                     -  Touch command(mimic touch)
%
%                                   Inputfiles  -  Input files for toolbox
% -----------------------------------------------------------------------------------------------------------------
%   color_precipitation.mat                     -  Color matrix for precipitation
%
%
%                                    Savefiles  -  Save files for toolbox
% -----------------------------------------------------------------------------------------------------------------
%   None
%
%
%                               Configurefiles  -  Config files for toolbox
% -----------------------------------------------------------------------------------------------------------------
%   INSTALL.json                                -  Config file for INSTALL Mbaysalt_toolbox
%   Pic_draw.conf                               -  Config file for Picfunctions
%   Post_fvcom.conf                             -  Config file for Post_fvcom/Postprocess_fvcom
%   Post_mitgcm.conf                            -  Config file for Post_mitgcm/Postprocess_mitgcm
%   Post_wrf2fvcom.conf                         -  Config file for Post_wrf2fvcom/Postprocess_wrf2fvcom_domain
%
%
%                                     Examples  -  Examples for toolbox
% -----------------------------------------------------------------------------------------------------------------
%   example.vtk                                 -  Example of vtk file
%   Example_adjust_res.m                        -  Example for adjust lonlat-resolution
%   Example_calc_timeStep.m                     -  Example for calculate time step
%   Example_calculateV.m                        -  Example for calculate volume
%   Example_cdt.m                               -  Example for cdt
%   Example_check_depth.m                       -  Example for check depth
%   Example_draw_ersem.m                        -  Example for draw ersem
%   Example_draw_gfvcom_UHSLC_comparison.m      -  Example for draw gfvcom UHSLC comparison
%   Example_draw_global.m                       -  Example for draw global
%   Example_draw_hist_cloud.m                   -  Example for draw histogram and cloud
%   Example_draw_inu.m                          -  Example for draw inu
%   Example_draw_planet.m                       -  Example for draw planet
%   Example_draw_plot_bar.m                     -  Example for draw bar and plot
%   Example_draw_sst_ssh_sss.m                  -  Example for draw sst ssh sss
%   Example_draw_tide.m                         -  Example for draw tide
%   Example_draw_TMD.m                          -  Example for draw TMD tide
%   Example_draw_tsuvz.m                        -  Example for draw tsuvz(fvcom)
%   Example_draw_uv_avg.m                       -  Example for draw uv 0-300m avg
%   Example_draw_uv_Luwang.m                    -  Example for draw uv, teached by Luwang
%   Example_ellipse.m                           -  Example for ellipse
%   Example_erosion                             -  Example for erosion coast cal id
%   Example_export_fig.m                        -  Example for export_fig
%   Example_extract_cst_from_fgrid.m            -  Example for extract cst from fgrid
%   Example_filter.m                            -  Example for filter
%   Example_Holland.m                           -  Example for Holland wind model
%   Example_inpolygons.m                        -  Example for inpolygons
%   Example_kriging.m                           -  Example for kriging
%   Example_loaddata.m                          -  Example for loaddata
%   Example_matFVCOM.m                          -  Example for matFVCOM
%   Example_matFVCOM_interp_ESMF.m              -  Example for matFVCOM interp ESMF
%   Example_matFVCOM_interp_MATLAB.m            -  Example for matFVCOM interp MATLAB
%   Example_nctoolbox.m                         -  Example for nctoolbox
%   Example_predict_tide.m                         -  Example for predict tide with tpxo and t_tide
%   Example_py.m                                -  Example for matlab-python code
%   Example_read_draw_christmas.m               -  Example for read and draw by Christmas
%   Example_read_kml_xml.m                      -  Example for read kml xml (Uncompleted)
%   Example_read_nc_lldtv.m                     -  Example for read nc lldtv
%   Example_scaterdensity_Wcx.m                 -  Example for scatterdensity by Wcx
%   Example_taylordiag.m                        -  Example for taylordiag
%   Example_seawater.m                          -  Example for seawater toolbox
%   Example_smooth.m                            -  Example for smooth
%   Example_tidal_analysis.m                    -  Example for tidal analysis
%   Example_TMD.m                               -  Example for TMD toolbox
%   Example_WindRose.m                          -  Example for WindRose toolbox
%   FVCOM_DEFAULT.nml                           -  Example of FVCOM nml file
%   Post_bbw.conf                               -  Example for Post_fvcom/Postprocess_fvcom
%   Post_fvcom_scs.conf                         -  Example for Post_fvcom/Postprocess_fvcom
%   Post_gersem_v2.conf                         -  Example for Post_fvcom/Postprocess_fvcom
%   Post_gfvcom_v2.conf                         -  Example for Post_fvcom/Postprocess_fvcom
%   Post_nemuro.conf                            -  Example for Post_fvcom/Postprocess_fvcom
%   Post_Wenzhou.conf                           -  Example for Post_fvcom/Postprocess_fvcom
%   Post_Wenzhou_ww3.conf                       -  Example for Post_fvcom/Postprocess_fvcom
%   Post_WZAJinu.conf                           -  Example for Post_fvcom/Postprocess_fvcom
%   Post_WZtide3.conf                           -  Example for Post_fvcom/Postprocess_fvcom
%   stations.xml                                -  Example of xml file
%
%
%                             Matesetfunctions  -  Functions for Mateset
% -----------------------------------------------------------------------------------------------------------------
%   functionSignatures.json                     -  Function signatures for this folder
%   Mateset.m                                   -  Mateset class
%   +Mateset:
%      get_Dimensions_from_nc.m                 -  Get dimensions from nc file
%      get_Variables_from_nc.m                  -  Get variables from nc file
%   @Mdatetime                                  -  MATLAB datetime class
%   @Mdraw                                      -  MATLAB draw class
%   @Mgrid                                      -  MATLAB grid class
%
%
%                                     Callcodes - Call functions codes
% -----------------------------------------------------------------------------------------------------------------
%   functionSignatures.json                     -  Function signatures for this folder
%   BBW_add_lonlat.m                            -  Add lon lat to nc file for bbw
%   create_obc_from_MITgcmllc540.m              -  Create open boundary conditions from MITgcmllc540
%   WRFforcing2gcm.m                            -  Convert WRF forcing to gcm forcing
%   FVCOM_Bohai/                                -  FVCOM Bohai toolbox
%   FVCOM_ECS_2d_v2/                            -  FVCOM ECS 2d v2 toolbox
%   FVCOM_NSCS/                                 -  FVCOM NSCS toolbox
%   FVCOM_WZAJinu/                              -  FVCOM WZAJinu toolbox
%   FVCOM_WZinu3/                               -  FVCOM WZinu3 toolbox
%   FVCOM_WZtide3/                              -  FVCOM WZtide3 toolbox
%   gzh2html/                                   -  Convert gongzhonghao to html
%   Map2Gray/                                   -  download maptiles and transform to graytiles
%
%
%                                         Docs  -  Documents and Manuals for toolbox
% -----------------------------------------------------------------------------------------------------------------
%   Collect_dataset.html                        -  Collect dataset
%   Communication.md                            -  Communication
%   Holland_deduce.pdf                          -  Holland deduce PDF
%   Nctoolbox.zh.pdf                            -  Nctoolbox中文说明
%   OceanMesh2D.md                              -  OceanMesh2D
%   OceanMesh2D__User_Guide_20200912.pdf        -  OceanMesh2D使用说明
%   README_TMD.pdf                              -  TMD说明
%   M_map中文说明.pdf
%   M_map翻译和示例官方中文版.pdf
%   MATLAB气象海洋简单粗暴教程.pdf
%   Matlab读取气象海洋数据教程.pdf
%   t_tide中文版说明.pdf
%   t_tide软件包使用说明plus.md
%   Climate Data Toolbox中文说明.pdf
%   MATLAB、ArcGIS、SPSS和Excel在地学中的实践应用（Version6.0）-2020-04-27.pdf
%   pics/                                       -  Pictures for docs
%
%
%                                  Exfunctions  -  External functions for toolbox
% -----------------------------------------------------------------------------------------------------------------
%   %%  Github
%   ann_wrapper                  (optional)     -  ann_wrapper toolbox                         ||  https://github.com/shaibagon/ann_wrapper.git
%   CDT                          (optional)     -  Climate Data Toolbox                        ||  https://github.com/chadagreene/CDT
%   Course                       (optional)     -  Course                                      ||  https://github.com/SiqiLiOcean/Course
%   export_fig                   (optional)     -  export_fig toolbox                          ||  https://ww2.mathworks.cn/matlabcentral/fileexchange/23629-export_fig/
%   freezeColors                 (optional)     -  freezeColors                                ||  https://github.com/jiversen/freezeColors
%   funcsign                     (optional)     -  funcsign toolbox                            ||  https://gitee.com/iam002/funcsign.git
%   FVCOM_NML                    (optional)     -  FVCOM NML                                   ||  https://github.com/SiqiLiOcean/FVCOM_NML
%   FVCOMToolbox_v2              (optional)     -  fvcom-toolbox-new                           ||  https://gitea.iocean.cn/Christmas/FVCOMToolbox_v2
%   gcmfaces                     (optional)     -  gcmfaces toolbox                            ||  https://github.com/MITgcm/gcmfaces
%   genpath2                                    -  genpath2 toolbox                            ||  https://ww2.mathworks.cn/matlabcentral/fileexchange/72791-genpath2
%   googleearthtoolbox           (optional)     -  googleearthtoolbox toolbox                  ||  https://github.com/sverhoeven/googleearthtoolbox
%   htool                        (optional)     -  htool bash script                           ||  https://github.com/SiqiLiOcean/htool
%   HYCOM2FVCOM                  (optional)     -  Run fvcom with HYCOM data                   ||  https://github.com/SiqiLiOcean/HYCOM2FVCOM
%   inpoly                       (optional)     -  A fast 'point(s)-in-polygon' test           ||  https://github.com/dengwirda/inpoly
%   inpolygons-pkg               (optional)     -  inpolygons-pkg toolbox                      ||  https://ww2.mathworks.cn/matlabcentral/fileexchange/7187-inpolygons
%   ipi4d                        (optional)     -  ipi4d toolbox                               ||  https://github.com/mariosgeo/ipi4d
%   irfu-matlab                  (optional)     -  irfu-matlab toolbox                         ||  https://github.com/irfu/irfu-matlab
%   JSONLab                      (optional)     -  JSONLab toolbox                             ||  https://ww2.mathworks.cn/matlabcentral/fileexchange/33381-jsonlab | https://github.com/fangq/jsonlab | https://iso2mesh.sourceforge.net/cgi-bin/index.cgi?jsonlab
%   kml-toolbox                  (optional)     -  kml-toolbox toolbox                         ||  https://ww2.mathworks.cn/matlabcentral/fileexchange/34694-kml-toolbox
%   kmz2struct                   (optional)     -  kmz2struct toolbox                          ||  https://github.com/njellingson/kmz2struct
%   kriging                      (optional)     -  kriging toolbox                             ||  https://github.com/wschwanghart/kriging || https://ww2.mathworks.cn/matlabcentral/fileexchange/29025-ordinary-kriging
%   matFigure                    (optional)     -  Figure toolbox                              ||  https://github.com/SiqiLiOcean/matFigure
%   matFVCOM                     (optional)     -  FVCOM toolbox                               ||  https://github.com/SiqiLiOcean/matFVCOM
%   MATLAB-PLOT-CHEAT-SHEET      (optional)     -  MATLAB-PLOT-CHEAT-SHEET toolbox             ||  https://github.com/slandarer/MATLAB-PLOT-CHEAT-SHEET
%   matlab-schemer               (optional)     -  matlab-schemer                              ||  https://github.com/scottclowe/matlab-schemer
%   matlabPlotCheatsheet         (optional)     -  matlabPlotCheatsheet toolbox                ||  https://github.com/peijin94/matlabPlotCheatsheet
%   matNC                        (optional)     -  NetCDF toolbox                              ||  https://github.com/SiqiLiOcean/matNC
%   matWRF                       (optional)     -  WRF toolbox                                 ||  https://github.com/SiqiLiOcean/matWRF
%   MESH2D                       (optional)     -  MESH2D toolbox                              ||  https://github.com/dengwirda/mesh2d
%   mitgcm_toolbox               (optional)     -  mitgcm_toolbox                              ||  https://github.com/seamanticscience/mitgcm_toolbox
%   nctoolbox                    (optional)     -  NCTOOLBOX                                   ||  https://github.com/nctoolbox/nctoolbox | http://nctoolbox.github.io/nctoolbox/
%   OceanData                    (optional)     -  Compare with famous ocean data              ||  https://github.com/SiqiLiOcean/OceanData
%   ocean_data_tools             (optional)     -  ocean_data_tools toolbox                    ||  https://github.com/lnferris/ocean_data_tools
%   OceanMesh2D                  (optional)     -  OceanMesh2D toolbox                         ||  https://github.com/CHLNDDEV/OceanMesh2D.git
%   ParforProgMon                (optional)     -  Progress monitor for matlab parfor          ||  https://github.com/fsaxen/ParforProgMon || https://ww2.mathworks.cn/matlabcentral/fileexchange/71436-parfor-progress-monitor-progress-bar-v4?s_tid=srchtitle
%   plot_google_map              (optional)     -  plot_google_map toolbox                     ||  https://ww2.mathworks.cn/matlabcentral/fileexchange/27627-zoharby-plot_google_map || https://github.com/zoharby/plot_google_map
%   RPSstuff                     (optional)     -  RPSstuff toolbox                            ||  https://github.com/rsignell-usgs/RPSstuff
%   TMDToolbox_v2_5              (optional)     -  Tidal Model Driver                          ||  https://github.com/EarthAndSpaceResearch/TMD_Matlab_Toolbox_v2.5 | https://www.mathworks.com/matlabcentral/fileexchange/75599-tide-model-driver-tmd-version-2-5-toolbox-for-matlab
%   TMDToolbox_v3_0              (optional)     -  Tidal Model Driver                          ||  https://github.com/chadagreene/Tide-Model-Driver | https://www.mathworks.com/matlabcentral/fileexchange/133417-tide-model-driver-tmd-version-3-0
%   topotoolbox                  (optional)     -  TopoToolbox                                 ||  https://github.com/wschwanghart/topotoolbox
%   variogramfit                 (optional)     -  variogramfit toolbox                        ||  https://github.com/wschwanghart/variogramfit || https://ww2.mathworks.cn/matlabcentral/fileexchange/25948-variogramfit
%   visualization-cheat-sheet    (optional)     -  visualization-cheat-sheet toolbox           ||  https://github.com/mathworks/visualization-cheat-sheet
%   vtkToolbox                   (optional)     -  VTK toolbox                                 ||  https://ww2.mathworks.cn/matlabcentral/fileexchange/94993-vtktoolbox
%   WRF2FVCOM                    (optional)     -  Run fvcom with WRF data                     ||  https://github.com/SiqiLiOcean/WRF2FVCOM
%   WW3-tools                    (optional)     -  WW3-tools toolbox                           ||  https://github.com/NOAA-EMC/WW3-tools
%   yaml                         (optional)     -  yaml parser                                 ||  https://github.com/MartinKoch123/yaml
%   ZoomPlot                     (optional)     -  ZoomPlot toolbox                            ||  https://github.com/iqiukp/ZoomPlot-MATLAB
%
%   %% Download
%   dace                         (optional)     -  dace toolbox                                ||  https://www.omicron.dk/dace.html
%   DHIMIKE                      (optional)     -  DHIMIKE toolbox                             ||  https://github.com/DHI/DHI-MATLAB-Toolbox/
%   etopo1                       (optional)     -  ETOPO1                                      ||  https://www.ngdc.noaa.gov/mgg/global/global.html
%   gshhs                        (optional)     -  GSHHS                                       ||  https://www.ngdc.noaa.gov/mgg/shorelines/gshhs.html
%   GSW Oceanographic Toolbox    (optional)     -  GSW Oceanographic Toolbox                   ||  http://www.teos-10.org/software.htm
%   m_map                        (optional)     -  m_map toolbox(v1.4o)                        ||  https://www.eoas.ubc.ca/~rich/map.html  &&  https://www.eoas.ubc.ca/~rich/mapug.html
%   Mesh2d                       (optional)     -  Mesh2d toolbox                              ||  https://ww2.mathworks.cn/matlabcentral/fileexchange/25555-mesh2d-delaunay-based-unstructured-mesh-generation
%   mexcdf                       (optional)     -  mexcdf toolbox                              ||  https://mexcdf.sourceforge.net/index.php | https://sourceforge.net/p/mexcdf/svn/HEAD/tree/
%   seawater                     (optional)     -  seawater toolbox                            ||  https://www.cmar.csiro.au/datacentre/ext_docs/seawater.html
%   t_tide                       (optional)     -  T_Tide Harmonic Analysis Toolbox(v1.5beta)  ||  https://www.eoas.ubc.ca/~rich/#T_Tide
%   WindRose                     (optional)     -  WindRose toolbox                            ||  https://dpereira.asempyme.com/windrose/
%   ETOPO1_Bed_g_gmt4            (optional)     -  ETOPO1_Bed_g_gmt4.grd                       ||  https://www.ngdc.noaa.gov/mgg/global/relief/ETOPO1/data/bedrock/grid_registered/netcdf/ETOPO1_Bed_g_gmt4.grd.gz
%   ETOPO1_Ice_g_gmt4            (optional)     -  ETOPO1_Ice_g_gmt4.grd                       ||  https://www.ngdc.noaa.gov/mgg/global/relief/ETOPO1/data/ice_surface/grid_registered/netcdf/ETOPO1_Ice_g_gmt4.grd.gz
%
%   %% Builtin
%   cprintf                      (optional)     -  Color printf                                ||  https://www.mathworks.com/matlabcentral/fileexchange/24093-cprintf-display-formatted-colored-text-in-the-command-window
%   ellipse                      (optional)     -  ellipse                                     ||  https://ww2.mathworks.cn/matlabcentral/fileexchange/289-ellipse-m
%   genpath_exclude              (optional)     -  genpath_exclude                             ||  https://ww2.mathworks.cn/matlabcentral/fileexchange/22209-genpath_exclude
%   grabit                       (optional)     -  grabit                                      ||  https://ww2.mathworks.cn/matlabcentral/fileexchange/7173-grabit/files/grabit.m
%   guillaumemaze                (optional)     -  guillaumemaze                               ||  http://code.google.com/p/guillaumemaze/
%   IDW                          (optional)     -  Inverse Distance Weight toolbox             ||  https://ww2.mathworks.cn/matlabcentral/fileexchange/24477-inverse-distance-weight
%   INI                          (optional)     -  INI toolbox                                 ||  https://ww2.mathworks.cn/matlabcentral/fileexchange/55766-ini
%   iniconfig                    (optional)     -  INI Config toolbox                          ||  https://ww2.mathworks.cn/matlabcentral/fileexchange/24992-ini-config
%   inifile                      (optional)     -  INFILE toolbox                              ||  https://ww2.mathworks.cn/matlabcentral/fileexchange/2976-inifile
%   KrigingToolbox               (optional)     -  KrigingToolbox                              ||  https://ww2.mathworks.cn/matlabcentral/fileexchange/59960-krigingtoolbox
%   LanczosFilter                (optional)     -  LanczosFilter                               ||  https://ww2.mathworks.cn/matlabcentral/fileexchange/14041-lanczosfilter-m
%   LIRSC                        (optional)     -  LIRSC                                       ||  https://ww2.mathworks.cn/matlabcentral/fileexchange/71491-largest-inscribed-rectangle-square-or-circle
%   MITgcmTools                  (optional)     -  MITgcm matlab toolbox                       ||  https://github.com/MITgcm/MITgcm/tree/master/utils/matlab
%   parfor_progress              (optional)     -  Progress monitor with parfor                ||  https://ww2.mathworks.cn/matlabcentral/fileexchange/32101-progress-monitor-progress-bar-that-works-with-parfor?s_tid=srchtitle
%   parfor_progressbar           (optional)     -  parfor_progressbar                          ||  https://ww2.mathworks.cn/matlabcentral/fileexchange/53773-parfor_progressbar
%   perfectPolarPlot             (optional)     -  perfectPolarPlot                            ||  https://ww2.mathworks.cn/matlabcentral/fileexchange/73967-perfect-polar-plots
%   plotyyy                      (optional)     -  plotyyy                                     ||  https://ww2.mathworks.cn/matlabcentral/fileexchange/1017-plotyyy
%   Spiral diagram               (optional)     -  Spiral diagram                              ||  https://www.mathworks.com/matlabcentral/fileexchange/164966-spiral-diagram
%   struct2ini                   (optional)     -  struct2ini toolbox                          ||  https://ww2.mathworks.cn/matlabcentral/fileexchange/22079-struct2ini
%   taylordiagram                (optional)     -  taylordiagram                               ||  https://ww2.mathworks.cn/matlabcentral/fileexchange/20559-taylor-diagram
%   utm2deg                      (optional)     -  utm2deg                                     ||  https://www.mathworks.com/matlabcentral/fileexchange/10914-utm2deg
%   New Desktop for MATLAB (Beta)(optional)     -  New Desktop for MATLAB (Beta)               ||  https://www.mathworks.com/matlabcentral/fileexchange/119593-new-desktop-for-matlab-beta
%
%                                     Supplement Files
%   cdt                                         -  Supplement files for cdt toolbox
%       cdt/functionSignatures.json             -  Function signatures for cdt toolbox
%
%   matFigure
%       functionSignatures.json                 -  Function signatures for toolbox
%       cm_disp.m                               -  Display colormap
%       Contents.m                              -  Contents for toolbox
%       mf_legend.m                             -  Draw legend for matFigure
%       cm/cmp_b2r.mat                          -  Colormap for b2r
%       cm/nclColormap                          -  Colormap for ncl document
%
%   matFVCOM                                    -  Supplement files for matFVCOM toolbox
%       functionSignatures.json                 -  Function signatures for toolbox
%       add_restart_el_eqi.m                    -  Add restart el_eqi
%       add_restart_inundation_cells.m          -  Add restart inundation cells
%       basemap_read.m                          -  Read basemap
%       Contents.m                              -  Contents for toolbox
%       convert_fig2avi.m                       -  Convert figure to avi video
%       create_tidestruc.m                      -  Create tidestruc for tidal analysis
%       esmf_write_structured_grid.m            -  Write structured grid to ESMF format
%       f_2d_coast.m                            -  Draw the FVCOM grid coastline
%       f_2d_mask_boundary.m                    -  Mask the region out of the FVCOM grid boundary
%       f_2d_mesh.m                             -  Draw 2d fvcom mesh
%       f_calc_resolution.m                     -  Calculate the resolution of the grid
%       f_load_grid.m                           -  Generate all the information of FVCOM grid
%       initial.m                               -  Reinitial figure
%       kml_w_mesh.m                            -  Draw FVCOM mesh in KML
%       minmax.m                                -  Find the minimum and maximum of the data
%       obs_merge_location.m                    -  Merge the obs struct according to (lon,lat)
%       set_path.m                              -  Set the path for the matFVCOM package
%       w_2d_boundary.m                         -  Draw WRF mesh boundary
%       w_load_grid.m                           -  Load the WRF grid from WRF output
%       write_2dm.m                             -  Write 2dm file
%       write_brf_dy.m                          -  Write bottom roughness file
%       write_met_forcing_fvcom.m               -  Write meteorological forcing for FVCOM
%
%   matWRF                                      -  Extend matWRF toolbox
%       functionSignatures.json                 -  Function signatures for toolbox
%       calc_rh2.m                              -  Calculate relative humidity from temperature and dew point at 2m
%
%
%                                           Otherpkgs
%   Otherpkgs                                   -  Show other packages
%       Otherpkgs.m                             -  Show other packages
%       scatplot.m                              -  Scatter plot with colorbar   ||  https://ww2.mathworks.cn/matlabcentral/fileexchange/8577-scatplot
%       scatterOOR.m                            -  Scatter out of range         ||  https://mp.weixin.qq.com/s/B9Yv8LCLpb1fOw9Wz1MmMA
%       tpxo_atlas2local.m      (fixed)         -  Convert TPXO9-atlas to local ||  https://www.tpxo.net/global/tpxo9-atlas
%
%
%                                           Py  -  Python scripts for toolbox
% -----------------------------------------------------------------------------------------------------------------
%   gluemncbig.py                               -  Glue mnc files to big mnc file
%   Postprocess_fvcom.py                        -  Postprocess fvcom triangle data, contains daily/hourly
%
%
%                                        Hidden  -  Hidden folder
% -----------------------------------------------------------------------------------------------------------------
%   ./Htmls
%   ./References
%   ./Data
%   ./Docs
%
%
% =================================================================================================================
%
%
% Author        :  Christmas, Dovelet, Qidi Ma
% Organization  :  Ocean University of China,           Qingdao, China;
%                  Qingdao Ekman Technology Co., Ltd,   Qingdao, China;
% Email         :  273519355@qq.com
% Website       :  https://github.com/ChristmasZCY/Mbaysalt (github)
