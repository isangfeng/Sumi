import SwiftUI

struct EditorPane: View {
    @EnvironmentObject private var store: DocumentStore

    var body: some View {
        ZStack {
            Color(nsColor: .textBackgroundColor)
                .ignoresSafeArea()

            MarkdownEditor(text: $store.text)
        }
        .overlay(alignment: .topTrailing) {
            if store.isDirty {
                Text("Edited")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            }
        }
        .navigationTitle(store.displayName)
    }
}
