//
//  Created by Benjohn on 30/04/2020.
//


public struct NFA<Symbol> {
    let initialStates: Set<Node>
    let acceptanceStates: Set<Node>
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
    
    static var nothing: NFA {
        .init(
            initialStates: .init(),
            // May need to put this back?
            acceptanceStates: .init([Node()]),
            predicateEdges: .init(),
            epsilonEdges: .init()
        )
    }
    
    static var everything: NFA {
        !nothing
    }
    
    static var empty: NFA {
        let node = Node()
        
        return NFA(
            initialStates: Set([node]),
            acceptanceStates: Set([node]),
            predicateEdges: .init(),
            epsilonEdges: .init()
        )
    }
    
    static var any: NFA {
        one { _ in true }
    }
    
    static func one(_ predicate: @escaping (Symbol) -> Bool) -> NFA {
        let initialState = Node()
        let acceptState = Node()
        
        return NFA(
            initialStates: Set([initialState]),
            acceptanceStates: Set([acceptState]),
            predicateEdges: [initialState: [acceptState: [predicate]]],
            epsilonEdges: .init()
        )
    }
    
    static func |(_ l: NFA, _ r: NFA) -> NFA {
        let acceptance = Node()
        let extraEpsilon = l.acceptanceStates.union(r.acceptanceStates).map { EpsilonEdge(source: $0, target: acceptance, isActive: true) }
        
        return NFA(
            initialStates: l.initialStates.union(r.initialStates),
            acceptanceStates: Set([acceptance]),
            // Using fatal error here as these seems like it would be a logic error?
            predicateEdges: l.predicateEdges.merging(r.predicateEdges, uniquingKeysWith: { _, _ in fatalError() }),
            epsilonEdges: r.epsilonEdges + l.epsilonEdges + extraEpsilon
        )
    }

    static func &(_ l: NFA, _ r: NFA) -> NFA {
        !((!l) | (!r))
    }


    static prefix func !(_ nfa: NFA) -> NFA {
        let newAcceptance = Node()
        let extraEpsilon = nfa.acceptanceStates.map { EpsilonEdge(source: $0, target: newAcceptance, isActive: false)}
        
        return NFA(
            initialStates: nfa.initialStates,
            acceptanceStates: Set([newAcceptance]),
            predicateEdges: nfa.predicateEdges,
            epsilonEdges: nfa.epsilonEdges + extraEpsilon
        )
    }

    var optional: NFA {
        self | .empty
    }
    
    var star: NFA {
        plus | .empty
    }
    
    var plus: NFA {
        let loopEpsilonEdges = acceptanceStates.flatMap { acceptanceState in
            self.initialStates.map { initialState in
                return EpsilonEdge(source: acceptanceState, target: initialState, isActive: true)
            }
        }

        return NFA(
            initialStates: initialStates,
            acceptanceStates: acceptanceStates,
            predicateEdges: predicateEdges,
            epsilonEdges: epsilonEdges + loopEpsilonEdges
        )
    }
    
    func then(_ next: NFA) -> NFA {
        let joinEpsilonEdges = acceptanceStates.flatMap { acceptanceState in
            next.initialStates.map { initialState in
                return EpsilonEdge(source: acceptanceState, target: initialState, isActive: true)

            }
        }

        return NFA(
            initialStates: initialStates,
            acceptanceStates: next.acceptanceStates,
            // A merge here would be a logic error, I think.
            predicateEdges: predicateEdges.merging(next.predicateEdges, uniquingKeysWith: { _, _ in fatalError() }),
            epsilonEdges: epsilonEdges + next.epsilonEdges + joinEpsilonEdges
        )
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
        acceptanceStates.first(where: { activeStates.contains($0) }) != nil
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
