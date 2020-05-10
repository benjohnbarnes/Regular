
import XCTest
@testable import Regular

final class ExpressionTests: XCTestCase {
    func test_checkExpressionsCanBeCreated() {
        
        let any: Expression<Int> = .any
        let expression = any + any + any + any + any + any + any + any + any
        
    }
}
