import AppKit

@MainActor
final class DocumentWindowDelegate: NSObject, NSWindowDelegate {
    let model: SingleDocumentModel
    let registry: DocumentRegistry
    private let onClose: () -> Void

    init(model: SingleDocumentModel, registry: DocumentRegistry, onClose: @escaping () -> Void = {}) {
        self.model = model
        self.registry = registry
        self.onClose = onClose
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        model.confirmClose()
    }

    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            registry.unregister(window: window)
        }
        registry.unregister(model: model)
        onClose()
    }
}
