# Repository Guidelines

## 项目结构与模块组织
- 源码：`Maccy/`（`AppDelegate.swift`、`MaccyApp.swift`、`Models/`、`Observables/`、`Views/`、`Settings/`、`Assets.xcassets`、`Sounds/`、本地化 `*.lproj`、数据模型 `History.xcdatamodeld`/`Storage.xcdatamodeld`）。
- 测试：`MaccyTests/`（单元测试）、`MaccyUITests/`（UI 测试）。
- 工程配置：`Maccy.xcodeproj`（共享 Scheme：`Maccy`），测试计划：`Maccy.xctestplan`。
- 质量与自动化：`.swiftlint.yml`、`.periphery.yml`、`.bartycrouch.toml`，CI 配置在 `.github/`。
- 其它：文档 `docs/`，设计素材 `Designs/`，发布 `appcast.xml`。

## 构建、测试与本地运行
- 打开工程：`open Maccy.xcodeproj`（或在 Xcode 里选择 Scheme `Maccy` 运行）。
- 构建（Debug）：`xcodebuild -project Maccy.xcodeproj -scheme Maccy -configuration Debug build`。
- 运行测试：`xcodebuild test -project Maccy.xcodeproj -scheme Maccy -destination 'platform=macOS' -testPlan Maccy`。
- 静态检查：`swiftlint`；无用代码扫描：`periphery scan --config .periphery.yml`。
- 本地化同步：`bartycrouch update`（请不要提交真实翻译密钥）。

## 代码风格与命名规范
- 语言：Swift（建议 2 空格缩进，保持短小函数与单一职责）。
- SwiftLint：遵循 `.swiftlint.yml`（忽略注释行长，禁用 `todo` 等规则）；提交前确保 `swiftlint` 通过。
- 命名：类型/枚举/协议用 UpperCamelCase；变量/函数用 lowerCamelCase；文件名与主类型一致。

## 测试指南
- 框架：XCTest（单元测试在 `MaccyTests/`，UI 测试在 `MaccyUITests/`）。
- 约定：文件名 `FooTests.swift`，方法名以 `test...` 开头；优先覆盖剪贴板、搜索、排序与首要交互路径。
- 运行前确保在“系统设置 → 隐私与安全 → 辅助功能”中允许应用，以避免 UI/剪贴板相关测试波动。

## 提交与 Pull Request
- 提交信息：英文祈使句，简洁具体（示例：`Fix crash when pasting HTML`），引用问题 `Fixes #123`（如适用）。
- PR 要求：变更说明、动机与影响、测试范围与步骤、UI 改动附截图/录屏、相关文档/本地化更新、风险与回滚方案。
- 质量门槛：通过 `swiftlint` 与全部测试；如涉及清理无用代码，附 `periphery` 结果要点。

## 安全与配置提示（可选）
- 从源码签名需配置个人 Team；修改 `Maccy.entitlements` 前请充分评估沙盒与权限影响。
- 请勿提交敏感信息（例如 `.bartycrouch.toml` 的翻译密钥），使用占位符或本地环境变量。

