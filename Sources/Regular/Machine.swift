//
//  Created by Benjohn on 30/04/2020.
//


struct NFA<Symbol> {
    let initialStates: Set<Node>
    let edges: Edges
    let acceptance: Set<NodeState>
    
    typealias Edges = [Edge: [Predicate]]
    typealias Predicate = (Symbol) -> Bool

    init(
        initialStates: Set<Node>,
        edges: Edges = [:],
        acceptance: Set<NodeState>
    ) {
        self.initialStates = initialStates
        self.edges = edges
        self.acceptance = acceptance
    }
    
    func matches<S: Sequence>(_ symbols: S) -> Bool where S.Element == Symbol {
        let initialState = initialStates
        let finalState = symbols.reduce(initialState, self.step(state:with:))
        return stateRepresentsAcceptance(finalState)
    }
    
    func step(state activeStates: MachineState, with symbol: Symbol) -> MachineState {
        let subsequentStates = possibleSubsequentStates(followingActiveStates: activeStates)
        return subsequentStates(symbol)
    }
    
    func stateRepresentsAcceptance(_ activeStates: MachineState) -> Bool {
        acceptance.first(where: { activeStates.contains($0.node) == $0.isActive }) != nil
    }
    
    private func possibleSubsequentStates(followingActiveStates activeStates: MachineState) -> (Symbol) -> Set<Node> {
        
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
            edges: [Edge(from: initial, to: initial): [{ _ in true }]],
            acceptance: Set([.active(initial)])
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
            edges: [Edge(from: startState, to: acceptState): [predicate]],
            acceptance: Set([.active(acceptState)])
        )
    }
    
    static func |(_ l: NFA, _ r: NFA) -> NFA {
        NFA(
            initialStates: l.initialStates.union(r.initialStates),
            edges: l.edges.merging(r.edges, uniquingKeysWith: +),
            acceptance: l.acceptance.union(r.acceptance)
        )
    }

    static func &(_ l: NFA, _ r: NFA) -> NFA {
        !(!l | !r)
    }


    static prefix func !(_ nfa: NFA) -> NFA {
        .init(
            initialStates: nfa.initialStates,
            edges: nfa.edges,
            acceptance: Set(nfa.acceptance.map { $0.invert })
        )
    }
    
    func then(_ next: NFA) -> NFA {
        
        return self
//        .init(
//            initialStates: initialStates,
//            activeAcceptance: next.activeAcceptance,
//            inactiveAcceptance: next.inactiveAcceptance,
//            activeEdges: <#T##[Node : SubsequentStates]#>,
//            inactiveEdges: <#T##[Node : SubsequentStates]#>
//        )
        
        /*
         Need to join the two NFA to build a new one.
         
         The resulting NFA has all nodes of each and all edges. In addition, all edges of the
         `next` `initialStates` should be attached to (all) acceptance states of first.
        */
    }
}

// MARK:-

class Node: Hashable {
    
    static func == (lhs: Node, rhs: Node) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        ObjectIdentifier(self).hash(into: &hasher)
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
