//
//  Created by Benjohn on 10/05/2020.
//

import Regular
import XCTest

final class ExpressionTests: XCTestCase {
    
    func test_matchA1() {
        
        let expression: Expression<Int> = .one(1)
        let matcher = Regular.matcher(for: expression)
        
        XCTAssertTrue(matcher.matches([1]))

        XCTAssertFalse(matcher.matches([]))
        XCTAssertFalse(matcher.matches([2]))
        XCTAssertFalse(matcher.matches([1, 1]))
    }

    func test_matchA1ThenA2() {
        
        let expression: Expression<Int> = .one(1) + .one(2)
        let matcher = Regular.matcher(for: expression)
        
        XCTAssertTrue(matcher.matches([1, 2]))

        XCTAssertFalse(matcher.matches([]))
        XCTAssertFalse(matcher.matches([1]))
        XCTAssertFalse(matcher.matches([2]))
        XCTAssertFalse(matcher.matches([1, 1]))
        XCTAssertFalse(matcher.matches([2, 2]))
        XCTAssertFalse(matcher.matches([2, 1]))
    }
    
    func test_matchA1ThenAnythingThenA1() {

        let expression: Expression<Int> = .one(1) + .all + .one(1)
        let matcher = Regular.matcher(for: expression)
        
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
        
        let expression: Expression<Int> = .all + .one(1) + .all
        let matcher = Regular.matcher(for: expression)
        
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
