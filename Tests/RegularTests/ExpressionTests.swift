//
//  Created by Benjohn on 10/05/2020.
//

import Regular
import XCTest

final class ExpressionTests: XCTestCase {
    
    func test_matchA1() {
        
        let expression: Expression<Int> = .require(1)
        let matcher = createMatcher(for: expression)
        
        XCTAssertTrue(matcher.matches([1]))

        XCTAssertFalse(matcher.matches([]))
        XCTAssertFalse(matcher.matches([2]))
        XCTAssertFalse(matcher.matches([1, 1]))
    }

    func test_matchA1ThenA2() {
        
        let expression: Expression<Int> = .require(1) + .require(2)
        let matcher = createMatcher(for: expression)
        
        XCTAssertTrue(matcher.matches([1, 2]))

        XCTAssertFalse(matcher.matches([]))
        XCTAssertFalse(matcher.matches([1]))
        XCTAssertFalse(matcher.matches([2]))
        XCTAssertFalse(matcher.matches([1, 1]))
        XCTAssertFalse(matcher.matches([2, 2]))
        XCTAssertFalse(matcher.matches([2, 1]))
    }
    
    func test_matchA1ThenAnythingThenAnythingButA1() {

        let expression: Expression<Int> = .require(1) + .anything + .reject(1)
        let matcher = createMatcher(for: expression)
        
        XCTAssertTrue(matcher.matches([1, 2]))
        XCTAssertTrue(matcher.matches([1, 1, 2]))
        XCTAssertTrue(matcher.matches([1, 2, 2, 2, 2, 1, 2, 1, 2]))

        XCTAssertFalse(matcher.matches([]))
        XCTAssertFalse(matcher.matches([1]))
        XCTAssertFalse(matcher.matches([2]))
        XCTAssertFalse(matcher.matches([1, 1]))
        XCTAssertFalse(matcher.matches([2, 1]))
        XCTAssertFalse(matcher.matches([2, 2, 1]))
    }
    
    func test_matchAnythingBut1ThenAnythingThen1() {

        let expression: Expression<Int> = .reject(1) + .anything + .require(1)
        let matcher = createMatcher(for: expression)
        
        XCTAssertTrue(matcher.matches([2, 1]))
        XCTAssertTrue(matcher.matches([3, 2, 1]))
        XCTAssertTrue(matcher.matches([3, 1, 1, 1, 1]))

        XCTAssertFalse(matcher.matches([]))
        XCTAssertFalse(matcher.matches([1]))
        XCTAssertFalse(matcher.matches([2]))
        XCTAssertFalse(matcher.matches([1, 1]))
        XCTAssertFalse(matcher.matches([1, 2]))
        XCTAssertFalse(matcher.matches([2, 2]))
    }
    
    func test_matchA1ThenAnythingThenA1() {

        let expression: Expression<Int> = .require(1) + .anything + .require(1)
        let matcher = createMatcher(for: expression)
        
        XCTAssertTrue(matcher.matches([1, 1]))
        XCTAssertTrue(matcher.matches([1, 2, 1]))
        XCTAssertTrue(matcher.matches([1, 1, 1]))
        XCTAssertTrue(matcher.matches([1, 1, 1, 1]))
        XCTAssertTrue(matcher.matches([1, 2, 2, 1]))

        XCTAssertFalse(matcher.matches([]))
        XCTAssertFalse(matcher.matches([1]))
        XCTAssertFalse(matcher.matches([2]))
        XCTAssertFalse(matcher.matches([2, 1, 2, 1, 2]))
        XCTAssertFalse(matcher.matches([2, 2]))
        XCTAssertFalse(matcher.matches([2, 1]))
        XCTAssertFalse(matcher.matches([1, 2]))
    }

    func test_matchAnythingContaining123() {
        let expression: Expression<Int> = .anything + .require([1, 2, 3]) + .anything
        let matcher = createMatcher(for: expression)
        
        XCTAssertTrue(matcher.matches([1, 2, 3]))
        XCTAssertTrue(matcher.matches([0, 0, 1, 2, 3]))
        XCTAssertTrue(matcher.matches([1, 2, 3, 0, 0]))
        XCTAssertTrue(matcher.matches([0, 0, 1, 2, 3, 0, 0]))
        XCTAssertTrue(matcher.matches([1, 2, 3, 1, 2, 3, 1, 2, 3]))

        XCTAssertFalse(matcher.matches([]))
        XCTAssertFalse(matcher.matches([1]))
        XCTAssertFalse(matcher.matches([1, 2]))
        XCTAssertFalse(matcher.matches([1, 3]))
        XCTAssertFalse(matcher.matches([2, 3]))
        XCTAssertFalse(matcher.matches([3, 2, 1]))
    }
    
    func test_aSequenceHavingA1() {
        
        let expression: Expression<Int> = .anything + .require(1) + .anything
        let matcher = createMatcher(for: expression)
        
        XCTAssertTrue(matcher.matches([1]))
        XCTAssertTrue(matcher.matches([3, 2, 1, 2, 3]))
        XCTAssertTrue(matcher.matches([1, 2, 3]))
        XCTAssertTrue(matcher.matches([3, 2, 1]))
        XCTAssertTrue(matcher.matches([1, 1, 1, 1]))
        XCTAssertTrue(matcher.matches([1, 1, 2, 1, 1]))

        XCTAssertFalse(matcher.matches([]))
        XCTAssertFalse(matcher.matches([2]))
        XCTAssertFalse(matcher.matches([2, 2]))
    }
}
