//
//  Created by Benjohn on 30/04/2020.
//


struct NFA<Symbol> {
    let initialStates: Set<Node>
    let edges: Edges

    let activeAcceptance: Set<Node>
    let inactiveAcceptance: Set<Node>
    
    typealias Edges = [Edge: [Predicate]]
    typealias Predicate = (Symbol) -> Bool

    init(
        initialStates: Set<Node>,
        edges: Edges = [:],
        activeAcceptance: Set<Node> = Set(),
        inactiveAcceptance: Set<Node> = Set()
    ) {
        self.initialStates = initialStates
        self.edges = edges
        self.activeAcceptance = activeAcceptance
        self.inactiveAcceptance = inactiveAcceptance
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
        activeStates.includesAnyOf(activeAcceptance) || activeStates.missesAnyOf(inactiveAcceptance)
    }
    
    private func possibleSubsequentStates(followingActiveStates activeStates: MachineState) -> (Symbol) -> Set<Node> {
        
        let enabledEdges = edges.compactMap { edge -> (Node, [Predicate])? in
            guard activeStates.contains(edge.key.source) == edge.key.active else { return nil }
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
            activeAcceptance: Set([initial])
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
            activeAcceptance: Set([acceptState])
        )
    }
    
    static func |(_ l: NFA, _ r: NFA) -> NFA {
        NFA(
            initialStates: l.initialStates.union(r.initialStates),
            edges: l.edges.merging(r.edges, uniquingKeysWith: +),
            activeAcceptance: l.activeAcceptance.union(r.activeAcceptance),
            inactiveAcceptance: l.inactiveAcceptance.union(r.inactiveAcceptance)
        )
    }

    static func &(_ l: NFA, _ r: NFA) -> NFA {
        !(!l | !r)
    }


    static prefix func !(_ nfa: NFA) -> NFA {
        .init(
            initialStates: nfa.initialStates,
            edges: nfa.edges,
            activeAcceptance: nfa.inactiveAcceptance,
            inactiveAcceptance: nfa.activeAcceptance
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

struct Edge: Hashable {
    let active: Bool
    let source: Node
    let target: Node
    
    init(from source: Node, when active: Bool = true, to target: Node) {
        self.source = source
        self.active = active
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
