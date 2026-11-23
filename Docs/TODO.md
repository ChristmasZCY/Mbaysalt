# Mbaysalt 待办

按状态分组，每项一行；已完成事项移入 [DONE](DONE.md)。

## 安全维护

- GSW 下载地址暂缓改为 HTTPS；重新确认后核实同版本官方地址并更新 INSTALL.json。
- 旧版 ln/readlink 的 Windows 快捷方式分支待实测创建、读取和覆盖；前提：Windows 旧版 MATLAB 环境。
- parfor_pgb 进度隔离待在 Processes 池复核；前提：本机进程池能正常启动。

## 待发布

- **科学计算配套发布**：温跃层、障碍层与声速的批处理和分组优化，及 MakeTilesService 读取与预取；前提：用户授权，跨仓见 IOCEAN TODO「制瓦服务更新」。

## 待线上验收

- **科学计算上线验收**：用多日制瓦批次和失败温跃层任务重跑核验科学输出、缺测掩码、内存与墙钟，核查上游版本差异，完成 ST 初始化与 API/队列验收；阻塞：待发布。
