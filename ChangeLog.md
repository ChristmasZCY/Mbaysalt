# Change Log

## v3.0.0 - 2026-11-19

- 配置数组不再执行代码：数值、算式、冒号范围、嵌套方括号以及 pi、Inf、true、false 按数值读取，其余内容按原规则读成文本列表；以数字开头的键也照常转换值。
- 安装清单按手动指定、当前目录、仓库默认的顺序选择。新命令行克隆的依赖仅保存无凭据的来源地址，后续访问私有库可能需要重新认证；克隆失败时给出警告并继续安装。
- INSTALL.json 的 git.method 写错时直接报错，并指出所在行。
- 旧版 MATLAB 链接操作支持带空格和引号的路径；日志原样打印消息，并在时间戳中显示本地时区和 UTC 偏移。
- 站点 XML 下载在写入前拒绝越出工作目录的路径；同一会话的多个并行进度条分别保存各自的进度。

- 发行版本升级到 v3.0.0，v2.6.0 功能概述并入 [DONE](Docs/DONE.md)。
- README 与 README_zh 恢复 Contains 第三方组件清单。
- 新增 GitHub Actions 回归测试与 `Tests/run_all_tests.m`：干净路径下由 ST_Mbaysalt 安装测试依赖后运行全部用例，并缓存 MATLAB 安装以缩短后续运行时间。
- matFVCOM、matFigure、nctoolbox 子模块指针改回上游提交，修复递归克隆找不到本机补丁提交的问题。
- ST_Mbaysalt 不再依赖 Mapping Toolbox 的 `struct2array`，未装该工具箱时也能安装依赖。
- preuvh2 在无法使用 Parallel Computing Toolbox 时提示并改为串行计算，不再报错。
