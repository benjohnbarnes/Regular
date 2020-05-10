import XCTest
@testable import Regular

final class NFATests: XCTestCase {
    
    func test_everything() {
        let nfa = NFA<Int>.all

        XCTAssertTrue(nfa.matches([]))
        XCTAssertTrue(nfa.matches([1]))
        XCTAssertTrue(nfa.matches([1, 2]))
    }

    func test_nothing() {
        let nfa = NFA<Int>.none

        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([1]))
        XCTAssertFalse(nfa.matches([1, 2]))
    }
    
    func test_empty() {
        let empty: NFA<Int> = .empty
        
        XCTAssertTrue(empty.matches([]))

        XCTAssertFalse(empty.matches([1]))
        XCTAssertFalse(empty.matches([1, 2]))
    }
    
    func test_notEmpty() {
        let empty: NFA<Int> = !.empty
        
        XCTAssertFalse(empty.matches([]))

        XCTAssertTrue(empty.matches([1]))
        XCTAssertTrue(empty.matches([1, 2]))
    }
    
    func test_matchOne_matchesOne() {
        let nfa = NFA<Int>.symbol({ $0 == 0 })

        XCTAssertTrue(nfa.matches([0]))

        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([1]))
        XCTAssertFalse(nfa.matches([0, 0]))
        XCTAssertFalse(nfa.matches([0, 1]))
        XCTAssertFalse(nfa.matches([1, 1]))
    }

    func test_matchOneInverted_matchesAnythingButOne() {
        let nfa = !NFA<Int>.symbol({ $0 == 0 })

        XCTAssertTrue(nfa.matches([]))
        XCTAssertTrue(nfa.matches([1]))
        XCTAssertTrue(nfa.matches([0, 0]))
        XCTAssertTrue(nfa.matches([0, 1]))
        XCTAssertTrue(nfa.matches([1, 1]))

        XCTAssertFalse(nfa.matches([0]))
    }
    
    func test_match1Or2_andNot1_matches2AndNot1() {
        let nfa: NFA<Int> = .symbol({ 1...2 ~= $0 }) & !.symbol({ $0 == 1 })
        
        XCTAssertTrue(nfa.matches([2]))

        XCTAssertFalse(nfa.matches([1]))
    }
    
    func test_1Or2Or2Or3_matches1Or2Or3() {
        let nfa: NFA<Int> = .symbol({ 1...2 ~= $0 }) | .symbol({ 2...3 ~= $0 })

        XCTAssertTrue(nfa.matches([1]))
        XCTAssertTrue(nfa.matches([2]))
        XCTAssertTrue(nfa.matches([3]))

        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([1,2]))
        XCTAssertFalse(nfa.matches([2,1]))
        XCTAssertFalse(nfa.matches([4]))
    }

