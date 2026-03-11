#!/usr/bin/env bash
# Claude Code PreToolUse(Bash) Hook
# git commit 전 Swift 코드 품질 자동 검사
#
# 검사 항목:
#   1. main 브랜치 직접 커밋 차단
#   2. 스테이징된 .swift 파일의 print() 사용 검사

set -uo pipefail

# ── stdin 에서 tool call JSON 수신 ─────────────────────────────────────────
input=$(cat)

# git commit 명령이 아니면 즉시 통과
echo "$input" | grep -q '"git commit' || exit 0

# ── 1. main 브랜치 직접 커밋 차단 ─────────────────────────────────────────
branch=$(git branch --show-current 2>/dev/null || echo "")
if [ "$branch" = "main" ]; then
  echo '{"block":true,"message":"main 브랜치 직접 커밋 불가 — feature 브랜치를 사용하세요."}' >&2
  exit 2
fi

# ── 2. 스테이징된 Swift 파일에서 print() 검사 ─────────────────────────────
staged=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null \
         | grep '\.swift$' || true)

# 스테이징된 Swift 파일 없으면 통과
[ -z "$staged" ] && exit 0

print_hits=$(echo "$staged" | xargs grep -l 'print(' 2>/dev/null || true)
if [ -n "$print_hits" ]; then
  files=$(echo "$print_hits" | tr '\n' ',' | sed 's/,$//')
  echo "{\"block\":true,\"message\":\"커밋 불가 — print() 발견: $files\"}" >&2
  exit 2
fi

exit 0
