import XCTest
@testable import SpeakSmart

final class RecordingTests: XCTestCase {

    // MARK: - Codable Roundtrip

    func testCodableRoundtripWithAllFields() throws {
        let recording = Recording(
            originalText: "Hello world",
            rewrittenText: "Greetings, world",
            tone: .professional,
            format: .email,
            audioURL: URL(string: "file:///tmp/test.m4a")
        )

        let data = try JSONEncoder().encode(recording)
        let decoded = try JSONDecoder().decode(Recording.self, from: data)

        XCTAssertEqual(decoded.id, recording.id)
        XCTAssertEqual(decoded.originalText, recording.originalText)
        XCTAssertEqual(decoded.rewrittenText, recording.rewrittenText)
        XCTAssertEqual(decoded.tone, recording.tone)
        XCTAssertEqual(decoded.format, recording.format)
        XCTAssertEqual(decoded.audioURL, recording.audioURL)
        XCTAssertEqual(
            decoded.createdAt.timeIntervalSinceReferenceDate,
            recording.createdAt.timeIntervalSinceReferenceDate,
            accuracy: 0.001
        )
    }

    func testCodableRoundtripWithNilOptionals() throws {
        let recording = Recording(originalText: "Just text")

        let data = try JSONEncoder().encode(recording)
        let decoded = try JSONDecoder().decode(Recording.self, from: data)

        XCTAssertEqual(decoded.originalText, "Just text")
        XCTAssertNil(decoded.rewrittenText)
        XCTAssertNil(decoded.tone)
        XCTAssertEqual(decoded.format, .notes) // default
        XCTAssertNil(decoded.audioURL)
    }

    func testCodableRoundtripArray() throws {
        let recordings = [
            Recording(originalText: "First", tone: .casual, format: .message),
            Recording(originalText: "Second", rewrittenText: "2nd", tone: .funny, format: .social),
        ]

        let data = try JSONEncoder().encode(recordings)
        let decoded = try JSONDecoder().decode([Recording].self, from: data)

        XCTAssertEqual(decoded.count, 2)
        XCTAssertEqual(decoded[0].originalText, "First")
        XCTAssertEqual(decoded[1].rewrittenText, "2nd")
    }

    // MARK: - Default Values

    func testDefaultValues() {
        let recording = Recording(originalText: "Test")

        XCTAssertFalse(recording.id.uuidString.isEmpty)
        XCTAssertEqual(recording.format, .notes)
        XCTAssertNil(recording.rewrittenText)
        XCTAssertNil(recording.tone)
        XCTAssertNil(recording.audioURL)
    }

    // MARK: - Identifiable

    func testUniqueIDs() {
        let r1 = Recording(originalText: "A")
        let r2 = Recording(originalText: "A")
        XCTAssertNotEqual(r1.id, r2.id)
    }
}
