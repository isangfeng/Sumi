import AppKit
import UniformTypeIdentifiers

private extension UTType {
    static let markdownDocument = UTType(filenameExtension: "md") ?? .plainText
}

private extension NSApplication.ModalResponse {
    static let newDocument = NSApplication.ModalResponse(2)
}

@MainActor
enum DocumentActions {
    enum OpenPanelChoice {
        case open(URL)
        case newDocument
        case cancel
    }

    static func chooseDocument(showsNewDocumentButton: Bool) -> OpenPanelChoice {
        runOpenPanel(showsNewDocumentButton: showsNewDocumentButton)
    }

    static func newDocument() {
        AppController.shared.newDocument()
    }

    static func openDocument() {
        AppController.shared.openDocument()
    }

    private static func runOpenPanel(showsNewDocumentButton: Bool) -> OpenPanelChoice {
        let panel = NSOpenPanel()
        panel.title = "Open"
        panel.prompt = "Open"
        panel.allowedContentTypes = [.markdownDocument, .plainText]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        let response = panel.runModal()

        switch response {
        case .OK:
            guard let url = panel.url else { return .cancel }
            return .open(url)
        case .newDocument:
            return .newDocument
        default:
            return .cancel
        }
    }
}
