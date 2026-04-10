<!--
 * @ -*- coding:UTF-8 -*-: 
 * @#########################: 
 * @Author: Christmas
 * @Date: 2023-09-18 21:13:00
 * @LastEditTime: 2024-02-22 11:30:13
 * @Description: 
-->

# Mbaysalt Toolbox

---
[![问问 DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/ChristmasZCY/Mbaysalt)


## Mbaysalt means Matlab-baysalt-toolbox

   **[English](README.md)  |  [中文](README_zh.md)**

## 安装

1. Shell/Powershell/Command Prompt.

   如果您打算使用它而不推送代码，那么只需从命令行运行中下载代码

   ```shell
   git clone https://github.com/ChristmasZCY/Mbaysalt.git
   ```

   如果您只想要最新版本而不是完整的存储库，请运行以下命令：

   ```shell
    git clone --depth=1 https://github.com/ChristmasZCY/Mbaysalt.git
   ```

   任何时候要将代码更新到最新版本，都可以从命令行运行以下命令：

   ```shell
   git pull (--unshallow)
   ```
2. 打开你想安装的额外模块的开关。

   ```shell
   cd /path/to/Mbaysalt
   vim Mbaysalt/Configurefiles/INSTALL.json
   ```

   - 如果你想安装子模块，将`INSTALL.json`中的`INSTALL`的值更改为`true`
     例如，如果您想安装子模块`matFigure`，可以将`packages:gitclone:matFigure:INSTALL`更改为`true`。
   - 如果`git`不在你的系统路径中，你可以在`INSTALL.json`中的`git:path`设置你的git-path。
   - 如果你希望在github镜像上克隆，你可以在`INSTALL.json`中的`git:mirror`设置你的镜像。
     它将替换`INSTALL.json`中的`packages:gitclone:*:URL`中的`https://www.github.com`为你的镜像。
3. Matlab

   ```matlab
   addpath('Mbaysalt')
   ST_Mbaysalt()
   ```

   或者如果您想要基本模块而不是所有模块，您可以运行

   ```matlab
   ST_Mbaysalt('add','./Examples/INSTALL_custom.json','init')
   ```
   如果需要删除路径，可以执行命令

   ```matlab
   ST_Mbaysalt('rm')
   ```

   它将保留基本路径，并删除所有其他路径。

## Contains

<details> <summary> 点击展开查看更多</summary>

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
