import AppKit
import SwiftUI

struct MarkdownEditor: NSViewRepresentable {
    @Binding var text: String

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder

        let textView = TrackingTextView()
        textView.delegate = context.coordinator
        textView.string = text
        textView.drawsBackground = false
        textView.isRichText = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = true
        textView.allowsUndo = true
        textView.font = MarkdownSyntaxHighlighter.baseFont
        textView.textColor = .labelColor
        textView.insertionPointColor = .controlAccentColor
        textView.textContainerInset = NSSize(width: 28, height: 40)
        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]

        if let textContainer = textView.textContainer {
            textContainer.widthTracksTextView = true
            textContainer.containerSize = NSSize(width: scrollView.contentSize.width, height: CGFloat.greatestFiniteMagnitude)
            textContainer.lineFragmentPadding = 0
        }

        scrollView.documentView = textView
        context.coordinator.textView = textView
        MarkdownSyntaxHighlighter.highlight(textView)

        DispatchQueue.main.async {
            textView.window?.makeFirstResponder(textView)
            EditorRegistry.shared.activate(textView)
        }

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else {
            return
        }

        if textView.string != text {
            let selectedRange = textView.selectedRange()
            textView.string = text
            MarkdownSyntaxHighlighter.highlight(textView)
            let maxLocation = (text as NSString).length
            textView.setSelectedRange(NSRange(location: min(selectedRange.location, maxLocation), length: 0))
        }
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        @Binding var text: String
        weak var textView: NSTextView?

        init(text: Binding<String>) {
            self._text = text
        }

        func textDidBeginEditing(_ notification: Notification) {
            if let textView = notification.object as? NSTextView {
                EditorRegistry.shared.activate(textView)
            }
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }

            text = textView.string
            MarkdownSyntaxHighlighter.highlight(textView)
        }
    }
}

final class TrackingTextView: NSTextView {
    private let readableWidth: CGFloat = 820
    private let minimumHorizontalInset: CGFloat = 28
    private let verticalInset: CGFloat = 40

    override func becomeFirstResponder() -> Bool {
        let became = super.becomeFirstResponder()
        if became {
            EditorRegistry.shared.activate(self)
        }
        return became
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        updateTextInsets()
    }

    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        updateTextInsets()
    }

    override func layout() {
        super.layout()
        updateTextInsets()
    }

    private func updateTextInsets() {
        let horizontalInset = max(minimumHorizontalInset, (bounds.width - readableWidth) / 2)
        let nextInset = NSSize(width: horizontalInset, height: verticalInset)
        if textContainerInset != nextInset {
            textContainerInset = nextInset
        }
    }
}
