//
//  Created by Benjohn on 30/04/2020.
//

public indirect enum Expression<Symbol> {
    case everything
    case nothing
    case empty

    case any
    case one(Predicate)
    
    case optional(Expression)
    case oneOrMore(Expression)
    case zeroOrMore(Expression)
    case not(Expression)
    
    case or(Expression, Expression)
    case and(Expression, Expression)
    case xor(Expression, Expression)
    case then(Expression, Expression)

    public typealias Predicate = (Symbol) -> Bool
}

// MARK:-

extension Expression {
    
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

extension Expression where Symbol: Equatable {

    static func one(_ symbol: Symbol) -> Expression {
        .one { $0 == symbol }
    }

    static func sequence(_ symbols: [Symbol]) -> Expression {
        symbols.reduce(.empty) { $0 + .one($1) }
    }
}

// MARK:-

extension Expression where Symbol: Hashable {
    static func one(of set: Set<Symbol>) -> Expression {
        .one { set.contains($0) }
    }
}

// MARK:-

extension Expression where Symbol: Comparable {
    static func one(in range: Range<Symbol>) -> Expression {
        .one { range.contains($0) }
    }
}
