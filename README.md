<!--
 * @ -*- coding:UTF-8 -*-: 
 * @#########################: 
 * @Author: Christmas
 * @Date: 2023-09-18 21:13:00
 * @LastEditTime: 2024-02-22 11:30:13
 * @Description: 
-->

# Mbaysalt Toolbox

## Mbaysalt means Matlab-baysalt-toolbox

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

   -  If you want to install submodule, change value of INSTALL in `INSTALL.json`  to `true` \
      Such as if you want to install submodule `matFigure`, you can change `packages:gitclone:matFigure:INSTALL` to `true`.
   -  If git is not in your system path, you can set your git-path in `INSTALL.json` at `git:path`.
   -  If you want to clone at github mirror, you can set your mirror in `INSTALL.json` at `git:mirror`. \
      It will replace `https://www.github.com` in `INSTALL.json` at `packages:gitclone:*:URL` to your mirror.

3. Matlab

   ```matlab
   addpath('Mbaysalt')
   ST_Mbaysalt()
   ```

   If you want to delete the path, you can run 

   ```matlab
   ST_Mbaysalt('rm')
   ```
   It will reserve basepath, and remove all other paths.

## Contains 
<details> <summary> 点击展开查看更多</summary>

- [Mbaysalt](https://github.com/ChristmasZCY/Mbaysalt)
- [matFigure](https://github.com/SiqiLiOcean/matFigure)
- [matFVCOM](https://github.com/SiqiLiOcean/matFVCOM)
- [matNC](https://github.com/SiqiLiOcean/matNC)
- [matWRF](https://github.com/SiqiLiOcean/matWRF)
- [HYCOM2FVCOM](https://github.com/SiqiLiOcean/HYCOM2FVCOM)
- [WRF2FVCOM](https://github.com/SiqiLiOcean/WRF2FVCOM)
- [OceanData](https://github.com/ChristmasZCY/OceanData)
- [FVCOM_NML](https://github.com/SiqiLiOcean/FVCOM_NML)
- [nctoolbox](https://github.com/nctoolbox/nctoolbox)
- [CDT](https://github.com/chadagreene/CDT)
- [vtkToolbox](https://ww2.mathworks.cn/matlabcentral/fileexchange/94993-vtktoolbox)
- [TMDToolbox_v2_5](https://github.com/EarthAndSpaceResearch/TMD_Matlab_Toolbox_v2.5)
- [TMDToolbox_v3_0](https://github.com/chadagreene/Tide-Model-Driver)
- [kmz2struct](https://github.com/njellingson/kmz2struct)
- [inpolygons-pkg](https://ww2.mathworks.cn/matlabcentral/fileexchange/7187-inpolygons)
- [JSONLab](https://ww2.mathworks.cn/matlabcentral/fileexchange/33381-jsonlab)
- [OceanMesh2D](https://github.com/CHLNDDEV/OceanMesh2D.git)
- [ann_wrapper](https://github.com/shaibagon/ann_wrapper.git)
- [ZoomPlot](https://github.com/iqiukp/ZoomPlot-MATLAB)
- [htool](https://github.com/SiqiLiOcean/htool)
- [export_fig](https://ww2.mathworks.cn/matlabcentral/fileexchange/23629-export_fig/)
- [genpath2](https://github.com/ssordopalacios/matlab-genpath2)
- [irfu-matlab](https://github.com/irfu/irfu-matlab)
- [WW3-tools](https://github.com/NOAA-EMC/WW3-tools)
- [funcsign](https://gitee.com/iam002/funcsign)
- [kml-toolbox](https://github.com/theolivenbaum/kml-toolbox)


- [m_map](https://www.eoas.ubc.ca/~rich/map.html)
- [t_tide](https://www.eoas.ubc.ca/~rich/#T_Tide)
- [gshhs](https://www.ngdc.noaa.gov/mgg/shorelines/gshhs.html)
- [etopo1](https://www.ngdc.noaa.gov/mgg/global/global.html)
- [seawater](https://www.cmar.csiro.au/datacentre/ext_docs/seawater.html)
- [GSW Oceanographic Toolbox](http://www.teos-10.org/software.htm)
- [WindRose](https://dpereira.asempyme.com/windrose/)
- [mexcdf](https://mexcdf.sourceforge.net/index.php)
- [DHIMIKE](https://github.com/DHI/DHI-MATLAB-Toolbox/)
- [cprintf](https://www.mathworks.com/matlabcentral/fileexchange/24093-cprintf-display-formatted-colored-text-in-the-command-window)
- [INI](https://ww2.mathworks.cn/matlabcentral/fileexchange/55766-ini)
- [struct2ini](https://ww2.mathworks.cn/matlabcentral/fileexchange/22079-struct2ini)
- [inifile](https://ww2.mathworks.cn/matlabcentral/fileexchange/2976-inifile)
- [iniconfig](https://ww2.mathworks.cn/matlabcentral/fileexchange/24992-ini-config)
- [MITgcmTools](https://github.com/MITgcm/MITgcm/tree/master/utils/matlab)
- [LanczosFilter](https://ww2.mathworks.cn/matlabcentral/fileexchange/14041-lanczosfilter-m)
- [ellipse](https://ww2.mathworks.cn/matlabcentral/fileexchange/289-ellipse-m)
- [genpath_exclude](https://ww2.mathworks.cn/matlabcentral/fileexchange/22209-genpath_exclude)
- [taylordiagram](https://ww2.mathworks.cn/matlabcentral/fileexchange/20559-taylor-diagram)
- [guillaumemaze](http://code.google.com/p/guillaumemaze/)
- [perfectPolarPlot](https://ww2.mathworks.cn/matlabcentral/fileexchange/73967-perfect-polar-plots)
- [LIRSC](https://ww2.mathworks.cn/matlabcentral/fileexchange/71491-largest-inscribed-rectangle-square-or-circle)

</details>

