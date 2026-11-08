# GPU Observer for macOS

轻量菜单栏应用，分别显示 AMD Vega 8 和 NVIDIA RTX 3050 的驱动上报占用率。

- 每 2 秒读取一次 IORegistry；无需管理员密码。
- 菜单栏显示 Vega8 和 RTX3050 百分比。
- 不显示 Dock 图标，启动时不弹窗口；点击菜单可显示窗口或退出。
- 多个 AMD 加速器条目取最大值，不进行相加。

占用数字来自 PerformanceStatistics / Device Utilization %。第三方驱动可能缺少字段或上报不准确；无数据时显示 --。本工具不会选择 GPU、安装驱动，也不能从总占用率判定某个网页用了哪张卡。

## 安装

从 Releases 下载 DMG，将应用拖到 Applications。应用为本地临时签名，未经 Apple 公证；如被拦截，可按 macOS 提示在系统设置中允许打开。

## 从源码构建

需要 macOS 与 Xcode Command Line Tools（Swift、AppKit、iconutil、hdiutil）。运行 ./build.sh，产物位于 dist/。当前安装包是 Intel x86_64 构建。其他 GPU 或 Apple Silicon 尚未验证。

## 实测电脑

| 项目 | 规格 |
| --- | --- |
| 笔记本 | ASUS Vivobook Pro 14X OLED M7400QC |
| CPU | AMD Ryzen 7 5800H，8 核 16 线程 |
| 核显 | AMD Radeon Vega 8 / Renoir，系统报告 512 MB |
| 独显 | NVIDIA GeForce RTX 3050 Laptop GPU，4 GB GDDR6 |
| 内存 | 16 GB DDR4-3200 |
| 内屏 | 14 英寸 OLED，2880 × 1800，90 Hz |
| 外接屏 | Lenovo Y27q-30，2560 × 1440，144 Hz，当前由 AMD 输出 |
| 系统 | macOS Sequoia 15.8.1，x86_64，OpenCore |
| 指纹模块 | ELAN USB 04f3:0c6e，采集尺寸 150 × 52 |

硬件型号相同不保证固件和驱动行为一致。

## 许可

MIT。图标由 src/main.swift 中的原生 AppKit 绘图代码生成。
