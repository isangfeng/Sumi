# MarkdownStudio

A focused native macOS Markdown editor.

The app intentionally keeps the scope small:

- Native macOS window, toolbar, sidebar, file dialogs, and text editing.
- Typora-style single writing surface with a centered readable column.
- Markdown syntax highlighting and common formatting commands.
- Local `.md` file open/save and recent documents.
- No PDF export, no Typst/Rust pipeline, no pagination.

The app has no bundled editing engine dependency. The bundle script copies Swift runtime libraries into `.app/Contents/Frameworks` when Xcode reports they are needed. AppKit and SwiftUI remain macOS system frameworks and are not copied into the app bundle.

## Build

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build -c release
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
./scripts/make-app-bundle.sh
open .build/MarkdownStudio.app
```

## Release Package

Create a downloadable macOS disk image:

```bash
./scripts/make-release-dmg.sh
```

The generated installer-style package is:

```text
.build/dist/MarkdownStudio.dmg
```

GitHub Releases are created automatically when a `v*` tag is pushed, for example:

```bash
git tag v0.1.0
git push origin main --tags
```

The app is not code signed or notarized yet, so macOS may show the standard warning for apps downloaded from the internet.
