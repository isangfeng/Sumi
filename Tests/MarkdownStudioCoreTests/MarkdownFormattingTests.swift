import XCTest
@testable import MarkdownStudioCore

final class MarkdownFormattingTests: XCTestCase {
    func testBoldWrapsSelection() {
        let result = MarkdownFormatting.apply(
            style: .bold,
            to: "Hello world",
            selection: NSRange(location: 6, length: 5)
        )

        XCTAssertEqual(result.text, "Hello **world**")
        XCTAssertEqual(result.selection, NSRange(location: 8, length: 5))
    }

    func testBoldInsertsPlaceholderForEmptySelection() {
        let result = MarkdownFormatting.apply(
            style: .bold,
            to: "Hello ",
            selection: NSRange(location: 6, length: 0)
        )

        XCTAssertEqual(result.text, "Hello **strong text**")
        XCTAssertEqual(result.selection, NSRange(location: 8, length: 11))
    }

    func testHeadingReplacesExistingBlockPrefix() {
        let result = MarkdownFormatting.apply(
            style: .heading(2),
            to: "# Title\nBody",
            selection: NSRange(location: 0, length: 7)
        )

        XCTAssertEqual(result.text, "## Title\nBody")
    }

    func testNumberedListCoversSelectedLines() {
        let result = MarkdownFormatting.apply(
            style: .numberedList,
            to: "Alpha\nBeta\nGamma",
            selection: NSRange(location: 0, length: 10)
        )

        XCTAssertEqual(result.text, "1. Alpha\n2. Beta\nGamma")
    }

    func testFormattingKeepsUnicodeSelectionRangeValid() {
        let text = "中文 English"
        let range = (text as NSString).range(of: "中文")
        let result = MarkdownFormatting.apply(style: .italic, to: text, selection: range)

        XCTAssertEqual(result.text, "*中文* English")
        XCTAssertEqual((result.text as NSString).substring(with: result.selection), "中文")
    }
}
