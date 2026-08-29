#!/usr/bin/env bash
# 빌드 + 부트로더(더블탭) 대기 + 자동 플래싱.
#
# 사용법:
#   ./flash.sh            # 빌드 후 오른쪽 플래싱 (키맵만 바꿨을 땐 이걸로 충분)
#   ./flash.sh both       # 빌드 후 오른쪽 → 왼쪽 순서로 플래싱
#   ./flash.sh left       # 빌드 후 왼쪽만
#   ./flash.sh -n right   # 빌드 생략, 플래싱만
#
# 안내가 나오면 해당 하프를 USB로 연결하고 리셋 버튼을 빠르게 두 번 누르면 된다.
# 마운트에 sudo 대신 docker(privileged)를 쓰므로 docker 그룹 권한만 있으면 된다.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

BUILD=1
if [ "${1:-}" = "-n" ]; then BUILD=0; shift; fi
TARGET="${1:-right}"

if [ "$BUILD" -eq 1 ]; then
  "$REPO_DIR/build.sh"
fi

flash_one() {
  local fw="$1" name="$2"
  [ -f "$REPO_DIR/firmware/$fw" ] || { echo "!!! firmware/$fw 없음 — 먼저 빌드하세요"; exit 1; }
  echo ""
  echo ">>> [$name] USB 연결 후 리셋 버튼을 빠르게 두 번 누르세요 (부트로더 대기 중... Ctrl+C로 중단)"
  local dev=""
  while true; do
    dev=$(lsblk -rno NAME,LABEL 2>/dev/null | awk '$2=="NICENANO"{print $1; exit}')
    [ -n "$dev" ] && break
    sleep 1
  done
  echo ">>> [$name] 부트로더 감지: /dev/$dev — 플래싱 중..."
  sleep 2
  local ok=0
  for _ in 1 2 3; do
    if docker run --rm --privileged -v /dev:/dev -v "$REPO_DIR/firmware":/fw:ro alpine:3.19 \
        sh -c "mkdir -p /m && mount /dev/$dev /m && cp /fw/$fw /m/ && sync" >/dev/null 2>&1; then
      ok=1; break
    fi
    sleep 1
  done
  [ "$ok" -eq 1 ] || { echo "!!! [$name] 플래싱 실패 — 다시 더블탭 후 재시도하세요"; exit 1; }
  while lsblk -rno NAME,LABEL 2>/dev/null | grep -q NICENANO; do sleep 1; done
  echo ">>> [$name] 완료 (자동 재부팅됨)"
}

case "$TARGET" in
  right) flash_one charybdis_right.uf2 "오른쪽" ;;
  left)  flash_one charybdis_left.uf2  "왼쪽" ;;
  both)  flash_one charybdis_right.uf2 "오른쪽"
         flash_one charybdis_left.uf2  "왼쪽" ;;
  *)     echo "사용법: ./flash.sh [-n] [right|left|both]"; exit 1 ;;
esac

echo ""
echo "전체 완료."
