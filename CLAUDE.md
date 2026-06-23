# MarkdownStudio — native macOS Markdown editor

This file records the current project state for future sessions.

## Product Scope

MarkdownStudio is a focused native macOS Markdown editor.

Current product decisions:

- App name: `MarkdownStudio`.
- Bundle identifier: `local.markdownstudio.app`.
- Native macOS window style is required: standard title bar, toolbar, sidebar, file dialogs, and system text editing behavior.
- The main content area should feel like Typora: one continuous writing surface, centered readable text column, no page cards, no pagination.
- The app writes Markdown documents only.
- PDF export is intentionally not included.
- Typst/Rust/PDF/layout engine code has been removed.
- The app should not depend on project-local tools or external editing engines at runtime.
- AppKit, SwiftUI, Foundation, and `/usr/lib/swift` are system runtime dependencies and are expected for a native macOS app.

## Current Project Structure

```text
.
├── Package.swift
├── README.md
├── CLAUDE.md
├── Sources
│   ├── MarkdownStudio
│   │   ├── MarkdownStudioApp.swift
│   │   ├── ContentView.swift
│   │   ├── SidebarView.swift
│   │   ├── EditorPane.swift
│   │   ├── MarkdownEditor.swift
│   │   ├── MarkdownSyntaxHighlighter.swift
│   │   ├── EditorRegistry.swift
│   │   └── DocumentStore.swift
│   └── MarkdownStudioCore
│       └── MarkdownFormatting.swift
├── Tests
│   └── MarkdownStudioCoreTests
│       └── MarkdownFormattingTests.swift
└── scripts
    └── make-app-bundle.sh
```

## Implementation Notes

- `Package.swift` defines:
  - executable product: `MarkdownStudio`
  - app target: `MarkdownStudio`
  - core target: `MarkdownStudioCore`
  - test target: `MarkdownStudioCoreTests`
- `MarkdownStudioApp.swift` is the SwiftUI app entry point.
- `ContentView.swift` uses `NavigationSplitView` for a native sidebar/detail app layout.
- `SidebarView.swift` shows the current document and recent Markdown files.
- `EditorPane.swift` hosts the editor area.
- `MarkdownEditor.swift` wraps `NSTextView` in `NSViewRepresentable`.
- `MarkdownSyntaxHighlighter.swift` applies lightweight Markdown styling directly to `NSTextStorage`.
- `EditorRegistry.swift` tracks the active `NSTextView` so toolbar/menu commands can apply formatting to the current selection.
- `DocumentStore.swift` handles new/open/save/save-as, recent documents, dirty state, and unsaved-change prompts.
- `MarkdownFormatting.swift` contains testable Markdown source transformations.

## Important UI Detail

The `NSScrollView` must fill the whole right-side content area so the vertical scrollbar sits at the far right edge of the window.

The centered Typora-like writing column is implemented inside `TrackingTextView` by dynamically adjusting `textContainerInset`, not by constraining the width of `MarkdownEditor`.

Do not reintroduce a narrow outer frame around `MarkdownEditor`; that causes the scrollbar to appear beside the readable column instead of at the window edge.

## Runtime and Bundling

Build command:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -c release
```

Test command:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```

Bundle command:

```bash
./scripts/make-app-bundle.sh
```

Run command:

```bash
open .build/MarkdownStudio.app
```

The bundle script:

- creates `.build/MarkdownStudio.app`
- copies `.build/release/MarkdownStudio` when available
- falls back to `.build/debug/MarkdownStudio`
- writes `Contents/Info.plist`
- uses `CFBundleName = MarkdownStudio`
- uses `CFBundleExecutable = MarkdownStudio`
- uses `CFBundleIdentifier = local.markdownstudio.app`
- adds `@executable_path/../Frameworks` rpath
- removes the Xcode toolchain Swift rpath when present
- runs `swift-stdlib-tool` to copy Swift runtime libraries into `Contents/Frameworks` if Xcode reports they are needed

On the current machine, `swift-stdlib-tool` reported no libraries to copy; `otool -L` showed only macOS system frameworks and `/usr/lib/swift` dependencies.

## Verification Already Run

After the rename to MarkdownStudio and scrollbar/layout fix, these commands passed:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -c release
./scripts/make-app-bundle.sh
```

The generated app is:

```text
.build/MarkdownStudio.app
```

Info.plist values were checked:

```text
CFBundleName = MarkdownStudio
CFBundleExecutable = MarkdownStudio
CFBundleIdentifier = local.markdownstudio.app
```

## Current Features

- Create a new Markdown document.
- Open `.md` and plain text files.
- Save and Save As.
- Track dirty state and prompt before losing unsaved changes.
- Store recent document paths under `MarkdownStudio.recentDocuments`.
- Native toolbar buttons for new/open/save and common Markdown formatting.
- Markdown menu commands and keyboard shortcuts.
- Lightweight Markdown syntax highlighting:
  - headings
  - blockquotes
  - inline code
  - fenced code blocks
  - bold
  - italic
  - links
- Markdown source transformations:
  - bold
  - italic
  - inline code
  - headings
  - bullet list
  - numbered list
  - blockquote
  - code block
  - link

## Known Limitations

- This is a source-mode Markdown editor, not a live rendered preview.
- Markdown syntax highlighting is intentionally lightweight and regex-based.
- There is no PDF export.
- There is no Typst integration.
- There is no custom icon yet.
- There is no code signing or notarization yet.
- `.build` may still contain stale products from earlier names if not manually cleaned, but active build and bundle outputs are `MarkdownStudio`.

## Avoid Reintroducing

Do not bring back:

- Rust workspace
- Typst engine
- PDF export
- page setup UI
- paginated preview
- fixed page canvas
- external renderer dependency
- app name `TypstNext`

If future work needs preview behavior, keep it optional and separate from the core writing surface.
