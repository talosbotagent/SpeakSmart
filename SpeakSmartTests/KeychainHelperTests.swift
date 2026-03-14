import XCTest
@testable import SpeakSmart

final class KeychainHelperTests: XCTestCase {

    private let testKey = "com.speaksmart.test-keychain-key"

    override func tearDown() {
        KeychainHelper.delete(forKey: testKey)
        super.tearDown()
    }

    // MARK: - String Operations

    func testSaveAndLoadString() {
        let saved = KeychainHelper.save("secret-value", forKey: testKey)
        XCTAssertTrue(saved)

        let loaded = KeychainHelper.loadString(forKey: testKey)
        XCTAssertEqual(loaded, "secret-value")
    }

    func testLoadReturnsNilForMissingKey() {
        let loaded = KeychainHelper.loadString(forKey: "nonexistent-key-\(UUID().uuidString)")
        XCTAssertNil(loaded)
    }

    func testSaveOverwritesPreviousValue() {
        KeychainHelper.save("first", forKey: testKey)
        KeychainHelper.save("second", forKey: testKey)

        let loaded = KeychainHelper.loadString(forKey: testKey)
        XCTAssertEqual(loaded, "second")
    }

    // MARK: - Data Operations

    func testSaveAndLoadData() {
        let data = Data([0x01, 0x02, 0x03])
        let saved = KeychainHelper.save(data, forKey: testKey)
        XCTAssertTrue(saved)

        let loaded = KeychainHelper.load(forKey: testKey)
        XCTAssertEqual(loaded, data)
    }

    // MARK: - Delete

    func testDeleteRemovesValue() {
        KeychainHelper.save("to-delete", forKey: testKey)
        let deleted = KeychainHelper.delete(forKey: testKey)
        XCTAssertTrue(deleted)

        let loaded = KeychainHelper.loadString(forKey: testKey)
        XCTAssertNil(loaded)
    }

    func testDeleteNonexistentKeySucceeds() {
        let result = KeychainHelper.delete(forKey: "nonexistent-key-\(UUID().uuidString)")
        XCTAssertTrue(result) // returns true for errSecItemNotFound
    }

    // MARK: - Edge Cases

    func testSaveEmptyString() {
        let saved = KeychainHelper.save("", forKey: testKey)
        XCTAssertTrue(saved)

        let loaded = KeychainHelper.loadString(forKey: testKey)
        XCTAssertEqual(loaded, "")
    }

    func testSaveLongString() {
        let longString = String(repeating: "a", count: 10_000)
        let saved = KeychainHelper.save(longString, forKey: testKey)
        XCTAssertTrue(saved)

        let loaded = KeychainHelper.loadString(forKey: testKey)
        XCTAssertEqual(loaded, longString)
    }
}
