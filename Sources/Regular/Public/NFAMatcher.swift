//
//  Created by Benjohn on 10/05/2020.
//

public func createMatcher<Symbol>(for expression: Expression<Symbol>) -> AnyMatcher<Symbol> {
    nfaMatcher(for: expression).asAny
}

// MARK:-

private func nfaMatcher<Symbol>(for expression: Expression<Symbol>) -> NFA<Symbol> {
    switch expression {
    case .anything: return .all
    case .zero: return .zero
    case .empty: return .empty
    case .some: return .some

    case .any1: return .dot
        
    case let .require(predicate): return .symbol(predicate)
    case let .reject(predicate): return .symbol { !predicate($0) }

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
