//
//  Created by Benjohn on 10/05/2020.
//

public protocol Matcher {
    func matches<S: Sequence>(_ s: S) -> Bool where S.Element == Symbol
    associatedtype Symbol
}

extension Matcher {
    
    public var asAny: AnyMatcher<Symbol> {
        .init(matchesImplementation: self.matches)
    }
}

// MARK: -

public struct AnyMatcher<Symbol>: Matcher {
    
    let matchesImplementation: (AnySequence<Symbol>) -> Bool
    
    public func matches<S: Sequence>(_ s: S) -> Bool where S.Element == Symbol {
        matchesImplementation(AnySequence(s))
    }
}

