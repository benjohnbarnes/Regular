//
//  Created by Benjohn on 15/05/2020.
//

@testable import Regular
import XCTest

final class EpsilonEdgesTests: XCTestCase {
    
    func test_closure() {
        let sut = EpsilonEdges([(n1, n2), (n2, n3), (n3, n4)])
        
        XCTAssertEqual(sut.activeEdges[n1], Set([n2, n3, n4]))
        XCTAssertEqual(sut.activeEdges[n2], Set([n3, n4]))
        XCTAssertEqual(sut.activeEdges[n3], Set([n4]))

        let states = Set([n1])
        let propagted = sut.propagate(state: states)
        XCTAssertEqual(propagted, Set([n1, n2, n3, n4]))
    }
    
    
    let (n1, n2, n3, n4, n5) = (Node(), Node(), Node(), Node(), Node())
}
