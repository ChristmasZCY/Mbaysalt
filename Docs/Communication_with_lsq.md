
1. 先差值到netsting点再滤潮还是先滤潮再插值到nesting --> 先滤波再插值，先对原数据处理好再插值
2. uv，zeta要分开做吗 --> 要分开做， uv的调和常数不能用来给zeta用
3. uv调和分析每层都要做吗 --> 是的
4. uv只能输入complex吗，如果只输入u？ --> uv必须complex
5. 为什么Z用tmd_extract_HC，uv用tmd_ellipse     --> 可能是传入t_predict需要ellipse的结果，extrac_HC可能不行
6. tmd_extract_HC的'z','u','v','U','V'分别是什么
          'z' - elvation (m) 水位
          'u','v' - velocities (cm/s) 速度
          'U','V' - transports (m^2/s); 传输，注意U，V的单位
7. [nesting_lon, nesting_lat] = sp_proj('1802', 'inverse', f.x, f.y, 'm');    --> 从直角坐标系转为经纬度坐标系
8. t_tide，t_predict输入的lat是WGS84坐标
9. Example_TMD TMD中的u v U V z Ell --> u v U V z 应该同tmd_extract_HC，Ell不知道
10. FVCOM开边界输入两种情况，1种是obc的点上，2是双排网格，因为u v在cell上，所以要双排
11. interp_2d_calc_weight的QU是适用于WRF的，有形变的双线性（QU means Quadra）
12. interp_2d_calc_weight的ID是反距离加权
13. interp_2d_calc_weight的BI基本不用，用的基本上GLOBAL_BI，x,y只用给一列
14. create_tidestruc的0部分是指误差，如果t_tide会给出误差，但是手动制作则不需要了
15. ESMF网格的三种类型，grid（有结构），mesh（无结构，三角形），scatter（点）
16. read_2dm的tail指得是剩下的部分
17. 2d是指垂向积分，正压是指温盐为常数
18. 7个方程，u,v,w,t,s,连续方程,海水状态方程(密度不仅与温度、压强有关，还与盐度有关）
19. 大气状态方程(大气状态方程)
20. 有关FVCOM开边界在手册的327页
21. ESMF_RegridWeightGen(https://earthsystemmodeling.org/docs/release/latest/ESMF_refdoc.pdf)
22. FVCOM要求三角形顺时针
23. 河流网站 GRDC（Global Runoff Data Centre）：http://www.bafg.de/GRDC/EN/01_GRDC/13_dtbse/database_node.html
24. 滤潮长时间序列用pl66tn就可以，准确度很高
25. 验证滤潮后的环流准不准 --> 经验看看本地区的主要环流有没有（基础），拿到长时间的观测值进行滤潮对比
26. gfvcom1没有加潮流是因为时间紧，加上潮流算的流动会比只算环流准，因为潮流和环流不是简单的线性关系，意味着潮流环流不能简单的相加
27. 热通量 = 长波辐射 + 短波辐射 + 感热 + 潜热 <a href='https://ningchenhui.github.io/Earth-Science/Ocean/Physical-Oceanography-Coarse/ocean1120/'> 详细介绍</a>
             黑体辐射B(T) = σT^4 T为绝对温度 <a href="https://baike.baidu.com/item/%E9%BB%91%E4%BD%93%E8%BE%90%E5%B0%84/516583"> 黑体辐射</a> 
             频率越高，能量越多(eg.紫外线杀菌)
             c = λμ 能量越大，频率越高，波长越短--> 太阳为短波辐射。云/海面发出的，温度较低的发出的为长波辐射
             感热(eg. 触摸桌子，温度差产生的)
             潜热(eg. 相变 吸收或放出的热量，液态水变为水蒸气)
             FVCOM 输入Shortwave 和NetHeat
28. WRF的SWDOWN是指到达海面的总短波辐射，对应的是MITgcm的[exf](https://mitgcm.readthedocs.io/en/latest/phys_pkgs/exf.html)包中的swdown
29. WRF的GLW是指到达海面的总长波辐射，对应的是MITgcm的exf包中的lwdown
30. MITgcm的exf包中的swflux是指WRF2FVCOM产出的ShortWave，等于WRF中的SWDOWN*(1-ALBEO)=GSW，ALBEO为反照率，大约为0.04（WRF中）
31. 冬天穿羽绒服保暖却不在周围围一圈镜子保暖---> 镜子反射短波辐射，但不反射长波辐射
32. MITgcm的exf包中的swflux
          ​	-swflux=( swdown - ice and snow absorption - reflected) `ice and snow absorption`不计
          ​	-swflux=( swdown -- reflected) = SWDOWN*(1-ALBEO) 
33. 综上，MITgcm的exf的swflux，lwflux为WRF2FVCOM的Shortwave和Longwave；swdown，lwdown为WRF直接输出的swdown和glw
34. MITgcm的exf包中的lwflux中的emitted为黑体辐射发出的热量[`= 0.98*5.6697*((TS*0.01)**4)`](https://github.com/SiqiLiOcean/WRF2FVCOM/blob/main/module_coare.f90)
35. MITgcm的exf包中的apressure为WRF中的PSFC
36. [swdown*(1-albedo)+glw-0.95*5.67*10-8*(tsk)**4      这个就是计算净辐射的公式，我的比辐射率取为0.95](https://bbs.06climate.com/forum.php?mod=viewthread&tid=18079)
37. [MITgcm同时打开mnc和二进制](https://mitgcm.readthedocs.io/en/latest/getting_started/getting_started.html#input-output-files) 在`data`的`PARM03`部分添加`outputTypesInclusive=.TRUE.,`
38. 热启动还能导入网格吗 --> 不能
39. 为什么会采用UTM，因为双精度会计算的慢，单精度如果经纬度的话精确度低，所以会采用UTM

          
