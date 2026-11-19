# Mbaysalt 待办

按状态分组，每项一行；已完成事项移入 [DONE](DONE.md)。

## 待发布

- **科学计算配套发布**：发布阈值批处理、障碍层逐层密度、温跃层细化筛选/有界分组、候选区间与节点索引复用、纯温度模式与声速 Horner 分组，以及 MakeTilesService 表层读取、垂向诊断分块与提前预取；前提：用户授权发布。

## 待线上验收

- <a id="thermocline-mask-keys-20261107"></a><a id="barrier-profile-index-reuse-20261107"></a>**温跃层与障碍层优化验收**：发布后结合 MakeTilesService 正常多日批次核验科学输出、输入等待、主机内存与端到端墙钟；阻塞：待发布。
- <a id="thermocline-short-profile-20261028"></a>**短剖面缺测验收**：部署 NaN 修复后重跑失败温跃层任务并校验正常海域与缺测掩码，核查上游版本差异；阻塞：待发布。
- <a id="science-batch-20261021"></a><a id="barrier-layer-streaming-20261021"></a><a id="science-hotspot-block-test-20261022"></a>**批处理生产验收**：正式 ST 初始化、API/队列与完整生产验收，完整多日制瓦跟踪见 IOCEAN 父仓 `docs/TODO.md#matlab-science-batch-20261021`；阻塞：待发布。

## 长期约束

- **本地验证不作上线证明**：数据库执行、部署与验收各自取得实际结果后才移入 DONE。
