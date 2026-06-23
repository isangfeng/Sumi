import AppKit

enum MarkdownSyntaxHighlighter {
    static let baseFont = NSFont.systemFont(ofSize: 18, weight: .regular)
    private static let monoFont = NSFont.monospacedSystemFont(ofSize: 16, weight: .regular)

    static func highlight(_ textView: NSTextView) {
        let selectedRange = textView.selectedRange()
        let text = textView.string as NSString
        let fullRange = NSRange(location: 0, length: text.length)

        guard let storage = textView.textStorage else {
            return
        }

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 5
        paragraph.paragraphSpacing = 9

        storage.beginEditing()
        storage.setAttributes([
            .font: baseFont,
            .foregroundColor: NSColor.labelColor,
            .paragraphStyle: paragraph
        ], range: fullRange)

        apply(pattern: #"(?m)^#{1,6}\s.+$"#, in: text, storage: storage) { match in
            let line = text.substring(with: match.range)
            let level = min(line.prefix { $0 == "#" }.count, 6)
            let size = max(20, 30 - (level * 2))
            storage.addAttributes([
                .font: NSFont.systemFont(ofSize: CGFloat(size), weight: .semibold),
                .foregroundColor: NSColor.labelColor
            ], range: match.range)
        }

        apply(pattern: #"(?m)^\s{0,3}>\s?.+$"#, in: text, storage: storage) { match in
            storage.addAttributes([
                .foregroundColor: NSColor.secondaryLabelColor
            ], range: match.range)
        }

        apply(pattern: #"`[^`\n]+`"#, in: text, storage: storage) { match in
            storage.addAttributes([
                .font: monoFont,
                .foregroundColor: NSColor.systemPink
            ], range: match.range)
        }

        apply(pattern: #"(?s)```.*?```"#, in: text, storage: storage) { match in
            storage.addAttributes([
                .font: monoFont,
                .foregroundColor: NSColor.labelColor,
                .backgroundColor: NSColor.textColor.withAlphaComponent(0.06)
            ], range: match.range)
        }

        apply(pattern: #"\*\*([^*\n]+)\*\*"#, in: text, storage: storage) { match in
            storage.addAttributes([
                .font: NSFont.systemFont(ofSize: 18, weight: .bold)
            ], range: match.range)
        }

        apply(pattern: #"(?<!\*)\*([^*\n]+)\*(?!\*)"#, in: text, storage: storage) { match in
            storage.addAttributes([
                .font: NSFont.systemFont(ofSize: 18).withTraits(.italic)
            ], range: match.range)
        }

        apply(pattern: #"\[[^\]\n]+\]\([^)]+\)"#, in: text, storage: storage) { match in
            storage.addAttributes([
                .foregroundColor: NSColor.linkColor,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ], range: match.range)
        }

        storage.endEditing()
        textView.setSelectedRange(selectedRange)
    }

    private static func apply(
        pattern: String,
        in text: NSString,
        storage: NSTextStorage,
        block: (NSTextCheckingResult) -> Void
    ) {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return
        }

        regex.enumerateMatches(
            in: text as String,
            range: NSRange(location: 0, length: text.length)
        ) { match, _, _ in
            if let match {
                block(match)
            }
        }
    }
}

private extension NSFont {
    func withTraits(_ traits: NSFontDescriptor.SymbolicTraits) -> NSFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return NSFont(descriptor: descriptor, size: pointSize) ?? self
    }
}
