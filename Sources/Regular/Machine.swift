//
//  Created by Benjohn on 30/04/2020.
//


struct NFA<Symbol> {
    let initialStates: Set<Node>
    let acceptanceStates: Set<NodeState>
    let predicatedEdges: [Edge: [Predicate]]
    let epsilonEdges: Set<Edge>

    typealias Predicate = (Symbol) -> Bool

    func matches<S: Sequence>(_ symbols: S) -> Bool where S.Element == Symbol {
        let initialState = propagateEpsilonEdges(fromActiveStates: initialStates)
        let finalState = symbols.reduce(initialState, self.step(state:with:))
        return stateRepresentsAcceptance(finalState)
    }
    
    func step(state activeStates: MachineState, with symbol: Symbol) -> MachineState {
        let subsequentStates = nextStateFunction(forActiveStates: activeStates)
        return subsequentStates(symbol)
    }
    
    func stateRepresentsAcceptance(_ activeStates: MachineState) -> Bool {
        acceptanceStates.first(where: { acceptanceState in
            activeStates.contains(acceptanceState.node) == acceptanceState.isActive
        }) != nil
    }
    
    private func nextStateFunction(forActiveStates activeStates: MachineState) -> (Symbol) -> Set<Node> {
        let enabledEdges = predicatedEdges.compactMap { edge -> (target: Node, predicates: [Predicate])? in
            guard activeStates.contains(edge.key.source.node) == edge.key.source.isActive else { return nil }
            return (target: edge.key.target, predicates: edge.value)
        }
        
        return { symbol in
            self.propagateEpsilonEdges(fromActiveStates: Set(enabledEdges.compactMap { edge in
                edge.predicates.first(where: { $0(symbol) }) == nil ? nil : edge.target
            }))
        }
    }
    
    private func propagateEpsilonEdges(fromActiveStates activeStates: MachineState) -> MachineState {
        let expandedActiveStates = activeStates.union(epsilonEdges.compactMap { edge -> Node? in
            guard !edge.source.isActive, !activeStates.contains(edge.source.node) else { return nil }
            return edge.target
        })
        
        return sequence(first: expandedActiveStates) { activeStates -> Set<Node>? in
            let nextStates = Set(self.epsilonEdges.compactMap { edge -> Node? in
                guard edge.source.isActive, activeStates.contains(edge.source.node) else { return nil }
                return edge.target
            })
            
            guard !nextStates.isEmpty else { return nil }
            return nextStates
        }.reduce(expandedActiveStates) { $0.union($1) }
    }
}

// MARK:-

extension NFA {
    
    static var everything: NFA {
        let initial = Node()
        return NFA(
            initialStates: Set([initial]),
            acceptanceStates: Set([.active(initial)]),
            predicatedEdges: [Edge(from: initial, to: initial): [{ _ in true }]],
            epsilonEdges: .init()
        )
    }
    
    static var nothing: NFA {
        !everything
    }
    
    static func match(one predicate: @escaping (Symbol) -> Bool) -> NFA {
        let startState = Node()
        let acceptState = Node()
        
        return NFA(
            initialStates: Set([startState]),
            acceptanceStates: Set([.active(acceptState)]),
            predicatedEdges: [Edge(from: startState, to: acceptState): [predicate]],
            epsilonEdges: .init()
        )
    }
    
    static func |(_ l: NFA, _ r: NFA) -> NFA {
        NFA(
            initialStates: l.initialStates.union(r.initialStates),
            acceptanceStates: l.acceptanceStates.union(r.acceptanceStates),
            predicatedEdges: l.predicatedEdges.merging(r.predicatedEdges, uniquingKeysWith: +),
            epsilonEdges: l.epsilonEdges.union(r.epsilonEdges)
        )
    }

    static func &(_ l: NFA, _ r: NFA) -> NFA {
        !(!l | !r)
    }


    static prefix func !(_ nfa: NFA) -> NFA {
        NFA(
            initialStates: nfa.initialStates,
            acceptanceStates: Set(nfa.acceptanceStates.map { $0.invert }),
            predicatedEdges: nfa.predicatedEdges,
            epsilonEdges: nfa.epsilonEdges
        )
    }

    var optional: NFA {
        NFA(
            initialStates: initialStates,
            acceptanceStates: acceptanceStates.union(initialStates.map { .active($0) }),
            predicatedEdges: predicatedEdges,
            epsilonEdges: epsilonEdges
        )
    }
    
    var star: NFA {
        plus.optional
    }
    
    var plus: NFA {
        let epsilonEdges = self.epsilonEdges.union(acceptanceStates.flatMap { acceptanceState in
            self.initialStates.map { initialState in
                return Edge(from: acceptanceState, to: initialState)
            }
        })

        return NFA(
            initialStates: initialStates,
            acceptanceStates: acceptanceStates,
            predicatedEdges: predicatedEdges,
            epsilonEdges: epsilonEdges
        )
    }
    
    func then(_ next: NFA) -> NFA {
        let epsilonEdges = self.epsilonEdges.union(acceptanceStates.flatMap { acceptanceState in
            next.initialStates.map { initialState in
                return Edge(from: acceptanceState, to: initialState)
            }
        })
        
        return NFA(
            initialStates: initialStates,
            acceptanceStates: next.acceptanceStates,
            predicatedEdges: predicatedEdges.merging(next.predicatedEdges, uniquingKeysWith: +),
            epsilonEdges: epsilonEdges
        )
    }
}

// MARK:-

struct Edge: Hashable {
    let source: NodeState
    let target: Node
    
    init(from activeSource: Node, to target: Node) {
        self.source = .active(activeSource)
        self.target = target
    }

    init(from source: NodeState, to target: Node) {
        self.source = source
        self.target = target
    }
    
    func changing(source newSource: NodeState) -> Edge {
        .init(from: NodeState(node: newSource.node, isActive: source.isActive == newSource.isActive ), to: target)
    }
}

struct NodeState: Hashable {
    let node: Node
    let isActive: Bool
    
    static func active(_ node: Node) -> NodeState {
        .init(node: node, isActive: true)
    }
    
    var invert: NodeState {
        .init(node: node, isActive: !isActive)
    }
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

extension Set {
    func includesAnyOf(_ other: Set) -> Bool {
        !intersection(other).isEmpty
    }
    
    func missesAnyOf(_ other: Set) -> Bool {
        intersection(other).count < other.count
    }
}
