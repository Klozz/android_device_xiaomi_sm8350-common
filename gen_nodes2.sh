#!/system/bin/sh
#
# Copyright (C) 2025 The XPerience Project
# SPDX-License-Identifier: Apache-2.0
#
#
# gen_nodes.sh
# Generate CPU/GPU nodes list and dump values into /sdcard

OUTFILE="/sdcard/powerhint_nodes.json"

echo "[x] Dumping sysfs nodes to $OUTFILE..."
echo "==== CPU/GPU Sysfs Nodes ====" > "$OUTFILE"
date >> "$OUTFILE"
echo "" >> "$OUTFILE"

# CPU policies
for policy in /sys/devices/system/cpu/cpufreq/policy*; do
    if [ -d "$policy" ]; then
        echo "[$policy]" >> "$OUTFILE"
        for node in $(ls "$policy"); do
            path="$policy/$node"
            if [ -f "$path" ]; then
                echo "$node = $(cat "$path" 2>/dev/null)" >> "$OUTFILE"
            fi
        done
        echo "" >> "$OUTFILE"
    fi
done

# GPU freq (si existe, varía por device/vendor)
if [ -d /sys/class/kgsl/kgsl-3d0/devfreq ]; then
    echo "[GPU]" >> "$OUTFILE"
    for node in $(ls /sys/class/kgsl/kgsl-3d0/devfreq/); do
        path="/sys/class/kgsl/kgsl-3d0/devfreq/$node"
        if [ -f "$path" ]; then
            echo "$node = $(cat "$path" 2>/dev/null)" >> "$OUTFILE"
        fi
    done
    echo "" >> "$OUTFILE"
fi

echo "[x] Done. File saved at $OUTFILE"
