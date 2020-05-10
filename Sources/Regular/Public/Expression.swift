//
//  Created by Benjohn on 30/04/2020.
//

public indirect enum Expression<Symbol> {

    // Match nothing at all, and the inverse – whatever: anything at all.
    //
    case nothing
    case whatever

    // Match the empty sequence, and any sequence that is not empty
    //
    case empty
    case some

    // Require a symbol that matches a predicate, or reject a symbol matching a predicate. Note that negation may not
    // behave as you expect. Negation of an expression is a new expression matchihg _everything_ that the expression
    // does not match. So `!.require { $0 == 1 }` matches _everything except_ the symbol 1. This includes
    // the empty sequence, and any sequence of any length, provided it is not a sequence of a single 1.
    //
    // For this reason, two forms are provided: `require` and `reject`. The latter is an expression matching a single
    // symbol that _does not_ match the predicate.
    //
    case require(Predicate)
    case reject(Predicate)

    // Match any one symbol.
    //
    case any1
    
    // Modify expressions.
    //
    case optional(Expression)
    case oneOrMore(Expression)
    case zeroOrMore(Expression)
    case not(Expression)
    
    // Combine expressions.
    //
    case or(Expression, Expression)
    case and(Expression, Expression)
    case xor(Expression, Expression)
    case then(Expression, Expression)

    public typealias Predicate = (Symbol) -> Bool
}

// MARK:-

public extension Expression {
    
    static func |(_ a: Expression, _ b: Expression) -> Expression {
        .or(a, b)
    }
    
    static func &(_ a: Expression, _ b: Expression) -> Expression {
        .and(a, b)
    }
    
    static func ^(_ a: Expression, _ b: Expression) -> Expression {
        .xor(a, b)
    }
    
    static func +(_ a: Expression, _ b: Expression) -> Expression {
        .then(a, b)
    }
    
    static prefix func !(_ e: Expression) -> Expression {
        .not(e)
    }

    var maybe: Expression {
        .optional(self)
    }
    
    var zeroOrMore: Expression {
        .zeroOrMore(self)
    }
    
    var oneOrMore: Expression {
        .oneOrMore(self)
    }
    
    var not: Expression {
        .not(self)
    }
}

// MARK:-

public extension Expression where Symbol: Equatable {

    static func require(_ symbol: Symbol) -> Expression {
        .require { $0 == symbol }
    }

    static func reject(_ symbol: Symbol) -> Expression {
        .reject { $0 == symbol }
    }

    static func require(_ symbols: [Symbol]) -> Expression {
        symbols.reduce(.empty) { $0 + .require($1) }
    }
}

// MARK:-

public extension Expression where Symbol: Hashable {
    
    static func require(anyOf set: Set<Symbol>) -> Expression {
        .require { set.contains($0) }
    }

    static func reject(allOf set: Set<Symbol>) -> Expression {
        .reject { set.contains($0) }
    }
}

// MARK:-

public extension Expression where Symbol: Comparable {
    
    static func require(in range: Range<Symbol>) -> Expression {
        .require { range.contains($0) }
    }

    static func reject(in range: Range<Symbol>) -> Expression {
        .reject { range.contains($0) }
    }
}
