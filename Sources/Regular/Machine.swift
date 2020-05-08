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
            guard activeStates.contains(edge.key.source.node), edge.key.source.isActive else { return nil }
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
    
    static var nothing: NFA {
        .init(
            initialStates: .init(),
            acceptanceStates: .init([.active(.init())]),
            predicatedEdges: .init(),
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
            acceptanceStates: Set([.active(node)]),
            predicatedEdges: .init(),
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
            acceptanceStates: Set([.active(acceptState)]),
            predicatedEdges: [Edge(from: initialState, to: acceptState): [predicate]],
            epsilonEdges: .init()
        )
    }
    
    static func |(_ l: NFA, _ r: NFA) -> NFA {
        let acceptance = Node()
        let extraEpsilon = l.acceptanceStates.union(r.acceptanceStates).map { Edge(from: $0, to: acceptance) }
        
        return NFA(
            initialStates: l.initialStates.union(r.initialStates),
            acceptanceStates: Set([.active(acceptance)]),
            // Using fatal error here as these seems like it would be a logic error?
            predicatedEdges: l.predicatedEdges.merging(r.predicatedEdges, uniquingKeysWith: { _, _ in fatalError() }),
            epsilonEdges: l.epsilonEdges.union(r.epsilonEdges + extraEpsilon)
        )
    }

    static func &(_ l: NFA, _ r: NFA) -> NFA {
        !((!l) | (!r))
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
        self | .empty
    }
    
    var star: NFA {
        plus | .empty
    }
    
    var plus: NFA {
        let loopEpsilonEdges = acceptanceStates.flatMap { acceptanceState in
            self.initialStates.map { initialState in
                return Edge(from: acceptanceState, to: initialState)
            }
        }

        return NFA(
            initialStates: initialStates,
            acceptanceStates: acceptanceStates,
            predicatedEdges: predicatedEdges,
            epsilonEdges: epsilonEdges.union(loopEpsilonEdges)
        )
    }
    
    func then(_ next: NFA) -> NFA {
        let joinEpsilonEdges = acceptanceStates.flatMap { acceptanceState in
            next.initialStates.map { initialState in
                return Edge(from: acceptanceState, to: initialState)
            }
        }
        
        return NFA(
            initialStates: initialStates,
            acceptanceStates: next.acceptanceStates,
            predicatedEdges: predicatedEdges.merging(next.predicatedEdges, uniquingKeysWith: +),
            epsilonEdges: epsilonEdges.union(next.epsilonEdges + joinEpsilonEdges)
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
