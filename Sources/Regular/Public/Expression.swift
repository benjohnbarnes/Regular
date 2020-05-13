//
//  Created by Benjohn on 30/04/2020.
//

public indirect enum Expression<Symbol> {

    // Match any one symbol.
    //
    // Equivalent to the RegEx /./
    //
    case any1
    
    // Require a symbol that matches a predicate, or reject a symbol matching a predicate.
    //
    // In a RegEx you can achieve effects like this with character classes and sets of symbols. RegEx only support
    // character symbols though, so don't allow general predicates.
    //
    // Extensions elsewhere for  `Equatable`, `Hashable` and `Comparable` make matching to these concise.
    //
    case require(Predicate)
    case reject(Predicate)

    // Match every possible sequence. This includes the empty sequence.
    //
    // Equivalent to RegEx /.*/.
    //
    case anything

    // Match all non empty sequences.
    //
    // Equivalent to the RegEx /.+/
    //
    case some

    // Modifiers on expressions.
    //
    // Note that all of these have `var` forms. Instead of
    //    `.optional(someExpression)`
    //
    // …you can write:
    //    `someExpression.optional`
    //
    case optional(Expression)   // Like appending `?` to a RegEx.
    case oneOrMore(Expression)  // Like appending `+` to a RegEx.
    case zeroOrMore(Expression) // Like appending `*` to a RegEx.
    
    // Negate an expression. This forms an expression that matching everything that the underlying expression will
    // not match, and nothing that it will match. This is also known as "complement".
    //
    // There is no RegEx equivalent to this.
    //
    // This has a `var` form so you can write `someExpression.not` rather than `.not(someExpression).
    //
    // Note that negation may not behave as you expect. Negation of an expression is a new expression matching
    // _everything_ that the expression does not match. `!.require { $0 == 1 }` matches _everything except_ the
    // symbol 1. This _includes the empty sequence_, and any sequence of any length, provided it is not a sequence of
    // a single 1. If you just want to matching a single thing that is not a 1, use `.reject { $0 == 1}`
    //
    case not(Expression)
    
    // Sequentially combine expressions. Also called "concatenation"
    //
    // In regular expressions this is implicit. So, give /e1/ and /e2/ we would combine them by writing /e1e2/.
    //
    // Operator `+` is overloaded to create a `.then` so you can write:
    //    `expression1 + expression2`
    //
    case then(Expression, Expression)

    // Logically combine expressions.
    //
    // In regular expressions, given /e1/ and /e2/, we can match to _either_ of these with /e1|e2/, so the `or`
    // Boolean combination is supported in RegEx. RegEx don't support other Boolean combinations.
    //
    // The all have operators defined, so you can write:
    //    `expression1 | expression2`
    //    `expression1 & expression2`
    //    `expression1 ^ expression2`
    //
    case or(Expression, Expression)
    case and(Expression, Expression)
    case xor(Expression, Expression)
    
    // Match only the empty sequence. This is the identity element for concatenation.
    //
    // Equivalent to RegEx //.
    //
    case empty
    
    // This is the empty language. It matches nothing whatsoever. It is the identity element for `or`
    // and the annihilator for `and`.
    //
    // N.B. it does not match the _empty_ string. For that, use `empty`
    //
    case zero

    public typealias Predicate = (Symbol) -> Bool
}

// MARK:- Sequencing

public extension Expression {

    static func +(_ first: Expression, _ second: Expression) -> Expression {
        .then(first, second)
    }
}

// MARK:- Logically combine
    
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
}

// MARK:- Expression modifiers

public extension Expression {

    static prefix func !(_ e: Expression) -> Expression {
        .not(e)
    }

    var optional: Expression {
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
