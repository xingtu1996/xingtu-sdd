#!/bin/bash
# ============================================================================
# sdd — Spec 驱动开发 v2 命令（断代续传 / worktree 并行 / Dashboard / 知识回流）
# 纯 bash + python3(mac/linux 自带)，无第三方依赖。
#
#   sdd status   <spec_dir>              机器可读状态总览
#   sdd resume   <spec_dir>              三行断点续传（上次到哪/挂什么/下一步）
#   sdd touch    <spec_dir> [--stage X] [--status X] [--tail "..."] [--decision D1=yes] [--hyp H1=confirmed]
#                                        更新 state.json（执行 agent 的写原语）
#   sdd start    <phase> [--worktree]    开一个并行 phase（worktree 隔离）
#   sdd merge    <worktree_name>         合并并行 phase 回主线
#   sdd dashboard <specs_parent>          跨 spec 聚合看板
#   sdd recall   <关键词>                检索 case-studies 复用
# ============================================================================
set -euo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
TPL="$HERE/templates"
CASES="$HERE/../case-studies"

# ---------- python3 JSON helpers ----------
py() { python3 - "$@" <<'PYEOF'
import sys, json, os
cmd = sys.argv[1]
p = sys.argv[2]
def load():
    if not os.path.exists(p): return {}
    try: return json.load(open(p, encoding="utf-8"))
    except: return {}
def save(d): json.dump(d, open(p,"w",encoding="utf-8"), ensure_ascii=False, indent=2)

if cmd == "get":
    d = load(); print(json.dumps(d, ensure_ascii=False))
elif cmd == "touch":
    # args: touch <path> --stage X --status X --tail "..." --set-stage X done --decision K=V --hyp K=V
    d = load()
    i = 3
    while i < len(sys.argv):
        a = sys.argv[i]
        if a == "--stage" or a == "--status":
            d[a[2:]] = sys.argv[i+1]; i += 2
        elif a == "--tail":
            d["tail"] = sys.argv[i+1]; i += 2
        elif a == "--set-stage":
            stage, val = sys.argv[i+1].split("=",1)
            d.setdefault("stages",{}).setdefault(stage,{})["done"] = (val=="done")
            d["stages"][stage]["updated"] = sys.argv[i+2] if i+2 < len(sys.argv) and sys.argv[i+2][0]!="-" else d["stages"][stage].get("updated")
            i += 3 if i+2 < len(sys.argv) and sys.argv[i+2][0]!="-" else 2
        elif a == "--decision":
            k,v = sys.argv[i+1].split("=",1)
            for dec in d.get("open_decisions",[]):
                if dec["id"]==k: dec["decided"]=True; dec["value"]=v
            i += 2
        elif a == "--hyp":
            k,v = sys.argv[i+1].split("=",1)
            for h in d.get("hypotheses",[]):
                if h["id"]==k: h["status"]=v
            i += 2
        else:
            i += 1
    from datetime import datetime
    d["updated"] = datetime.now().strftime("%Y-%m-%d %H:%M")
    save(d)
    print("ok")
elif cmd == "resume":
    d = load()
    if not d:
        print("NO_STATE"); sys.exit(2)
    # 找第一个未 done 的 stage
    order = ["analysis","requirements","design","tasks","validating","executing"]
    nxt = next((s for s in order if not d.get("stages",{}).get(s,{}).get("done",False)), "done")
    pending_dec = [x for x in d.get("open_decisions",[]) if not x.get("decided")]
    open_hyp   = [x for x in d.get("hypotheses",[]) if x.get("status")=="open"]
    print("WHERE::" + (d.get("tail") or "(无断点记录)"))
    print("PENDING_DEC::" + ("; ".join(f"{x['id']} {x['question']}(默认:{x.get('default','')})" for x in pending_dec) or "无"))
    print("NEXT::" + (f"下一阶段={nxt}" if nxt!="done" else "全部阶段完成，走置✅门禁"))
    if open_hyp:
        print("OPEN_HYP::" + "; ".join(f"{x['id']} {x['claim']}" for x in open_hyp))
elif cmd == "dash":
    # dashboard: scan parent dir
    parent = sys.argv[2]
    rows=[]
    for name in sorted(os.listdir(parent)):
        sp = os.path.join(parent,name)
        sj = os.path.join(sp,"state.json")
        if os.path.isdir(sp) and os.path.exists(sj):
            d=load()
            order=["analysis","requirements","design","tasks","validating","executing"]
            done=sum(1 for s in order if d.get("stages",{}).get(s,{}).get("done"))
            rows.append((name, d.get("depth","?"), d.get("task_type","?"), d.get("status","?"), f"{done}/6", d.get("updated","?"), (d.get("tail") or "")[:40]))
    # markdown table
    print("| Spec | 档位 | 类型 | 状态 | 阶段 | 更新 | 断点 |")
    print("|---|---|---|---|---|---|---|")
    for r in rows: print("| " + " | ".join(r) + " |")
PYEOF
}

