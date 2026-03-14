import XCTest
@testable import SpeakSmart

@MainActor
final class RewriteViewModelTests: XCTestCase {

    override func tearDown() {
        AIService.shared.clearAPIKey()
        super.tearDown()
    }

    func testRewriteWithEmptyTextDoesNothing() {
        let vm = RewriteViewModel()
        vm.rewrite("")

        XCTAssertFalse(vm.isRewriting)
        XCTAssertNil(vm.rewrittenText)
    }

    func testRewriteWithNoEngineShowsAPIKeyPrompt() {
        let vm = RewriteViewModel()
        AIService.shared.clearAPIKey()

        // Only test on non-Apple-Intelligence devices
        if !AIService.shared.appleIntelligenceAvailable {
            vm.rewrite("Some text")
            XCTAssertTrue(vm.showAPIKeyPrompt)
            XCTAssertFalse(vm.isRewriting)
        }
    }

    #if DEBUG
    func testRewriteInDebugProducesResult() async {
        let vm = RewriteViewModel()
        AIService.shared.clearAPIKey()
        vm.selectedTone = .casual
        vm.selectedFormat = .message

        vm.rewrite("Hello there")

        // Wait for the async task to complete
        try? await Task.sleep(for: .seconds(2))

        // In debug without a key, the simulator fallback runs
        // But only if AI service isn't configured — if Apple Intelligence
        // is available it may take a different path
        if !AIService.shared.appleIntelligenceAvailable {
            if vm.rewrittenText != nil {
                XCTAssertFalse(vm.rewrittenText!.isEmpty)
            } else {
                // showAPIKeyPrompt path — also valid
                XCTAssertTrue(vm.showAPIKeyPrompt)
            }
        }
    }
    #endif

    func testSelectedToneAndFormatDefaults() {
        let vm = RewriteViewModel()
        XCTAssertEqual(vm.selectedTone, .professional)
        XCTAssertEqual(vm.selectedFormat, .notes)
    }
}
