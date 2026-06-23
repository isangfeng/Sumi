import SwiftUI

struct SidebarView: View {
    @EnvironmentObject private var store: DocumentStore

    var body: some View {
        List(selection: Binding(
            get: { store.fileURL },
            set: { url in
                if let url {
                    store.loadRecentDocument(url)
                }
            }
        )) {
            Section("Current") {
                Label(store.displayName, systemImage: store.isDirty ? "doc.badge.ellipsis" : "doc.text")
                    .tag(store.fileURL)
            }

            if !store.recentDocuments.isEmpty {
                Section("Recent") {
                    ForEach(store.recentDocuments, id: \.self) { url in
                        Label(url.deletingPathExtension().lastPathComponent, systemImage: "doc.text")
                            .tag(Optional(url))
                            .help(url.path)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 10) {
                Button {
                    store.newDocument()
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.borderless)
                .help("New Document")

                Button {
                    store.openDocument()
                } label: {
                    Image(systemName: "folder")
                }
                .buttonStyle(.borderless)
                .help("Open Document")

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.bar)
        }
    }
}
