% matFVCOM Toolbox
% Version 1 (R2023b) 2024-01-25
% A MATLAB toolbox for dealing with FVCOM
%
% Toolbox contents
%
%   Contents                                -  This file
%   N_arrow                                 -  Add the North Arrow in the current figure
%   UV_projection                           -  Convert FVCOM UV from Cartisian Coordinate to Geographic Coordinate
%   add_met_xy                              -  Add the xy coordinate variables in the meteorological forcing file
%   add_nesting_center                      -  Add the variables of element center in the nesting files including h_center, siglay_center, siglev_center
%   add_nesting_hyw                         -  Add 'hyw' to the nesting boundary file
%   add_restart_dye                         -  Add dye in the restart file
%   add_restart_el_press                    -  Add el_press in the restart file
%   add_restart_lsf                         -  Add longshore forcing to FVCOM restart file
%   add_restart_nh                          -  Add non-hydrostatic variables in the restart file
%   add_restart_obc                         -  Add the open boundary to FVCOM restart file
%   add_restart_wave                        -  Add hs, tpeak, wdir in the restart file, for wave case
%   add_restart_wetdry                      -  Add the following variables in the restart file, for WET-DRY case
%   angle_mean                              -  Calculate the mean of angle data
%   basemap_plot                            -  Plot basemap
%   basemap_read                            -  Read basemap
%   calc_area                               -  Calculate m-polygon area in Cartisian Coordinate or Geo-referenced Coordinate
%   calc_atg                                -  Calculate the adiabatic lapse-rate of temperature, in terms of in situ temperature (degree C), salinity (1e-4), and oceanographic pressure (dbar)
%   calc_circle                             -  Calculate the circle (x, y) of given center and radius
%   calc_coare30                            -  Calculate heat flux via COARE30 using WRF output
%   calc_coare40                            -  Calculate heat flux via COARE40 using WRF output
%   calc_convert_range                      -  Convert the data to a certain range
%   calc_cor                                -  Calculate Coriolis 
%   calc_current2uv                         -  Calculate wind u, v from current/wave speed and direction
%   calc_data_index                         -  Calculate the covering index
%   calc_dens1                              -  Calculate Potential Density Based on Potential Temp and Salinity Pressure effects are incorported (Can Model Fresh Water < 4 Deg C)     
%   calc_dens2                              -  To calculate the density from salinity and temperature
%   calc_dens3                              -  To calculate the density from salinity, temperature and depth
%   calc_distance                           -  Calculate distance between two points in Cartisian Coordinate or Geo-referenced Coordinate.
%   calc_doy2num                            -  Convert day of year (starting from 1) to datenum
%   calc_evaporation                        -  Calculate evaporation
%   calc_heatflux                           -  Calculate heat flux via COARE30 using WRF output(repeat of calc_coare30)
%   calc_heatflux40                         -  Calculate heat flux via COARE40 using WRF output(repeat of calc_coare40)
%   calc_isoline                            -  Calculate the isolines from 2d fields
%   calc_lon_180                            -  Convert longitude to [-180, 180]
%   calc_lon_360                            -  Convert longitude to [0 360]
%   calc_lon_same                           -  Change the longitude to the same range as the other
%   calc_mld                                -  Calculate mixed layer depth
%   calc_num2doy                            -  Convert datenum to day of year (starting from 1)
%   calc_pca                                -  Do PCA to 2-d vectors 
%   calc_polygon_vorticity                  -  Calculate vorticity within a polygon from its velocity
%   calc_proj_vector                        -  Project vector B onto A
%   calc_rh2                                -  Calculate relative humidity at 2m
%   calc_rmse                               -  Calculate RMSE
%   calc_rvo                    
%   calc_sigma                              -  Calculate the FVCOM sigma layer and level depths
%   calc_slp                                -  Calculate SLP based on perturbation potential temperature, water vapor mixing ratio, pressure and geopotential
%   calc_storm                              -  Calculate storm based on wind stress
%   calc_tc                                 -  Calculate 'real' air temperature from potential tempearture and pressure
%   calc_tc_center                          -  Calculate the hurricane center location and slp based on slp
%   calc_tc_center2                         -  Calculate the hurricane center location and slp based on slp with the wind-adjustment 
%   calc_tc_mw                              -  Calculate the maximum wind, radius of maximum wind, and the location, based on wind speed and sea level pressure 
%   calc_theta                              -  Calculate the potential temperature
%   calc_uv2current                         -  Calculate current/wave speed and direction from u, v
%   calc_uv2wind                            -  Calculate wind speed and direction from u, v
%   calc_uv_scale                           -  Scale the vector (u, v) in a non-linear way
%   calc_wind2uv                            -  Calculate wind u, v from wind speed and direction
%   calc_wind_stress_LP1981                 -  Calculate the wind stress based on Large and Pond (1981)
%   calc_xcyc                               -  Calculate the cell center in spherical coordinate
%   check_grid_type                         -  Check if the grid is a global one based on (x,y)
%   coare30vn_ref_cool                      -  Vectorized version of COARE3 code for the cool skin effect
%   coare40vn                               -  Vectorized version of COARE4 code
%   color2rgb       
%   contour_angle                           -  Draw 2d contour for angle (0-360) 
%   convert_fig2avi                         -  Convert the figure to avi
%   convert_fvcom_time                      -  Convert MATLAB time to FVCOM time
%   create_tidestruc                        -  Create the 'tidestruc' structure variable for t_tide
%   create_tidestruct                       -  Create tidestruct for t_predic
%   cudem_boundary                          -  Create the boundary of all CUDEM data
%   cudem_interp                            -  Interpolate depth from CUDEM dataset
%   data_clean                              -  Remove the columns or rows that are full of NaN
%   data_daily2monthly                      -  Calculate the monthly mean data
%   data_hourly2daily                       -  Calculate the hourly mean data
%   data_mean                               -  Calculate the mean of the data(hourly, daily mean, monthly mean, seasonal mean, annual mean)
%   data_monthly2annual                     -  Calculate the annual mean data
%   data_monthly2seasonal                   -  Calculate the seasonal mean data
%   data_random2hourly                      -  Move the data to sharp hour: Only calculate the index
%   dims_tar        
%   dims_untar      
%   draw_global_ortho                       -  Draw Global FVCOM grid using the orthographic projection
%   draw_sigma      
%   draw_timebar                            -  Draw time-bar
%   earth_circle        
%   esmf_read_weight                        -  Read weights in ESMF style
%   esmf_regrid                             -  Interpolate in ESMF style
%   esmf_regrid_weight                      -  Calculate interpolating weights in ESMF style
%   esmf_write_grid                         -  write grid nc for ESMF regrid
%   example_2d_depth        
%   example_N_arrow     
%   example_UV_projection       
%   example_cb      
%   example_draw_2d     
%   example_draw_transect       
%   example_draw_transect_2     
%   example_interp_3d       
%   example_interp_fvcom        
%   example_interp_transect     
%   example_interpolation_2d        
%   example_mean        
%   example_restart2initial_ts      
%   example_smooth      
%   example_vector2     
%   f_2d_boundary                           -  Draw the FVCOM grid boundary
%   f_2d_cell       
%   f_2d_coast                              -  Draw the FVCOM grid coastline
%   f_2d_contour                            -  Draw 2d contour for fvcom-grid variables
%   f_2d_image                              -  Draw 2d image for fvcom-grid variables
%   f_2d_lonlat     
%   f_2d_mask_boundary                      -  Mask the region out of the FVCOM grid boundary
%   f_2d_mesh                               -  Draw 2d fvcom mesh
%   f_2d_range                              -  Get the FVCOM grid domain range
%   f_2d_vector     
%   f_2d_vector2                            -  Draw 2D FVCOM-grid vectors 
%   f_2d_vector3                            -  Draw 2D FVCOM-grid vectors 
%   f_2d_vector_legend      
%   f_calc_boundary                         -  Find out the FVCOM grid boundary
%   f_calc_cell_id      
%   f_calc_depth_avg                        -  Calculate vertically averaged velocity of FVCOM currents
%   f_calc_flux                             -  Calculate flux using FVCOM data
%   f_calc_gradient                         -  Calculate gradient of FVCOM variables (based on cell)
%   f_calc_grid_direction                   -  Calculate the direction of each cell: clockwise or counter clockwise
%   f_calc_nbe                              -  Calculate nbe (cell id around each cell)
%   f_calc_nbsn                             -  Calculate nbsn (node id around each node)
%   f_calc_nbve                             -  Calculate nbve (cell id around each node)
%   f_calc_resolution                       -  Calculate the resolution of FVCOM grd
%   f_calc_shape_coef2                      -  Calculate the shape coefficients u1a, u2a
%   f_calc_sigma                            -  Calculate FVCOM sigma varaibles 
%   f_calc_statistic        
%   f_calc_string                           -  Calculate the strings of FVCOM grid
%   f_calc_transect_neighbor                -  Calculate node or cell list around the given transect
%   f_calc_transport                        -  Calculate transport using FVCOM data
%   f_calc_ua                               -  Calculate vertically averaged velocity of FVCOM currents
%   f_calc_vorticity                        -  Calculate vorticity of FVCOM grid
%   f_cut_grid                              -  Cut a part of grid from the original one
%   f_fill_missing                          -  Fill the NaN with the nearest points
%   f_find_cell     
%   f_find_nearest                          -  Find the nearest node/cell point id to the input (x0, y0)
%   f_find_nestcell                         -  Find the nesting cell ids based on nesting node ids
%   f_find_nesting                          -  Find the n-layer nodes and cells for nesting boundary 
%   f_find_node     
%   f_grid_check                            -  Check the grid to find out the duplicated cells and nodes
%   f_grid_cp_ns        
%   f_grid_extr_cell                        -  Extract cells from the FVCOM grid
%   f_grid_extr_node                        -  Extract nodes from the FVCOM grid
%   f_grid_rm_cell                          -  Delete cells from the FVCOM grid
%   f_grid_rm_node                          -  Delete nodes from the FVCOM grid
%   f_interp_3d     
%   f_interp_3d_calc_weight     
%   f_interp_4d     
%   f_interp_cell2node      
%   f_interp_depth                          -  Interpolate FVCOM data to certain depth
%   f_interp_layer2level        
%   f_interp_level2layer        
%   f_interp_node2cell      
%   f_interp_t                              -  Interpolate FVCOM 3d data to scatted times
%   f_interp_transect       
%   f_interp_ts                             -  Interp FVCOM temperature and salinity results to observation points
%   f_interp_u                              -  Interp FVCOM temperature and salinity results to observation points
%   f_interp_uv                             -  Interp FVCOM temperature and salinity results to observation points
%   f_interp_v                              -  Interp FVCOM temperature and salinity results to observation points
%   f_interp_xy                             -  Interpolate FVCOM 3d data to scatted points.
%   f_interp_xyt                            -  Interpolate FVCOM 3d data to scatted points
%   f_interp_xyz                            -  Interpolate FVCOM 3d data to scatted points.
%   f_interp_xyzt                           -  Interpolate FVCOM 4d data to scatted points and times.
%   f_interp_z                              -  Interpolate FVCOM 3d data to scatted depths.
%   f_isoline                               -  Calculate the isoline of one certain level
%   f_kml_boundary                          -  Draw FVCOM boundary in KML
%   f_kml_image                             -  Save the image to kmz file
%   f_kml_mesh                              -  Draw FVCOM mesh in KML
%   f_load_grid                             -  Generate all the information of FVCOM grid
%   f_load_grid_nesting                     -  Create the fgrid structure of the nesting boundary
%   f_load_time                             -  Read time from FVCOM NetCDF files
%   f_mean_column                           -  Calculate vertically averaged FVCOM variables
%   f_merge_grid        
%   f_nesting_match                         -  Re-set the nesting node location to match the given ones 
%   f_nesting_merge                         -  Merge multiple fiels into one 
%   f_nesting_merge1        
%   f_nesting_merge2                        -  Merge multiple fiels into one with pre-calculated index
%   f_ortho_mesh                            -  Draw FVCOM grid with Orthographic Projection
%   f_pick_cell                             -  Pick points from the current figure and get their (x, y) and the nearest cell numbers
%   f_pick_node                             -  Pick points from the current figure and get their (x, y) and the nearest node numbers
%   f_proj_geo2xy                           -  Projection for FVCOM grid: from Geographic Coordinate to Cartesian Coordinate
%   f_proj_xy2geo                           -  Projection for FVCOM grid: from Cartesian Coordinate to Geographic Coordinate
%   f_renumber_grid     
%   f_smooth                                -  Smooth the FVCOM field (on node or cell) 
%   f_transect_contour                      -  Draw transect contour for 
%   f_transect_image        
%   f_transect_mask_topo        
%   f_transect_mesh                         -  Draw transect fvcom mesh
%   format_num                              -  Format the number with certain digits
%   fundir      
%   geo2ortho                               -  Orthographic Projection 
%   get_coastline_gshhs     
%   h_forcing_from_wrf                      -  Create WRF-Hydro forcing input from WRF hourly wrfout
%   h_forcing_from_wrf2                     -  Create WRF-Hydro forcing input from WRF hourly wrfout
%   initial     
%   interp_2d                               -  Do the 2d interpolation with different kind of data in three different
%   interp_2d_calc_weight                   -  Do the 2d interpolation with different kind of data in three different
%   interp_2d_via_weight                    -  Do the 2d interpolation with different kind of data in three different
%   interp_3d                               -  3-D Interpolation
%   interp_3d_calc_weight                   -  3-D Interpolation
%   interp_3d_via_weight                    -  3-D Interpolation
%   interp_cudem                            -  Interpolate depth from CUDEM dataset
%   interp_restart                          -  Create a new FVCOM restart file from an existing one of a different grid.
%   interp_time     
%   interp_time_calc_weight     
%   interp_time_nearest_calc_id     
%   interp_time_via_weight      
%   interp_transect                         -  Interpolation for transect plot
%   interp_transect_calc_weight             -  Interpolation for transect plot
%   interp_transect_pixel                   -  Interpolate the pixels on the transect
%   interp_transect_pixel_horizontal        -  Interpolate the pixels on the transect on the horizontal
%   interp_transect_pixel_vertical          -  Interpolate the pixels on the transect
%   interp_transect_via_weight              -  Interpolation for transect plot
%   interp_vertical                         -  Vertical interpolatin
%   interp_vertical_calc_weight             -  Generate the vertical interpolation weights
%   interp_vertical_via_weight              -  Horizontal interpolatin via weights
%   interp_wrf2fvcom                        -  interp WRF-grid variables to FVCOM-grid ones 
%   interp_wrf2fvcom_calc_weight            -  interp WRF-grid variables to FVCOM-grid ones (calculate weights)
%   interp_wrf2fvcom_via_weight             -  interp WRF-grid variables to FVCOM-grid ones (via weights)
%   isoline     
%   kml_boundary                            -  Draw WRF boundary in KML
%   kml_f_boundary                          -  Draw FVCOM boundary in KML
%   kml_f_mesh                              -  Draw FVCOM mesh in KML
%   kml_image                               -  Save the image to kmz file
%   kml_line                                -  Draw lines in Google Earth
%   kml_line2                               -  Draw lines in Google Earth
%   kml_overlay                             -  Overlay the current figure onto Google Earth
%   kml_point                               -  Draw points in Google Earth
%   kml_poly                                -  Draw lines in Google Earth
%   kml_w_boundary                          -  Draw WRF boundary in KML
%   ksearch                                 -  Find k-nearest neighbors using input data
%   line_in_box     
%   line_mat2cell                           -  Convert the lines from mat format into cell format
%   merge_nesting                           -  Merge the nesting files
%   merge_nml                               -  Merge two nameslits
%   merge_to_record     
%   merge_to_station        
%   minmax                                  -  Find the minimum and maximum of the data
%   nml_default_wps     
%   normal_transect                         -  Given three points, output a set of (x,y) on the transect, which across the middle point and is normal to the lines
%   obs_merge_location                      -  Merge the obs struct according to (lon,lat)
%   osm_get_data                            -  get OSM relation data
%   osm_get_node                            -  get OSM node data
%   osm_get_relation                        -  get OSM relation data
%   osm_get_relation2                       -  get OSM relation data
%   osm_get_way                             -  get OSM way data
%   pick_from_image                         -  Pick points from a picture and get their (x, y)
%   pick_line                               -  Pick a line from the current figure and get their (x, y)
%   pl66tn                                  -  Compute the 66-point low-pass filter
%   plane_coast     
%   plane_lonlat        
%   plane_range                             -  Set the xlims and ylims, and set axes equal
%   plane_topo      
%   plane_vector        
%   plane_vector_legend     
%   plot2                                   -  Plot line with interpolated gradient colors
%   poly_intersect                          -  Calculate the polygon intersect
%   poly_order                              -  Find the polygon orders
%   proj_geo2lony                           -  Project (lon, lat) to (x, y)
%   proj_geo2mercator       
%   proj_geo2miller     
%   proj_geo2ortho                          -  Orthographic Projection  
%   proj_geo2ps                             -  Convert Geo-referenced Coordinate (lon, lat) to Polar Stereographic Coordinate (x, y) in WGS84
%   proj_geo2utm                            -  Convert Geo-referenced Coordinate (lon, lat) to UTM (x, y) in WGS84
%   proj_lambert        
%   proj_latlon     
%   proj_lony2geo                           -  Project (x, y) to (lon, lat)
%   proj_mercator       
%   proj_mercator2geo       
%   proj_miller2geo                         -  Projection: (x, y) --> (longitude, latitude) via Miller projection
%   proj_polar                              -  Polar Projection: ij2ll
%   proj_ps2geo                             -  Convert Polar Stereographic Coordinate (x, y) in WGS84 to Geo-referenced Coordinate (lon, lat)
%   proj_utm2geo                            -  Convert UTM (x, y) to Geo-referenced Coordinate (lon, lat) in WGS84
%   rarefy                                  -  Rarefy the data
%   read_2dm                                -  Read the SMS 2dm input file (ASCII)
%   read_cnv                                -  Read the cnv file
%   read_contourC       
%   read_cor                                -  Read the FVCOM cor input file (ASCII)
%   read_cst                                -  Read the coastline in cst format
%   read_cudem                              -  Read CUDEM dataset
%   read_current                            -  Read FVCOM Current DA input data
%   read_dep                                -  Read the FVCOM dep input file (ASCII)
%   read_grd                                -  Read the FVCOM grd input file (ASCII) or the SMS grd input file (ASCII)
%   read_gri_grd                            -  Read gri-grd file
%   read_kml                                -  Read the kml/kmz file to get the Points, Lines, and Polygons.
%   read_map                                -  Read SMS map file
%   read_map2                               -  Read SMS map file
%   read_nc_combine                         -  Combine the variabels from multiple NetCDF files
%   read_nestnode                           -  Read FVCOM nestnode file 
%   read_nml                                -  Read nml file
%   read_nml_wps                            -  Read the WPS namelist file (with default settings)
%   read_obc                                -  Read the FVCOM obc input file (ASCII)
%   read_registry                           -  Read WRF registry file(s).
%   read_sigma                              -  Read FVCOM sigma file (ASCII)
%   read_spg                                -  Read the FVCOM spg input file (ASCII)
%   read_tiff                               -  Read tiff file
%   read_tiff_lims                          -  Read tiff file to get xlims and ylims
%   read_ts                                 -  Read FVCOM TS DA input data
%   read_varargin                           -  Read the varargin in the function input (style 1)
%   read_varargin2                          -  Read the varargin in the function input (style 1)
%   renumber_grid                           -  Renumber the grid node id
%   replace_2dm                             -  Replace part of the SMS 2dm input file (ASCII)
%   replace_river_nml                       -  Replace the node id in the river nml fiel
%   rotate_theta        
%   set_path                                -  Set the path for the matFVCOM package
%   sms_tab2cst     
%   sp_proj                                 -  convert to and from US state plane coordinates
%   struct_extract                          -  Extract variables from a struct
%   template        
%   txt_middle      
%   url_download_files      
%   vdatum                                  -  Call VDatum to convert vertical datum
%   vector_legend                           -  Draw a vector legend
%   w_2d_boundary                           -  Draw WRF mesh boundary
%   w_2d_coast                              -  Draw WRF coastline
%   w_2d_contour                            -  Draw 2D contour for WRF variable
%   w_2d_image                              -  Draw 2D image for WRF variable
%   w_2d_mask_boundary                      -  Mask the region out of the WRF grid boundary
%   w_2d_mesh                               -  Draw WRF mesh
%   w_2d_range                              -  Get the WRF grid domain range
%   w_2d_vector     
%   w_2d_vector_legend      
%   w_calc_boundary                         -  Find out the WRF grid boundary
%   w_calc_hurricane_center                 -  Calculate the hurricane center from SLP
%   w_calc_hurricane_radius     
%   w_calc_resolution                       -  Calculate the resolution of WRF grd
%   w_interp_UV2M       
%   w_interp_W2M        
%   w_isoline       
%   w_load_data                             -  Load data from WRF output (wrfout*)
%   w_load_data_slp                         -  Load the WRF grid from WRF output
%   w_load_grid                             -  Load the WRF grid from WRF output
%   w_smooth                                -  Smooth the WRF field 
%   w_transect_contour                      -  Draw transect contour for 
%   w_transect_image        
%   w_transect_mask_topo        
%   w_transect_mesh                         -  Draw transect WRF mesh
%   write_2dm                               -  Write the SMS 2dm input file (ASCII)
%   write_cor                               -  Write the FVCOM cor input file (ASCII)
%   write_cst                               -  Write out the coastline in cst format
%   write_current                           -  Read FVCOM Current DA input data
%   write_dep                               -  Write the FVCOM dep input file (ASCII)
%   write_grd                               -  Write the FVCOM grd input file (ASCII)
%   write_gri_grd                           -  Write gri-grd file
%   write_groundwater                       -  Write FVCOM groundwater input NetCDF file
%   write_hvc                               -  Write horizontal diffusion coefficient NetCDF file
%   write_hydro_forcing                     -  Write hydro forcing 
%   write_ice_forcing_fvcom                 -  Write FVCOM ice forcing input (FVCOM grid)
%   write_initial                           -  Write FVCOM initial NetCDF file
%   write_initial_ts                        -  Write FVCOM TS initial NetCDF file
%   write_lonlat                            -  Write the FVCOM lonlat input file (ASCII)
%   write_lsf                               -  Write the FVCOM lsf input file (ASCII)
%   write_map                               -  Write SMS map file
%   write_map2                              -  Write SMS map file
%   write_met                               -  Write horizontal diffusion coefficient NetCDF file
%   write_met_forcing_fvcom                 -  Write FVCOM meteorological forcing input (FVCOM grid)
%   write_nesting                           -  Write the FVCOM nesting forcing input file
%   write_nesting_wave                      -  Write the FVCOM-SWAVE nesting forcing input file
%   write_nestnode                          -  Write FVCOM nestnode file 
%   write_nml                               -  Write Fortran nml file
%   write_nml_river                         -  write FVCOM river nml file
%   write_obc                               -  Write OBC input file
%   write_obc_spectral                      -  Write FVCOM tidal forcing NetCDF file
%   write_river                             -  Write the FVCOM river forcing input file
%   write_sigma                             -  Write the FVCOM sigma input file (ASCII)
%   write_spg                               -  Write the FVCOM spg input file (ASCII)
%   write_ssh                               -  Write FVCOM SSH input NetCDF file
%   write_sss                               -  Write FVCOM SSS input NetCDF file
%   write_sst                               -  rite FVCOM SST input NetCDF file
%   write_station                           -  Write FVCOM station file
%   write_ts                                -  Write FVCOM TS DA input data
%   write_wrf_iofield                       -  Create the iofield file of WRF
%   write_z0b                               -  Write Z0b NetCDF file


