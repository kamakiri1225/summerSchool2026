#!/bin/bash
# コンテナ起動時に以下を順番に立ち上げる:
#   1. Xvfb        : 画面のない仮想ディスプレイ
#   2. x11vnc      : そのディスプレイをVNCで配信
#   3. websockify  : VNCをWebSocketに変換し、noVNCのHTML/JSを配信（ブラウザから接続できるようにする）
#   4. mesa_salome : SALOME本体（ソフトウェアレンダリング版）
set -e

DISPLAY_NUM="${DISPLAY_NUM:-1}"
export DISPLAY=":${DISPLAY_NUM}"
GEOMETRY="${GEOMETRY:-1600x900x24}"

cleanup() {
  kill "$XVFB_PID" "$X11VNC_PID" "$WEBSOCKIFY_PID" 2>/dev/null || true
}
trap cleanup EXIT

echo "[entrypoint] starting Xvfb on ${DISPLAY} (${GEOMETRY})"
Xvfb "${DISPLAY}" -screen 0 "${GEOMETRY}" -nolisten tcp &
XVFB_PID=$!

for _ in $(seq 1 30); do
  if xdpyinfo -display "${DISPLAY}" >/dev/null 2>&1; then
    break
  fi
  sleep 0.5
done

echo "[entrypoint] starting x11vnc"
x11vnc -display "${DISPLAY}" -forever -shared -nopw -quiet -rfbport 5900 &
X11VNC_PID=$!

echo "[entrypoint] starting noVNC (websockify) on :6080"
websockify --web=/usr/share/novnc/ 6080 localhost:5900 &
WEBSOCKIFY_PID=$!

echo "[entrypoint] launching SALOME (mesa_salome)"
/opt/salome/mesa_salome
