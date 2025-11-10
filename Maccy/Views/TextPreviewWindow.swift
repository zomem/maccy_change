import AppKit
import SwiftUI

struct TextPreviewView: View {
  let text: String

  var body: some View {
    VStack(spacing: 0) {
      ScrollView {
        Text(text)
          .font(.system(.body, design: .monospaced))
          .textSelection(.enabled)
          .padding()
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .scrollIndicators(.hidden)
      .background { HiddenScrollIndicatorsView() }

      Divider()

      HStack(spacing: 8) {
        Button {
          copyToPasteboard(text)
        } label: {
          Label("复制", systemImage: "doc.on.doc")
        }
        .keyboardShortcut("c", modifiers: [.command])

        Button {
          saveText(text)
        } label: {
          Label("保存", systemImage: "square.and.arrow.down")
        }
      }
      .padding(8)
    }
    .frame(minWidth: 360, minHeight: 280)
  }

  private func copyToPasteboard(_ text: String) {
    let pb = NSPasteboard.general
    pb.clearContents()
    pb.setString(text, forType: .string)
  }

  private func saveText(_ text: String) {
    let panel = NSSavePanel()
    panel.canCreateDirectories = true
    panel.allowedFileTypes = ["txt", "md", "log", "json", "yaml", "yml", "csv", "xml"]
    panel.nameFieldStringValue = "Clipboard Text.txt"
    panel.begin { response in
      guard response == .OK, let url = panel.url else { return }
      do {
        try text.data(using: .utf8)?.write(to: url)
      } catch {
        NSSound.beep()
      }
    }
  }
}

final class PreviewTextWindow: NSWindow {
  convenience init(rootView: any View, title: String) {
    let hosting = NSHostingController(rootView: AnyView(rootView))
    self.init(contentViewController: hosting)
    // 使用最普通的窗口：可标题、可关闭、可缩放、可最小化
    styleMask = [.titled, .closable, .resizable, .miniaturizable]
    isReleasedWhenClosed = false
    self.title = title.isEmpty ? NSLocalizedString("文本预览", comment: "") : title
    setFrameAutosaveName("MaccyTextPreviewWindow")
    setContentSize(NSSize(width: 720, height: 560))
    // 标准窗口层级与行为，不做置顶/浮动/非激活等特殊处理
    center()
    makeKeyAndOrderFront(nil)
  }
}

final class TextPreviewWindowController: NSWindowController, NSWindowDelegate {
  override init(window: NSWindow?) {
    super.init(window: window)
    self.window?.delegate = self
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func windowWillClose(_ notification: Notification) {
    TextPreviewWindowManager.shared.detach(self)
  }
}

final class TextPreviewWindowManager {
  static let shared = TextPreviewWindowManager()
  private var controllers: [TextPreviewWindowController] = []

  func attach(_ controller: TextPreviewWindowController) {
    controllers.append(controller)
  }

  func detach(_ controller: TextPreviewWindowController) {
    controllers.removeAll { $0 === controller }
  }
}

enum TextPreviewWindow {
  static func show(text: String, title: String) {
    let view = TextPreviewView(text: text)
    let window = PreviewTextWindow(rootView: view, title: title)
    let controller = TextPreviewWindowController(window: window)
    TextPreviewWindowManager.shared.attach(controller)
    controller.window?.orderFrontRegardless()
  }
}
