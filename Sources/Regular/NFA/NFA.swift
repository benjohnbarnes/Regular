//
//  Created by Benjohn on 30/04/2020.
//

struct NFA<Symbol> {
    let initialStates: Set<Node>
    let acceptanceState: Node
    let predicateEdges: [Node: [Node: [Predicate]]]
    let epsilonEdges: [EpsilonEdge]
    typealias Predicate = (Symbol) -> Bool
}

// MARK:- Matcher

extension NFA: Matcher {
    
    func matches<S: Sequence>(_ symbols: S) -> Bool where S.Element == Symbol {
        let initialState = propagateEpsilonEdges(fromActiveStates: self.initialStates)
        let finalState = symbols.reduce(initialState, self.step(state:with:))
        return stateRepresentsAcceptance(finalState)
    }
}

// MARK:-

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
