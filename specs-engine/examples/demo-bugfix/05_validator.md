# 验证计划：下单接口超时降级修复

> Ticket: TICKET-123 | 日期: 2026-09-07 15:00 | 状态: ✅

> 📜 可执行验证脚本集。写完即跑，失败修码重跑至全过。

---

## 一、数据准备

```sql
-- 造一张测试单（TEST_001），置初始状态 'PENDING'
-- INSERT INTO t_order(id, status, idempotency_key) VALUES('TEST_001','PENDING','ik_test_001');
```

## 二、验证用例

### TC-API-01: 正常下单（库存正常）

```bash
curl -X POST 'http://localhost:8080/orders' -H 'Content-Type: application/json' \
  -d '{"sku":"A-1","qty":1,"idempotency_key":"ik_test_002"}'
```

**预期**：HTTP 200，响应含 `orderId`，订单状态为 `CONFIRMED`

### TC-API-02: 库存超时（模拟库存接口延迟 2s+）

```bash
curl -X POST 'http://localhost:8080/orders' -H 'Content-Type: application/json' \
  -d '{"sku":"A-1","qty":1,"idempotency_key":"ik_test_003"}'
```

**预期**：HTTP 200 非 500，返回业务态 `QUEUED`（排队重试），无异常堆栈日志

### TC-API-03: 同 key 重放（幂等）

```bash
curl -X POST 'http://localhost:8080/orders' -H 'Content-Type: application/json' \
  -d '{"sku":"A-1","qty":1,"idempotency_key":"ik_test_002"}'
```

**预期**：返回首次 orderId，不重复创建

## 三、数据一致性验证

### 链 1: 超时降级后补偿推进

```sql
-- Step 1: 验证 TC-02 订单状态 = QUEUED
-- SELECT status FROM t_order WHERE id = (SELECT id FROM t_order WHERE idempotency_key='ik_test_003');
-- Step 2: 等补偿 worker 跑完 → 状态应为 CONFIRMED，预留记录 = 1 条
```

**预期**：QUEUED → CONFIRMED，补偿不留重复预留

## 四、安全条件验证

### 4.1 退出条件

| # | 检查项 | 命令 | 预期 |
|---|--------|------|------|
| 1 | 补偿重试 3 次上限 | 观察日志 | 超 3 次转人工标记，不再自动重试 |

### 4.2 幂等条件

| # | 检查项 | 命令/SQL | 预期 |
|---|--------|---------|------|
| 1 | 幂等记录写入 | `SELECT count(*) FROM t_order WHERE idempotency_key='ik_test_002'` | = 1 |
| 2 | 重放不重复执行 | TC-03 跑 2 次 | 预留记录仍 = 1 条 |

### 4.3 回滚条件

| # | 检查项 | 命令 | 预期 |
|---|--------|------|------|
| 1 | 配置先于代码发布 | 发布顺序检查 | 先 YAML 后代码，可回滚 |
| 2 | 异常时不部分写入 | 杀库存服务后下单 | 订单留 PENDING/QUEUED，无半成品 |

## 五、合规检查

| # | 检查项 | 命令 | 预期 |
|---|--------|------|------|
| 1 | 资源增减对称 | 预留表 count 前后对比 | 释放 = 预留逆操作 |
| 2 | 事务回滚验证 | 模拟异常 | 数据不变 |
| 3 | 铁律/宪法违规 | 对照 laws.md | 零违规 |

## 六、合并后对账

| AC# | 结论 | 证据 |
|-----|:---:|------|
| AC-1 正常下单不受影响 | ✅ | TC-01 200 + 状态 CONFIRMED |
| AC-2 超时不返 500 | ✅ | TC-02 200 + QUEUED，无堆栈日志 |
| AC-3 幂等重放安全 | ✅ | TC-03 单条预留 |

### 审核签字

| 项 | 值 |
|------|------|
| 产品/需求视角审核 | alice@2026-09-07 15:50 ✅ |
| 结论 | ✅ 可合并 |
