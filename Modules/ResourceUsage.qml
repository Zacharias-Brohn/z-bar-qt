pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Config

Singleton {
    id: root
	property double memoryTotal: 1
	property double memoryFree: 1
	property double memoryUsed: memoryTotal - memoryFree
    property double memoryUsedPercentage: memoryUsed / memoryTotal
    property double swapTotal: 1
	property double swapFree: 1
	property double swapUsed: swapTotal - swapFree
    property double swapUsedPercentage: swapTotal > 0 ? (swapUsed / swapTotal) : 0
    property double cpuUsage: 0
    property var previousCpuStats
    property double gpuUsage: 0
    property double gpuMemUsage: 0
    property double totalMem: 0
    readonly property string gpuType: Config.gpuType.toUpperCase() || autoGpuType
    property string autoGpuType: "NONE"

	Timer {
		interval: 1
        running: true 
        repeat: true
		onTriggered: {
            // Reload files
            fileMeminfo.reload()
            fileStat.reload()

            // Parse memory and swap usage
            const textMeminfo = fileMeminfo.text()
            memoryTotal = Number(textMeminfo.match(/MemTotal: *(\d+)/)?.[1] ?? 1)
            memoryFree = Number(textMeminfo.match(/MemAvailable: *(\d+)/)?.[1] ?? 0)
            swapTotal = Number(textMeminfo.match(/SwapTotal: *(\d+)/)?.[1] ?? 1)
            swapFree = Number(textMeminfo.match(/SwapFree: *(\d+)/)?.[1] ?? 0)

            // Parse CPU usage
            const textStat = fileStat.text()
            const cpuLine = textStat.match(/^cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/)
            if (cpuLine) {
                const stats = cpuLine.slice(1).map(Number)
                const total = stats.reduce((a, b) => a + b, 0)
                const idle = stats[3]

                if (previousCpuStats) {
                    const totalDiff = total - previousCpuStats.total
                    const idleDiff = idle - previousCpuStats.idle
                    cpuUsage = totalDiff > 0 ? (1 - idleDiff / totalDiff) : 0
                }

                previousCpuStats = { total, idle }
            }
            if ( root.gpuType === "NVIDIA" ) {
                processGpu.running = true
            }

            interval = 1000
        }
	}

	FileView { id: fileMeminfo; path: "/proc/meminfo" }
    FileView { id: fileStat; path: "/proc/stat" }

    Process {
        id: gpuTypeCheck

        running: !Config.gpuType
        command: ["sh", "-c", "if command -v nvidia-smi &>/dev/null && nvidia-smi -L &>/dev/null; then echo NVIDIA; elif ls /sys/class/drm/card*/device/gpu_busy_percent 2>/dev/null | grep -q .; then echo GENERIC; else echo NONE; fi"]
        stdout: StdioCollector {
            onStreamFinished: root.autoGpuType = text.trim()
        }
    }

    Process {
        id: oneshotMem
        command: ["nvidia-smi", "--query-gpu=memory.total", "--format=csv,noheader,nounits"]
        running: root.gpuType === "NVIDIA" && totalMem === 0
        stdout: StdioCollector {
            onStreamFinished: {
                totalMem = Number(this.text.trim())
                oneshotMem.running = false
            }
        }
    }

    Process {
        id: processGpu
        command: ["nvidia-smi", "--query-gpu=utilization.gpu,memory.used", "--format=csv,noheader,nounits"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split(", ")
                gpuUsage = Number(parts[0]) / 100
                gpuMemUsage = Number(parts[1]) / totalMem
            }
        }
    }
}
