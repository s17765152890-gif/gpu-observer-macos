import Cocoa

if CommandLine.arguments.contains("--make-icon") {
 let image = NSImage(size: NSSize(width: 1024, height: 1024))
 image.lockFocus()
 NSColor(calibratedRed: 0.06, green: 0.10, blue: 0.18, alpha: 1).setFill()
 NSBezierPath(roundedRect: NSRect(x: 0, y: 0, width: 1024, height: 1024), xRadius: 220, yRadius: 220).fill()
 let chip = NSBezierPath(roundedRect: NSRect(x: 230, y: 250, width: 564, height: 524), xRadius: 78, yRadius: 78)
 NSColor(calibratedRed: 0.20, green: 0.87, blue: 0.68, alpha: 1).setStroke(); chip.lineWidth = 34; chip.stroke()
 let p = NSBezierPath(); p.move(to: NSPoint(x: 300,y: 460)); p.line(to: NSPoint(x: 402,y: 460)); p.line(to: NSPoint(x: 457,y: 590)); p.line(to: NSPoint(x: 526,y: 370)); p.line(to: NSPoint(x: 590,y: 512)); p.line(to: NSPoint(x: 724,y: 512)); p.lineWidth = 30; p.lineCapStyle = .round; p.lineJoinStyle = .round; NSColor.white.setStroke(); p.stroke()
 for i in 0..<4 { let x = 320 + i * 128; let a = NSBezierPath(); a.move(to: NSPoint(x:x,y:170)); a.line(to:NSPoint(x:x,y:250)); a.move(to:NSPoint(x:x,y:774)); a.line(to:NSPoint(x:x,y:854)); a.lineWidth=24; a.lineCapStyle = .round; NSColor(calibratedRed:0.20,green:0.87,blue:0.68,alpha:1).setStroke(); a.stroke() }
 image.unlockFocus()
 if let t=image.tiffRepresentation, let b=NSBitmapImageRep(data:t), let png=b.representation(using:.png,properties:[:]) { try? png.write(to:URL(fileURLWithPath:CommandLine.arguments[2])) }
 exit(0)
}
let app = NSApplication.shared
app.setActivationPolicy(.accessory)
class MenuWindow: NSWindow { override func miniaturize(_ sender: Any?) { orderOut(sender) } }
let window = MenuWindow(contentRect: NSRect(x:0,y:0,width:420,height:235), styleMask:[.titled,.closable,.miniaturizable], backing:.buffered, defer:false)
window.title="GPU 观察器"; window.center(); window.isReleasedWhenClosed=false
let view=window.contentView!
func label(_ text:String,_ y:CGFloat)->NSTextField { let l=NSTextField(labelWithString:text); l.frame=NSRect(x:24,y:y,width:375,height:28); l.font = .systemFont(ofSize:18); view.addSubview(l); return l }
let amd=label("Vega 8：读取中…",174)
let nv=label("RTX 3050：读取中…",133)
let note=NSTextField(wrappingLabelWithString:"每 2 秒刷新。数据由显卡驱动提供；第三方驱动可能不准确。关闭或最小化窗口后，应用仍在右上角运行。")
note.frame=NSRect(x:24,y:35,width:372,height:78); note.font = .systemFont(ofSize:12); note.textColor = .secondaryLabelColor; view.addSubview(note)
let status=NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
status.button?.title="Vega8: --  RTX3050: --"
status.button?.image = NSImage(systemSymbolName: "cpu", accessibilityDescription: "GPU 观察器")
status.button?.imagePosition = .imageLeading
class Actions: NSObject, NSWindowDelegate {
 var targetWindow: NSWindow!
 @objc func showWindow() { targetWindow.deminiaturize(nil); targetWindow.makeKeyAndOrderFront(nil); NSApplication.shared.activate(ignoringOtherApps:true) }
 @objc func quit() { NSApplication.shared.terminate(nil) }
 func windowShouldClose(_ sender:NSWindow)->Bool { sender.orderOut(nil); return false }
}
let actions=Actions(); actions.targetWindow=window; window.delegate=actions
let menu=NSMenu(); let show=NSMenuItem(title:"显示窗口",action:#selector(Actions.showWindow),keyEquivalent:""); show.target=actions; menu.addItem(show); menu.addItem(.separator()); let quit=NSMenuItem(title:"退出 GPU 观察器",action:#selector(Actions.quit),keyEquivalent:""); quit.target=actions; menu.addItem(quit); status.menu=menu
func refresh() {
 DispatchQueue.global(qos:.utility).async {
  let p=Process(); p.executableURL=URL(fileURLWithPath:"/usr/sbin/ioreg"); p.arguments=["-r","-c","IOAccelerator","-a"]
  let out=Pipe(); p.standardOutput=out; p.standardError=FileHandle.nullDevice
  var a:[Double]=[]; var n:[Double]=[]
  do { try p.run(); let data=out.fileHandleForReading.readDataToEndOfFile(); p.waitUntilExit()
   if p.terminationStatus == 0, let items=try PropertyListSerialization.propertyList(from:data,format:nil) as? [[String:Any]] {
    for item in items { let name=(item["IORegistryEntryName"] as? String ?? "") + " " + (item["MetalPluginName"] as? String ?? "")
     if let stats=item["PerformanceStatistics"] as? [String:Any], let value=stats["Device Utilization %"] as? NSNumber {
      if name.localizedCaseInsensitiveContains("NVAccel") || name.localizedCaseInsensitiveContains("NVMTL") { n.append(value.doubleValue) }
      if name.localizedCaseInsensitiveContains("AMDRadeon") { a.append(value.doubleValue) }
     }
    }
   }
  } catch {}
  let av=a.max().map { String(format:"%.0f%%",$0) } ?? "--"
  let nvValue=n.max().map { String(format:"%.0f%%",$0) } ?? "--"
  DispatchQueue.main.async { amd.stringValue="Vega 8：\(av)"; nv.stringValue="RTX 3050：\(nvValue)"; status.button?.title="Vega8: \(av)  RTX3050: \(nvValue)" }
 }
}
refresh(); Timer.scheduledTimer(withTimeInterval:2,repeats:true) { _ in refresh() }; app.run()
