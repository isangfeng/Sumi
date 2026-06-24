import SwiftUI

struct EditorPane: View {
    @EnvironmentObject private var model: SingleDocumentModel

    var body: some View {
        ZStack {
            Color(nsColor: .textBackgroundColor)
                .ignoresSafeArea()

            MarkdownEditor(text: Binding(
                get: { model.text },
                set: { model.updateText($0) }
            ))
        }
        .overlay(alignment: .topTrailing) {
            if model.isDirty {
                Text("Edited")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            }
        }
        .navigationTitle(model.displayName)
    }
}