//    func test_1Or2XOR2Or3_matches1And3ButNot2() {
//        let nfa: NFA<Int> = .symbol({ 1...2 ~= $0 }) ^ .symbol({ 2...3 ~= $0 })
//
//        XCTAssertTrue(nfa.matches([1]))
//        XCTAssertTrue(nfa.matches([3]))
//
//        XCTAssertFalse(nfa.matches([]))
//        XCTAssertFalse(nfa.matches([2]))
//        XCTAssertFalse(nfa.matches([1,2]))
//        XCTAssertFalse(nfa.matches([2,1]))
//        XCTAssertFalse(nfa.matches([4]))
//    }
    
    func test_1Or2And2Or3_matchesOnly2() {
        let nfa: NFA<Int> = .symbol({ 1...2 ~= $0 }) & .symbol({ 2...3 ~= $0 })

        XCTAssertTrue(nfa.matches([2]))

        XCTAssertFalse(nfa.matches([1]))
        XCTAssertFalse(nfa.matches([3]))
        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([2,2]))
    }

    func test_1then2_matches1Then2() {
        let nfa = NFA<Int>.symbol({ $0 == 1 }) + .symbol({ $0 == 2 })

        XCTAssertTrue(nfa.matches([1,2]))

        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([1]))
        XCTAssertFalse(nfa.matches([2]))
        XCTAssertFalse(nfa.matches([2,1]))
        XCTAssertFalse(nfa.matches([1,2,2]))
        XCTAssertFalse(nfa.matches([1,1]))
    }
    
    func test_1then2then3() {
        let nfa: NFA<Int> = NFA<Int>.symbol({ $0 == 1 }) + NFA<Int>.symbol({ $0 == 2 }) + NFA<Int>.symbol({ $0 == 3 })

        XCTAssertTrue(nfa.matches([1,2,3]))

        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([1]))
        XCTAssertFalse(nfa.matches([2]))
        XCTAssertFalse(nfa.matches([2,1]))
        XCTAssertFalse(nfa.matches([1,2]))
        XCTAssertFalse(nfa.matches([1,2,3,3]))
        XCTAssertFalse(nfa.matches([1,2,2]))
        XCTAssertFalse(nfa.matches([1,1]))
    }
    
    func test_not1then2then3() {
        let nfa: NFA<Int> = !(NFA<Int>.symbol { $0 == 1 } + NFA<Int>.symbol { $0 == 2 } + NFA<Int>.symbol { $0 == 3 })

        XCTAssertFalse(nfa.matches([1,2,3]))

        XCTAssertTrue(nfa.matches([]))
        XCTAssertTrue(nfa.matches([1]))
        XCTAssertTrue(nfa.matches([2]))
        XCTAssertTrue(nfa.matches([2,1]))
        XCTAssertTrue(nfa.matches([1,2]))
        XCTAssertTrue(nfa.matches([1,2,3,3]))
        XCTAssertTrue(nfa.matches([1,2,2]))
        XCTAssertTrue(nfa.matches([1,1]))
    }
    
    func test_1optional() {
        let nfa =  NFA<Int>.symbol({ $0 == 1 }).optional
        
        XCTAssertTrue(nfa.matches([]))
        XCTAssertTrue(nfa.matches([1]))
        
        XCTAssertFalse(nfa.matches([2]))
        XCTAssertFalse(nfa.matches([1,1]))
    }
    
    func test_not1optional() {
        let nfa: NFA<Int> =  !(NFA.symbol({ $0 == 1 }).optional)
        
        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([1]))
        
        XCTAssertTrue(nfa.matches([2]))
        XCTAssertTrue(nfa.matches([1,1]))
    }
    
    func test_1plus() {
        let nfa = NFA<Int>.symbol({ $0 == 1 }).plus
        
        XCTAssertTrue(nfa.matches([1]))
        XCTAssertTrue(nfa.matches([1, 1]))
        XCTAssertTrue(nfa.matches([1, 1, 1]))
        XCTAssertTrue(nfa.matches([1, 1, 1, 1]))

        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([1, 2]))
        XCTAssertFalse(nfa.matches([2, 1]))
    }
    
    func test_not1Plus() {
        let nfa = !(NFA<Int>.symbol({ $0 == 1 }).plus)
        
        XCTAssertFalse(nfa.matches([1]))
        XCTAssertFalse(nfa.matches([1, 1]))
        XCTAssertFalse(nfa.matches([1, 1, 1]))
        XCTAssertFalse(nfa.matches([1, 1, 1, 1]))

        XCTAssertTrue(nfa.matches([]))
        XCTAssertTrue(nfa.matches([1, 2]))
        XCTAssertTrue(nfa.matches([2, 1]))
    }

    func test_1star() {
        let nfa = NFA<Int>.symbol({ $0 == 1 }).star
        
        XCTAssertTrue(nfa.matches([]))
        XCTAssertTrue(nfa.matches([1]))
        XCTAssertTrue(nfa.matches([1, 1]))
        XCTAssertTrue(nfa.matches([1, 1, 1]))
        XCTAssertTrue(nfa.matches([1, 1, 1, 1]))

        XCTAssertFalse(nfa.matches([1, 2]))
        XCTAssertFalse(nfa.matches([2, 1]))
    }
    
    func test_not1star() {
        let nfa: NFA<Int> = !(NFA.symbol({ $0 == 1 }).star)
        
        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([1]))
        XCTAssertFalse(nfa.matches([1, 1]))
        XCTAssertFalse(nfa.matches([1, 1, 1]))
        XCTAssertFalse(nfa.matches([1, 1, 1, 1]))

        XCTAssertTrue(nfa.matches([1, 2]))
        XCTAssertTrue(nfa.matches([2, 1]))
    }
    
    func test_dot() {
        let nfa: NFA<Int> = .symbol

        XCTAssertTrue(nfa.matches([0]))
        XCTAssertTrue(nfa.matches([1]))
        XCTAssertTrue(nfa.matches([2]))
        
        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([1, 1]))
    }

    func test_notDot() {
        let nfa: NFA<Int> = !.symbol

        XCTAssertFalse(nfa.matches([0]))
        XCTAssertFalse(nfa.matches([1]))
        XCTAssertFalse(nfa.matches([2]))
        
        XCTAssertTrue(nfa.matches([]))
        XCTAssertTrue(nfa.matches([1, 1]))
    }

    func test_1AtFourFromEnd() {
        let nfa: NFA<Int> = NFA.all + .symbol { $0 == 1 } + .symbol + .symbol + .symbol
        
        XCTAssertTrue(nfa.matches([1, 0, 0, 0]))
        XCTAssertTrue(nfa.matches([1, 1, 0, 0]))
        XCTAssertTrue(nfa.matches([1, 0, 1, 1]))
        XCTAssertTrue(nfa.matches([1, 1, 0, 1, 1]))
        XCTAssertTrue(nfa.matches([0, 1, 0, 1, 1]))
        XCTAssertTrue(nfa.matches([0, 0, 1, 0, 1, 1]))
        XCTAssertTrue(nfa.matches([1, 0, 1, 0, 1, 1]))

        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([1]))
        XCTAssertFalse(nfa.matches([1, 1]))
        XCTAssertFalse(nfa.matches([1, 1, 1]))
    }
}
