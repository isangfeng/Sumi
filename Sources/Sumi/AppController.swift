import AppKit
import SwiftUI

@MainActor
final class AppController {
    static let shared = AppController()

    private static let tabbingIdentifier = "com.sumi.documentTabGroup"

    let registry = DocumentRegistry()

    private var delegates: [ObjectIdentifier: DocumentWindowDelegate] = [:]

    private init() {}

    func openUntitledDocumentIfNeeded() {
        guard registry.openWindowCount == 0 else { return }
        newDocument()
    }

    func newDocument() {
        let model = SingleDocumentModel.blank(untitledName: registry.nextUntitledName(), registry: registry)
        showWindow(for: model)
    }

    func openDocument() {
        switch DocumentActions.chooseDocument(showsNewDocumentButton: true) {
        case .open(let url):
            openOrFocus(url: url)
        case .newDocument:
            newDocument()
        case .cancel:
            break
        }
    }

    func openOrFocus(url: URL) {
        if let window = registry.window(for: url) {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        do {
            let model = try SingleDocumentModel(loadingContentsOf: url, registry: registry)
            showWindow(for: model)
        } catch {
            showError("Could not open document.", detail: error.localizedDescription)
        }
    }

    var selectedModel: SingleDocumentModel? {
        registry.model(forWindow: NSApp.keyWindow)
    }

    private func showWindow(for model: SingleDocumentModel) {
        let content = ContentView()
            .environmentObject(model)
            .environmentObject(registry)

        let hostingController = NSHostingController(rootView: content)
        let window = NSWindow(contentViewController: hostingController)
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
        window.titlebarAppearsTransparent = true
        window.title = model.displayName
        window.representedURL = model.fileURL
        window.isDocumentEdited = model.isDirty
        window.tabbingMode = .preferred
        window.tabbingIdentifier = Self.tabbingIdentifier
        window.contentMinSize = NSSize(width: 880, height: 620)
        window.setContentSize(NSSize(width: 1040, height: 720))

        model.window = window
        let delegate = DocumentWindowDelegate(model: model, registry: registry) { [weak self] in
            self?.delegates[ObjectIdentifier(window)] = nil
        }
        window.delegate = delegate
        delegates[ObjectIdentifier(window)] = delegate
        registry.register(window: window, model: model)
        model.refreshWindowMetadata()

        if let keyWindow = NSApp.keyWindow, keyWindow !== window, registry.model(forWindow: keyWindow) != nil {
            keyWindow.addTabbedWindow(window, ordered: .above)
        } else {
            window.center()
        }

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func showError(_ message: String, detail: String) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = message
        alert.informativeText = detail
        alert.runModal()
    }
}
