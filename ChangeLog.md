# Change Log

## v3.0.0 - 2026-11-19

- 发行版本升级到 v3.0.0，v2.6.0 功能概述并入 [DONE](Docs/DONE.md)。
- README 与 README_zh 恢复 Contains 第三方组件清单。
- 新增 GitHub Actions 回归测试与 `Tests/run_all_tests.m`：干净路径下由 ST_Mbaysalt 安装测试依赖后运行全部用例，并缓存 MATLAB 安装以缩短后续运行时间。
- matFVCOM、matFigure、nctoolbox 子模块指针改回上游提交，修复递归克隆找不到本机补丁提交的问题。
- ST_Mbaysalt 不再依赖 Mapping Toolbox 的 `struct2array`，未装该工具箱时也能安装依赖。
- preuvh2 在无法使用 Parallel Computing Toolbox 时提示并改为串行计算，不再报错。
