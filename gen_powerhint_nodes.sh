#!/system/bin/sh
#
# Copyright (C) 2025 The XPerience Project
# SPDX-License-Identifier: Apache-2.0
#
# gen_powerhint_nodes.sh
# Auto-genera un JSON con nodos de CPU/GPU/uclamp para PowerHAL
# Compatible con SM8350 (y similares)

OUT="/sdcard/powerhint_nodes.json"

echo "[x] Generando $OUT ..."

cat > "$OUT" <<EOF
{
  "Nodes": [
EOF

# Detectar policies
for pol in /sys/devices/system/cpu/cpufreq/policy*; do
    name=$(basename "$pol")
    max_path="$pol/scaling_max_freq"
    min_path="$pol/scaling_min_freq"
    freqs=$(cat "$pol/scaling_available_frequencies" 2>/dev/null)

    if [ -f "$max_path" ]; then
        echo "    {" >> "$OUT"
        echo "      \"Name\": \"${name}MaxFreq\"," >> "$OUT"
        echo "      \"Path\": \"$max_path\"," >> "$OUT"
        vals=$(echo $freqs | awk '{print "[\"" $1 "\",\"" $2 "\",\"" $NF "\"]"}')
        echo "      \"Values\": $vals," >> "$OUT"
        echo "      \"ResetOnInit\": true" >> "$OUT"
        echo "    }," >> "$OUT"
    fi

    if [ -f "$min_path" ]; then
        echo "    {" >> "$OUT"
        echo "      \"Name\": \"${name}MinFreq\"," >> "$OUT"
        echo "      \"Path\": \"$min_path\"," >> "$OUT"
        vals=$(echo $freqs | awk '{print "[\"" $1 "\",\"" $2 "\",\"" $NF "\"]"}')
        echo "      \"Values\": $vals," >> "$OUT"
        echo "      \"ResetOnInit\": true" >> "$OUT"
        echo "    }," >> "$OUT"
    fi
done

# GPU
GPU="/sys/class/kgsl/kgsl-3d0/devfreq"
if [ -d "$GPU" ]; then
    freqs=$(cat $GPU/available_frequencies)
    echo "    {" >> "$OUT"
    echo "      \"Name\": \"GPUMinFreq\"," >> "$OUT"
    echo "      \"Path\": \"$GPU/min_freq\"," >> "$OUT"
    vals=$(echo $freqs | awk '{print "[\"" $1 "\",\"" $2 "\",\"" $NF "\"]"}')
    echo "      \"Values\": $vals," >> "$OUT"
    echo "      \"ResetOnInit\": true" >> "$OUT"
    echo "    }," >> "$OUT"

    echo "    {" >> "$OUT"
    echo "      \"Name\": \"GPUMaxFreq\"," >> "$OUT"
    echo "      \"Path\": \"$GPU/max_freq\"," >> "$OUT"
    vals=$(echo $freqs | awk '{print "[\"" $2 "\",\"" $3 "\",\"" $NF "\"]"}')
    echo "      \"Values\": $vals," >> "$OUT"
    echo "      \"ResetOnInit\": true" >> "$OUT"
    echo "    }," >> "$OUT"
fi

# Uclamp básicos
cat >> "$OUT" <<EOF
    {
      "Name": "UclampTAMin",
      "Path": "/dev/cpuctl/top-app/cpu.uclamp.min",
      "Values": ["0", "60"],
      "ResetOnInit": true
    },
    {
      "Name": "UclampFGMin",
      "Path": "/dev/cpuctl/foreground/cpu.uclamp.min",
      "Values": ["0", "30"],
      "ResetOnInit": true
    },
    {
      "Name": "UclampBGMax",
      "Path": "/dev/cpuctl/background/cpu.uclamp.max",
      "Values": ["60"],
      "ResetOnInit": true
    },
    {
      "Name": "UclampSysBGMax",
      "Path": "/dev/cpuctl/system-background/cpu.uclamp.max",
      "Values": ["70"],
      "ResetOnInit": true
    }
  ],
  "Actions": []
}
EOF

echo "[x] Archivo generado en $OUT"
