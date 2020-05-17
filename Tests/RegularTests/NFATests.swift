//
//  Created by Benjohn on 10/05/2020.
//

@testable import Regular
import XCTest

final class NFATests: XCTestCase {
    
    func test_all() {
        let nfa: NFA<Int> = .all

        XCTAssertTrue(nfa.matches([]))
        XCTAssertTrue(nfa.matches([1]))
        XCTAssertTrue(nfa.matches([1, 2]))
        XCTAssertTrue(nfa.matches([1, 2, 3, 4, 5, 6, 7]))
    }

    func test_zero() {
        let nfa: NFA<Int> = .zero

        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([1]))
        XCTAssertFalse(nfa.matches([1, 2]))
        XCTAssertFalse(nfa.matches([1, 2, 3, 4, 5, 6, 7]))
    }
    
    func test_empty() {
        let nfa = empty
        
        XCTAssertTrue(nfa.matches([]))

        XCTAssertFalse(nfa.matches([1]))
        XCTAssertFalse(nfa.matches([1, 2]))
    }
    
    func test_some() {
        let nfa: NFA<Int> = some
        
        XCTAssertFalse(nfa.matches([]))

        XCTAssertTrue(nfa.matches([1]))
        XCTAssertTrue(nfa.matches([1, 2]))
    }
    
    func test_matchOne_matchesOne() {
        let nfa = one

        XCTAssertTrue(nfa.matches([1]))

        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([2]))
        XCTAssertFalse(nfa.matches([1, 1]))
        XCTAssertFalse(nfa.matches([1, 2]))
        XCTAssertFalse(nfa.matches([2, 2]))
    }

    func test_1Or2Or2Or3() {
        let nfa = NFA<Int>.symbol({ 1...2 ~= $0 }) | NFA<Int>.symbol({ 2...3 ~= $0 })

        XCTAssertTrue(nfa.matches([1]))
        XCTAssertTrue(nfa.matches([2]))
        XCTAssertTrue(nfa.matches([3]))

        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([1,2]))
        XCTAssertFalse(nfa.matches([2,1]))
        XCTAssertFalse(nfa.matches([4]))
    }

    func test_orAnihillation() {
        let nfa = NFA<Int>.zero | NFA<Int>.all

        XCTAssertTrue(nfa.matches([]))
        XCTAssertTrue(nfa.matches([1]))
        XCTAssertTrue(nfa.matches([1, 2]))
    }
    
    func test_allThenAll() {
        let nfa: NFA<Int> = all + all
        
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
        let nfa: NFA<Int> = one + all

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
        let nfa: NFA<Int> = one + all + one

        XCTAssertTrue(nfa.matches([1,1]))
        XCTAssertTrue(nfa.matches([1, 2, 1]))
        XCTAssertTrue(nfa.matches([1, 2, 3, 4, 3, 2, 1]))

        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([1]))
        XCTAssertFalse(nfa.matches([1, 2]))
        XCTAssertFalse(nfa.matches([2, 1]))
    }
    
    func test_failure() {
        let nfa: NFA<Int> = one + all + one
        XCTAssertFalse(nfa.matches([1]))
    }
    
    func test_1optional() {
        let nfa =  one.optional
        
        XCTAssertTrue(nfa.matches([]))
        XCTAssertTrue(nfa.matches([1]))
        
        XCTAssertFalse(nfa.matches([2]))
        XCTAssertFalse(nfa.matches([1,1]))
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
    
    func test_dot() {
        let nfa = dot

        XCTAssertTrue(nfa.matches([0]))
        XCTAssertTrue(nfa.matches([1]))
        XCTAssertTrue(nfa.matches([2]))
        
        XCTAssertFalse(nfa.matches([]))
        XCTAssertFalse(nfa.matches([1, 1]))
    }

    func test_1AtFourFromEnd() {
        let nfa = all + one + dot + dot + dot
        
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

    func test_NoneStarMatchesEmpty() {
        let nfa = zero.zeroOrMore
        XCTAssertTrue(nfa.matches([]))
    }
    
    func test_epsilonCycle() {
        let matcher = (empty + dot).oneOrMore
        
        // The failures here are because the oneOrMore's loop is applied _after_ the edge between empty and
        // dot, so dot is not able to relaunch itself. Changing to transitive closure should fix this, but
        // that requires an answer to how negative edges behave in cycles.
        XCTAssertTrue(matcher.matches([1]))
        XCTAssertTrue(matcher.matches([1, 1]))
        XCTAssertTrue(matcher.matches([1, 1, 1]))
        XCTAssertTrue(matcher.matches([1, 1, 1, 1, 1, 1, 1, 1]))
    }
}

// MARK: -

private extension NFATests {

    var empty: NFA<Int> { .empty }
    var some: NFA<Int> { .some }

    var zero: NFA<Int> { .zero }
    var all: NFA<Int> { .all }

    var dot: NFA<Int> { .dot }
    var one: NFA<Int> { .symbol { $0 == 1 } }
    var two: NFA<Int> { .symbol { $0 == 2 } }
    var three: NFA<Int> { .symbol { $0 == 3 } }
}

