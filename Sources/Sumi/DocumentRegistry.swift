import AppKit
import Foundation

@MainActor
final class DocumentRegistry: ObservableObject {
    private var nextUntitledNumber = 1

    private struct Entry {
        weak var window: NSWindow?
        weak var model: SingleDocumentModel?
    }

    private var entries: [Entry] = []

    var openFileURLs: [URL] {
        entries.compactMap { $0.model?.fileURL }
    }

    var dirtyModels: [SingleDocumentModel] {
        entries.compactMap(\.model).filter(\.isDirty)
    }

    var openWindowCount: Int {
        Set(entries.compactMap { $0.window.map(ObjectIdentifier.init) }).count
    }

    func register(window: NSWindow, model: SingleDocumentModel) {
        entries.removeAll { $0.window == nil || $0.model == nil || $0.model === model }
        entries.append(Entry(window: window, model: model))
    }

    func unregister(window: NSWindow) {
        entries.removeAll { $0.window == nil || $0.window === window }
    }

    func unregister(model: SingleDocumentModel) {
        entries.removeAll { $0.model == nil || $0.model === model }
    }

    func window(for url: URL) -> NSWindow? {
        entries.first { $0.model?.fileURL == url }?.window
    }

    func model(forWindow window: NSWindow?) -> SingleDocumentModel? {
        guard let window else { return nil }
        return entries.first { $0.window === window }?.model
    }

    func nextUntitledName() -> String {
        defer { nextUntitledNumber += 1 }
        return nextUntitledNumber == 1 ? "Untitled.md" : "Untitled \(nextUntitledNumber).md"
    }

    func displayName(for url: URL) -> String {
        let matchingNameCount = openFileURLs.filter { $0.lastPathComponent == url.lastPathComponent }.count
        if matchingNameCount > 1 {
            return url.path
        }

        return url.lastPathComponent
    }
}
