#!/usr/bin/env bash
# GitHub Actions 없이 Docker로 ZMK 펌웨어를 로컬 빌드한다.
# 사용법: ./build.sh          (첫 실행은 west update 때문에 수 분 소요)
# 결과물: firmware/charybdis_left.uf2, firmware/charybdis_right.uf2
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE="${ZMK_WORKSPACE:-$HOME/zmk-workspace}"
IMAGE=zmkfirmware/zmk-build-arm:stable

mkdir -p "$WORKSPACE"

run() {
  docker run --rm -u "$(id -u):$(id -g)" -e HOME=/workspace \
    -v "$WORKSPACE":/workspace \
    -v "$REPO_DIR/config":/workspace/config \
    -w /workspace "$IMAGE" bash -c "$1"
}

if [ ! -d "$WORKSPACE/.west" ]; then
  run "west init -l config && west update && west zephyr-export"
fi

run "west build -p -s zmk/app -d build/left -b nice_nano_v2 -- \
      -DSHIELD=charybdis_left -DZMK_CONFIG=/workspace/config"
run "west build -p -s zmk/app -d build/right -b nice_nano_v2 -S studio-rpc-usb-uart -- \
      -DSHIELD=charybdis_right -DCONFIG_ZMK_STUDIO=y -DZMK_CONFIG=/workspace/config"

mkdir -p "$REPO_DIR/firmware"
cp "$WORKSPACE/build/left/zephyr/zmk.uf2" "$REPO_DIR/firmware/charybdis_left.uf2"
cp "$WORKSPACE/build/right/zephyr/zmk.uf2" "$REPO_DIR/firmware/charybdis_right.uf2"
echo "완료: firmware/charybdis_left.uf2, firmware/charybdis_right.uf2"
