//
//  Created by Benjohn on 30/04/2020.
//


public struct NFA<Symbol> {
    let initialStates: Set<Node>
    let acceptanceState: Node
    let predicateEdges: [Node: [Node: [Predicate]]]
    let epsilonEdges: [EpsilonEdge]
    typealias Predicate = (Symbol) -> Bool
}

public extension NFA {
    
    func matches<S: Sequence>(_ symbols: S) -> Bool where S.Element == Symbol {
        let initialState = propagateEpsilonEdges(fromActiveStates: initialStates)
        let finalState = symbols.reduce(initialState, self.step(state:with:))
        return stateRepresentsAcceptance(finalState)
    }
}

// MARK:-

public extension NFA {
    
    static var none: NFA {
        .init(
            initialStates: .init(),
            acceptanceState: .init(),
            predicateEdges: .init(),
            epsilonEdges: .init()
        )
    }
    
    static var all: NFA {
        !none
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
    
    static var symbol: NFA {
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
    
    var star: NFA {
        plus | .empty
    }
    
    var plus: NFA {
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
    
    func then(_ next: NFA) -> NFA {
        let joinEpsilonEdges = next.initialStates.map { initialState in
            return EpsilonEdge(source: acceptanceState, target: initialState, isActive: true)
        }

        return NFA(
            initialStates: initialStates,
            acceptanceState: next.acceptanceState,
            predicateEdges: predicateEdges.merging(next.predicateEdges, uniquingKeysWith: { _, _ in fatalError("Logic error") }),
            epsilonEdges: epsilonEdges + next.epsilonEdges + joinEpsilonEdges
        )
    }
    
    static func sequence(_ s: [NFA]) -> NFA {
        s.reduce(.empty) { $0.then($1) }
    }
}

// MARK: -

private extension NFA {

    func step(state activeStates: MachineState, with symbol: Symbol) -> MachineState {
        let edges = activeStates.reduce([Node: [Predicate]]()) { (partial, node) in
            guard let edges = predicateEdges[node] else { return partial }
            return partial.merging(edges, uniquingKeysWith: +)
        }
        
        let nextStatesBeforeEpsilonEdges = Set(edges.compactMap { nodeAndPredicates in
            nodeAndPredicates.value.first(where: { $0(symbol) }).map { _ in nodeAndPredicates.key }
        })
        
        return propagateEpsilonEdges(fromActiveStates: nextStatesBeforeEpsilonEdges)
    }
    
    private func propagateEpsilonEdges(fromActiveStates activeStates: MachineState) -> MachineState {
        var activeStates = activeStates
        
        for epsilonEdge in epsilonEdges {
            if activeStates.contains(epsilonEdge.source) == epsilonEdge.isActive {
                activeStates.insert(epsilonEdge.target)
            }
        }
        
        return activeStates
    }

    func stateRepresentsAcceptance(_ activeStates: MachineState) -> Bool {
        activeStates.contains(acceptanceState)
    }
}

// MARK:-

struct EpsilonEdge: Hashable {
    let source: Node
    let target: Node
    let isActive: Bool
}

class Node: Hashable {
    static func == (lhs: Node, rhs: Node) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        ObjectIdentifier(self).hash(into: &hasher)
    }
}

typealias MachineState = Set<Node>
