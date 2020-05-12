//
//  Created by Benjohn on 10/05/2020.
//

extension NFA {
    
    static var all: NFA {
        return self.any.zeroOrMore
    }
    
    static var none: NFA {
        !all
    }
    
    static var empty: NFA {
        let node = Node()
        
        return NFA(
            initialStates: .init([node]),
            acceptanceState: node,
            predicateEdges: .init(),
            epsilonEdges: .init()
        )
    }
    
    static var some: NFA {
        !empty
    }

    static var any: NFA {
        symbol { _ in true }
    }
    
    static func symbol(_ predicate: @escaping (Symbol) -> Bool) -> NFA {
        let initialState = Node()
        let acceptState = Node()
        
        return NFA(
            initialStates: .init([initialState]),
            acceptanceState: acceptState,
            predicateEdges: [initialState: [acceptState: [predicate]]],
            epsilonEdges: .init()
        )
    }
    
    static prefix func !(_ nfa: NFA) -> NFA {
        let newAcceptance = Node()
        
        return NFA(
            initialStates: nfa.initialStates,
            acceptanceState: newAcceptance,
            predicateEdges: nfa.predicateEdges,
            epsilonEdges: nfa.epsilonEdges + [EpsilonEdge(source: nfa.acceptanceState, target: newAcceptance, isActive: false)]
        )
    }

    var optional: NFA {
        self | .empty
    }
    
    var zeroOrMore: NFA {
        oneOrMore | .empty
    }
    
    var oneOrMore: NFA {
        let loopEpsilonEdges = initialStates.map { initialState in
            return EpsilonEdge(source: acceptanceState, target: initialState, isActive: true)
        }
        
        return NFA(
            initialStates: initialStates,
            acceptanceState: acceptanceState,
            predicateEdges: predicateEdges,
            epsilonEdges: epsilonEdges + loopEpsilonEdges
        )
    }
    
    static func |(_ l: NFA, _ r: NFA) -> NFA {
        let acceptance = Node()
        let extraEpsilon = [l.acceptanceState, r.acceptanceState].map { EpsilonEdge(source: $0, target: acceptance, isActive: true) }
        
        return NFA(
            initialStates: l.initialStates.union(r.initialStates),
            acceptanceState: acceptance,
            predicateEdges: l.predicateEdges.merging(r.predicateEdges, uniquingKeysWith: { _, _ in fatalError("Logic error") }),
            epsilonEdges: r.epsilonEdges + l.epsilonEdges + extraEpsilon
        )
    }

    static func &(_ l: NFA, _ r: NFA) -> NFA {
        !((!l) | (!r))
    }

    static func +(_ l: NFA, _ r: NFA) -> NFA {
        let joinEpsilonEdges = r.initialStates.map { EpsilonEdge(source: l.acceptanceState, target: $0, isActive: true) }

        return NFA(
            initialStates: l.initialStates,
            acceptanceState: r.acceptanceState,
            predicateEdges: l.predicateEdges.merging(r.predicateEdges, uniquingKeysWith: { _, _ in fatalError("Logic error") }),
            epsilonEdges: l.epsilonEdges + joinEpsilonEdges + r.epsilonEdges
        )
    }
}
