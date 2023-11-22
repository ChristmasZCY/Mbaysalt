# Mbaysalt Toolbox

## Mbaysalt means Matlab-baysalt-toolbox.

## Installation

> 1. Shell/Powershell/Command Prompt.
>
>    ```shell
>    git clone https://github.com/ChristmasZCY/Mbaysalt.git
>    ```
> 2. Change which Exfunction you want to use.
>
>    ```shell
>    vim Mbaysalt/Configurefiles/INSTALL.conf
>    ```
>
>    **From**
>
>    > \# Name     : INSTALL.conf
>    > \# Author   : Christmas
>    > \# Time     : 2023.11.22
>    > \# Abstract : 安装配置文件
>    >
>    > m_map     = .TRUE.
>    > matFigure = .TRUE.
>    > matFVCOM  = .TRUE.
>    > matNC     = .TRUE.
>    > matWRF    = .TRUE.
>    > nctoolbox = .TRUE.
>    > t_tide    = .TRUE.
>    > cdt       = .TRUE.
>    > gshhs     = .TRUE.
>    >
>
>    **To**
>
>    > \# Name     : INSTALL.conf
>    > \# Author   : Christmas
>    > \# Time     : 2023.11.22
>    > \# Abstract : 安装配置文件
>    >
>    > m_map     = .FALSE.
>    > matFigure = .TRUE.
>    > matFVCOM  = .TRUE.
>    > matNC.    = .TRUE.
>    > matWRF    = .TRUE.
>    > nctoolbox = .FALSE.
>    > t_tide    = .FALSE.
>    > cdt       = .FALSE.
>    > gshhs     = .FALSE.
>    >
> 3. Matlab
>
>    ```matlab
>    addpath('Mbaysalt')
>    run Mainpath.m
>    ```

## Contains

* [Mbaysalt](https://github.com/ChristmasZCY/Mbaysalt)
* [cprintf](https://www.mathworks.com/matlabcentral/fileexchange/24093-cprintf-display-formatted-colored-text-in-the-command-window)
* [INI](https://ww2.mathworks.cn/matlabcentral/fileexchange/55766-ini)
* [iniconfig](https://ww2.mathworks.cn/matlabcentral/fileexchange/24992-ini-config)
* [inifile](https://ww2.mathworks.cn/matlabcentral/fileexchange/2976-inifile)
* [matFVCOM](https://github.com/SiqiLiOcean/matFVCOM)
* [matWRF](https://github.com/SiqiLiOcean/matWRF)
* [matFigure](https://github.com/SiqiLiOcean/matFigure)
* [matNC](https://github.com/SiqiLiOcean/matNC)
* [struct2ini](https://ww2.mathworks.cn/matlabcentral/fileexchange/22079-struct2ini)
* [m_map](https://www.eoas.ubc.ca/~rich/map.html)
* [t_tide](https://www.eoas.ubc.ca/~rich/#T_Tide)
* [CDT](https://github.com/chadagreene/CDT)
* [nctoolbox](https://github.com/nctoolbox/nctoolbox)
