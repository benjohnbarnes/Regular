//
//  Created by Benjohn on 10/05/2020.
//

extension NFA {
    
    static var empty: NFA {
        let node = Node()

        return NFA(
            initialStates: .init([node]),
            acceptanceState: node,
            predicateEdges: .init(),
            epsilonEdges: .init()
        )
    }
    
    static var all: NFA {
        return empty | !empty
    }
    
    static var zero: NFA {
        !all
    }
    
    static var some: NFA {
        !empty
    }

    static var dot: NFA {
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
        let inversionEdges = EpsilonEdges([(nfa.acceptanceState, newAcceptance)]).inverted

        return NFA(
            initialStates: nfa.initialStates,
            acceptanceState: newAcceptance,
            predicateEdges: nfa.predicateEdges,
            epsilonEdges: nfa.epsilonEdges.merging(inversionEdges)
        )
    }

    var oneOrMore: NFA {
        let loopEpsilonEdges = EpsilonEdges(initialStates.map { initialState in (acceptanceState, initialState) })
            
        return NFA(
            initialStates: initialStates,
            acceptanceState: acceptanceState,
            predicateEdges: predicateEdges,
            epsilonEdges: epsilonEdges.merging(loopEpsilonEdges)
        )
    }
    
    var zeroOrMore: NFA {
        oneOrMore | .empty
    }
    
    var optional: NFA {
        self | .empty
    }
    
    static func |(_ l: NFA, _ r: NFA) -> NFA {
        let acceptance = Node()
        let combineEpsilon = EpsilonEdges([(l.acceptanceState, acceptance), (r.acceptanceState, acceptance)])
        
        return NFA(
            initialStates: l.initialStates.union(r.initialStates),
            acceptanceState: acceptance,
            predicateEdges: l.predicateEdges.merging(r.predicateEdges, uniquingKeysWith: { _, _ in fatalError("Logic error") }),
            epsilonEdges: r.epsilonEdges.merging(l.epsilonEdges).merging(combineEpsilon)
        )
    }

    static func &(_ l: NFA, _ r: NFA) -> NFA {
        !(!l | !r)
    }

    static func +(_ l: NFA, _ r: NFA) -> NFA {
        let joinEpsilonEdges = EpsilonEdges(r.initialStates.map { rInitialState in (l.acceptanceState, rInitialState) })

        return NFA(
            initialStates: l.initialStates,
            acceptanceState: r.acceptanceState,
            predicateEdges: l.predicateEdges.merging(r.predicateEdges, uniquingKeysWith: { _, _ in fatalError("Logic error") }),
            epsilonEdges: l.epsilonEdges.merging(r.epsilonEdges).merging(joinEpsilonEdges)
        )
    }
}
