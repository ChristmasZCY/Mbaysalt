# Change Log

## v2.6.0 - 2026-09-12

- `preuvh2` 现在按请求的分潮顺序提取潮位调和常数，避免指定 `tideList` 时振幅、相位与分潮名称错配。
- `preuvh2` 为 AreaBin 生成 `area_meta.json`，在提供 TPXO 源目录时校验模型网格与分潮范围，避免静默复用不匹配的缓存。
- `preuvh2` 使用独立临时控制文件并在退出时自动清理，避免并发调用互相覆盖。
- `preuvh2` 直接从 AreaBin 高度调和常数文件读取分潮列表，不再为获取 `conList` 读取并插值全部分潮。
- `preuvh2` 按输出类型分别校验 `h_area` 与 `uv_area` 的分潮列表，避免潮位与潮流文件不一致时延迟到计算阶段才失败。
- `preuvh2` 按 TPXO 源网格分辨率扩展裁剪边界，并按最小环形经度范围处理 `-180–180`、`0–360` 及跨日界线输入；同时修正 Atlas 裁剪脚本读取 UV 文件列表时误用高度文件索引的问题。
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
