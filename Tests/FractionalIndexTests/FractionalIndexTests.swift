import XCTest
@testable import FractionalIndex

final class FractionalIndexTests: XCTestCase {
    func testGetMidpointTest() {
        XCTAssertEqual(try! getMidpoint(a: "", b: nil), "V")
        XCTAssertEqual(try! getMidpoint(a: "V", b: nil), "l")
        XCTAssertEqual(try! getMidpoint(a: "l", b: nil), "t")
        XCTAssertEqual(try! getMidpoint(a: "001", b: "001001"), "001000V")
    }
    
    func testIncrementInteger() {
        XCTAssertEqual(try! incrementInteger(x: "a0"), "a1")
        XCTAssertEqual(try! incrementInteger(x: "az"), "b00")
        XCTAssertEqual(try! incrementInteger(x: "Zy"), "Zz")
        XCTAssertEqual(try! incrementInteger(x: "zzzzzzzzzzzzzzzzzzzzzzzzzzz"), nil)
        XCTAssertEqual(try! incrementInteger(x: "a0"), "a1")
    }
    
    func testDecrementInteger() {
        XCTAssertEqual(try! decrementInteger(x: "a1"), "a0")
        XCTAssertEqual(try! decrementInteger(x: "b00"), "az")
        XCTAssertEqual(try! decrementInteger(x: "dAC00"), "dABzz")
        XCTAssertEqual(try! decrementInteger(x: "A00000000000000000000000000"), nil)
        XCTAssertEqual(try! decrementInteger(x: "Xz00"), "Xyzz")
    }
    
    func testGenerateKeyBetween() {
        XCTAssertEqual(try! generateKeyBetween(a: "a0", b: nil), "a1")
        XCTAssertEqual(try! generateKeyBetween(a: "a0", b: "a0V"), "a0G")
        XCTAssertEqual(try! generateKeyBetween(a: nil, b: nil), "a0")
        XCTAssertEqual(try! generateKeyBetween(a: "Zz", b: "a0"), "ZzV")
        XCTAssertEqual(try! generateKeyBetween(a: "Zz", b: "a01"), "a0")
    }

    static var allTests = [
        ("midpoint", testGetMidpointTest),
        ("increment", testIncrementInteger),
        ("decrement", testDecrementInteger),
        ("generateKeyBetween", testGenerateKeyBetween)
    ]
}
