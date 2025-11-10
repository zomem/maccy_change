import AppKit
import SwiftUI

struct ImagePreviewView: View {
  let image: NSImage

  var body: some View {
    VStack(spacing: 0) {
      ScrollView {
        Image(nsImage: image)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .padding()
      }
      .scrollIndicators(.hidden)
      .background { HiddenScrollIndicatorsView() }

      Divider()

      HStack(spacing: 8) {
        Button {
          copyToPasteboard(image)
        } label: {
          Label("复制", systemImage: "doc.on.doc")
        }
        .keyboardShortcut("c", modifiers: [.command])

        Button {
          saveImage(image)
        } label: {
          Label("保存", systemImage: "square.and.arrow.down")
        }
      }
      .padding(8)
    }
    .frame(minWidth: 360, minHeight: 280)
  }

  private func copyToPasteboard(_ image: NSImage) {
    let pb = NSPasteboard.general
    pb.clearContents()
    pb.writeObjects([image])
  }

  private func saveImage(_ image: NSImage) {
    let panel = NSSavePanel()
    panel.canCreateDirectories = true
    panel.allowedFileTypes = ["png", "jpg", "jpeg", "tiff"]
    panel.nameFieldStringValue = "Clipboard Image.png"
    panel.begin { response in
      guard response == .OK, let url = panel.url else { return }
      do {
        if let data = imageData(for: image, url: url) {
          try data.write(to: url)
        }
      } catch {
        NSSound.beep()
      }
    }
  }

  private func imageData(for image: NSImage, url: URL) -> Data? {
    let ext = url.pathExtension.lowercased()
    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff) else { return nil }
    switch ext {
    case "jpg", "jpeg":
      return rep.representation(using: .jpeg, properties: [.compressionFactor: 0.9])
    case "tiff":
      return rep.representation(using: .tiff, properties: [:])
    default:
      return rep.representation(using: .png, properties: [:])
    }
  }
}

final class PreviewImageWindow: NSWindow {
  convenience init(rootView: any View, title: String) {
    let hosting = NSHostingController(rootView: AnyView(rootView))
    self.init(contentViewController: hosting)
    // 使用最普通的窗口：可标题、可关闭、可缩放、可最小化
    styleMask = [.titled, .closable, .resizable, .miniaturizable]
    isReleasedWhenClosed = false
    self.title = title.isEmpty ? NSLocalizedString("图片预览", comment: "") : title
    setFrameAutosaveName("MaccyImagePreviewWindow")
    setContentSize(NSSize(width: 720, height: 560))
    // 标准窗口层级与行为，不做置顶/浮动/非激活等特殊处理
    center()
    makeKeyAndOrderFront(nil)
  }
}

final class ImagePreviewWindowController: NSWindowController, NSWindowDelegate {
  override init(window: NSWindow?) {
    super.init(window: window)
    self.window?.delegate = self
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func windowWillClose(_ notification: Notification) {
    ImagePreviewWindowManager.shared.detach(self)
  }
}

final class ImagePreviewWindowManager {
  static let shared = ImagePreviewWindowManager()
  private var controllers: [ImagePreviewWindowController] = []

  func attach(_ controller: ImagePreviewWindowController) {
    controllers.append(controller)
  }

  func detach(_ controller: ImagePreviewWindowController) {
    controllers.removeAll { $0 === controller }
  }
}

enum ImagePreviewWindow {
  static func show(image: NSImage, title: String) {
    let view = ImagePreviewView(image: image)
    let window = PreviewImageWindow(rootView: view, title: title)
    let controller = ImagePreviewWindowController(window: window)
    ImagePreviewWindowManager.shared.attach(controller)
    controller.window?.orderFrontRegardless()
  }
}