usage() {
  sed -n '2,20p' "$0"; exit 1
}

cmd="${1:-}"; [ $# -ge 1 ] || usage
shift

case "$cmd" in
  status)
    dir="${1:-.}"; [ -f "$dir/state.json" ] || { echo "❌ $dir/state.json 不存在（老 spec 先跑 sdd touch 初始化）"; exit 1; }
    py get "$dir/state.json" | python3 -m json.tool
    ;;
  resume)
    dir="${1:-.}"
    if [ ! -f "$dir/state.json" ]; then
      echo "⚠️  无 state.json，降级读 execution-log 尾部："
      [ -f "$dir/execution-log.md" ] && tail -15 "$dir/execution-log.md" || echo "(也无 execution-log.md)"
      exit 0
    fi
    py resume "$dir/state.json"
    echo "--- execution-log 尾部（交叉核对）---"
    [ -f "$dir/execution-log.md" ] && tail -8 "$dir/execution-log.md" || echo "(无)"
    ;;
  touch)
    dir="${1:-.}"; shift
    [ -f "$dir/state.json" ] || cp "$TPL/state.json" "$dir/state.json"
    py touch "$dir/state.json" touch "$dir/state.json" "$@"
    ;;
  start)
    phase="${1:?用法: sdd start <phase> [--worktree]}"; shift
    wt=0; [ "${1:-}" = "--worktree" ] && wt=1
    cur=$(basename "$(pwd)")
    if [ "$wt" = "1" ]; then
      branch="sdd/${cur}/${phase}"
      wt_dir="../.worktrees/${cur}-${phase}"
      git rev-parse --git-dir >/dev/null 2>&1 || { echo "❌ worktree 需在 git 仓内"; exit 1; }
      git worktree add "$wt_dir" -b "$branch" 2>&1
      echo "✅ 已建 worktree: $wt_dir (分支 $branch)"
      echo "   → 子 agent 在 $wt_dir 内跑，完成后: sdd merge ${cur}-${phase}"
    else
      echo "ℹ️  非 worktree 模式：直接在主线推进 $phase"
    fi
    echo "   开工首条必记：execution-log 追加澄清状态；sdd touch . --stage executing --tail \"开始 $phase\""
    ;;
  merge)
    name="${1:?用法: sdd merge <worktree_name>}"
    wt_dir="../.worktrees/$name"
    [ -d "$wt_dir" ] || { echo "❌ 无此 worktree: $wt_dir"; exit 1; }
    branch=$(cd "$wt_dir" && git branch --show-current)
    echo "→ 合并 $branch 回当前分支前，请人工核对："
    echo "   1) git -C $wt_dir status    有无未提交"
    echo "   2) 有无共改文件冲突（契约目录是否先行）"
    echo "   3) 验收认磁盘产物（实跑/grep），不轻信子 agent 自述"
    read -rp "核对无误？输入 y 合并: " ok
    if [ "$ok" = "y" ]; then
      git merge --no-ff "$branch" -m "sdd merge: $phase" 2>/dev/null || echo "⚠️ 有冲突，人工解后再 git worktree remove $wt_dir"
      echo "✅ 已合并。清理: git worktree remove $wt_dir"
    fi
    ;;
  dashboard)
    parent="${1:-.}"
    echo "# SDD Dashboard: $parent"
    py dash "$parent"
    echo ""
    echo "## 任务类型分布"
    for d in "$parent"/*/; do
      [ -f "$d/state.json" ] || continue
      python3 -c "import json,sys; d=json.load(open('$d/state.json')); print(d.get('task_type','?'),d.get('depth','?'))"
    done | sort | uniq -c | sort -rn
    ;;
  recall)
    kw="${*:?用法: sdd recall <关键词>}"
    echo "🔍 在 case-studies 检索: $kw"
    grep -ril "$kw" "$CASES" 2>/dev/null || echo "(无命中)"
    echo "---"
    grep -rh "$kw" "$CASES" 2>/dev/null | head -10 || true
    ;;
  *) usage ;;
esac
