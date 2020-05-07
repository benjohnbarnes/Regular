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
        let nfa = NFA<Int>.just({ $0 == 0 })

        XCTAssertTrue(nfa.matches([0]))

        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([1]))
        XCTAssertFalse(nfa.matches([0, 0]))
        XCTAssertFalse(nfa.matches([0, 1]))
        XCTAssertFalse(nfa.matches([1, 1]))
    }

    func test_matchOneInverted_matchesAnythingButOne() {
        let nfa = !NFA<Int>.just({ $0 == 0 })

        XCTAssertTrue(nfa.matches([]))
        XCTAssertTrue(nfa.matches([1]))
        XCTAssertTrue(nfa.matches([0, 0]))
        XCTAssertTrue(nfa.matches([0, 1]))
        XCTAssertTrue(nfa.matches([1, 1]))

        XCTAssertFalse(nfa.matches([0]))
    }
    
    func test_match1Or2_andNot1_matches2AndNot1() {
        let nfa: NFA<Int> = .just({ 1...2 ~= $0 }) & !.just({ $0 == 1 })
        
        XCTAssertTrue(nfa.matches([2]))

        XCTAssertFalse(nfa.matches([1]))
    }
    
    func test_1Or2Or2Or3_matches1Or2Or3() {
        let nfa: NFA<Int> = .just({ 1...2 ~= $0 }) | .just({ 2...3 ~= $0 })

        XCTAssertTrue(nfa.matches([1]))
        XCTAssertTrue(nfa.matches([2]))
        XCTAssertTrue(nfa.matches([3]))

        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([1,2]))
        XCTAssertFalse(nfa.matches([2,1]))
        XCTAssertFalse(nfa.matches([4]))
    }

    func test_1Or2And2Or3_matchesOnly2() {
        let nfa: NFA<Int> = .just({ 1...2 ~= $0 }) & .just({ 2...3 ~= $0 })

        XCTAssertTrue(nfa.matches([2]))

        XCTAssertFalse(nfa.matches([1]))
        XCTAssertFalse(nfa.matches([3]))
        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([2,2]))
    }

    func test_1then2_matches1Then2() {
        let nfa = NFA<Int>.just({ $0 == 1 }).then(.just({ $0 == 2 }))

        XCTAssertTrue(nfa.matches([1,2]))

        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([1]))
        XCTAssertFalse(nfa.matches([2]))
        XCTAssertFalse(nfa.matches([2,1]))
        XCTAssertFalse(nfa.matches([1,2,2]))
        XCTAssertFalse(nfa.matches([1,1]))
    }
    
    func test_1optional() {
        let nfa =  NFA<Int>.just({ $0 == 1 }).optional
        
        XCTAssertTrue(nfa.matches([]))
        XCTAssertTrue(nfa.matches([1]))
        
        XCTAssertFalse(nfa.matches([2]))
        XCTAssertFalse(nfa.matches([1,1]))
    }
    
    func test_1plus() {
        let nfa = NFA<Int>.just({ $0 == 1 }).plus
        
        XCTAssertTrue(nfa.matches([1]))
        XCTAssertTrue(nfa.matches([1, 1]))
        XCTAssertTrue(nfa.matches([1, 1, 1]))
        XCTAssertTrue(nfa.matches([1, 1, 1, 1]))

        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([1, 2]))
        XCTAssertFalse(nfa.matches([2, 1]))
    }
    
    func test_not1Plus() {
        let nfa = !(NFA<Int>.just({ $0 == 1 }).plus)
        
        XCTAssertFalse(nfa.matches([1]))
        XCTAssertFalse(nfa.matches([1, 1]))
        XCTAssertFalse(nfa.matches([1, 1, 1]))
        XCTAssertFalse(nfa.matches([1, 1, 1, 1]))

        XCTAssertTrue(nfa.matches([]))
        XCTAssertTrue(nfa.matches([1, 2]))
        XCTAssertTrue(nfa.matches([2, 1]))
    }

    func test_1star() {
        let nfa = NFA<Int>.just({ $0 == 1 }).star
        
        XCTAssertTrue(nfa.matches([]))
        XCTAssertTrue(nfa.matches([1]))
        XCTAssertTrue(nfa.matches([1, 1]))
        XCTAssertTrue(nfa.matches([1, 1, 1]))
        XCTAssertTrue(nfa.matches([1, 1, 1, 1]))

        XCTAssertFalse(nfa.matches([1, 2]))
        XCTAssertFalse(nfa.matches([2, 1]))
    }
    
    func test_not1star() {
        let nfa: NFA<Int> = !(NFA.just({ $0 == 1 }).star)
        
        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([1]))
        XCTAssertFalse(nfa.matches([1, 1]))
        XCTAssertFalse(nfa.matches([1, 1, 1]))
        XCTAssertFalse(nfa.matches([1, 1, 1, 1]))

        XCTAssertTrue(nfa.matches([1, 2]))
        XCTAssertTrue(nfa.matches([2, 1]))
    }
}
