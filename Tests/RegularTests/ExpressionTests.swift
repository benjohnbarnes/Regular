//
//  Created by Benjohn on 10/05/2020.
//

import Regular
import XCTest

final class ExpressionTests: XCTestCase {
    
    func test_whatever() {

        let expression: Expression<Int> = .whatever
        let matcher = createMatcher(for: expression)
        
        XCTAssertTrue(matcher.matches([]))
        XCTAssertTrue(matcher.matches([1]))
        XCTAssertTrue(matcher.matches([1, 2]))
        XCTAssertTrue(matcher.matches([1, 2, 3, 4, 1, 0, 1]))
    }

    func test_nothing() {

        let expression: Expression<Int> = .nothing
        let matcher = createMatcher(for: expression)
        
        XCTAssertFalse(matcher.matches([]))
        XCTAssertFalse(matcher.matches([1]))
        XCTAssertFalse(matcher.matches([1, 2]))
        XCTAssertFalse(matcher.matches([1, 2, 3, 4, 1, 0, 1]))
    }

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

        let expression: Expression<Int> = .require(1) + .whatever + .reject(1)
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

        let expression: Expression<Int> = .reject(1) + .whatever + .require(1)
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

        let expression: Expression<Int> = .require(1) + .whatever + .require(1)
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

    func test_aSequenceHavingA1() {
        
        let expression: Expression<Int> = .whatever + .require(1) + .whatever
        let matcher = createMatcher(for: expression)
        
        XCTAssertTrue(matcher.matches([1]))
        XCTAssertTrue(matcher.matches([3, 2, 1, 2, 3]))
        XCTAssertTrue(matcher.matches([1, 2, 3]))
        XCTAssertTrue(matcher.matches([3, 2, 1]))
        XCTAssertTrue(matcher.matches([3, 2, 1, 1, 2, 3]))
        XCTAssertTrue(matcher.matches([1, 3, 2, 1, 1, 2, 3, 1]))
        XCTAssertTrue(matcher.matches([1, 1, 1, 1]))
        XCTAssertTrue(matcher.matches([1, 1, 2, 1, 1]))

        XCTAssertFalse(matcher.matches([]))
        XCTAssertFalse(matcher.matches([2]))
        XCTAssertFalse(matcher.matches([2, 2]))
    }

    func test_matchAnythingContaining123() {
        let expression: Expression<Int> = .whatever + .require([1, 2, 3]) + .whatever
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
}
