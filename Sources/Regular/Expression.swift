//
//  Created by Benjohn on 30/04/2020.
//

import Foundation

indirect enum Expression<Symbol> {

    case any
    case predicate(Predicate)

    case optional(Expression)
    case oneOrMore(Expression)
    case zeroOrMore(Expression)
    case not(Expression)
    
    case sequence(Expression, Expression)
    case or(Expression, Expression)
    case and(Expression, Expression)

    typealias Predicate = (Symbol) -> Bool
}

// MARK:-

extension Expression {
    
    static func |(_ a: Expression, _ b: Expression) -> Expression {
        .or(a, b)
    }
    
    static func &(_ a: Expression, _ b: Expression) -> Expression {
        .and(a, b)
    }
    
    func then(_ next: Expression) -> Expression {
        .sequence(self, next)
    }
    
    var maybe: Expression {
        .optional(self)
    }
    
    var star: Expression {
        .zeroOrMore(self)
    }
    
    var plus: Expression {
        .oneOrMore(self)
    }
    
    var not: Expression {
        .not(self)
    }
}

// MARK:-

extension Expression where Symbol: Equatable {
     
    init(_ symbol: Symbol) {
        self = .predicate({ $0 == symbol })
    }
}

// MARK:-

extension Expression where Symbol: Hashable {
    
    init(_ set: Set<Symbol>) {
        self = .predicate({ set.contains($0) })
    }
}
