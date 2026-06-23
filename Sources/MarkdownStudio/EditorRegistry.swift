import AppKit
import MarkdownStudioCore

@MainActor
final class EditorRegistry {
    static let shared = EditorRegistry()

    private weak var activeTextView: NSTextView?

    private init() {}

    func activate(_ textView: NSTextView) {
        activeTextView = textView
    }

    func apply(_ style: MarkdownFormatStyle) {
        guard let textView = activeTextView else {
            return
        }

        let oldText = textView.string
        let oldLength = (oldText as NSString).length
        let result = MarkdownFormatting.apply(
            style: style,
            to: oldText,
            selection: textView.selectedRange()
        )

        let fullRange = NSRange(location: 0, length: oldLength)
        guard textView.shouldChangeText(in: fullRange, replacementString: result.text) else {
            return
        }

        textView.string = result.text
        MarkdownSyntaxHighlighter.highlight(textView)
        textView.setSelectedRange(result.selection)
        textView.didChangeText()
    }
}
