#!/bin/bash

echo "========================================="
echo "macOS Security & Process Audit"
echo "========================================="

echo
echo "=== Miradore Check ==="

mem=$(ps aux | awk '/[m]iradore/ {sum += $6} END {print sum+0}')

if [ "$mem" -eq 0 ]; then
    echo "Miradore process not found ✅"
elif [ "$mem" -gt 10000 ]; then
    echo "⚠️ Miradore memory usage high: ${mem} KB"

    # Uncomment if running on Linux with systemd
    # sudo systemctl restart miradore-agent
else
    echo "Miradore memory OK (${mem} KB) ✅"
fi

echo
echo "=== High CPU Processes (>20%) ==="
ps aux | awk '$3 > 20 {print}'

echo
echo "=== High Memory Processes (>5%) ==="
ps aux | awk '$4 > 5 {print}'

echo
echo "=== Processes from suspicious locations ==="
ps aux | grep -E '/tmp|/private/tmp|/var/tmp|Downloads' | grep -v grep

echo
echo "=== Listening Network Services ==="
lsof -iTCP -sTCP:LISTEN -P -n

echo
echo "=== Admin Users ==="
dseditgroup -o read admin

echo
echo "=== User Launch Agents ==="
ls -la ~/Library/LaunchAgents 2>/dev/null

echo
echo "=== System Launch Agents ==="
ls -la /Library/LaunchAgents 2>/dev/null

echo
echo "=== System Launch Daemons ==="
ls -la /Library/LaunchDaemons 2>/dev/null

echo
echo "=== Unsigned Applications ==="
find /Applications -maxdepth 2 -name "*.app" 2>/dev/null | while read -r app
do
    codesign -v "$app" >/dev/null 2>&1 || echo "Unsigned: $app"
done

echo
echo "=== Top 10 CPU Consumers ==="
ps aux | sort -nrk 3 | head -10

echo
echo "=== Top 10 Memory Consumers ==="
ps aux | sort -nrk 4 | head -10

echo
echo "=== Recent Login History ==="
last | head -10

echo
echo "=== System Extensions ==="
systemextensionsctl list

echo
echo "=== Configuration Profiles ==="
profiles show

echo
echo "=== Summary ==="
echo "Audit complete."
