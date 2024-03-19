
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
t_tide，t_predict输入的lat是WGS84坐标
8. Example_TMD TMD中的u v U V z Ell --> u v U V z 应该同tmd_extract_HC，Ell不知道
9. FVCOM开边界输入两种情况，1种是obc的点上，2是双排网格，因为u v在cell上，所以要双排
10. interp_2d_calc_weight的QU是适用于WRF的，有形变的双线性（QU means Quadra）
11. interp_2d_calc_weight的ID是反距离加权
12. interp_2d_calc_weight的BI基本不用，用的基本上GLOBAL_BI，x,y只用给一列
13. create_tidestruc的0部分是指误差，如果t_tide会给出误差，但是手动制作则不需要了
14. ESMF网格的三种类型，grid（有结构），mesh（无结构，三角形），scatter（点）
15. read_2dm的tail指得是剩下的部分
16. 2d是指垂向积分，正压是指温盐为常数
17. 7个方程，u,v,w,t,s,连续方程,海水状态方程(密度不仅与温度、压强有关，还与盐度有关）
18. 大气状态方程(大气状态方程)
19. 有关FVCOM开边界在手册的327页
20. ESMF_RegridWeightGen(https://earthsystemmodeling.org/docs/release/latest/ESMF_refdoc.pdf)
