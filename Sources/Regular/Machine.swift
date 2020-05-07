//
//  Created by Benjohn on 30/04/2020.
//


struct NFA<Symbol> {
    let initialStates: Set<Node>
    let acceptanceStates: Set<NodeState>
    let edges: Edges

    typealias Edges = [Edge: [Predicate]]
    typealias Predicate = (Symbol) -> Bool

    func matches<S: Sequence>(_ symbols: S) -> Bool where S.Element == Symbol {
        let initialState = initialStates
        let finalState = symbols.reduce(initialState, self.step(state:with:))
        return stateRepresentsAcceptance(finalState)
    }
    
    func step(state activeStates: MachineState, with symbol: Symbol) -> MachineState {
        let subsequentStates = nextStateFunction(forActiveStates: activeStates)
        return subsequentStates(symbol)
    }
    
    func stateRepresentsAcceptance(_ activeStates: MachineState) -> Bool {
        acceptanceStates.first(where: { activeStates.contains($0.node) == $0.isActive }) != nil
    }
    
    private func nextStateFunction(forActiveStates activeStates: MachineState) -> (Symbol) -> Set<Node> {
        
        let enabledEdges = edges.compactMap { edge -> (Node, [Predicate])? in
            guard activeStates.contains(edge.key.source.node) == edge.key.source.isActive else { return nil }
            return (edge.key.target, edge.value)
        }
        
        return { symbol in
            Set(enabledEdges.compactMap { edge in
                edge.1.first(where: { $0(symbol) }) == nil ? nil : edge.0
            })
        }
    }
}

// MARK:-

extension NFA {
    
    static var everything: NFA {
        let initial = Node()
        return NFA(
            initialStates: Set([initial]),
            acceptanceStates: Set([.active(initial)]),
            edges: [Edge(from: initial, to: initial): [{ _ in true }]]
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
            edges: [Edge(from: startState, to: acceptState): [predicate]]
        )
    }
    
    static func |(_ l: NFA, _ r: NFA) -> NFA {
        NFA(
            initialStates: l.initialStates.union(r.initialStates),
            acceptanceStates: l.acceptanceStates.union(r.acceptanceStates),
            edges: l.edges.merging(r.edges, uniquingKeysWith: +)
        )
    }

    static func &(_ l: NFA, _ r: NFA) -> NFA {
        !(!l | !r)
    }


    static prefix func !(_ nfa: NFA) -> NFA {
        NFA(
            initialStates: nfa.initialStates,
            acceptanceStates: Set(nfa.acceptanceStates.map { $0.invert }),
            edges: nfa.edges
        )
    }

    var optional: NFA {
        NFA(
            initialStates: initialStates,
            acceptanceStates: acceptanceStates.union(initialStates.map { .active($0) }),
            edges: edges
        )
    }
    
    var plus: NFA {
        self
    }
    
    func then(_ next: NFA) -> NFA {
        let nextInitialEdges = next.edges.filter { next.initialStates.contains($0.key.source.node) }
        let joins = acceptanceStates.flatMap { acceptanceState in
            nextInitialEdges.map { edge in (edge.key.changing(source: acceptanceState), edge.value) }
        }
        
        return NFA(
            initialStates: initialStates,
            acceptanceStates: next.acceptanceStates,
            edges: Dictionary(edges.map { $0 } + next.edges.map { $0 } + joins, uniquingKeysWith: +)
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
