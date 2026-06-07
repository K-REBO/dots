pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property int  cpuPercent: 0
    property int  memPercent: 0
    property real memUsedGb:  0.0
    property real memTotalGb: 0.0

    property var _proc: Process {
        command: ["bash", "-c", `
            read _ c1 < /proc/stat
            sleep 1
            read _ c2 < /proc/stat
            set -- $c1
            idle1=$4 total1=0; for v in "$@"; do total1=$((total1+v)); done
            set -- $c2
            idle2=$4 total2=0; for v in "$@"; do total2=$((total2+v)); done
            dt=$((total2-total1)) di=$((idle2-idle1))
            [ $dt -gt 0 ] && cpu=$(( (dt-di)*100/dt )) || cpu=0
            while IFS=': kB' read key val _; do
                case $key in
                    MemTotal)     mt=$val ;;
                    MemFree)      mf=$val ;;
                    Buffers)      mb=$val ;;
                    Cached)       mc=$val ;;
                    SReclaimable) ms=$val ;;
                esac
            done < /proc/meminfo
            used=$((mt - mf - mb - mc - ms))
            [ $used -lt 0 ] && used=0
            pct=$((used*100/mt))
            echo "$cpu|$used|$mt|$pct"
        `]
        running: false
        stdout: SplitParser {
            onRead: line => {
                const p = line.split("|")
                root.cpuPercent = parseInt(p[0]) || 0
                const usedKb    = parseFloat(p[1]) || 0
                const totalKb   = parseFloat(p[2]) || 1
                root.memPercent = parseInt(p[3]) || 0
                root.memUsedGb  = Math.round(usedKb  / 1048576 * 10) / 10
                root.memTotalGb = Math.round(totalKb / 1048576 * 10) / 10
                root._proc.running = false
            }
        }
    }

    function refresh() { _proc.running = true }

    property var _timer: Timer {
        interval: 3000; repeat: true; running: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: refresh()
}
