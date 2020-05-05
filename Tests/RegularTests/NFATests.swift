import XCTest
@testable import Regular

final class NFATests: XCTestCase {
    
    func test_everything_matchesEmptySequence() {
        let nfa = NFA<Int>.everything
        XCTAssertTrue(nfa.matches([]))
    }

    func test_everything_matchesNonEmptySequence() {
        let nfa = NFA<Int>.everything
        XCTAssertTrue(nfa.matches([1]))
        XCTAssertTrue(nfa.matches([1, 2]))
    }

    func test_nothing_doesNotMatchEmptySequence() {
        let nfa = NFA<Int>.nothing
        XCTAssertFalse(nfa.matches([]))
    }
    
    func test_nothing_doesNotMatchNonEmptySequence() {
        let nfa = NFA<Int>.nothing
        XCTAssertFalse(nfa.matches([1]))
        XCTAssertFalse(nfa.matches([1, 2]))
    }
    
    func test_matchOne_matchesOne() {
        let nfa = NFA<Int>.match(one: { $0 == 0 })
        XCTAssertFalse(nfa.matches([]))
        XCTAssertTrue(nfa.matches([0]))
        XCTAssertFalse(nfa.matches([1]))
        XCTAssertFalse(nfa.matches([0, 0]))
        XCTAssertFalse(nfa.matches([0, 1]))
        XCTAssertFalse(nfa.matches([1, 1]))
    }

    func test_matchOneInverted_matchesAnythingButOne() {
        let nfa = NFA<Int>.match(one: { $0 == 0 }).inverted
        XCTAssertTrue(nfa.matches([]))
        XCTAssertFalse(nfa.matches([0]))
        XCTAssertTrue(nfa.matches([1]))
        XCTAssertTrue(nfa.matches([0, 0]))
        XCTAssertTrue(nfa.matches([0, 1]))
        XCTAssertTrue(nfa.matches([1, 1]))
    }
    
    func test_1then2_matches1Then2() {
        let nfa = NFA<Int>.match(one: { $0 == 1 }).then(.match(one: { $0 == 2 }))
        XCTAssertTrue(nfa.matches([1,2]))
        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([1]))
        XCTAssertFalse(nfa.matches([2]))
        XCTAssertFalse(nfa.matches([2,1]))
        XCTAssertFalse(nfa.matches([1,2,2]))
        XCTAssertFalse(nfa.matches([1,1]))
    }
}
