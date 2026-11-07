# Mbaysalt 待办

当前版本：v2.6.0。只记录未完成的发布、验证和决策。

<a id="barrier-profile-index-reuse-20261107"></a>

- [ ] 用户发布障碍层数组复用后，在完整多日制瓦中核验两项科学输出、输入等待、CPU及端到端墙钟。双海域短块函数均值减少15.0%／26.2%，批量PCHIP候选已测试撤回。[本地实现与隔离比测](DONE.md#barrier-profile-index-reuse-20261107)

- [ ] 部署温跃层短剖面 NaN 修复，重跑失败的温跃层任务并校验正常海域与缺测掩码；独立核查上游原始/插值文件版本和缺测差异。本轮不修改下载数据、GPU 配置或线上服务，见[本地修复记录](DONE.md#thermocline-short-profile-20261028)。

- [ ] 配套发布本仓的阈值批处理及障碍层逐层密度、温跃层细化筛选/有界分组、候选区间及节点索引复用、单区间修复、纯温度模式和声速 Horner 分组，以及 MakeTilesService 的表层读取、垂向诊断读取前纬度分块与提前预取。2026-10-22 缓存尺寸修复后，服务器原生/Engine、四项全球四小时真实包装调用、块大小逐值对照及全天声速内存测量已通过；额外温跃层候选更慢未采用，详见[最新记录](DONE.md#science-hotspot-block-test-20261022)。正式ST初始化、API/队列及完整生产验收仍待配套发布。完整多日制瓦、并发内存和耗时验收统一跟踪于 IOCEAN 父仓 `docs/TODO.md#matlab-science-batch-20261021`，本地与服务器临时验证见 [批处理记录](DONE.md#science-batch-20261021)及[逐层密度实施记录](DONE.md#barrier-layer-streaming-20261021)。
