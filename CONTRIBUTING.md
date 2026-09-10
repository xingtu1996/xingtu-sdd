# 贡献指南 · xingtu-sdd

感谢你愿意花时间。这是一个**个人维护的开源项目**，不是公司级大仓——所以规矩少、反馈快、但对质量不放水。

## 先读这三句

1. **小 PR 最受欢迎。** 改一个错字、补一个例子、修一条失效链接，都是真贡献。
2. **动手前先开 Issue。** 尤其是新功能/大改动——先对齐，再写代码，省得白干。
3. **别提交隐私与公司数据。** 这条是红线，见下方「提交前自检」。

## 怎么贡献

| 方式 | 门槛 | 说明 |
|------|------|------|
| ⭐ Star / Watch | 0 | 最便宜的支持，也是我判断"要不要继续投入"的信号 |
| 🐛 提 Issue | 低 | 报错、错字、跑不通、文档看不懂——**早期最有价值的贡献** |
| 📝 文档 / 样例 PR | 低 | 最好的第一个 PR：补例子、修 typo、补使用场景 |
| 🔧 代码 / 新能力 PR | 中 | **必须先开 Issue 对齐**，避免方向跑偏 |

## 流程

```bash
# 1. fork 并克隆
git clone git@github.com:<你的账号>/xingtu-sdd.git && cd xingtu-sdd

# 2. 拉分支（一 PR 一主题）
git switch -c feat/你的改动

# 3. 改完自检（见下），然后提交
git commit -m "feat: 一句话说明改了什么"

# 4. 推送并开 PR，正文里写清「为什么改」+ 关联 Issue
git push origin feat/你的改动
```

**分支前缀**：`feat/` `fix/` `docs/` `chore/` `refactor/` `test/`
**提交格式**：Conventional Commits，中文描述即可 —— `type(scope): 简述`
**合并方式**：squash merge，合完删分支

## 提交前自检（红线）

- [ ] **无真实身份**：不含本人/他人的真实姓名、手机号、个人邮箱、住址
- [ ] **无公司数据**：不含内部代码、工单、花名册、客户名、内网域名、未公开的业务数字
- [ ] **无密钥**：不含 API key / token / AppSecret / 私钥；配置一律走环境变量或 `.env.example`
- [ ] commit 身份用 GitHub noreply（`ID+USERNAME@users.noreply.github.com`），**禁用公司邮箱**
- [ ] 新增的依赖有明确理由（本项目偏好**零依赖 / 轻量**）

自查命令（若仓库带该脚本）：

```bash
python3 tools/privacy_scan.py --fail-fast
```

## AI 辅助贡献

欢迎用 AI agent 辅助写码，但请在 PR 描述里注明「AI 辅助」，并**自己先审一遍**——
你为提交的内容负责，不是模型负责。AI 生成但没读过就提交的代码，我会直接 close。

## 响应时间（诚实版）

一个人维护，别期待 24h SLA：

- Issue 首次响应：**≤ 7 天**
- PR 首次 review：**≤ 14 天**
- 超期没动静，直接在 Issue 里 ping 我，不会介意

## 许可

提交即表示你同意本项目在 [LICENSE](./LICENSE) 下发布你的贡献。

---

> 开源矩阵导航：https://github.com/xingtu1996 —— AI 工程化 / Agent Harness / 省 Token 实践，17 仓互连。
