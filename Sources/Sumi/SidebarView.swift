import SwiftUI
import SumiCore

struct SidebarView: View {
    @EnvironmentObject private var model: SingleDocumentModel

    var body: some View {
        List {
            Section("Outline") {
                if model.outlineItems.isEmpty {
                    Text("No headings")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(model.outlineItems) { item in
                        outlineRow(item)
                    }
                }
            }
        }
    }

    private func outlineRow(_ item: MarkdownOutlineItem) -> some View {
        HStack(spacing: 6) {
            Text("H\(item.level)")
                .font(.caption2.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 24, alignment: .leading)

            Text(item.title)
                .lineLimit(1)
        }
        .padding(.leading, CGFloat(max(0, item.level - 1)) * 10)
        .help("Line \(item.lineNumber)")
    }
}
