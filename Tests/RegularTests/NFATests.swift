//
//  Created by Benjohn on 10/05/2020.
//

@testable import Regular
import XCTest

final class NFATests: XCTestCase {
    
    func test_all() {
        let nfa = NFA<Int>.all

        XCTAssertTrue(nfa.matches([]))
        XCTAssertTrue(nfa.matches([1]))
        XCTAssertTrue(nfa.matches([1, 2]))
        XCTAssertTrue(nfa.matches([1, 2, 3, 4, 5, 6, 7]))
    }

    func test_none() {
        let nfa = NFA<Int>.none

        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([1]))
        XCTAssertFalse(nfa.matches([1, 2]))
        XCTAssertFalse(nfa.matches([1, 2, 3, 4, 5, 6, 7]))
    }
    
    func test_empty() {
        let empty: NFA<Int> = .empty
        
        XCTAssertTrue(empty.matches([]))

        XCTAssertFalse(empty.matches([1]))
        XCTAssertFalse(empty.matches([1, 2]))
    }
    
    func test_some() {
        let empty: NFA<Int> = .some
        
        XCTAssertFalse(empty.matches([]))

        XCTAssertTrue(empty.matches([1]))
        XCTAssertTrue(empty.matches([1, 2]))
    }
    
    func test_matchOne_matchesOne() {
        let nfa = zero

        XCTAssertTrue(nfa.matches([0]))

        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([1]))
        XCTAssertFalse(nfa.matches([0, 0]))
        XCTAssertFalse(nfa.matches([0, 1]))
        XCTAssertFalse(nfa.matches([1, 1]))
    }

    func test_matchOneInverted_matchesAnythingButOne() {
        let nfa = !zero

        XCTAssertTrue(nfa.matches([]))
        XCTAssertTrue(nfa.matches([1]))
        XCTAssertTrue(nfa.matches([0, 0]))
        XCTAssertTrue(nfa.matches([0, 1]))
        XCTAssertTrue(nfa.matches([1, 1]))

        XCTAssertFalse(nfa.matches([0]))
    }
    
    func test_match1Or2_andNot1_matches2AndNot1() {
        let nfa: NFA<Int> = .symbol({ 1...2 ~= $0 }) & !one
        
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

    func test_1Or2And2Or3_matchesOnly2() {
        let nfa: NFA<Int> = .symbol({ 1...2 ~= $0 }) & .symbol({ 2...3 ~= $0 })

        XCTAssertTrue(nfa.matches([2]))

        XCTAssertFalse(nfa.matches([1]))
        XCTAssertFalse(nfa.matches([3]))
        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([2,2]))
    }

    func test_allThenAll() {
        let nfa: NFA<Int> = .all + .all
        
        XCTAssertTrue(nfa.matches([]))
        XCTAssertTrue(nfa.matches([1]))
        XCTAssertTrue(nfa.matches([1, 1]))
        XCTAssertTrue(nfa.matches([1, 2, 3, 4, 5, 6]))
    }

    func test_1then2_matches1Then2() {
        let nfa = one + two

        XCTAssertTrue(nfa.matches([1,2]))

        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([1]))
        XCTAssertFalse(nfa.matches([2]))
        XCTAssertFalse(nfa.matches([2,1]))
        XCTAssertFalse(nfa.matches([1,2,2]))
        XCTAssertFalse(nfa.matches([1,1]))
    }
    
    func test_1then2then3() {
        let nfa: NFA<Int> = one + two + three

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
    
    func test_1ThenAnything() {
        let nfa: NFA<Int> = one + NFA<Int>.all

        XCTAssertTrue(nfa.matches([1]))
        XCTAssertTrue(nfa.matches([1, 1]))
        XCTAssertTrue(nfa.matches([1, 2, 1]))
        XCTAssertTrue(nfa.matches([1, 2, 3, 4, 3, 2, 1]))

        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([2]))
        XCTAssertFalse(nfa.matches([2, 2]))
        XCTAssertFalse(nfa.matches([2, 1]))
        XCTAssertFalse(nfa.matches([2, 1, 3, 4, 1, 2]))
    }
    
    func test_1ThenAnythingThen1() {
        let nfa: NFA<Int> = one + NFA<Int>.all + one

        XCTAssertTrue(nfa.matches([1,1]))
        XCTAssertTrue(nfa.matches([1, 2, 1]))
        XCTAssertTrue(nfa.matches([1, 2, 3, 4, 3, 2, 1]))

        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([1]))
        XCTAssertFalse(nfa.matches([1, 2]))
        XCTAssertFalse(nfa.matches([2, 1]))
    }
    
    func test_failure() {
        let nfa: NFA<Int> = one + NFA<Int>.all + one
        XCTAssertFalse(nfa.matches([1]))
    }
    
    func test_not1then2then3() {
        let nfa: NFA<Int> = !(one + two + three)

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
        let nfa =  one.optional
        
        XCTAssertTrue(nfa.matches([]))
        XCTAssertTrue(nfa.matches([1]))
        
        XCTAssertFalse(nfa.matches([2]))
        XCTAssertFalse(nfa.matches([1,1]))
    }
    
    func test_not1optional() {
        let nfa: NFA<Int> =  !(one.optional)
        
        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([1]))
        
        XCTAssertTrue(nfa.matches([2]))
        XCTAssertTrue(nfa.matches([1,1]))
    }
    
    func test_1plus() {
        let nfa = one.oneOrMore
        
        XCTAssertTrue(nfa.matches([1]))
        XCTAssertTrue(nfa.matches([1, 1]))
        XCTAssertTrue(nfa.matches([1, 1, 1]))
        XCTAssertTrue(nfa.matches([1, 1, 1, 1]))

        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([1, 2]))
        XCTAssertFalse(nfa.matches([2, 1]))
    }
    
    func test_not1Plus() {
        let nfa = !(one.oneOrMore)
        
        XCTAssertFalse(nfa.matches([1]))
        XCTAssertFalse(nfa.matches([1, 1]))
        XCTAssertFalse(nfa.matches([1, 1, 1]))
        XCTAssertFalse(nfa.matches([1, 1, 1, 1]))

        XCTAssertTrue(nfa.matches([]))
        XCTAssertTrue(nfa.matches([1, 2]))
        XCTAssertTrue(nfa.matches([2, 1]))
    }

    func test_1star() {
        let nfa = one.zeroOrMore
        
        XCTAssertTrue(nfa.matches([]))
        XCTAssertTrue(nfa.matches([1]))
        XCTAssertTrue(nfa.matches([1, 1]))
        XCTAssertTrue(nfa.matches([1, 1, 1]))
        XCTAssertTrue(nfa.matches([1, 1, 1, 1]))

        XCTAssertFalse(nfa.matches([1, 2]))
        XCTAssertFalse(nfa.matches([2, 1]))
    }
    
    func test_not1star() {
        let nfa: NFA<Int> = !(one.zeroOrMore)
        
        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([1]))
        XCTAssertFalse(nfa.matches([1, 1]))
        XCTAssertFalse(nfa.matches([1, 1, 1]))
        XCTAssertFalse(nfa.matches([1, 1, 1, 1]))

        XCTAssertTrue(nfa.matches([1, 2]))
        XCTAssertTrue(nfa.matches([2, 1]))
    }
    
    func test_dot() {
        let nfa: NFA<Int> = .any

        XCTAssertTrue(nfa.matches([0]))
        XCTAssertTrue(nfa.matches([1]))
        XCTAssertTrue(nfa.matches([2]))
        
        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([1, 1]))
    }

    func test_notDot() {
        let nfa: NFA<Int> = !.any

        XCTAssertFalse(nfa.matches([0]))
        XCTAssertFalse(nfa.matches([1]))
        XCTAssertFalse(nfa.matches([2]))
        
        XCTAssertTrue(nfa.matches([]))
        XCTAssertTrue(nfa.matches([1, 1]))
    }

    func test_1AtFourFromEnd() {
        let nfa: NFA<Int> = NFA.all + one + .any + .any + .any
        
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

    func test_1None1() {
        let nfa: NFA<Int> = one + .none + one
        
        XCTAssertTrue(nfa.matches([]))
        XCTAssertTrue(nfa.matches([1]))
        XCTAssertTrue(nfa.matches([1, 2]))
        XCTAssertTrue(nfa.matches([2, 1]))
        XCTAssertTrue(nfa.matches([2, 2, 2, 2]))
        XCTAssertTrue(nfa.matches([2, 1, 1, 2]))

        XCTAssertFalse(nfa.matches([1, 1]))
        XCTAssertFalse(nfa.matches([1, 1, 1]))
    }
}

// MARK: -

private extension NFATests {

    var zero: NFA<Int> { .symbol { $0 == 0 } }
    var one: NFA<Int> { .symbol { $0 == 1 } }
    var two: NFA<Int> { .symbol { $0 == 2 } }
    var three: NFA<Int> { .symbol { $0 == 3 } }
}

