# Mbaysalt Toolbox

**[English](README.md) | [中文](README_zh.md)**

Matlab-baysalt-toolbox: MATLAB 海洋科学函数库（温跃层、障碍层、声速、锋面等），可选 Exfunctions 子模块，可编译为 Python/共享库。任务记录见 [Docs/TODO.md](Docs/TODO.md)、[Docs/DONE.md](Docs/DONE.md)。

## Installation

```shell
git clone https://github.com/ChristmasZCY/Mbaysalt.git   # 或 --depth=1
```

Edit `Configurefiles/INSTALL.json` to select Exfunctions submodules (`packages:gitclone:*:INSTALL`), then in MATLAB:

```matlab
addpath('Mbaysalt')
ST_Mbaysalt()                                        % install + addpath
ST_Mbaysalt('add','./Examples/INSTALL_custom.json','init')   % 自定义清单
ST_Mbaysalt('rm')                                    % 移除路径
```

`INSTALL.json` 也可设 `git:path` 与 `git:mirror`（镜像替换 github.com）。

## Build a Python package or shared library

`Scripts/build_python_package.m`，`Target`：`ctf`（Python 包，默认）、`so`（MATLAB Runtime 依赖库）、`coder`（独立原生库，需 `CoderArgs` 固定接口）。产物在 `build/{python,shared,coder}` 并附 `api.json`。

```matlab
build_python_package({'calc_weather_front.m','calc_thermocline.m','calc_sound_speed.m'}, 'Target', 'ctf');
```

目标机安装匹配版本的 MATLAB Runtime 后 `cd build/python && python -m pip install .`，使用 `mbaysalt.initialize()` / `toolbox.<func>` / `toolbox.terminate()`。

## Tests

```matlab
addpath('Tests'); run_all_tests
```

Runs on a clean MATLAB path: `ST_Mbaysalt` installs only the test dependencies listed in `Configurefiles/INSTALL.json`, then all `Tests/test_*.m` run and the original path is restored. GitHub Actions runs it on every push (`.github/workflows/test.yml`).

## 目录

`*functions/` 科学与工具函数（`Infunctions/`、`Ncfunctions/`、`Gridfunctions/` 等）、`Post_*/` 各模式后处理、`Callcodes/` 业务算例、`Exfunctions/` 可选子模块（第三方，不随本仓文档管理）、`Configurefiles/` 安装清单、`Docs/` 任务记录、`Examples/`、`Scripts/`、`Tests/`。

## Contains

<details> <summary> Click to expand to see more</summary>

