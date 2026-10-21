# Change Log

## v2.6.0 - 2026-09-12

- 按用户确认实施温跃层 3 倍 PCHIP 安全上界、有界深度分组及单候选区间形状修复，沿用 1 米插值、阈值、选段和原索引。原生回归与全球四小时四输出逐值一致，函数 127.69→59.92 秒（约 2.13 倍），计算 RSS 峰值基本持平；Engine 与四小时分块保持，测试已清理、未部署，见[实施记录](Docs/DONE.md#thermocline-refinement-implementation-20261021)。

- 记录温跃层进一步优化的临时验证与待实施计划：更紧安全上界配合有界深度分组，在两个全球小时中约快 2.14/2.17 倍、四输出逐值相同；复现单区间向量形状边界并验证临时修复。用户要求先计划，原代码未改；服务器测试已恢复清理，不能作为完整制瓦收益，详见[记录](Docs/DONE.md#thermocline-refinement-test-20261021)。

- 经用户确认，声速在深度广播基础上采用 Horner 因式分组，减少重复幂运算及临时数组；Del Grosso 系数、输入校验和接口保持。新增高精度参考值回归；服务器真实全球小时三轮中位数约快 2.365 倍，single 最大差 0.0003662109375 m/s、缺测掩码不变，不作为整批制瓦提速或位级一致承诺。未部署，详见[本轮记录](Docs/DONE.md#sound-horner-20261021)。

- 障碍层在压力复用上批量寻找阈值交点；温跃层以保守区间筛选减少无效插值，保留原 1 米 PCHIP、阈值与最大平均梯度连续段。海洋锋新增默认关闭的纯温度模式，供 MakeTilesService 只传表层温度，两仓需配套发布；声速保留深度广播与原公式，Engine 初始化不变。服务器三海域及完整全球小时全部逐值一致，全球单轮障碍层约快 8.62 倍、温跃层约快 2.32 倍，非整批耗时。原生回归与 MakeTilesService 117 项相关测试通过，未部署；沿用 Docs 目录维护交付边界，见[记录](Docs/DONE.md#science-batch-20261021)。

- `ST_Mbaysalt` 原生 MATLAB Git 克隆前按 HTTPS、HTTP、ALL 顺序读取大小写代理环境变量，临时设置 `https_proxy`，并在克隆成功或报错后恢复原值；没有代理时保持原行为，不修改全局 Git 配置。
- `preuvh2` 现在按请求的分潮顺序提取潮位调和常数，避免指定 `tideList` 时振幅、相位与分潮名称错配。
- `preuvh2` 为 AreaBin 生成 `area_meta.json`，在提供 TPXO 源目录时校验模型网格与分潮范围，避免静默复用不匹配的缓存。
- `preuvh2` 使用独立临时控制文件并在退出时自动清理，避免并发调用互相覆盖。
- `preuvh2` 直接从 AreaBin 高度调和常数文件读取分潮列表，不再为获取 `conList` 读取并插值全部分潮。
- `preuvh2` 按输出类型分别校验 `h_area` 与 `uv_area` 的分潮列表，避免潮位与潮流文件不一致时延迟到计算阶段才失败。
- `preuvh2` 按 TPXO 源网格分辨率扩展裁剪边界，并按最小环形经度范围处理 `-180–180`、`0–360` 及跨日界线输入；同时修正 Atlas 裁剪脚本读取 UV 文件列表时误用高度文件索引的问题。
- `preuvh2` 计算裁剪范围时仅读取 TPXO 网格头，并在逐点预报前复用时间数组和潮汐结构模板，减少大网格 I/O、重复文件加载及时间转换。
- `preuvh2` 批量提取潮流椭圆参数，所有请求分潮共用一次网格、水深和目标点预处理，避免按分潮重复读取 AreaBin 网格。
- `preuvh2` 新增 `Predictor='ttide'|'tmd3'`，默认继续使用 T_Tide；TMD3 模式复用现有 AreaBin 和空间插值结果，通过 `tmd_harp` 矩阵化重建明确请求的分潮，不推算次要分潮。
- TMD3 模式直接使用插值后的复数潮位与潮流调和常数，潮流保持 `m/s` 输出，并跳过不需要的潮流椭圆数组；未加载 TMD3 时给出明确的 MATLAB 路径提示，不自动修改搜索路径。
- 支持将指定的多个 MATLAB 函数及其实际依赖构建为供 Python 调用的 `mbaysalt` 包。
- 依赖导出现在保留源码目录结构，避免包目录、类目录或同名文件在复制时失效或互相覆盖。
- Python 包构建改为非交互执行，便于命令行和持续集成环境使用。
- Python 构建脚本位于 `Scripts/build_python_package.m`，README 和 `Contents.m` 已补充构建及调用说明。
- `makedepends` 和 Python 构建脚本使用传统 `varargin` 名称-值参数，以兼容不支持 `options` 参数块的 MATLAB 版本。
- 保留 `arguments` 输入声明，并补充 `Scripts` 及相关函数的 `functionSignatures.json` 定义。
- `.VERSION` 与 `Contents.m` 当前版本统一为 `v2.6.0`。
- `build_python_package` 新增 `ctf`、`so` 和 `coder` 三种构建目标；Compiler SDK 共享库依赖 MATLAB Runtime，Coder 共享库需显式提供入口参数类型。
- 三个示例函数已移除不兼容 Coder 的动态选项赋值、动态 cell 分段和深度维度重赋值，可作为同一个 Coder 共享库的多入口。
- 共享库在 Linux/macOS 上自动使用 `lib` 前缀；Coder 目标禁用 OpenMP 以减少部署依赖，并在报告构建失败时返回明确错误。
- 构建前恢复 MATLAB 默认搜索路径，再显式添加 Toolbox 路径，降低用户环境路径对依赖分析的干扰。
- 构建时排除 MATLAB `userpath`，避免将本机 `startup.m` 及其个人配置意外打入 CTF 或共享库。
- 三种构建目标成功后均生成统一的 `api.json`，仅列出当前入口函数的参数、返回值、维度、单位、目标平台及 Runtime/绑定要求。
- 新增兼容旧版 MATLAB 的 `parse_varargin`，以接近 `read_varargin` 的调用方式统一解析名称-值参数与独立开关，并返回未识别参数；Python 构建脚本和 `calc_weather_front` 已改用该函数。
- 修正 `calc_sound_speed.m` 主函数名称与文件名不一致的问题，并移除其对 `len.m` 的非必要依赖；原 `Del_Grosso_cn` 名称不再作为入口。
- 构建生成物需要使用与构建时 MATLAB 版本、操作系统和 CPU 架构匹配的 MATLAB Runtime；可用 Python 版本以对应 MATLAB 版本的生成说明为准。
