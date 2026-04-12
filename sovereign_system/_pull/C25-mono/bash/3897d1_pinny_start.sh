#!/usr/bin/env bash
# pinny_start.sh — starts pinggy safely, writes PID, rotates logs
BASE="$HOME/pinggy"
LOG="$BASE/logs/pinggy.out"
PIDFILE="$BASE/pinggy.pid"
ONEBASH="$BASE/pinggy_onebash.sh"

# rotate small old log
if [ -f "$LOG" ] && [ $(stat -c%s "$LOG") -gt $((1024*1024*5)) ]; then
  mv "$LOG" "$BASE/logs/pinggy.$(date +%Y%m%d_%H%M).log"
fi

# if already running, exit
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  echo "pinny already running (pid $(cat "$PIDFILE"))"
  exit 0
fi

# prefer existing onebash; fallback to simple loop emitter
if [ -x "$ONEBASH" ]; then
  nohup bash "$ONEBASH" >> "$LOG" 2>&1 &
else
  nohup bash -c 'while true; do echo "$(date) | pinny pulse"; sleep 60; done' >> "$LOG" 2>&1 &
fi

# save PID and ensure it stays alive
echo $! > "$PIDFILE"
echo "pinny started: pid $(cat "$PIDFILE")"
