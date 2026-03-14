import XCTest
@testable import SpeakSmart

@MainActor
final class AIServiceTests: XCTestCase {

    private let testKeychainKey = "com.speaksmart.openai-api-key"

    override func tearDown() {
        // Clean up any keys set during tests
        KeychainHelper.delete(forKey: testKeychainKey)
        UserDefaults.standard.removeObject(forKey: "openai_api_key")
        super.tearDown()
    }

    // MARK: - API Key Management

    func testSetAPIKeyStoresInKeychain() {
        let service = AIService()
        service.setAPIKey("sk-test-key-12345")

        let stored = KeychainHelper.loadString(forKey: testKeychainKey)
        XCTAssertEqual(stored, "sk-test-key-12345")
    }

    func testSetAPIKeyTrimsWhitespace() {
        let service = AIService()
        service.setAPIKey("  sk-test-key  \n")

        let stored = KeychainHelper.loadString(forKey: testKeychainKey)
        XCTAssertEqual(stored, "sk-test-key")
    }

    func testClearAPIKeyRemovesFromKeychain() {
        let service = AIService()
        service.setAPIKey("sk-test-key-12345")
        service.clearAPIKey()

        let stored = KeychainHelper.loadString(forKey: testKeychainKey)
        XCTAssertNil(stored)
    }

    func testHasAPIKeyReflectsState() {
        let service = AIService()
        service.clearAPIKey()
        XCTAssertFalse(service.hasAPIKey)

        service.setAPIKey("sk-test")
        XCTAssertTrue(service.hasAPIKey)

        service.clearAPIKey()
        XCTAssertFalse(service.hasAPIKey)
    }

    // MARK: - Engine Selection

    func testEngineWithKeyIsConfigured() {
        let service = AIService()
        service.setAPIKey("sk-test-key")

        // With a key, the service should be configured regardless of
        // whether Apple Intelligence is also available
        XCTAssertTrue(service.isConfigured)
        XCTAssertTrue(service.hasAPIKey)

        // Engine is either .appleIntelligence (if available, takes priority)
        // or .openAI (fallback)
        if service.appleIntelligenceAvailable {
            XCTAssertEqual(service.activeEngine, .appleIntelligence)
        } else {
            XCTAssertEqual(service.activeEngine, .openAI)
        }
    }

    func testEngineIsNoneWhenNoKey() {
        let service = AIService()
        service.clearAPIKey()

        // On non-Apple-Intelligence devices, should be .none
        if !service.appleIntelligenceAvailable {
            XCTAssertEqual(service.activeEngine, .none)
            XCTAssertFalse(service.isConfigured)
        }
    }

    // MARK: - Legacy Migration

    func testMigratesKeyFromUserDefaults() {
        // Seed a key into UserDefaults (legacy location)
        UserDefaults.standard.set("sk-legacy-key", forKey: "openai_api_key")
        // Clear Keychain so migration actually writes
        KeychainHelper.delete(forKey: testKeychainKey)

        let service = AIService()
        _ = service // trigger init which calls migrateFromUserDefaultsIfNeeded

        // Key should now be in Keychain
        let stored = KeychainHelper.loadString(forKey: testKeychainKey)
        XCTAssertEqual(stored, "sk-legacy-key")

        // Legacy key should be removed from UserDefaults
        XCTAssertNil(UserDefaults.standard.string(forKey: "openai_api_key"))
    }

    // MARK: - Rewrite

    func testRewriteWithoutKeyProducesResult() async throws {
        let service = AIService()
        service.clearAPIKey()

        // Both Apple Intelligence (on-device) and DEBUG simulator
        // should produce a non-empty result
        let result = try await service.rewrite(
            text: "Hello world",
            tone: .professional,
            format: .email
        )
        XCTAssertFalse(result.isEmpty)
    }

    func testRewriteSimulatorOnlyAppliesTonePrefix() async throws {
        let service = AIService()
        service.clearAPIKey()

        // Simulated rewrite tests only apply when Apple Intelligence
        // is NOT available (otherwise the real AI rewrites the text)
        guard !service.appleIntelligenceAvailable else { return }

        #if DEBUG
        let casual = try await service.rewrite(text: "Test", tone: .casual, format: .message)
        XCTAssertTrue(casual.hasPrefix("Hey!"))

        let professional = try await service.rewrite(text: "Test", tone: .professional, format: .message)
        XCTAssertTrue(professional.hasPrefix("Dear"))
        #endif
    }

    func testRewriteSimulatorOnlyAppliesFormatSuffix() async throws {
        let service = AIService()
        service.clearAPIKey()

        guard !service.appleIntelligenceAvailable else { return }

        #if DEBUG
        let email = try await service.rewrite(text: "Test", tone: .polite, format: .email)
        XCTAssertTrue(email.contains("Best regards"))

        let social = try await service.rewrite(text: "Test", tone: .polite, format: .social)
        XCTAssertTrue(social.contains("#SpeakSmart"))
        #endif
    }

    func testRewriteSimulatorOnlyConciseTruncates() async throws {
        let service = AIService()
        service.clearAPIKey()

        guard !service.appleIntelligenceAvailable else { return }

        #if DEBUG
        let result = try await service.rewrite(
            text: "First sentence. Second sentence. Third sentence.",
            tone: .concise,
            format: .message
        )
        XCTAssertFalse(result.contains("Second sentence"))
        #endif
    }
}
