//
//  Created by Benjohn on 30/04/2020.
//


struct NFA<Symbol> {
    let startState: State
    let acceptanceStates: Set<State>
    let isInverted: Bool
    
    let activeEdges: [State: PredicatedStates]
    let inactiveEdges: [State: PredicatedStates]
    
    struct PredicatedStates {
        let states: [State: [(Symbol) -> Bool]]
    }
    
    class State {}
    
    typealias MachineState = Set<State>
    
    init(
        startState: State,
        acceptanceStates: Set<State>,
        isInverted: Bool = false,
        activeEdges: [State: PredicatedStates],
        inactiveEdges: [State: PredicatedStates] = [:]
    ) {
        self.startState = startState
        self.acceptanceStates = acceptanceStates
        self.isInverted = isInverted
        self.activeEdges = activeEdges
        self.inactiveEdges = inactiveEdges
    }
    
    func matches<S: Sequence>(_ symbols: S) -> Bool where S.Element == Symbol {
        let initialState = Set([startState])
        let finalState = symbols.reduce(initialState, self.step(state:with:))
        return stateRepresentsAcceptance(finalState)
    }
    
    func step(state activeStates: MachineState, with symbol: Symbol) -> MachineState {
        possibleSubsequentStates(followingActiveStates: activeStates).states(enabledFor: symbol)
    }
    
    func stateRepresentsAcceptance(_ activeStates: MachineState) -> Bool {
        let hasAcceptanceStates = activeStates.intersection(acceptanceStates).isEmpty == false
        return hasAcceptanceStates != isInverted
    }
    
    private func possibleSubsequentStates(followingActiveStates activeStates: MachineState) -> PredicatedStates {
        let activated = activeStates.compactMap { activeEdges[$0] }
        let innactivated = inactiveEdges.compactMap { activeStates.contains($0.key) ? nil : $0.value }
        return (activated + innactivated).reduce(PredicatedStates()) { $0.merging($1) }
    }
}

// MARK:-

extension NFA {
    
    static var everything: NFA {
        let initial = NFA.State()
        return NFA(
            startState: initial,
            acceptanceStates: Set([initial]),
            activeEdges: [initial: PredicatedStates(states: [initial: [{ _ in true }]])]
        )
    }
    
    static var nothing: NFA {
        everything.inverted
    }
    
    static func match(one predicate: @escaping (Symbol) -> Bool) -> NFA {
        let startState = NFA.State()
        let acceptState = NFA.State()
        
        return NFA(
            startState: startState,
            acceptanceStates: Set([acceptState]),
            activeEdges: [startState: PredicatedStates(states: [acceptState: [predicate]])]
        )
    }

    var inverted: NFA {
        .init(
            startState: startState,
            acceptanceStates: acceptanceStates,
            isInverted: !isInverted,
            activeEdges: activeEdges,
            inactiveEdges: inactiveEdges
        )
    }
    
    func then(_ next: NFA) -> NFA {
        
    }
}

// MARK:-

extension NFA.PredicatedStates {
    
    init() {
        self.states = [:]
    }
    
    func states(enabledFor symbol: Symbol) -> Set<NFA.State> {
        Set(states.compactMap { stateAndPredicates in
            guard stateAndPredicates.value.first(where: { $0(symbol) }) != nil else { return nil }
            return stateAndPredicates.key
        })
    }
    
    func merging(_ other: NFA.PredicatedStates) -> NFA.PredicatedStates {
        NFA.PredicatedStates(states: states.merging(other.states, uniquingKeysWith: +))
    }
}

// MARK:-

extension NFA.State: Hashable {
    
    static func == (lhs: NFA<Symbol>.State, rhs: NFA<Symbol>.State) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        ObjectIdentifier(self).hash(into: &hasher)
    }
}
