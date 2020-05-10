//
//  Created by Benjohn on 10/05/2020.
//

public func matcher<Symbol>(for expression: Expression<Symbol>) -> AnyMatcher<Symbol> {
    nfaMatcher(for: expression).asAny
}

// MARK:-

private func nfaMatcher<Symbol>(for expression: Expression<Symbol>) -> NFA<Symbol> {
    switch expression {
    case .all: return .all
    case .none: return .none
    case .empty: return .empty
    case .some: return .some

    case .any: return .any
        
    case let .one(predicate): return .symbol(predicate)
        
    case let .optional(expression): return nfaMatcher(for: expression).optional
    case let .oneOrMore(expression): return nfaMatcher(for: expression).oneOrMore
    case let .zeroOrMore(expression): return nfaMatcher(for: expression).zeroOrMore
    case let .not(expression): return !nfaMatcher(for: expression)

    case let .or(e1, e2): return nfaMatcher(for: e1) | nfaMatcher(for: e2)
    case let .and(e1, e2): return nfaMatcher(for: e1) & nfaMatcher(for: e2)
    case let .xor(e1, e2): return (nfaMatcher(for: e1) & !nfaMatcher(for: e2)) | (!nfaMatcher(for: e1) & nfaMatcher(for: e2))

    case let .then(e1, e2): return nfaMatcher(for: e1) + nfaMatcher(for: e2)
    }
}