- [Mbaysalt](https://github.com/ChristmasZCY/Mbaysalt)

----
Github
----

- [ann_wrapper](https://github.com/shaibagon/ann_wrapper.git)
- [CDT](https://github.com/chadagreene/CDT)
- [Course](https://github.com/SiqiLiOcean/Course)
- [export_fig](https://ww2.mathworks.cn/matlabcentral/fileexchange/23629-export_fig/)
- [freezeColors](https://github.com/jiversen/freezeColors)
- [funcsign](https://gitee.com/iam002/funcsign)
- [FVCOM_NML](https://github.com/SiqiLiOcean/FVCOM_NML)
- [FVCOMToolbox_v2](https://gitea.iocean.cn/Christmas/FVCOMToolbox_v2)
- [gcmfaces](https://github.com/MITgcm/gcmfaces)
- [genpath2](https://github.com/ssordopalacios/matlab-genpath2)
- [googleearthtoolbox](https://github.com/sverhoeven/googleearthtoolbox)
- [htool](https://github.com/SiqiLiOcean/htool)
- [HYCOM2FVCOM](https://github.com/SiqiLiOcean/HYCOM2FVCOM)
- [inpolygons-pkg](https://ww2.mathworks.cn/matlabcentral/fileexchange/7187-inpolygons)
- [inpoly](https://github.com/dengwirda/inpoly)
- [ipi4d](https://github.com/mariosgeo/ipi4d)
- [irfu-matlab](https://github.com/irfu/irfu-matlab)
- [JSONLab](https://ww2.mathworks.cn/matlabcentral/fileexchange/33381-jsonlab)
- [kml-toolbox](https://github.com/theolivenbaum/kml-toolbox)
- [kmz2struct](https://github.com/njellingson/kmz2struct)
- [kriging](https://github.com/wschwanghart/kriging)
- [matFigure](https://github.com/SiqiLiOcean/matFigure)
- [matFVCOM](https://github.com/SiqiLiOcean/matFVCOM)
- [MATLAB-PLOT-CHEAT-SHEET](https://github.com/slandarer/MATLAB-PLOT-CHEAT-SHEET)
- [matlab-schemer](https://github.com/scottclowe/matlab-schemer)
- [matlabPlotCheatsheet](https://github.com/peijin94/matlabPlotCheatsheet)
- [matNC](https://github.com/SiqiLiOcean/matNC)
- [matWRF](https://github.com/SiqiLiOcean/matWRF)
- [MESH2D](https://github.com/dengwirda/mesh2d)
- [mitgcm_toolbox](https://github.com/seamanticscience/mitgcm_toolbox)
- [nctoolbox](https://github.com/nctoolbox/nctoolbox)
- [OceanData](https://github.com/SiqiLiOcean/OceanData)
- [ocean_data_tools](https://github.com/lnferris/ocean_data_tools)
- [OceanMesh2D](https://github.com/CHLNDDEV/OceanMesh2D.git)
- [ParforProgMon](https://github.com/fsaxen/ParforProgMon)
- [plot_google_map](https://ww2.mathworks.cn/matlabcentral/fileexchange/27627-zoharby-plot_google_map)
- [RPSstuff](https://github.com/rsignell-usgs/RPSstuff)
- [TMDToolbox_v2_5](https://github.com/EarthAndSpaceResearch/TMD_Matlab_Toolbox_v2.5)
- [TMDToolbox_v3_0](https://github.com/chadagreene/Tide-Model-Driver)
- [TopoToolbox](https://github.com/wschwanghart/topotoolbox)
- [variogramfit](https://github.com/wschwanghart/variogramfit)
- [visualization-cheat-sheet](https://github.com/mathworks/visualization-cheat-sheet)
- [vtkToolbox](https://ww2.mathworks.cn/matlabcentral/fileexchange/94993-vtktoolbox)
- [WRF2FVCOM](https://github.com/SiqiLiOcean/WRF2FVCOM)
- [WW3-tools](https://github.com/NOAA-EMC/WW3-tools)
- [yaml](https://github.com/MartinKoch123/yaml)
- [ZoomPlot](https://github.com/iqiukp/ZoomPlot-MATLAB)

----
Download
----

- [dace](https://www.omicron.dk/dace.html)
- [DHIMIKE](https://github.com/DHI/DHI-MATLAB-Toolbox/)
- [etopo1](https://www.ngdc.noaa.gov/mgg/global/global.html)
- [gshhs](https://www.ngdc.noaa.gov/mgg/shorelines/gshhs.html)
- [GSW Oceanographic Toolbox](http://www.teos-10.org/software.htm)
- [m_map](https://www.eoas.ubc.ca/~rich/map.html)
- [Mesh2d](https://ww2.mathworks.cn/matlabcentral/fileexchange/25555-mesh2d-delaunay-based-unstructured-mesh-generation)
- [mexcdf](https://mexcdf.sourceforge.net/index.php)
- [seawater](https://www.cmar.csiro.au/datacentre/ext_docs/seawater.html)
- [t_tide](https://www.eoas.ubc.ca/~rich/#T_Tide)
- [WindRose](https://dpereira.asempyme.com/windrose/)
- [ETOPO1_Bed_g_gmt4](https://www.ngdc.noaa.gov/mgg/global/relief/ETOPO1/data/bedrock/grid_registered/netcdf/ETOPO1_Bed_g_gmt4.grd.gz)
- [ETOPO1_Ice_g_gmt4](https://www.ngdc.noaa.gov/mgg/global/relief/ETOPO1/data/ice_surface/grid_registered/netcdf/ETOPO1_Ice_g_gmt4.grd.gz)
- [UTide](https://www.po.gso.uri.edu/~codiga/utide/utide.htm)

----
Builtin
----

- [cprintf](https://www.mathworks.com/matlabcentral/fileexchange/24093-cprintf-display-formatted-colored-text-in-the-command-window)
- [ellipse](https://ww2.mathworks.cn/matlabcentral/fileexchange/289-ellipse-m)
- [genpath_exclude](https://ww2.mathworks.cn/matlabcentral/fileexchange/22209-genpath_exclude)
- [grabit](https://ww2.mathworks.cn/matlabcentral/fileexchange/7173-grabit/files/grabit.m)
- [guillaumemaze](http://code.google.com/p/guillaumemaze/)
- [IDW](https://ww2.mathworks.cn/matlabcentral/fileexchange/24477-inverse-distance-weight)
- [INI](https://ww2.mathworks.cn/matlabcentral/fileexchange/55766-ini)
- [iniconfig](https://ww2.mathworks.cn/matlabcentral/fileexchange/24992-ini-config)
- [inifile](https://ww2.mathworks.cn/matlabcentral/fileexchange/2976-inifile)
- [KrigingToolbox](https://ww2.mathworks.cn/matlabcentral/fileexchange/59960-krigingtoolbox)
- [LanczosFilter](https://ww2.mathworks.cn/matlabcentral/fileexchange/14041-lanczosfilter-m)
- [LIRSC](https://ww2.mathworks.cn/matlabcentral/fileexchange/71491-largest-inscribed-rectangle-square-or-circle)
- [MITgcmTools](https://github.com/MITgcm/MITgcm/tree/master/utils/matlab)
- [parfor_progress](https://ww2.mathworks.cn/matlabcentral/fileexchange/32101-progress-monitor-progress-bar-that-works-with-parfor?s_tid=srchtitle)
- [parfor_progressbar](https://ww2.mathworks.cn/matlabcentral/fileexchange/53773-parfor_progressbar)
- [perfectPolarPlot](https://ww2.mathworks.cn/matlabcentral/fileexchange/73967-perfect-polar-plots)
- [plotyyy](https://ww2.mathworks.cn/matlabcentral/fileexchange/1017-plotyyy)
- [Spiral diagram](https://www.mathworks.com/matlabcentral/fileexchange/164966-spiral-diagram)
- [struct2ini](https://ww2.mathworks.cn/matlabcentral/fileexchange/22079-struct2ini)
- [taylordiagram](https://ww2.mathworks.cn/matlabcentral/fileexchange/20559-taylor-diagram)
- [utm2deg](https://www.mathworks.com/matlabcentral/fileexchange/10914-utm2deg)
- [New Desktop for MATLAB (Beta)](https://www.mathworks.com/matlabcentral/fileexchange/119593-new-desktop-for-matlab-beta)

</details>
