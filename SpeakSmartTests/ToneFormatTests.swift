import XCTest
@testable import SpeakSmart

final class ToneTests: XCTestCase {

    func testAllCasesCount() {
        XCTAssertEqual(Tone.allCases.count, 6)
    }

    func testRawValues() {
        XCTAssertEqual(Tone.professional.rawValue, "Professional")
        XCTAssertEqual(Tone.casual.rawValue, "Casual")
        XCTAssertEqual(Tone.funny.rawValue, "Funny")
        XCTAssertEqual(Tone.polite.rawValue, "Polite")
        XCTAssertEqual(Tone.concise.rawValue, "Concise")
        XCTAssertEqual(Tone.detailed.rawValue, "Detailed")
    }

    func testIdentifiable() {
        for tone in Tone.allCases {
            XCTAssertEqual(tone.id, tone.rawValue)
        }
    }

    func testIconsAreNonEmpty() {
        for tone in Tone.allCases {
            XCTAssertFalse(tone.icon.isEmpty, "\(tone) has empty icon")
        }
    }

    func testCodableRoundtrip() throws {
        for tone in Tone.allCases {
            let data = try JSONEncoder().encode(tone)
            let decoded = try JSONDecoder().decode(Tone.self, from: data)
            XCTAssertEqual(decoded, tone)
        }
    }
}

final class FormatTests: XCTestCase {

    func testAllCasesCount() {
        XCTAssertEqual(Format.allCases.count, 5)
    }

    func testRawValues() {
        XCTAssertEqual(Format.email.rawValue, "Email")
        XCTAssertEqual(Format.notes.rawValue, "Notes")
        XCTAssertEqual(Format.message.rawValue, "Message")
        XCTAssertEqual(Format.memo.rawValue, "Memo")
        XCTAssertEqual(Format.social.rawValue, "Social Post")
    }

    func testIdentifiable() {
        for format in Format.allCases {
            XCTAssertEqual(format.id, format.rawValue)
        }
    }

    func testIconsAreNonEmpty() {
        for format in Format.allCases {
            XCTAssertFalse(format.icon.isEmpty, "\(format) has empty icon")
        }
    }

    func testCodableRoundtrip() throws {
        for format in Format.allCases {
            let data = try JSONEncoder().encode(format)
            let decoded = try JSONDecoder().decode(Format.self, from: data)
            XCTAssertEqual(decoded, format)
        }
    }
}
