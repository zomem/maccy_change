import Defaults
import SwiftUI

struct HistoryItemView: View {
  @Bindable var item: HistoryItemDecorator

  @Environment(AppState.self) private var appState
  

  private func isImageItem(_ item: HistoryItemDecorator) -> Bool {
    if item.thumbnailImage != nil { return true }
    let imageExts = ["png", "jpg", "jpeg", "heic", "tiff", "gif", "bmp", "webp"]
    return item.item.fileURLs.contains { url in
      imageExts.contains(url.pathExtension.lowercased())
    }
  }

  private func resolveImage() -> NSImage? {
    if let image = item.previewImage ?? item.item.image { return image }
    let imageExts = ["png", "jpg", "jpeg", "heic", "tiff", "gif", "bmp", "webp"]
    for url in item.item.fileURLs {
      if imageExts.contains(url.pathExtension.lowercased()),
         let data = try? Data(contentsOf: url),
         let img = NSImage(data: data) {
        return img
      }
    }
    return nil
  }

  private func isTextItem(_ item: HistoryItemDecorator) -> Bool {
    if let text = item.item.text, !text.isEmpty { return true }
    if let rtf = item.item.rtf, !rtf.string.isEmpty { return true }
    if let html = item.item.html, !html.string.isEmpty { return true }
    let textExts = [
      "txt", "md", "log", "json", "yaml", "yml", "xml", "csv", "plist",
      "swift", "py", "js", "ts", "java", "kt", "c", "cpp", "h", "m", "mm",
      "rs", "go", "rb", "php", "sh"
    ]
    if item.item.fileURLs.contains(where: { textExts.contains($0.pathExtension.lowercased()) }) {
      return true
    }
    return false
  }

  private func resolveText() -> String? {
    if let text = item.item.text, !text.isEmpty { return text }
    if let rtf = item.item.rtf, !rtf.string.isEmpty { return rtf.string }
    if let html = item.item.html, !html.string.isEmpty { return html.string }
    let textExts = [
      "txt", "md", "log", "json", "yaml", "yml", "xml", "csv", "plist",
      "swift", "py", "js", "ts", "java", "kt", "c", "cpp", "h", "m", "mm",
      "rs", "go", "rb", "php", "sh"
    ]
    for url in item.item.fileURLs where textExts.contains(url.pathExtension.lowercased()) {
      if let data = try? Data(contentsOf: url), let s = String(data: data, encoding: .utf8) {
        return s
      }
    }
    // 兜底：返回条目的可预览文本，避免点击无反应
    let fallback = item.text
    return fallback.isEmpty ? nil : fallback
  }

  var body: some View {
    ListItemView(
      id: item.id,
      appIcon: item.applicationImage,
      image: item.thumbnailImage,
      accessoryImage: item.thumbnailImage != nil ? nil : ColorImage.from(item.title),
      attributedTitle: item.attributedTitle,
      shortcuts: item.shortcuts,
      isSelected: item.isSelected,
      trailingAccessory: {
        var views: [AnyView] = []
        // 固定/取消固定 按钮（位于最左侧）
        views.append(AnyView(
          Button {
            appState.history.togglePin(item)
          } label: {
            if item.isPinned {
              Image(systemName: "pin.fill")
            } else {
              if item.isSelected {
                Image(systemName: "pin")
              } else {
                Image(systemName: "pin")
                  .foregroundStyle(.secondary) // 未固定时显示为灰色
              }
            }
          }
          .buttonStyle(.borderless)
          .help(LocalizedStringKey(item.isPinned ? "取消固定" : "固定"))
        ))
        if isImageItem(item) {
          views.append(AnyView(
            Button {
              if let image = resolveImage() {
                ImagePreviewWindow.show(image: image, title: item.title)
              } else {
                // 若无法解析图片，给出文本提示窗口，避免无响应
                TextPreviewWindow.show(text: "无可预览的图片", title: item.title)
              }
            } label: {
              Image(systemName: "doc.text.magnifyingglass")
            }
            .buttonStyle(.borderless)
            .help(LocalizedStringKey("预览图片"))
          ))
        }
        if isTextItem(item) {
          views.append(AnyView(
            Button {
              let text = resolveText() ?? "无可预览的文本"
              TextPreviewWindow.show(text: text, title: item.title)
            } label: {
              Image(systemName: "doc.text.magnifyingglass")
            }
            .buttonStyle(.borderless)
            .help(LocalizedStringKey("预览文本"))
          ))
        }
        if views.isEmpty { return nil }
        return AnyView(HStack(spacing: 6) { ForEach(Array(views.enumerated()), id: \.offset) { _, v in v } })
      }(),
      onPrimaryTap: {
        appState.history.select(item)
      }
    ) {
      Text(verbatim: item.title)
    }
  }
}
