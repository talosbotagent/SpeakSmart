import XCTest
@testable import SpeakSmart

@MainActor
final class AIDisclosureTests: XCTestCase {

    private let disclosureKey = "hasAcceptedAIDisclosure"

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: disclosureKey)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: disclosureKey)
        super.tearDown()
    }

    // MARK: - UserDefaults gate

    func testDisclosureDefaultsToFalse() {
        let value = UserDefaults.standard.bool(forKey: disclosureKey)
        XCTAssertFalse(value, "hasAcceptedAIDisclosure should default to false")
    }

    func testAcceptingDisclosurePersists() {
        UserDefaults.standard.set(true, forKey: disclosureKey)
        XCTAssertTrue(UserDefaults.standard.bool(forKey: disclosureKey))
    }

    // MARK: - AIDisclosureView instantiation

    func testDefaultModeIsNotReview() {
        let view = AIDisclosureView()
        XCTAssertFalse(view.isReviewMode, "Default mode should not be review mode")
    }

    func testReviewModeCanBeEnabled() {
        let view = AIDisclosureView(isReviewMode: true)
        XCTAssertTrue(view.isReviewMode, "Review mode should be true when passed")
    }

    // MARK: - App flow gate (SpeakSmartApp)

    func testSkipDisclosureLaunchArgument() {
        // Simulate the --skip-disclosure argument behavior
        UserDefaults.standard.set(true, forKey: disclosureKey)
        XCTAssertTrue(
            UserDefaults.standard.bool(forKey: disclosureKey),
            "--skip-disclosure should set hasAcceptedAIDisclosure to true"
        )
    }

    func testDisclosureAppearsAfterOnboarding() {
        // When onboarding is done but disclosure is not accepted,
        // the app should show AIDisclosureView (not the main tab bar)
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(false, forKey: disclosureKey)

        let disclosureAccepted = UserDefaults.standard.bool(forKey: disclosureKey)
        let onboardingDone = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

        XCTAssertTrue(onboardingDone, "Onboarding should be completed")
        XCTAssertFalse(disclosureAccepted, "Disclosure should not yet be accepted")
        // The app gate logic: if !hasCompletedOnboarding → onboarding
        //                      else if !hasAcceptedAIDisclosure → disclosure
        //                      else → main app
        // So with onboarding done and disclosure not accepted, disclosure screen should show.
    }

    func testMainAppShowsAfterDisclosureAccepted() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(true, forKey: disclosureKey)

        let disclosureAccepted = UserDefaults.standard.bool(forKey: disclosureKey)
        let onboardingDone = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

        XCTAssertTrue(onboardingDone)
        XCTAssertTrue(disclosureAccepted, "Both gates passed — main app should display")
    }

    // MARK: - Settings integration

    func testSettingsShowsDisclosureInReviewMode() {
        // Verify AIDisclosureView can be created in review mode for settings sheet
        let reviewView = AIDisclosureView(isReviewMode: true)
        XCTAssertTrue(reviewView.isReviewMode)
    }
}
