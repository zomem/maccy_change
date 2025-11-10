import AppKit
import SwiftUI

/// 强制隐藏 NSScrollView 的滚动条（包括滚动过程中）。
/// 将该视图放在 ScrollView 的内容层级内（如 background/overlay），
/// 它会向上找到最近的 NSScrollView 并关闭 scroller，并在滚动时持续抑制显示。
struct HiddenScrollIndicatorsView: NSViewRepresentable {
  final class Coordinator {
    weak var scrollView: NSScrollView?
    var observer: NSObjectProtocol?

    deinit {
      if let observer { NotificationCenter.default.removeObserver(observer) }
    }
  }

  func makeCoordinator() -> Coordinator { Coordinator() }

  func makeNSView(context: Context) -> NSView {
    let view = NSView(frame: .zero)
    DispatchQueue.main.async { self.apply(on: view, coordinator: context.coordinator) }
    return view
  }

  func updateNSView(_ nsView: NSView, context: Context) {
    DispatchQueue.main.async { self.apply(on: nsView, coordinator: context.coordinator) }
  }

  private func apply(on view: NSView, coordinator: Coordinator) {
    // 若已有并仍在窗口中，重复隐藏一次即可
    if let scroll = coordinator.scrollView, scroll.window != nil {
      hide(scroll)
      return
    }

    // 向上寻找最近的 NSScrollView
    var v: NSView? = view
    while let current = v {
      if let scroll = current.enclosingScrollView {
        coordinator.scrollView = scroll
        // 安装滚动监听，滚动时再次隐藏
        scroll.contentView.postsBoundsChangedNotifications = true
        coordinator.observer = NotificationCenter.default.addObserver(
          forName: NSView.boundsDidChangeNotification,
          object: scroll.contentView,
          queue: .main
        ) { [weak scroll] _ in
          guard let scroll else { return }
          self.hide(scroll)
        }
        hide(scroll)
        return
      }
      v = current.superview
    }
  }

  private func hide(_ scroll: NSScrollView) {
    // 使用 overlay 风格并彻底隐藏 scroller
    scroll.scrollerStyle = .overlay
    scroll.autohidesScrollers = true
    scroll.hasVerticalScroller = false
    scroll.hasHorizontalScroller = false
    scroll.verticalScroller?.isHidden = true
    scroll.horizontalScroller?.isHidden = true
    scroll.verticalScroller?.alphaValue = 0
    scroll.horizontalScroller?.alphaValue = 0
    if #available(macOS 12.0, *) {
      scroll.scrollerInsets = NSEdgeInsets(top: 0, left: -100, bottom: 0, right: -100)
    }
  }
}
