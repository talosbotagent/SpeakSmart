import XCTest
@testable import SpeakSmart

@MainActor
final class HistoryStoreTests: XCTestCase {

    private var testFileURL: URL!

    override func setUp() {
        super.setUp()
        // Use a unique temp file for each test to avoid cross-contamination
        testFileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("speaksmart_test_\(UUID().uuidString).json")
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: testFileURL)
        // Also clean up the default storage file used by HistoryStore
        let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("speaksmart_recordings.json")
        try? FileManager.default.removeItem(at: docsURL)
        UserDefaults.standard.removeObject(forKey: "speaksmart.recordings")
        super.tearDown()
    }

    // MARK: - CRUD

    func testAddInsertsAtFront() {
        let store = HistoryStore()
        let r1 = Recording(originalText: "First")
        let r2 = Recording(originalText: "Second")

        store.add(r1)
        store.add(r2)

        XCTAssertEqual(store.recordings.count, 2)
        XCTAssertEqual(store.recordings[0].originalText, "Second")
        XCTAssertEqual(store.recordings[1].originalText, "First")
    }

    func testDeleteRemovesCorrectItem() {
        let store = HistoryStore()
        let r1 = Recording(originalText: "Keep")
        let r2 = Recording(originalText: "Delete")

        store.add(r1)
        store.add(r2)

        // r2 is at index 0 (inserted at front)
        store.delete(at: IndexSet(integer: 0))

        XCTAssertEqual(store.recordings.count, 1)
        XCTAssertEqual(store.recordings[0].originalText, "Keep")
    }

    func testUpdateModifiesExistingRecording() {
        let store = HistoryStore()
        let original = Recording(originalText: "Original")
        store.add(original)

        let updated = Recording(
            id: original.id,
            originalText: "Original",
            rewrittenText: "Rewritten",
            tone: .professional,
            format: .email,
            createdAt: original.createdAt
        )
        store.update(updated)

        XCTAssertEqual(store.recordings.count, 1)
        XCTAssertEqual(store.recordings[0].rewrittenText, "Rewritten")
        XCTAssertEqual(store.recordings[0].tone, .professional)
    }

    func testUpdateWithNonexistentIDDoesNothing() {
        let store = HistoryStore()
        store.add(Recording(originalText: "Existing"))

        let unrelated = Recording(originalText: "Ghost")
        store.update(unrelated)

        XCTAssertEqual(store.recordings.count, 1)
        XCTAssertEqual(store.recordings[0].originalText, "Existing")
    }

    // MARK: - Persistence

    func testPersistenceAcrossInstances() {
        // First instance writes data
        let store1 = HistoryStore()
        store1.add(Recording(originalText: "Persisted", tone: .casual, format: .message))

        // Second instance should load it
        let store2 = HistoryStore()

        XCTAssertEqual(store2.recordings.count, 1)
        XCTAssertEqual(store2.recordings[0].originalText, "Persisted")
        XCTAssertEqual(store2.recordings[0].tone, .casual)
        XCTAssertEqual(store2.recordings[0].format, .message)
    }

    func testDeletePersists() {
        let store1 = HistoryStore()
        store1.add(Recording(originalText: "A"))
        store1.add(Recording(originalText: "B"))
        store1.delete(at: IndexSet(integer: 0))

        let store2 = HistoryStore()
        XCTAssertEqual(store2.recordings.count, 1)
    }

    // MARK: - Migration from UserDefaults

    func testMigratesFromUserDefaults() {
        // Seed legacy data into UserDefaults
        let legacy = [Recording(originalText: "Legacy data", tone: .polite, format: .memo)]
        let encoded = try! JSONEncoder().encode(legacy)
        UserDefaults.standard.set(encoded, forKey: "speaksmart.recordings")

        // Remove the file so migration runs
        let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("speaksmart_recordings.json")
        try? FileManager.default.removeItem(at: docsURL)

        let store = HistoryStore()

        XCTAssertEqual(store.recordings.count, 1)
        XCTAssertEqual(store.recordings[0].originalText, "Legacy data")
        // UserDefaults key should be cleaned up
        XCTAssertNil(UserDefaults.standard.data(forKey: "speaksmart.recordings"))
    }

    // MARK: - Empty State

    func testEmptyStoreOnFreshInit() {
        // Ensure no prior data
        let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("speaksmart_recordings.json")
        try? FileManager.default.removeItem(at: docsURL)

        let store = HistoryStore()
        XCTAssertTrue(store.recordings.isEmpty)
    }
}
