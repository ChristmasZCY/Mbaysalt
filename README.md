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

   ```shell
   git clone https://github.com/ChristmasZCY/Mbaysalt.git
   ```
2. Change Exfunction install switch which you want to open.

   ```shell
   cd /path/to/Mbaysalt
   vim Mbaysalt/Configurefiles/INSTALL.conf
   ```

   > a. Change What you want to install to **.TRUE.** and others to **.FALSE.** .
   > b. If git is not in your system path, you can uncomment `Git_path = /usr/bin/git`, and change the path to your git path.
   > c. If you want to clone at github mirror, you can uncomment `Github_mirror = $url`, '$url' means the mirror url, such as `Github_mirror = https://githubfast.com/`.
   >
3. Matlab

```matlab
addpath('Mbaysalt')
Mainpath
```

## Contains

- [Mbaysalt](https://github.com/ChristmasZCY/Mbaysalt)
- [cprintf](https://www.mathworks.com/matlabcentral/fileexchange/24093-cprintf-display-formatted-colored-text-in-the-command-window)
- [FVCOM_NML](https://github.com/SiqiLiOcean/FVCOM_NML)
- [INI](https://ww2.mathworks.cn/matlabcentral/fileexchange/55766-ini)
- [iniconfig](https://ww2.mathworks.cn/matlabcentral/fileexchange/24992-ini-config)
- [inifile](https://ww2.mathworks.cn/matlabcentral/fileexchange/2976-inifile)
- [matFVCOM](https://github.com/SiqiLiOcean/matFVCOM)
- [matWRF](https://github.com/SiqiLiOcean/matWRF)
- [matFigure](https://github.com/SiqiLiOcean/matFigure)
- [matNC](https://github.com/SiqiLiOcean/matNC)
- [HYCOM2FVCOM](https://github.com/SiqiLiOcean/HYCOM2FVCOM)
- [htool](https://github.com/SiqiLiOcean/htool)
- [struct2ini](https://ww2.mathworks.cn/matlabcentral/fileexchange/22079-struct2ini)
- [m_map](https://www.eoas.ubc.ca/~rich/map.html)
- [t_tide](https://www.eoas.ubc.ca/~rich/#T_Tide)
- [CDT](https://github.com/chadagreene/CDT)
- [nctoolbox](https://github.com/nctoolbox/nctoolbox)
- [OceanData](https://github.com/SiqiLiOcean/OceanData)
- [ZoomPlot](https://github.com/iqiukp/ZoomPlot-MATLAB)
- [TMDToolbox](https://github.com/EarthAndSpaceResearch/TMD_Matlab_Toolbox_v2.5)
- [vtkToolbox](https://github.com/KIT-IBT/vtkToolbox)
- [kmz2struct](https://github.com/njellingson/kmz2struct)
- [WRF2FVCOM](https://github.com/SiqiLiOcean/WRF2FVCOM)
- [joyPlot](https://ww2.mathworks.cn/matlabcentral/fileexchange/75147-joyplot-ridgeline-data-representation)
- [inpolygons-pkg](https://ww2.mathworks.cn/matlabcentral/fileexchange/7187-inpolygons)
- [seawater](https://www.cmar.csiro.au/datacentre/ext_docs/seawater.html)
- [GSW Oceanographic Toolbox](http://www.teos-10.org/software.htm)
- [WindRose](https://dpereira.asempyme.com/windrose/)
