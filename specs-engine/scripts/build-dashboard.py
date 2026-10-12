#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
specs-engine 看板 —— **spec 的一个标准组件**（与 00_README / laws / 01~05 / execution-log 并列）

用法:
    python3 build-dashboard.py <spec目录>          # 单 spec 看板 → <spec>/spec-dashboard.html（默认）
    python3 build-dashboard.py <specs目录> --all   # 全局列表看板 → <specs>/specs-dashboard.html

设计立场（为什么是这些图、不是别的图）:
    用户要的是**执行的过程**，不是产物盘点。所以:
      ✅ 推进轨迹（按天活动，看空窗）· 依赖前沿（现在该做哪个）· 卡点（为什么停着）
         · 任务 burnup（范围会变 → 用 burnup 不用 burndown）· 阶段时间线 · 事件流
      ❌ 不做工时/速度/效率（本地痕迹推不出来，做了就是伪造精度）
      ❌ 不做 CFD 累积流图（需要状态流转历史，我们只有文件 mtime + 事件日志）
    判据是业内那条决策测试：「这个数涨 20%，我会做什么不同？」答不上来就不放。
    真相源永远是目录里的那些 .md 文件，看板只是渲染。
"""
import argparse
import os
import re
import sys
import html
from datetime import datetime, date, timedelta

SKIP_DIRS = {"_TEMPLATE", "node_modules", ".git"}
ST = {"⬜": ("待启动", "todo"), "🔵": ("进行中", "ing"),
      "🟡": ("待验证", "confirm"), "✅": ("完成", "done")}
STALE_DAYS = 30
STALL_DAYS = 7
ELOG_WARN_KB = 60

COMPONENTS = [
    ("00", "00_README.md", "自述", "导航 + 状态 + 一句话 + 索引"),
    ("—", "laws.md", "规则", "方法论薄快照（子 Spec 不建，继承父）"),
    ("01", "01_analysis.md", "分析", "现状 / 根因 / 影响面 / 方案对比"),
    ("02", "02_requirements.md", "需求", "验收标准 AC + 安全三条件"),
    ("03", "03_design.md", "设计", "架构决策 + 接口 + 数据流"),
    ("04", "04_tasks.md", "任务", "任务清单 + 依赖图 + 覆盖矩阵"),
    ("05", "05_validator.md", "验证", "可执行验证用例（不是事后文档）"),
    ("—", "execution-log.md", "日志", "append-only 事件流 = 状态事实源"),
    ("—", "deliverables", "产出", "交付物目录（按需）"),
]
PHASES = [("01_analysis.md", "分析"), ("02_requirements.md", "需求"),
          ("03_design.md", "设计"), ("05_validator.md", "验证"), ("04_tasks.md", "任务")]
CONTI_RE = re.compile(r"(继续会话提示词|断点续传|STATUS\.md|会话记录)")


def read(p):
    try:
        with open(p, encoding="utf-8", errors="replace") as f:
            return f.read()
    except OSError:
        return ""


def esc(s):
    return html.escape(str(s if s is not None else ""))


def mtime(p):
    try:
        return os.path.getmtime(p)
    except OSError:
        return 0


def days_ago(ts):
    return (date.today() - date.fromtimestamp(ts)).days if ts else 0


def dstr(ts, with_time=True):
    if not ts:
        return "—"
    return datetime.fromtimestamp(ts).strftime("%Y-%m-%d %H:%M" if with_time else "%m-%d")


def first_para(text):
    for block in re.split(r"\n\s*\n", text):
        b = block.strip()
        if not b or b.startswith(("#", ">", "|", "```", "-", "*", "1.")):
            continue
        return re.sub(r"\s+", " ", b)[:260]
    return ""


def one_liner(text):
    m = re.search(r"^#{2,3}\s*\d*\.?\s*一句话[^\n]*\n+(.+?)(?=\n#{2,}|\Z)", text, re.S | re.M)
    if m:
        return re.sub(r"^[>\-*\s]+", "", re.sub(r"\s+", " ", m.group(1).strip()))[:320]
    return first_para(text)


# ---------------------------------------------------------------- 解析

def subs_section(body):
    out, on, found = [], False, False
    for line in body.splitlines():
        if re.match(r"^##\s.*子\s?Spec", line):
            on, found = True, True
            continue
        if on and re.match(r"^##\s", line):
            on = False
        if on:
            out.append(line)
    return out if found else None


def subs_index_rows(body):
    """父 README 的子 Spec 索引行 → [{id, deps, path}]（兼容三列/七列、按路径取）"""
    sec = subs_section(body)
    if sec is None:
        return {}
    rows = {}
    for line in sec:
        if not re.match(r"^\|", line):
            continue
        p = re.search(r"(sub-specs|subspecs)/([^/`)\s]+)/?", line)
        if not p:
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        sid = cells[0] if cells and re.match(r"^S?\d+$", cells[0]) else ""
        deps = ""
        if len(cells) >= 7:                       # 七列：ID/子/目标/边界/依赖/状态/路径
            deps = cells[4]
        rows[p.group(2)] = {"id": sid, "deps": deps}
    return rows


def count_subs_index(body):
    sec = subs_section(body)
    src = sec if sec is not None else body.splitlines()
    return sum(1 for line in src if re.match(r"^\|.*(sub-specs|subspecs)/", line))


def parse_spec(d):
    rp = os.path.join(d, "00_README.md")
    legacy = False
    if not os.path.isfile(rp):
        rp = os.path.join(d, "README.md")
        legacy = os.path.isfile(rp)
    body = read(rp)

    m = re.search(r"^#\s+(.+)$", body, re.M)
    title = m.group(1).strip() if m else os.path.basename(d)
    m = re.search(r"状态\s*[:：]\s*([⬜🔵🟡✅])", body)
    status = m.group(1) if m else "⬜"
    m = re.search(r"创建\s*[:：]\s*([0-9]{4}-[0-9]{2}-[0-9]{2})", body)
    created = m.group(1) if m else ""
    ts = mtime(rp if os.path.isfile(rp) else d)

    comps = []
    for num, fn, cn, desc in COMPONENTS:
        p = os.path.join(d, fn)
        if fn == "deliverables":
            exists = os.path.isdir(p)
            count = size = 0
            if exists:
                files = [os.path.join(dp, f) for dp, _, fs in os.walk(p) for f in fs]
                size = sum(os.path.getsize(x) for x in files)
                count = len(files)
            comps.append({"num": num, "file": fn, "cn": cn, "desc": desc, "exists": exists,
                          "lines": count, "kb": round(size / 1024, 1),
                          "ts": mtime(p) if exists else 0, "unit": "份"})
        else:
            exists = os.path.isfile(p)
            comps.append({"num": num, "file": fn, "cn": cn, "desc": desc, "exists": exists,
                          "lines": len(read(p).splitlines()) if exists else 0,
                          "kb": round(os.path.getsize(p) / 1024, 1) if exists else 0,
                          "ts": mtime(p) if exists else 0,
                          "unit": "行", "head": (read(p)[:20000] if exists else "")})

    # 阶段：就位情况 + 最后改动时间
    stages = []
    for f, lbl in PHASES:
        p = os.path.join(d, f)
        stages.append({"file": f, "label": lbl, "exists": os.path.isfile(p),
                       "ts": mtime(p) if os.path.isfile(p) else 0})

    # 事件流（带日期）
    events, by_day = [], {}
    ev = os.path.join(d, "execution-log.md")
    if os.path.isfile(ev):
        for line in read(ev).splitlines():
            m = re.match(r"^###\s+(\d{4}-\d{2}-\d{2})[\sT]?(\d{2}:\d{2})?\S*\s*·\s*(.+)$", line)
            if m:
                day, hhmm, txt = m.group(1), m.group(2) or "", m.group(3).strip()
                events.append({"day": day, "time": hhmm, "text": txt})
                by_day[day] = by_day.get(day, 0) + 1

    # 任务 / burnup
    todo_items, done_tasks = [], 0
    tp = os.path.join(d, "04_tasks.md")
    if os.path.isfile(tp):
        for line in read(tp).splitlines():
            if re.match(r"^\s*-\s*\[ \]", line):
                t = re.sub(r"^\s*-\s*\[ \]\s*", "", line).strip()
                t = re.sub(r"^\*\*(.+?)\*\*[:：]?\s*", r"\1：", t)
                todo_items.append(t[:120])
            elif re.match(r"^\s*-\s*\[[xX]\]", line):
                done_tasks += 1

    # 断点 / 交接文件
    conti = []
    try:
        for f in sorted(os.listdir(d)):
            if CONTI_RE.search(f) and os.path.isfile(os.path.join(d, f)):
                conti.append({"name": f, "ts": mtime(os.path.join(d, f)),
                              "kb": round(os.path.getsize(os.path.join(d, f)) / 1024, 1)})
    except OSError:
        pass

    # 子 Spec
    rows = subs_index_rows(body)
    subs = []
    for name in ("sub-specs", "subspecs"):
        root = os.path.join(d, name)
        if os.path.isdir(root):
            for c in sorted(os.listdir(root)):
                cp = os.path.join(root, c)
                if os.path.isdir(cp):
                    x = parse_spec(cp)
                    x["dir"] = f"{name}/{c}"
                    meta = rows.get(c, {})
                    x["sid"] = meta.get("id", "")
                    x["deps"] = meta.get("deps", "")
                    subs.append(x)
            break

    gates, gate_na = [], ""
    v = read(os.path.join(d, "05_validator.md"))
    if v:
        core = [(r"##.*数据准备", "数据准备"), (r"##.*验证", "验证用例"),
                (r"##.*一致性", "数据一致性"), (r"##.*合规", "合规检查")]
        if sum(1 for pat, _ in core if re.search(pat, v)) < 2:
            gate_na = f"该 05_validator 不是引擎模板结构（{len(v.splitlines())} 行），模板门禁不适用"
        else:
            for pat, nm in core:
                gates.append((nm, bool(re.search(pat, v))))
            ph = len(re.findall(r"\{(?:简述|TICKET|YYYY-[A-Z]|Spec 标题|正常场景|异常场景)\}", v))
            gates.append(("无占位符残留", ph == 0))
            for pat, nm in (("退出条件", "退出条件"), ("幂等|idempotent", "幂等条件"),
                            ("回滚|rollback|恢复", "回滚条件")):
                gates.append((nm, bool(re.search(pat, v))))

    # ---- 推进轨迹：把"事件日"与"文件改动日"合起来 ----
    act = dict(by_day)
    for c in comps:
        if c["exists"] and c["ts"]:
            day = datetime.fromtimestamp(c["ts"]).strftime("%Y-%m-%d")
            act[day] = act.get(day, 0) + 1
    span = sorted(act.keys())
    markers = []
    if created:
        markers.append(created)
    if s0 := (re.search(r"(\d{4}-\d{2}-\d{2})", created or "")):
        pass
    if status == "✅" and events:
        pass
    markers += span[:1]
    if events:
        markers.append(events[-1]["day"])
        markers.append(events[0]["day"])
    markers = [m for m in markers if m]
    first_day = created if created else (min(markers) if markers else "")
    last_ev_day = events[-1]["day"] if events else ""
    last_act_day = max(act.keys()) if act else (first_day or "")

    return {"path": d, "name": os.path.basename(d), "title": title, "status": status,
            "created": created, "one": one_liner(body), "legacy": legacy,
            "mtime": dstr(ts), "age": days_ago(ts),
            "stale": days_ago(ts) > STALE_DAYS and status != "✅",
            "comps": comps, "stages": stages, "subs": subs, "events": events,
            "activity": act, "first_day": first_day, "last_act_day": last_act_day,
            "last_ev_day": last_ev_day, "todo_items": todo_items, "done_tasks": done_tasks,
            "conti": conti, "gates": gates, "gate_na": gate_na,
            "subs_index": (len(subs), count_subs_index(body)) if subs else None,
            "elog_kb": next((c["kb"] for c in comps if c["file"] == "execution-log.md"), 0),
            "no_readme": not body}


def is_spec_dir(d):
    if not (os.path.isfile(os.path.join(d, "00_README.md"))
            or os.path.isfile(os.path.join(d, "README.md"))):
        return False
    return (any(os.path.isfile(os.path.join(d, f)) for f, _ in PHASES)
            or any(os.path.isdir(os.path.join(d, x)) for x in ("sub-specs", "subspecs")))


def scan(root):
    out = []
    if not os.path.isdir(root):
        return out
    for n in sorted(os.listdir(root)):
        d = os.path.join(root, n)
        if not os.path.isdir(d) or n in SKIP_DIRS or n.startswith(".") or n == "_archive":
            continue
        out.append(parse_spec(d))
    return out


def archive_summary(root):
    d = os.path.join(root, "_archive")
    if not os.path.isdir(d):
        return (0, 0)
    batches = [x for x in os.listdir(d) if os.path.isdir(os.path.join(d, x))]
    docs = sum(len([f for f in os.listdir(os.path.join(d, b))
                    if os.path.isfile(os.path.join(d, b, f))]) for b in batches)
    return (len(batches), docs)


# ---------------------------------------------------------------- 过程视图

def current_stage(s):
    for st in s["stages"]:
        if not st["exists"]:
            return st["label"]
    return "全部就位"


def stall_info(s):
    """返回 (天数, 文案, 等级) —— 过程视角最重要的一格"""
    if s["status"] == "✅":
        return (0, "已收口", "ok")
    ref = s["last_act_day"]
    if not ref:
        return (0, "无推进痕迹", "warn")
    try:
        dd = (date.today() - date.fromisoformat(ref)).days
    except ValueError:
        return (0, "日期无法解析", "warn")
    if dd >= STALL_DAYS:
        return (dd, f"已停滞 {dd} 天（最后推进 {ref}）", "alarm" if dd >= 14 else "warn")
    return (dd, f"{dd} 天前有推进（{ref}）", "ok")


def render_track(s):
    """推进轨迹：从首日到最后活动日，每天一根柱"""
    act = s["activity"]
    if not act:
        return ""
    days = sorted(act.keys())
    try:
        d0 = date.fromisoformat(s["first_day"]) if s["first_day"] else date.fromisoformat(days[0])
    except ValueError:
        d0 = date.fromisoformat(days[0])
    d1 = date.fromisoformat(days[-1])
    if (d1 - d0).days > 400:
        d0 = d1 - timedelta(days=180)
    total = (d1 - d0).days + 1
    mx = max(act.values())
    bars, gaps = [], 0
    cur = d0
    while cur <= d1:
        k = cur.isoformat()
        n = act.get(k, 0)
        wd = " 周末" if cur.weekday() >= 5 else ""
        if n:
            hpct = max(12, round(n / mx * 100))
            bars.append(f'<div class="d on" style="--h:{hpct}%" title="{k}{wd}：{n} 次改动/事件"></div>')
        else:
            gaps += 1
            bars.append(f'<div class="d" title="{k}{wd}：无推进"></div>')
        cur += timedelta(days=1)
    zero = sum(1 for v in act.values() if v)
    h = ('<div class="card"><h2>推进轨迹'
         f'<span class="rt">{total} 天跨度 · 活跃 {len(days)} 天 · 空窗 {gaps} 天</span></h2>'
         f'<div class="track">{"".join(bars)}</div>'
         f'<div class="trackx"><span>{d0.isoformat()}</span><span>{d1.isoformat()}</span></div>'
         '<div class="muted" style="margin-top:8px">柱高 = 当天的事件条数 + 文件改动数（本地痕迹，不是工时）。'
         '空窗期说明这段时间没有痕迹，不代表没在工作。</div></div>')
    return h


def render_stages(s):
    h = '<div class="card"><h2>阶段轨迹<span class="rt">按文件最后改动时间</span></h2><div class="stg">'
    for st in s["stages"]:
        on = st["exists"]
        h += (f'<div class="s2{" on" if on else ""}"><b>{esc(st["label"])}</b>'
              f'<span>{esc(dstr(st["ts"], False)) if on else "未建"}</span></div>')
    h += "</div>"
    done = sum(1 for st in s["stages"] if st["exists"])
    h += f'<div class="muted" style="margin-top:8px">当前阶段：<b>{esc(current_stage(s))}</b>（{done}/5 就位）</div></div>'
    return h


def render_burnup(s):
    done, todo = s["done_tasks"], len(s["todo_items"])
    tot = done + todo
    if tot == 0:
        return ""
    pct = round(done / tot * 100)
    return ('<div class="card"><h2>任务进度 <span class="rt">use burnup（范围会变）</span></h2>'
            f'<div class="bar"><i style="width:{pct}%"></i></div>'
            f'<div class="kvline"><span>已完成 <b>{done}</b></span><span>剩余 <b>{todo}</b></span>'
            f'<span>合计 <b>{tot}</b></span><span>{pct}%</span></div>'
            '<div class="muted" style="margin-top:6px">范围会随新指令增长，所以用 burnup（完成数 / 总数），'
            '不用 burndown —— 否则加需求会被误读成"生产力下降"。</div></div>')


def render_frontier(s):
    """依赖前沿：现在该做哪个"""
    subs = s["subs"]
    if not subs:
        return ""
    done = [x for x in subs if x["status"] == "✅"]
    open_ = [x for x in subs if x["status"] != "✅"]
    has_dep = any((x.get("deps") or "").strip() not in ("", "—", "-", "{待填}") for x in open_)
    frontier, blocked = open_, []
    if has_dep:
        done_ids = {x.get("sid") for x in done if x.get("sid")}
        frontier, blocked = [], []
        for x in open_:
            deps = [d.strip() for d in re.split(r"[、,，/\s]+", x.get("deps") or "") if d.strip()]
            deps = [d for d in deps if d not in ("—", "-", "{待填}")]
            if deps and not set(deps) <= done_ids:
                blocked.append((x, [d for d in deps if d not in done_ids]))
            else:
                frontier.append(x)
    h = ('<div class="card"><h2>依赖前沿'
         f'<span class="rt">{len(done)} 收口 · {len(open_)} 未收口</span></h2>')
    if not has_dep:
        h += ('<div class="muted" style="margin-bottom:8px">父索引表还是旧格式，没有「依赖」列 —— '
              '按状态粗略列出未收口项。补上依赖列后这里能算出真正的可开工集合。</div>')
    def card(x, tag="", tagcls="ok", extra=""):
        xc = {"⬜": "var(--todo)", "🔵": "var(--ing)", "🟡": "var(--confirm)", "✅": "var(--done)"}.get(
            x["status"], "var(--dim)")
        return (f'<div class="sub"><div class="h"><span class="dot" style="background:{xc}"></span>'
                f'<b>{esc(x["title"])}</b><span class="flag">{esc(x["sid"] or "-")}</span>'
                f'{f"<span class=\"flag {tagcls}\">{tag}</span>" if tag else ""}'
                f'<span class="muted">{x["age"]} 天前</span>{extra}</div>'
                f'<div class="m">{esc(x["dir"])}</div></div>')
    if frontier:
        h += f'<div class="grp">可开工 {len(frontier)}</div>'
        for x in frontier:
            h += card(x, "可立即开始", "ok")
    if blocked:
        h += f'<div class="grp">被挡 {len(blocked)}</div>'
        for x, miss in blocked:
            h += card(x, "等 " + "、".join(miss), "warn")
    if done:
        h += f'<details><summary class="grp" style="cursor:pointer">已收口 {len(done)}</summary>'
        for x in done:
            h += card(x, "已收口", "ok")
        h += "</details>"
    h += "</div>"
    return h


def render_conti(s):
    if not s["conti"]:
        return ""
    h = ('<div class="card"><h2>断点与交接'
         '<span class="rt">跨会话续接的真相源</span></h2>')
    for c in sorted(s["conti"], key=lambda x: -x["ts"]):
        h += (f'<div class="kvline" style="justify-content:space-between">'
              f'<span><code>{esc(c["name"])}</code></span>'
              f'<span class="muted">{c["kb"]} KB · {esc(dstr(c["ts"], False))}</span></div>')
    h += ('<div class="muted" style="margin-top:8px">接手时先读这几个（尤其 STATUS / 继续会话提示词），'
          '再读 execution-log。</div></div>')
    return h


# ---------------------------------------------------------------- HTML 骨架

CSS = """
:root{--bg:#f4f6fa;--card:#fff;--card2:#f8fafc;--line:#e5e9f0;--line2:#eef2f7;
--txt:#1f2937;--dim:#8b95a5;--acc:#2563eb;--acc2:#6366f1;
--ok:#15803d;--warn:#b45309;--err:#dc2626;--todo:#94a3b8;--ing:#2563eb;--confirm:#d97706;--done:#15803d;
--r:12px;--gap:14px}
*{margin:0;padding:0;box-sizing:border-box}
body{font:14px/1.62 -apple-system,BlinkMacSystemFont,"Segoe UI","PingFang SC","Microsoft YaHei",sans-serif;
background:var(--bg);color:var(--txt);padding:22px}
.wrap{max-width:1180px;margin:0 auto}
header{background:linear-gradient(135deg,#3b82f6,#6366f1);border-radius:16px;padding:22px 28px;
margin-bottom:var(--gap);position:relative;overflow:hidden;display:flex;gap:18px;align-items:center}
header::after{content:'';position:absolute;right:-50px;top:-70px;width:210px;height:210px;
border-radius:50%;background:rgba(255,255,255,.10)}
header .hx{flex:1;min-width:0;position:relative;z-index:1}
header h1{font-size:21px;font-weight:700;color:#fff;line-height:1.35}
header .sub{color:#e0ecff;font-size:12.5px;margin-top:5px}
.badges{margin-top:11px;display:flex;gap:7px;flex-wrap:wrap}
.badge{background:rgba(255,255,255,.18);border:1px solid rgba(255,255,255,.34);color:#fff;
padding:3px 12px;border-radius:999px;font-size:11.5px;font-weight:600;white-space:nowrap}
.badge.done{background:#0d7a45;border-color:#12a35c}
.badge.ing{background:#1d4ed8;border-color:#3b82f6}
.badge.confirm{background:#a35a09;border-color:#d97706}
.badge.todo{background:#64748b;border-color:#94a3b8}
.badge.alarm{background:#9f1239;border-color:#e11d48}
.ring{width:86px;height:86px;border-radius:50%;flex:none;position:relative;z-index:1;
background:conic-gradient(#fff calc(var(--p,0)*1%), rgba(255,255,255,.22) 0)}
.ring::before{content:'';position:absolute;inset:8px;border-radius:50%;
background:linear-gradient(135deg,#3b82f6,#6366f1)}
.ring i{position:absolute;inset:0;display:grid;place-items:center;color:#fff;font-style:normal;
font-weight:700;font-size:15px;line-height:1.1;text-align:center}
.ring i small{display:block;font-size:9.5px;font-weight:500;opacity:.85}
.grid{display:grid;gap:var(--gap);margin-bottom:var(--gap)}
.g4{grid-template-columns:repeat(4,1fr)}
@media(max-width:900px){.g4{grid-template-columns:repeat(2,1fr)}}
@media(max-width:560px){.g4{grid-template-columns:1fr}}
.kpi{background:var(--card);border:1px solid var(--line);border-radius:var(--r);padding:14px 16px;
position:relative;overflow:hidden}
.kpi::before{content:'';position:absolute;left:0;top:0;bottom:0;width:3px;background:var(--c,var(--acc))}
.kpi b{display:block;font-size:22px;font-weight:700;line-height:1.2;color:var(--c,var(--txt))}
.kpi span{font-size:12px;color:var(--dim)}
.kpi em{font-style:normal;font-size:11.5px;color:var(--dim);display:block;margin-top:3px}
.card{background:var(--card);border:1px solid var(--line);border-radius:var(--r);
padding:15px 18px;margin-bottom:var(--gap)}
.card>h2{font-size:13.5px;font-weight:700;color:var(--acc);margin-bottom:11px;
display:flex;align-items:center;gap:8px;flex-wrap:wrap}
.card>h2 .rt{margin-left:auto;font-weight:500;font-size:11.5px;color:var(--dim)}
.lead{font-size:13.5px;color:#374151;background:var(--card2);border-left:3px solid var(--acc);
border-radius:0 8px 8px 0;padding:11px 15px}
.track{display:flex;align-items:flex-end;gap:2px;height:74px;padding:0 0 0 1px}
.track .d{flex:1;min-width:3px;height:5px;background:#e8edf4;border-radius:2px;
display:flex;align-items:flex-end;transition:background .15s}
.track .d.on{background:#dbeafe;height:100%}
.track .d.on::after{content:'';display:block;width:100%;height:var(--h);border-radius:2px;
background:linear-gradient(180deg,#3b82f6,#6366f1)}
.trackx{display:flex;justify-content:space-between;color:var(--dim);font-size:10.5px;margin-top:4px}
.stg{display:grid;grid-template-columns:repeat(5,1fr);gap:9px}
@media(max-width:760px){.stg{grid-template-columns:repeat(2,1fr)}}
.stg .s2{background:var(--card2);border:1px solid var(--line);border-radius:10px;padding:9px 8px;text-align:center}
.stg .s2.on{border-color:#bbf7d0;background:#f0fdf4}
.stg .s2 b{display:block;font-size:12.5px}
.stg .s2 span{font-size:11px;color:var(--dim)}
.stg .s2.on span{color:var(--ok)}
.bar{height:9px;background:var(--line2);border-radius:99px;overflow:hidden;margin-bottom:8px}
.bar i{display:block;height:100%;background:linear-gradient(90deg,#3b82f6,#6366f1);border-radius:99px}
.kvline{display:flex;gap:18px;flex-wrap:wrap;font-size:12.5px;color:#4b5563}
.kvline b{color:var(--txt)}
.sub{background:var(--card2);border:1px solid var(--line);border-left:3px solid #c7d2fe;
border-radius:0 10px 10px 0;padding:9px 13px;margin-bottom:7px}
.sub .h{display:flex;align-items:center;gap:8px;flex-wrap:wrap}
.sub .h b{font-size:12.5px}
.sub .m{color:var(--dim);font-size:10.5px;font-family:ui-monospace,Menlo,monospace;margin-top:2px}
.grp{font-size:11.5px;color:var(--dim);font-weight:600;margin:11px 0 6px}
.dot{width:8px;height:8px;border-radius:50%;flex:none;display:inline-block}
.tl{position:relative;padding-left:18px;max-height:340px;overflow:auto}
.tl::before{content:'';position:absolute;left:4px;top:5px;bottom:5px;width:2px;background:var(--line)}
.tl .it{position:relative;padding:5px 0;font-size:12.5px;color:#4b5563}
.tl .it::before{content:'';position:absolute;left:-18px;top:11px;width:9px;height:9px;
border-radius:50%;background:var(--acc);box-shadow:0 0 0 3px #fff}
.tl .it.old::before{background:#cbd5e1}
.tl .dd{display:inline-block;min-width:74px;color:var(--dim);font-family:ui-monospace,Menlo,monospace;font-size:11px}
ul.clean{list-style:none;font-size:12.5px;max-height:280px;overflow:auto}
ul.clean li{padding:5px 0;border-bottom:1px dashed var(--line2);color:#4b5563}
ul.clean li:last-child{border:none}
ul.clean li::before{content:'☐ ';color:var(--dim)}
.comps{display:grid;grid-template-columns:repeat(auto-fill,minmax(210px,1fr));gap:10px}
.comp{background:var(--card2);border:1px solid var(--line);border-radius:10px;padding:11px 13px}
.comp.miss{background:#fcfcfd;border-style:dashed;opacity:.72}
.comp .t{font-weight:600;font-size:13px;display:flex;align-items:center;gap:6px}
.comp .num{background:var(--line2);color:var(--acc);min-width:19px;height:19px;border-radius:5px;
display:inline-flex;align-items:center;justify-content:center;font-size:10.5px;font-weight:700}
.comp.miss .num{color:var(--dim)}
.comp .fn{color:var(--dim);font-size:10.5px;font-family:ui-monospace,Menlo,monospace;margin:2px 0 5px}
.comp .d{color:#6b7280;font-size:11.5px}
.comp .s{color:var(--dim);font-size:11px;margin-top:7px;padding-top:6px;border-top:1px dashed var(--line)}
.comp .s.hi{color:var(--warn)}
table{width:100%;border-collapse:collapse;font-size:12.5px}
th{background:var(--card2);color:#64748b;text-align:left;padding:7px 10px;font-weight:600;
font-size:11.5px;border-bottom:1px solid var(--line)}
td{padding:7px 10px;border-bottom:1px solid var(--line2)}
tr:last-child td{border-bottom:none}
td.g{color:var(--ok);font-weight:600}td.r{color:var(--err);font-weight:600}
.flag{font-size:11px;padding:2px 9px;border-radius:6px;border:1px solid var(--line);
background:var(--card2);color:#64748b;font-weight:600}
.flag.ok{border-color:#bbf7d0;background:#f0fdf4;color:var(--ok)}
.flag.warn{border-color:#fde68a;background:#fffbeb;color:var(--warn)}
.flag.alarm{border-color:#fecaca;background:#fef2f2;color:var(--err)}
.note{background:#fffbeb;border:1px solid #fde68a;border-radius:9px;padding:10px 14px;
font-size:12.5px;color:#92400e}
.note.red{background:#fef2f2;border-color:#fecaca;color:#991b1b}
.muted{color:var(--dim);font-size:11.5px;line-height:1.7}
.toolbar{display:flex;gap:8px;flex-wrap:wrap;margin-bottom:var(--gap)}
.toolbar a{padding:6px 13px;border-radius:999px;background:var(--card);border:1px solid var(--line);
color:#475569;text-decoration:none;font-size:12px;font-weight:600}
.toolbar a:hover{border-color:var(--acc);color:var(--acc)}
input.search{flex:1;min-width:220px;background:var(--card);border:1px solid var(--line);
border-radius:10px;padding:8px 14px;font-size:13px;font-family:inherit;outline:none}
input.search:focus{border-color:var(--acc)}
details summary{list-style:none}
details summary::-webkit-details-marker{display:none}
footer{margin-top:6px;text-align:center;color:var(--dim);font-size:11.5px;line-height:1.8;
padding:16px;border-top:1px solid var(--line)}
code{background:#eef2f7;padding:1px 6px;border-radius:5px;font-size:11.5px;font-family:ui-monospace,Menlo,monospace}
"""


def head(title, subtitle, badges, right="", toolbar=""):
    return ('<!DOCTYPE html>\n<html lang="zh-CN"><head><meta charset="utf-8">'
            '<meta name="viewport" content="width=device-width,initial-scale=1">'
            f'<title>{esc(title)}</title><style>{CSS}</style></head><body><div class="wrap">'
            f'<header><div class="hx"><h1>{esc(title)}</h1><div class="sub">{subtitle}</div>'
            f'<div class="badges">{badges}</div></div>{right}</header>{toolbar}')


def foot(extra=""):
    return ('<footer>看板由 <code>specs-engine/scripts/build-dashboard.py</code> 从本目录的 .md 生成 —— '
            '派生视图，<b>真相源是那些文件本身</b>。只呈现可从本地痕迹推出的量：'
            '<b>不做工时 / 速度 / 效率</b>（推不出来），<b>不做累积流图</b>（无状态流转历史）。<br>'
            '重新生成：<code>python3 ~/.claude/skills/specs-engine/scripts/build-dashboard.py &lt;spec目录&gt;</code>'
            f'{extra}</footer></div></body></html>')


def render_spec(s):
    nm, cls = ST.get(s["status"], ("?", "todo"))
    stall_d, stall_txt, stall_lv = stall_info(s)
    badges = f'<span class="badge {cls}">{nm}</span>'
    if stall_lv == "alarm":
        badges += f'<span class="badge alarm">停滞 {stall_d} 天</span>'
    if s["elog_kb"] > ELOG_WARN_KB:
        badges += f'<span class="badge confirm">日志 {s["elog_kb"]} KB</span>'
    if s["legacy"]:
        badges += '<span class="badge todo">legacy 格式</span>'
    if s["subs"]:
        op = sum(1 for x in s["subs"] if x["status"] != "✅")
        badges += f'<span class="badge">{len(s["subs"])} 子 Spec · 未收口 {op}</span>'

    nphase = sum(1 for st in s["stages"] if st["exists"])
    ring = f'<div class="ring" style="--p:{round(nphase / 5 * 100)}"><i>{nphase}/5<small>阶段</small></i></div>'
    tb = ('<div class="toolbar"><a href="#track">推进轨迹</a><a href="#stage">阶段</a>'
          + ('<a href="#front">依赖前沿</a>' if s["subs"] else "")
          + ('<a href="#task">任务</a>' if s["todo_items"] or s["done_tasks"] else "")
          + ('<a href="#log">事件流</a>' if s["events"] else "")
          + ('<a href="#conti">断点</a>' if s["conti"] else "")
          + '<a href="#comp">组件</a><a href="#gate">门禁</a></div>')

    h = head(s["title"],
             f'{esc(s["name"])}　·　创建 {esc(s["created"] or "—")}　·　最后改动 {esc(s["mtime"])}',
             badges, ring, tb)

    # ---- KPI：全部是"过程"指标 ----
    h += '<a id="kpi"></a><div class="grid g4">'
    h += (f'<div class="kpi" style="--c:var(--acc2)"><b>{esc(current_stage(s))}</b>'
          f'<span>当前阶段</span><em>{nphase}/5 阶段就位</em></div>')
    c = {"ok": "var(--ok)", "warn": "var(--warn)", "alarm": "var(--err)"}[stall_lv]
    h += (f'<div class="kpi" style="--c:{c}"><b>{stall_d if stall_lv != "ok" or stall_d else 0}'
          f'{" 天" if stall_lv != "ok" else "天"}</b><span>{"停滞" if stall_lv != "ok" else "距上次推进"}</span>'
          f'<em>{esc(s["last_act_day"] or "—")}</em></div>')
    done, todo = s["done_tasks"], len(s["todo_items"])
    tot = done + todo
    h += (f'<div class="kpi" style="--c:var(--acc)"><b>{done}/{tot if tot else "—"}</b><span>任务完成</span>'
          f'<em>{"无任务清单" if not tot else str(todo) + " 项未打勾"}</em></div>')
    op = sum(1 for x in s["subs"] if x["status"] != "✅")
    h += (f'<div class="kpi" style="--c:{"var(--warn)" if op else "var(--ok)"}"><b>{op}</b>'
          f'<span>子 Spec 未收口</span><em>共 {len(s["subs"])} 个</em></div>')
    h += "</div>"

    # ---- 卡点 ----
    if s["status"] in ("🔵", "🟡"):
        lvl = "red" if stall_lv == "alarm" else ""
        h += f'<div class="card"><div class="note {lvl}"><b>卡点：</b>{esc(stall_txt)}'
        if s["todo_items"]:
            h += f'　下一件事（04_tasks 第一条）：{esc(s["todo_items"][0])}'
        elif s["subs"]:
            nf = sum(1 for x in s["subs"] if x["status"] != "✅")
            h += f'　父本身任务已清，剩 {nf} 个子 Spec 未收口'
        else:
            h += "　任务清单为空 —— 要么已做完，要么还没拆。"
        h += "</div></div>"

    if s["one"]:
        h += f'<div class="card"><h2>一句话</h2><div class="lead">{esc(s["one"])}</div></div>'

    h += '<a id="track"></a>' + render_track(s)
    h += '<a id="stage"></a>' + render_stages(s)

    if s["subs"]:
        h += '<a id="front"></a>' + render_frontier(s)

    h += '<a id="task"></a>' + render_burnup(s)

    if s["events"]:
        h += ('<a id="log"></a><div class="card"><h2>事件流'
              f'<span class="rt">execution-log · {len(s["events"])} 条，最新在上</span></h2><div class="tl">')
        for i, e in enumerate(reversed(s["events"][-70:])):
            h += (f'<div class="it{" old" if i > 14 else ""}">'
                  f'<span class="dd">{esc(e["day"][5:])} {esc(e["time"])}</span>{esc(e["text"])}</div>')
        h += "</div>"
        if len(s["events"]) > 70:
            h += f'<div class="muted" style="margin-top:6px">… 只显示最近 70 条</div>'
        h += "</div>"

    if s["todo_items"]:
        h += ('<div class="card"><h2>未完任务'
              f'<span class="rt">{len(s["todo_items"])} 项</span></h2><ul class="clean">')
        for t in s["todo_items"]:
            h += f"<li>{esc(t)}</li>"
        h += "</ul></div>"

    h += render_conti(s)

    # ---- 组件（降级：盘点，不是过程） ----
    ncomp = sum(1 for c in s["comps"] if c["exists"])
    h += (f'<a id="comp"></a><div class="card"><h2>组件 <span class="rt">{ncomp}/{len(s["comps"])} '
          '· 盘点信息，非过程指标</span></h2><div class="comps">')
    for c in s["comps"]:
        miss = "" if c["exists"] else " miss"
        stat = (f'{c["lines"]} {c["unit"]} · {c["kb"]} KB · {esc(dstr(c["ts"], False))}'
                if c["exists"] else "未建")
        hi = " hi" if (c["file"] == "execution-log.md" and c["kb"] > ELOG_WARN_KB) else ""
        h += (f'<div class="comp{miss}"><div class="t"><span class="num">{esc(c["num"])}</span>{esc(c["cn"])}</div>'
              f'<div class="fn">{esc(c["file"])}</div><div class="d">{esc(c["desc"])}</div>'
              f'<div class="s{hi}">{stat}</div></div>')
    h += "</div></div>"

    if s["gates"] or s["gate_na"]:
        ok = sum(1 for _, v in s["gates"] if v)
        h += f'<a id="gate"></a><div class="card"><h2>门禁自检'
        if s["gates"]:
            h += f'<span class="rt"><span class="flag {"ok" if ok == len(s["gates"]) else "warn"}">{ok}/{len(s["gates"])} 通过</span></span>'
        h += "</h2>"
        if s["gate_na"]:
            h += f'<div class="note">{esc(s["gate_na"])} —— 不是失败。</div>'
        else:
            h += '<table><tr><th>检查项</th><th style="width:80px">结果</th></tr>'
            for n_, v in s["gates"]:
                h += f'<tr><td>{esc(n_)}</td><td class="{"g" if v else "r"}">{"✅ 通过" if v else "❌ 缺"}</td></tr>'
            h += "</table>"
        h += ('<div class="muted" style="margin-top:9px">完整验证跑：'
              f'<code>bash ~/.claude/skills/specs-engine/scripts/validator-check.sh "{esc(s["path"])}"</code></div></div>')

    return h + foot()


def render_all(specs, root):
    na, nd = archive_summary(root)
    cnt = {}
    for s in specs:
        cnt[s["status"]] = cnt.get(s["status"], 0) + 1
    badges = "".join(f'<span class="badge {ST[k][1]}">{ST[k][0]} {cnt.get(k, 0)}</span>'
                     for k in ("✅", "🔵", "🟡", "⬜") if cnt.get(k))
    if na:
        badges += f'<span class="badge todo">归档批次 {na} · 文档 {nd}</span>'
    total = len(specs)
    stalled = [s for s in specs if s["status"] in ("🔵", "🟡") and stall_info(s)[0] >= STALL_DAYS]
    up = round((cnt.get("✅", 0) / total * 100) if total else 0)
    h = head("Specs 看板 · 全局", esc(os.path.abspath(root)), badges,
             f'<div class="ring" style="--p:{up}"><i>{cnt.get("✅",0)}/{total}<small>完成</small></i></div>')
    h += '<div class="grid g4">'
    h += f'<div class="kpi" style="--c:var(--acc)"><b>{total}</b><span>Spec 总数</span><em>含 {sum(len(s["subs"]) for s in specs)} 个子 Spec</em></div>'
    h += f'<div class="kpi" style="--c:var(--ing)"><b>{cnt.get("🔵",0)}{"+"+str(cnt.get("🟡",0)) if cnt.get("🟡") else ""}</b><span>在推进</span><em>🔵 {cnt.get("🔵",0)} · 🟡 {cnt.get("🟡",0)}</em></div>'
    h += f'<div class="kpi" style="--c:{"var(--err)" if stalled else "var(--ok)"}"><b>{len(stalled)}</b><span>停滞 &gt;{STALL_DAYS} 天</span><em>在推进但久未动</em></div>'
    h += f'<div class="kpi" style="--c:var(--done)"><b>{cnt.get("✅",0)}</b><span>已完成</span><em>{up}% 收口率</em></div>'
    h += "</div>"
    h += ('<div class="toolbar"><input class="search" id="q" placeholder="过滤：目录名 / 标题…" '
          'autocomplete="off"></div><div id="list">')
    for s in specs:
        tone = {"⬜": "var(--todo)", "🔵": "var(--ing)", "🟡": "var(--confirm)", "✅": "var(--done)"}.get(
            s["status"], "var(--dim)")
        d_, txt, lv = stall_info(s)
        flags = ""
        if lv == "alarm" and s["status"] in ("🔵", "🟡"):
            flags += f'<span class="flag alarm">停滞 {d_}d</span>'
        elif lv == "warn" and s["status"] in ("🔵", "🟡"):
            flags += f'<span class="flag warn">{d_}d 未动</span>'
        if s["no_readme"]:
            flags += '<span class="flag alarm">无 README</span>'
        if s["subs"]:
            op = sum(1 for x in s["subs"] if x["status"] != "✅")
            flags += f'<span class="flag">{len(s["subs"])} 子 · 未收口 {op}</span>'
        pc = round(sum(1 for st in s["stages"] if st["exists"]) / 5 * 100)
        h += (f'<div class="sub" data-n="{esc((s["name"] + " " + s["title"]).lower())}">'
              f'<div class="h"><span class="dot" style="background:{tone}"></span><b>{esc(s["title"])}</b>'
              f'<span class="flag">{ST.get(s["status"], ("?",))[0]}</span>'
              f'<span class="flag">阶段 {pc}%</span>{flags}</div>'
              f'<div class="m">{esc(s["name"])} · 最后改动 {esc(s["mtime"])}</div></div>')
    h += "</div>"
    h += ('<script>\nconst q=document.getElementById("q");\n'
          'q.addEventListener("input",()=>{const t=q.value.trim().toLowerCase();'
          'document.querySelectorAll("#list>.sub").forEach(c=>{'
          'c.style.display=(!t||c.dataset.n.includes(t))?"":"none";});});\n</script>')
    return h + foot("　全局模式：<code>build-dashboard.py &lt;specs目录&gt; --all</code>")


# ---------------------------------------------------------------- 入口

def build_one(d, out=None):
    s = parse_spec(d)
    out = out or os.path.join(d, "spec-dashboard.html")
    with open(out, "w", encoding="utf-8") as f:
        f.write(render_spec(s))
    d_, txt, lv = stall_info(s)
    print(f"✅ 单 spec 看板: {out}")
    print(f"   {s['title']}｜{ST.get(s['status'], ('?',))[0]}｜当前阶段 {current_stage(s)}"
          f"｜{txt}｜任务 {s['done_tasks']}/{s['done_tasks'] + len(s['todo_items'])}"
          f"｜事件 {len(s['events'])} 条" + (f"｜子 Spec {len(s['subs'])}" if s["subs"] else ""))
    if lv == "alarm":
        print(f"   ⚠️  停滞 {d_} 天（阈值 {STALL_DAYS}）")


def build_all(root, out=None):
    specs = scan(root)
    out = out or os.path.join(root, "specs-dashboard.html")
    with open(out, "w", encoding="utf-8") as f:
        f.write(render_all(specs, root))
    cnt = {}
    for s in specs:
        cnt[s["status"]] = cnt.get(s["status"], 0) + 1
    print(f"✅ 全局看板: {out}")
    print(f"   {len(specs)} 个 Spec（含 {sum(len(s['subs']) for s in specs)} 个子 Spec）｜"
          + " ".join(f"{ST[k][0]}{cnt[k]}" for k in ("✅", "🔵", "🟡", "⬜") if cnt.get(k)))
    stalled = [s for s in specs if s["status"] in ("🔵", "🟡") and stall_info(s)[0] >= STALL_DAYS]
    if stalled:
        print(f"   ⚠️  {len(stalled)} 个停滞超 {STALL_DAYS} 天｜最久 {max(stall_info(s)[0] for s in stalled)} 天")
    orph = [s for s in specs if s["no_readme"]]
    if orph:
        print(f"   ⚠️  {len(orph)} 个目录没有 README: " + "、".join(s["name"] for s in orph[:5]))


def main():
    ap = argparse.ArgumentParser(description="specs-engine 看板（spec 的标准组件）")
    ap.add_argument("target", help="spec 目录（默认单 spec 看板）或 specs 目录（配 --all）")
    ap.add_argument("--all", action="store_true", help="全局列表模式")
    ap.add_argument("-o", "--out", default=None)
    a = ap.parse_args()
    t = a.target.rstrip("/")
    if not os.path.isdir(t):
        sys.exit(f"❌ 目录不存在: {t}")
    if a.all:
        build_all(t, a.out)
    elif is_spec_dir(t):
        build_one(t, a.out)
    else:
        print(f"ℹ️  {t} 不像一个 spec 目录 → 按全局模式渲染")
        print("   （要单 spec 看板，请把参数指向具体的 spec 目录）")
        build_all(t, a.out)


if __name__ == "__main__":
    main()
