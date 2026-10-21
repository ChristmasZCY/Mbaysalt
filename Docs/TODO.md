# Mbaysalt 待办

当前版本：v2.6.0。只记录未完成的发布、验证和决策。

- [ ] 配套发布本仓的阈值批处理及障碍层逐层密度、温跃层细化筛选/有界分组、候选区间及节点索引复用、单区间修复、纯温度模式和声速 Horner 分组，以及 MakeTilesService 的表层读取、垂向诊断读取前纬度分块与提前预取。最新隔离Engine启动尚未通过，需复验完整MATLAB调用及全天声速返回数组；本机原生结果不代替服务器集成。完整多日制瓦、并发内存和耗时验收统一跟踪于 IOCEAN 父仓 `docs/TODO.md#matlab-science-batch-20261021`，本地与服务器临时验证见 [批处理记录](DONE.md#science-batch-20261021)及[逐层密度实施记录](DONE.md#barrier-layer-streaming-20261021)。
