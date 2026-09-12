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
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/ChristmasZCY/Mbaysalt)


## Mbaysalt means Matlab-baysalt-toolbox

   **[English](README.md)  |  [中文](README_zh.md)**

## Installation

1. Shell/Powershell/Command Prompt.

   If you intend to use it without pushing code then to simply download the code from the command line run

   ```shell
   git clone https://github.com/ChristmasZCY/Mbaysalt.git
   ```

   If you want only the latest version and not the full repository run

   ```shell
    git clone --depth=1 https://github.com/ChristmasZCY/Mbaysalt.git
   ```

   Any time you want to update the code to the latest version, run from the command line

   ```shell
   git pull (--unshallow)
   ```
2. Change Exfunctions install switch which you want to open.

   ```shell
   cd /path/to/Mbaysalt
   vim Mbaysalt/Configurefiles/INSTALL.json
   ```

   - If you want to install submodule, change value of `INSTALL` in `INSTALL.json`  to `true`
     Such as if you want to install submodule `matFigure`, you can change `packages:gitclone:matFigure:INSTALL` to `true`.
   - If `git` is not in your system path, you can set your git-path in `INSTALL.json` at `git:path`.
   - If you want to clone at github mirror, you can set your mirror in `INSTALL.json` at `git:mirror`.
     It will replace `https://www.github.com` in `INSTALL.json` at `packages:gitclone:*:URL` to your mirror.
3. Matlab

   ```matlab
   addpath('Mbaysalt')
   ST_Mbaysalt()
   ```

   Or if you want the basic module not all module, you can run

   ```matlab
   ST_Mbaysalt('add','./Examples/INSTALL_custom.json','init')
   ```
   If you want to delete the path, you can run

   ```matlab
   ST_Mbaysalt('rm')
   ```

   It will reserve basepath, and remove all other paths.

## Build a Python package or shared library

The build script resolves entry-function dependencies automatically. `Target` supports:

- `ctf`: Default. Build a Python package and CTF with MATLAB Compiler SDK in `build/python`.
- `so`: Build a MATLAB Runtime-dependent C shared library with MATLAB Compiler SDK in `build/shared`. The native file is `.so` on Linux, `.dylib` on macOS, and `.dll` on Windows.
- `coder`: Build a standalone native shared library with MATLAB Coder in `build/coder`. `CoderArgs` must define the input type and dimensions for each entry function.

Build the Python/CTF package:

```matlab
repoRoot = fileparts(which('ST_Mbaysalt'));
addpath(fullfile(repoRoot, 'Scripts'));
build_python_package({'calc_weather_front.m', ...
                      'calc_thermocline.m', ...
                      'calc_sound_speed.m'}, ...
                     'Target', 'ctf');
```

Build a MATLAB Compiler SDK shared library:

```matlab
build_python_package({'calc_weather_front.m', ...
                      'calc_thermocline.m', ...
                      'calc_sound_speed.m'}, ...
                     'Target', 'so');
```

MATLAB Coder requires a fixed or bounded interface. This example builds all three functions:

```matlab
vector = coder.typeof(0, [Inf 1], [1 0]);
array4d = coder.typeof(0, [Inf Inf Inf Inf], [1 1 1 1]);
build_python_package({'calc_weather_front.m', ...
                      'calc_thermocline.m', ...
                      'calc_sound_speed.m'}, ...
                     'Target', 'coder', ...
                     'CoderArgs', {{vector, vector, vector, array4d, array4d}, ...
                                   {vector, array4d}, ...
                                   {array4d, array4d, vector}});
```

On the target machine, install a MATLAB Runtime matching the build release, operating system, and CPU architecture, then install the generated Python package:

```shell
cd build/python
python -m pip install .
```

Python example:

```python
import mbaysalt

toolbox = mbaysalt.initialize()
try:
    sound_speed = toolbox.calc_sound_speed(10.0, 35.0, 100.0, nargout=1)
finally:
    toolbox.terminate()
```

A CTF containing only MATLAB code can be used across its declared supported platforms, but the target still needs a MATLAB Runtime matching the build release and the target operating system and CPU architecture. Rebuild and verify per platform if dependencies include MEX files or other native libraries. On macOS, use the MATLAB/Runtime `mwpython` command described in the generated `readme.txt`. For array inputs, use MATLAB array types such as `matlab.double`. Shared-library targets generate the library, headers, and examples only; they do not create an importable Python module. Python needs a separate `ctypes`, C-extension, or other binding for the generated interface. On Linux and macOS, the default shared-library filename starts with `lib`.

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
