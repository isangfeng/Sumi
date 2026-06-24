import XCTest
@testable import SumiCore

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

    func testImageInsertsPlaceholderForEmptySelection() {
        let result = MarkdownFormatting.apply(
            style: .image,
            to: "Hello ",
            selection: NSRange(location: 6, length: 0)
        )

        XCTAssertEqual(result.text, "Hello ![alt text](https://)")
        XCTAssertEqual(result.selection, NSRange(location: 8, length: 8))
    }

    func testTableInsertsTemplateAndSelectsFirstHeader() {
        let result = MarkdownFormatting.apply(
            style: .table,
            to: "",
            selection: NSRange(location: 0, length: 0)
        )

        XCTAssertEqual(result.text, "| Header | Header |\n| --- | --- |\n| Cell | Cell |")
        XCTAssertEqual((result.text as NSString).substring(with: result.selection), "Header")
    }

    func testHorizontalRuleInsertsOnItsOwnLines() {
        let result = MarkdownFormatting.apply(
            style: .horizontalRule,
            to: "Before",
            selection: NSRange(location: 6, length: 0)
        )

        XCTAssertEqual(result.text, "Before\n\n---\n\n")
        XCTAssertEqual(result.selection, NSRange(location: 13, length: 0))
    }
}
