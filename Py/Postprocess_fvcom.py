#!/Users/christmas/opt/anaconda3/bin/python3
# -*- coding: utf-8 -*-
#  Date           : 2023-03-25 15:00:00
#  Author         : Christmas
#  Email          : 273519355@qq.com
#  Project        : Mbaysalt_christmas
#  Python Version : 3.9.14
#  Abstract       : 
"""
Postprocess fvcom by matlab
"""
import os
import subprocess
import sys
import time

import matlab
import matlab.engine
from christmas.commonCode import get_date, osprint
from christmas.read_conf import read_conf


# 1. 读取配置文件
def read_config(_config_file):
    """
    读取配置文件,并写入EndDate
    :param _config_file: 配置文件路径
    :return: 配置文件信息
    """
    para_conf = read_conf(_config_file)
    Control_dir = para_conf['ControlDir']
    Input_dir = para_conf['ModelOutputDir']
    Standard_dir = para_conf['StandardDir']
    Postprocess_dir = para_conf['PostprocessDir']
    StartDate = int(para_conf['StartDate'])
    DuringDate = int(para_conf['DuringDate'])
    Method_interpn = para_conf['Method_interpn']
    Switch_Cal_hourly = para_conf['Switch_Cal_hourly']
    Switch_Cal_daily = para_conf['Switch_Cal_daily']
    if not os.path.exists(Standard_dir):
        os.makedirs(Standard_dir)  # 创建输出文件夹
    
    Dir = {
        'Control_dir': Control_dir,
        'Input_dir': Input_dir,
        'Standard_dir': Standard_dir,
        'Postprocess_dir': Postprocess_dir,
    }
    Date = {
        'StartDate': StartDate,
        'DuringDate': DuringDate,
    }
    Method = {
        'Method_interpn': Method_interpn,
    }
    Switch = {
        'Switch_Cal_hourly': Switch_Cal_hourly,
        'Switch_Cal_daily': Switch_Cal_daily,
    }
    return Dir, Date, Method, Switch


def wr_status(_status_file, _status):
    """
    写入状态文件
    :param _status_file: 状态文件
    :param _status: 状态
    :return: 无
    """
    Control_dir = read_config(_status_file)[0]['Control_dir']
    os.chdir(Control_dir)
    subprocess.call(f"sed -i 's/Postprocess=.*/Postprocess=  {str(_status)}/g' {_status_file}", shell=True, cwd=Control_dir)


def Postprocess_fvcom(_config_file, _date, _during_date):
    """
    后处理主函数
    :param _config_file: 配置文件
    :param _date: 需要被处理的日期
    :param _during_date: 处理的天数
    :return:
    """
    try:
        call_matlab(_config_file, _date, _during_date)
    except KeyboardInterrupt:
        wr_status(_config_file, 'Post Break')
        osprint(f'"--------------------  \033[35m 进程被用户强行终止 \033[0m  --------------------"')
        raise


def call_matlab(_config_file, _date, _during_date):
    """

    :param _config_file:
    :param _date:
    :param _during_date:
    """
    Postprocess_dir = read_config(_config_file)[0]['Postprocess_dir']
    Method_interpn = read_config(_config_file)[2]['Method_interpn']
    Switch_Cal_hourly = read_config(_config_file)[3]['Switch_Cal_hourly']
    Switch_Cal_daily = read_config(_config_file)[3]['Switch_Cal_daily']
    # 写入status信息
    wr_status(_config_file, 'Doing')
    
    TIC = time.time()
    
    sys.path.append(Postprocess_dir)
    t = matlab.engine.start_matlab()
    t.addpath(Postprocess_dir)
    # t.run(f'{Postprocess_dir}/Mbaysalt_christmas/Mainpath.m', nargout=0)
    t.ST_Mbaysalt(nargout=0)
    if Switch_Cal_hourly:
        t.Postprocess_fvcom(_config_file, 'hourly', float(_date), float(_during_date), nargout=0)
    if Switch_Cal_daily:
        t.Postprocess_fvcom(_config_file, 'daily', float(_date), float(_during_date), nargout=0)
    t.quit()
    
    TOC = time.time()
    print(f"Postprocess_FVCOM_SCS.py 耗时：{TOC - TIC} s")
    
    # 写入status信息
    wr_status(_config_file, 'Done')
    osprint(f'"Postprocess_FVCOM_SCS {str(_date)} is done !"')


def get_num():
    """
    获取当前时间和num
    :return: _date, _num
    """
    _date = get_date()
    _num = ''
    _num = sys.argv[2] if len(sys.argv) >1 else '7'
    return _date, _num


if __name__ == '__main__':
    # 配置文件
    config_file = '/home/ocean/ForecastSystem/FVCOM_Global/Postprocess/Mbaysalt_christmas/Configurefiles/Post_fvcom.conf'
    date = int(read_config(config_file)[1]['StartDate'])
    num = int(read_config(config_file)[1]['DuringDate'])
    osprint(f'"{os.path.basename(__file__)} {date} {num}"')
    Postprocess_fvcom(_config_file=config_file, _date=date, _during_date=num)
